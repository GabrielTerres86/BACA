CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS537
                                       (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nmtelant  IN craptel.nmdatela%TYPE --> Nome da tela
                                       ,pr_cdempres OUT crapemp.cdempres%TYPE --> Codigo da empresa
                                       ,pr_flgresta  IN PLS_INTEGER           --> Flag padrão para utilização de restart
                                       ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                       ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2)             --> Descricao da citica
AS
  BEGIN
    /* .........................................................................

    Programa: PC_CRPS537 (Antigo Fontes/crps537.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Guilherme / Supero
    Data    : Novembro/2009.                   Ultima atualizacao: 08/03/2018

    Dados referentes ao programa:

    Frequencia: Diario (Batch).
    Objetivo  : Integrar arquivos de Cheques da Nossa Remessa - Conciliacao.

    Alteracoes: 27/05/2010 - Alterar a data utilizada no FIND para a data que
                            esta no HEADER do arquivo e incluir um resumo ao
                            fim do relatorio de Rejeitados, Integrados e
                            Recebidos (Guilherme/Supero)

               28/05/2010 - Quando encontrar o registro Trailer dar LEAVE
                            e sair do laco de importacao do arquivo(Guilherme).
               04/06/2010 - Acertos Gerais (Ze).

               15/06/2010 - Alteração no layout do relatorio e detalhamento
                            quanto aos valores e quantidades dos cheques
                            (Adriano).

               23/06/2010 - Acertos Gerais (Ze).

               06/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)

               29/07/2010 - Acerto no nome do relatorio (Ze).

               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            na leitura e gravacao dos arquivos (Elton).

               16/11/2010 - Incluir identificacao se eh Compe Nacional (Ze).

               15/08/2012 - Alterado posições do cdtipdoc de 52,2 para 148,3
                            (Lucas R.).

               02/10/2013 - Conversao Progress -> PL/SQL (Douglas Pagel).

               10/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                             das criticas e chamadas a fimprg.p (Douglas Pagel)

               25/10/2013 - Ajustes no to_date para incluir a mascara de conversão
                            do literal para data (Marcos-Supero)

               27/08/2013 - Ajuste no format do Cheque (Ze).
               
               13/03/2015 - Adicionar o filtro por número da prévia na busca das
                            informações dos cheques, pois estava sendo realizado 
                            a liquidação no registro errado, causando problemas 
                            como relatado no chamado 264379 ( Renato - Supero )

               07/04/2017 - #642531 Tratamento do tail para pegar/validar os dados da última linha
                            do arquivo corretamente (Carlos)
               19/06/2017 - Retirados tratamentos efetuados para separação de cheques 
                            com valor Inferior e Superior.

               08/03/2018 - #prj367 Adicionado o parâmetro pr_nrvergrl = 1 para utilizar a versão do jasper
                            compilado pelo TIBCO (Carlos)

    ........................................................................ */
    DECLARE
      -- Identificacao do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS537';

      -- Controle de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_exc_prox_arquivo exception;

      -- CURSORES --
      -- Cursor para validação da cooperativa
      cursor cr_crapcop is
        SELECT nmrescop, dsdircop, cdbcoctl, cdagectl
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%rowtype;
      -- Rowtype para validacao da data
      rw_crapdat btch0001.cr_crapdat%rowtype;
      -- FIM CURSORES --

      -- VARIAVEIS --
      vr_exc_saida  EXCEPTION;              -- Excecao padrao
      vr_exc_semlog EXCEPTION;              -- Excecao para saida sem log
      vr_exc_fimprg EXCEPTION;              -- Exceção com fimprg sem interromper a cadeia.
      vr_dstextab   CRAPTAB.DSTEXTAB%TYPE;  -- Retorno para funcao tabe0001.fn_busca_dstextab
      vr_cdbanctl   VARCHAR2(500);          -- Codigo Banco Central
      vr_contado2   PLS_INTEGER;            -- Contador auxiliar 2
      vr_dtauxili   VARCHAR2(50);           -- Data auxiliar
      vr_nmarquiv   VARCHAR2(50);           -- Nome do arquivo para importar
      vr_dsdireto_integra VARCHAR2(100);    -- Diretorio /integra da cooperativa
      vr_dsdireto_salvar  VARCHAR2(100);    -- Diretorio /salvar da cooperativa
      vr_dsdireto_cooper  VARCHAR2(100);    -- Diretorio raiz da cooperativa
      -- FIM VARIAVEIS --

      -- PROCEDIMENTOS --
      -- Geracao de log
      procedure pc_gera_log as
      begin
        btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper                   --> Cooperativa
                                  ,pr_ind_tipo_log => 2 --Tratado               --> Nivel criticidade do log
                                  ,pr_des_log => to_char(sysdate, 'hh24:mi:ss')
                                                || ' - '
                                                || vr_cdprogra
                                                || ' --> '
                                                || pr_dscritic);                --> Descrição do log em si
      end;

      -- Procedimento principal para manipulacao dos arquivos
      procedure pc_processa_arquivos (pr_nmextarq varchar2) as
      begin
        declare
        -- CURSORES --
        -- Busca de dados na gncpchq
        cursor cr_gncpchq (pr_dtmvtolt gncpchq.dtmvtolt%type -- Data Movimento
                          ,pr_cdbanchq gncpchq.cdbanchq%type -- Codigo do banco impresso no cheque acolhido
                          ,pr_cdagechq gncpchq.cdagechq%type -- Codigo da agencia impressa no cheque acolhido
                          ,pr_nrctachq gncpchq.nrctachq%type -- Numero da conta do cheque acolhido
                          ,pr_nrcheque gncpchq.nrcheque%type)-- Numero do cheque capturado
          is
          SELECT flcmpnac, cdtipreg, progress_recid
            FROM gncpchq  -- Compensacao de Cheques da Central
           WHERE gncpchq.cdcooper = pr_cdcooper AND -- Codigo que identifica a Cooperativa
                 gncpchq.dtmvtolt = pr_dtmvtolt AND -- Data Movimento
                 gncpchq.cdbanchq = pr_cdbanchq AND -- Codigo do banco impresso no cheque acolhido
                 gncpchq.cdagechq = pr_cdagechq AND -- Codigo da agencia impressa no cheque acolhido
                 gncpchq.nrctachq = pr_nrctachq AND -- Numero da conta do cheque acolhido
                 gncpchq.nrcheque = pr_nrcheque AND -- Numero do cheque capturado
                 gncpchq.nrprevia = 0;              -- Número da prévia zero  -- Add por Renato Darosci - 13/03/2015
        rw_gncpchq cr_gncpchq%rowtype;

        -- Busca de dados na craprej
        cursor cr_craprej (pr_dtmvtolt craprej.dtmvtolt%type
                          ,pr_cdagenci craprej.cdagenci%type)
          is
          SELECT craprej.vllanmto,
                 craprej.cdpesqbb,
                 craprej.nrseqdig,
                 craprej.nrdconta,
                 craprej.nrdocmto,
                 craprej.cdcritic
            FROM craprej
           WHERE craprej.cdcooper = pr_cdcooper AND
                 craprej.dtmvtolt = pr_dtmvtolt AND
                 craprej.cdagenci = pr_cdagenci
           ORDER BY craprej.nrseqdig;
        rw_craprej cr_craprej%rowtype;

        -- FIM CURSORES --
        -- VARIAVEIS --
        vr_tot_qtregrec PLS_INTEGER := 0;
        vr_tot_vlregrec NUMBER := 0;
        vr_tot_qtregint PLS_INTEGER := 0;
        vr_tot_vlregint NUMBER := 0;
        vr_tot_qtregrej PLS_INTEGER := 0;
        vr_tot_vlregrej NUMBER := 0;
        vr_des_comando  VARCHAR2(500);       -- Comando Unix
        vr_des_saida    VARCHAR2(4000);      -- Retorno do comando executado
        vr_vet_arquivos GENE0002.TYP_SPLIT;  -- Vetor para receber a quebra do retorno do comando no Unix
        vr_typ_saida    VARCHAR2(3);         -- Tipo de retorno do comando executado
        vr_input_file   UTL_FILE.FILE_TYPE;  -- Handle para leitura de arquivo
        vr_setlinha     VARCHAR2(4000);      -- Texto do arquivo lido
        vr_conta_linha  NUMBER(10);          -- Contador de linhas
        vr_dtarquiv     DATE;                -- Data lida do arquivo
        vr_vlcheque     NUMBER;              -- Valor do cheque do arquivo
        vr_dtliquid     DATE;                -- Data de liquidacao para gncpchq
        vr_nmarqui2     VARCHAR2(100);       -- Nome do arquivo sem diretorios
        vr_dsxmldad     CLOB;                -- Variavel de dados do XML em memória (CLOB)
        -- FIM VARIAVEIS --
        -- PROCEDIMENTOS --
        -- Procedimento auxiliar para escrita no CLOB vr_dsxmldad
        procedure pc_escreve_clob(pr_des_dados in varchar2) is
        begin
          dbms_lob.writeappend(vr_dsxmldad,length(pr_des_dados),pr_des_dados);
        end;
        -- FIM PROCEDIMENTOS --

        begin
          -- Monta comando para listagem dos arquivos de integracao
          vr_des_comando := 'ls ' || vr_nmarquiv || ' 2> /dev/null';

          -- Executa comando da pesquisa
          gene0001.pc_OScommand(pr_typ_comando => 'S'
                            ,pr_des_comando => vr_des_comando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_des_saida);

          -- Valida o retorno da pesquisa
          if vr_des_saida is not null then
            -- Quebra string de retorno a cada arquivo e coloca os dados em um vetor
            vr_vet_arquivos := gene0002.fn_quebra_string(pr_string  => vr_des_saida
                                                        ,pr_delimit => vr_dsdireto_integra);
          end if;


          -- Valida se encontrou arquivos
          if vr_vet_arquivos is null then
            if pr_nmextarq = 'REM' then
              -- Se não encontrou arquivo do tipo REM, gera log e retorna para quem chamou.
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> ATENCAO !! '
                                                     || gene0001.fn_busca_critica(182));

              return;
            end if;
            -- retorna para quem chamou.
            return;
          end if;

          -- Para cada arquivo encontrado
          for vr_qtregis in vr_vet_arquivos.FIRST..vr_vet_arquivos.LAST loop
            begin
              -- Zera critica
              vr_cdcritic := 0;

              -- Se for nulo passa para o proximo
              if vr_vet_arquivos(vr_qtregis) is null then
                continue;
              end if;

              -- Monta nome do arquivo sem diretorios
              -- E feito o substr para desconsiderar qualquer caractere especial que possa vir do UNIX apos a extensao do arquivo.
              vr_nmarqui2 := trim(substr(vr_vet_arquivos(vr_qtregis), 2, instr(vr_vet_arquivos(vr_qtregis), '.'||pr_nmextarq, -1)+2));

              -- Monta o caminho completo do arquivo
              vr_nmarquiv := trim(vr_dsdireto_integra || '/' ||vr_nmarqui2);

              -- Verifica se o arquivo esta completo
              -- Monta comando
              -- -2 Para ler a penultima linha do arquivo, pois a ultima é em branco.
              vr_des_comando := 'tail -2 ' || vr_nmarquiv;
              -- Executa comando para abrir arquivo
              gene0001.pc_OScommand_Shell(pr_des_comando => vr_des_comando
                                         ,pr_typ_saida   => vr_typ_saida
                                         ,pr_des_saida   => vr_des_saida);

              -- Se o comeco da linha nao for 9999999999, criticar
              if  SUBSTR(vr_des_saida,1,10) <> '9999999999' AND
                  SUBSTR(vr_des_saida,162,10) <> '9999999999' then
                -- Monta descricao de critica para aparecer no log.
                vr_cdcritic := 258;
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> ATENCAO !! '
                                                       || gene0001.fn_busca_critica(vr_cdcritic)
                                                       || ' - Arquivo: ' || vr_nmarquiv);
                -- Zera critica para proxima iteracao
                vr_cdcritic := 0;
                -- Passa para proximo arquivo
                continue;
              end if;

              -- Carrega arquivo
              gene0001.pc_abre_arquivo (pr_nmcaminh => vr_nmarquiv    --> Diretório do arquivo
                                       ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                       ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                       ,pr_des_erro => vr_dscritic);  --> Descricao do erro

              -- Se retornou erro
              if vr_dscritic is not null then
                raise vr_exc_saida;
              end if;

              -- Zera contador de linhas do arquivo
              vr_conta_linha := 0;

              -- Laco para leitura de linhas do arquivo
              loop
                -- Carrega handle do arquivo
                gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text => vr_setlinha); --> Texto lido

                -- Aumentar o contador de linhas
                vr_conta_linha:= vr_conta_linha + 1;

                -- Sai do arquivo quando encontrar 999999
                exit when substr(vr_setlinha, 1, 6) = '999999';

                -- Se for a primeira linha, faz as verificacoes iniciais
                if vr_conta_linha = 1 then
                  -- Valida registro de controle
                  if substr(vr_setlinha, 48, 6) != 'CEL605' then
                    vr_cdcritic := 181;
                  else
                    -- Valida banco
                    if substr(vr_setlinha, 61, 3) != vr_cdbanctl then
                      vr_cdcritic := 057;
                    else
                      -- Valida data do arquivo com data do sistema
                      if substr(vr_setlinha, 66, 8) != vr_dtauxili then
                        vr_cdcritic := 013;
                      end if;
                    end if;
                  end if;

                  -- Pega data que esta no arquivo
                  vr_dtarquiv := to_date(substr(vr_setlinha, 72, 2) || '/' ||
                                         substr(vr_setlinha, 70, 2) || '/' ||
                                         substr(vr_setlinha, 66, 4),'dd/mm/yyyy');

                  -- Verifica erro nos procedimentos acima e gera log
                  if vr_cdcritic <> 0 then
                    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> ATENCAO !! '
                                                               || gene0001.fn_busca_critica(vr_cdcritic)
                                                               || ' - Arquivo: ' || vr_nmarquiv);

                    -- Zera critica para proxima iteracao
                    vr_cdcritic := 0;

                    -- fechar handle do arquivo
                    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto

                    -- Passa para proximo arquivo
                    RAISE vr_exc_prox_arquivo;
                  end if;

                end if;-- Fim verificacoes iniciais

                -- Se for a primeira linha, passa para proxima pois
                -- abaixo são validacoes com os dados dos cheques.
                if vr_conta_linha = 1 then
                  continue;
                end if;

                -- Busca valor do cheque no arquivo
                vr_vlcheque := to_number(substr(vr_setlinha, 34, 17) / 100);

                -- Rejeita registros de COMPENSACAO NACIONAL para arq. .REM
                if pr_nmextarq = 'REM' and substr(vr_setlinha, 134, 2) = 'CA' then
                  begin
                    INSERT
                      INTO craprej ( -- Cadastro de rejeitados na integracao - D23.
                           dtmvtolt, -- Data do movimento atual
                           cdagenci, -- Numero do PA
                           nrdconta, -- Numero da conta/dv do associado
                           nrdocmto, -- Numero do documento
                           vllanmto, -- Valor do lancamento
                           nrseqdig, -- Sequencia de digitacao
                           cdpesqbb, -- Codigo de pesquisa do lancamento no banco do Brasil
                           cdcritic, -- Codigo da critica da integracao.
                           cdcooper) -- Codigo que identifica a Cooperativa
                    VALUES(rw_crapdat.dtmvtolt,
                           537,
                           to_char(SUBSTR(vr_setlinha, 67, 12)),
                           to_char(SUBSTR(vr_setlinha, 25, 6)),
                           vr_vlcheque,
                           to_char(SUBSTR(vr_setlinha, 151, 10)),
                           vr_setlinha,
                           931,
                           pr_cdcooper);
                    exception
                      when others then
                        -- gera log
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> ATENCAO !! '
                                                               || 'Erro ao inserir dados na craprej: ' || sqlerrm);
                        -- sai do arquivo
                        exit;
                    end;

                  -- Proxima linha
                  continue;
                end if; -- Fim rejeitar COMPENSACAO NACIONAL para arq. .REM

                -- Busca data de liquidacao
                if pr_nmextarq = 'NAC' then
                  vr_dtliquid := rw_crapdat.dtmvtopr;
                else
                  vr_dtliquid := rw_crapdat.dtmvtolt;
                end if;

                -- Verifica se o regsitro já existe na gncpchq
                open cr_gncpchq (pr_dtmvtolt => vr_dtarquiv
                                ,pr_cdbanchq => to_char(SUBSTR(vr_setlinha, 4, 3))
                                ,pr_cdagechq => to_char(SUBSTR(vr_setlinha, 7, 4))
                                ,pr_nrctachq => to_number(SUBSTR(vr_setlinha, 12, 12))
                                ,pr_nrcheque => to_char(SUBSTR(vr_setlinha, 25, 6)));
                fetch cr_gncpchq
                  into rw_gncpchq;

                -- Se nao encontrar o registro
                if cr_gncpchq%notfound then
                  -- Cria registro
                  begin
                    INSERT
                      INTO gncpchq (  -- Compensacao de Cheques da Central
                            cdcooper, -- Codigo que identifica a Cooperativa
                            cdagenci, -- Numero do PA
                            dtmvtolt, -- Data Movimento
                            dtliquid, -- Data de Liquidacao
                            cdagectl, -- Numero da agencia da Central
                            cdbanchq, -- Codigo do banco impresso no cheque acolhido
                            cdagechq, -- Codigo da agencia impressa no cheque acolhido
                            nrctachq, -- Numero da conta do cheque acolhido
                            nrcheque, -- Numero do cheque capturado
                            nrddigv2, -- Segundo digito de controle do CMC7 (DV2)
                            cdcmpchq, -- Codigo da compensacao impressa no cheque acolhido
                            cdtipchq, -- Tipificacao do cheque conforme tabela do Banco Central
                            nrddigv1, -- Primeiro digito de controle do CMC7 (DV1)
                            vlcheque, -- Valor do cheque acolhido para debito na conta do associado
                            nrdconta, -- Numero da conta/dv do associado
                            nmarquiv, -- Nome do Arquivo
                            cdoperad, -- Codigo do operador
                            hrtransa, -- Hora em que ocorreu a transacao
                            cdtipreg, -- Identificador de Tipo de Registro
                            flgconci, -- Identificador de Registro Conciliado
                            flgpcctl, -- Identifica se processou na Central
                            nrseqarq, -- Numero Sequencial do Registro no Arquivo
                            cdcritic, -- Codigo da critica de integracao na cooperativa
                            cdalinea, -- Codigo da alinea
                            cdtipdoc, -- Tipo de documento
                            nrddigv3, -- Terceiro digito de controle do CMC7 (DV3)
                            flcmpnac) -- Indica se o cheque eh da compe nacional
                    VALUES( pr_cdcooper,										                  -- cdcooper, -- Codigo que identifica a Cooperativa
                            0,												                        -- cdagenci, -- Numero do PA
                            vr_dtarquiv,										                  -- dtmvtolt, -- Data Movimento
                            vr_dtliquid,										                  -- dtliquid, -- Data de Liquidacao
                            to_number(SUBSTR(vr_setlinha,59,4)),				      -- cdagectl, -- Numero da agencia da Central
                            to_number(SUBSTR(vr_setlinha,4,3)),					        -- cdbanchq, -- Codigo do banco impresso no cheque acolhido
                            to_number(SUBSTR(vr_setlinha,7,4)),					        -- cdagechq, -- Codigo da agencia impressa no cheque acolhido
                            to_number(SUBSTR(vr_setlinha,12,12)),				      -- nrctachq, -- Numero da conta do cheque acolhido
                            to_number(SUBSTR(vr_setlinha,25,6)),					      -- nrcheque, -- Numero do cheque capturado
                            to_number(SUBSTR(vr_setlinha,11,1)),					      -- nrddigv2, -- Segundo digito de controle do CMC7 (DV2)
                            to_number(SUBSTR(vr_setlinha,1,3)),					        -- cdcmpchq, -- Codigo da compensacao impressa no cheque acolhido
                            to_number(SUBSTR(vr_setlinha,51,1)),					      -- cdtipchq, -- Tipificacao do cheque conforme tabela do Banco Central
                            to_number(SUBSTR(vr_setlinha,24,1)),					      -- nrddigv1, -- Primeiro digito de controle do CMC7 (DV1)
                            vr_vlcheque,										                  -- vlcheque, -- Valor do cheque acolhido para debito na conta do associado
                            to_number(SUBSTR(vr_setlinha,67,12)),					      -- nrdconta, -- Numero da conta/dv do associado
                            vr_nmarqui2,										                  -- nmarquiv, -- Nome do Arquivo
                            '1',												                      -- cdoperad, -- Codigo do operador
                            to_number(to_char(sysdate, 'hhmmss')),									              -- hrtransa, -- Hora em que ocorreu a transacao
                            2,												                        -- cdtipreg, -- Identificador de Tipo de Registro
                            1,												                        -- flgconci, -- Identificador de Registro Conciliado
                            0,												                        -- flgpcctl, -- Identifica se processou na Central
                            to_number(SUBSTR(vr_setlinha,151,10)),				      -- nrseqarq, -- Numero Sequencial do Registro no Arquivo
                            927,												                      -- cdcritic, -- Codigo da critica de integracao na cooperativa
                            0,  											                        -- cdalinea, -- Codigo da alinea
                            to_number(SUBSTR(vr_setlinha,148,3)),					      -- cdtipdoc, -- Tipo de documento
                            to_number(SUBSTR(vr_setlinha,31,1)),					      -- nrddigv3, -- Terceiro digito de controle do CMC7 (DV3)
                            case when pr_nmextarq = 'NAC' then 1 else 0 end);	-- flcmpnac) -- Indica se o cheque eh da compe nacional

                  exception
                    when others then
                       -- gera log
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> ATENCAO !! '
                                                               || 'Erro ao inserir registro na gncpchq: ' || sqlerrm);
                      -- Sai do arquivo
                      exit;
                  end; -- Fim da insercao na gncpchq

                  -- Cria registro na craprej
                  begin
                    INSERT
                      INTO craprej (
                           dtmvtolt,
                           cdagenci,
                           nrdconta,
                           nrdocmto,
                           vllanmto,
                           nrseqdig,
                           cdpesqbb,
                           cdcritic,
                           cdcooper)
                    VALUES (rw_crapdat.dtmvtolt,
                            537,
                            to_char(substr(vr_setlinha, 67, 12)),
                            to_char(substr(vr_setlinha, 25, 6)),
                            vr_vlcheque,
                            to_char(substr(vr_setlinha, 151, 10)),
                            vr_setlinha,
                            927,
                            pr_cdcooper);
                  exception
                    when others then
                      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> ATENCAO !! '
                                                               || 'Erro ao inserir registro na craprej: ' || sqlerrm);
                      -- Sai do arquivo
                      exit;
                  end;

                else -- Se encontrou o registro
                  -- Se for do tipo 2
                  if rw_gncpchq.cdtipreg = 2 then
                    -- Insere registro na craprej
                    begin
                      INSERT
                        INTO craprej (
                             dtmvtolt,
                             cdagenci,
                             nrdconta,
                             nrdocmto,
                             vllanmto,
                             nrseqdig,
                             cdpesqbb,
                             cdcritic,
                             cdcooper)
                      VALUES(rw_crapdat.dtmvtolt,
                             537,
                             to_char(substr(vr_setlinha, 67, 12)),
                             to_char(substr(vr_setlinha, 25, 6)),
                             vr_vlcheque,
                             to_char(substr(vr_setlinha, 151, 10)),
                             vr_setlinha,
                             670,
                             pr_cdcooper);
                    exception
                      when others then
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> ATENCAO !! '
                                                               || 'Erro ao inserir registro na craprej: ' || sqlerrm);
                        -- Sai do arquivo
                        exit;
                    end;
                  else -- Se o registro nao for 2
                    -- Eh porque conseguiu conciliar, entao atualiza registro
                    begin
                      UPDATE gncpchq
                         SET gncpchq.cdtipreg = 2,
                             gncpchq.flgconci = 1,
                             gncpchq.dtliquid = vr_dtliquid,
                             gncpchq.flcmpnac = case when pr_nmextarq = 'NAC' then 1 else 0 end
                       WHERE progress_recid = rw_gncpchq.progress_recid;
                    exception
                      when others then
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> ATENCAO !! '
                                                               || 'Erro ao atualizar registro na gncpchq: ' || sqlerrm);
                        -- Sai do arquivo
                        exit;
                    end;
                    -- Alimenta contadores integrados
                    vr_tot_qtregint := vr_tot_qtregint + 1;
                    vr_tot_vlregint := vr_tot_vlregint + (to_char(SUBSTR(vr_setlinha,34,17)) / 100);

                  end if; -- Fim verifica tipo do registro encontrado

                end if; -- Fim Verifica se registro existe
                close cr_gncpchq;
                -- Alimenta contadores recebidos
                vr_tot_qtregrec := vr_tot_qtregrec + 1;
                vr_tot_vlregrec := vr_tot_vlregrec + vr_vlcheque;

              end loop; -- Fim das linhas do arquivo

              -- Executa o bloco abaixo independentemente de erros no
              -- arquivo que foram registrados no log, assim como no Progress.

              -- Terminou de ler o arquivo


              -- Gera log de sucesso na integracao
              vr_cdcritic := 190;
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> ATENCAO !! '
                                                               || gene0001.fn_busca_critica(vr_cdcritic)
                                                               || ' - Arquivo: ' || vr_nmarquiv);
              -- Zera criticas
              vr_cdcritic := 0;

              -- Começa a montagem do relatorio

              -- Inicializar o CLOB (XML)
              dbms_lob.createtemporary(vr_dsxmldad, TRUE);
              dbms_lob.open(vr_dsxmldad, dbms_lob.lob_readwrite);

              -- Escreve cabecalho padrao
              pc_escreve_clob('<?xml version="1.0" encoding="utf-8"?><raiz>');
              pc_escreve_clob(' <arquivo>' || vr_nmarquiv || '</arquivo>');
              pc_escreve_clob(' <data>' || to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || '</data>');

              -- Lê tabela de rejeitados para listagem no relatorio
              open cr_craprej(pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_cdagenci => 537);
              loop
                fetch cr_craprej
                  into rw_craprej;
                -- Sai quando não houverem mais registros
                exit when cr_craprej%notfound;

                pc_escreve_clob(' <rejeitados>');
                pc_escreve_clob(' <sequencia>' || rw_craprej.nrseqdig || '</sequencia>');
                pc_escreve_clob(' <conta>' || gene0002.fn_mask_conta(rw_craprej.nrdconta) || '</conta>');
                pc_escreve_clob(' <cheque>' || gene0002.fn_mask(rw_craprej.nrdocmto, 'zzz.zzz') || '</cheque>');
                pc_escreve_clob(' <valor>' || rw_craprej.vllanmto || '</valor>');
                pc_escreve_clob(' <bco>' || SUBSTR(rw_craprej.cdpesqbb,4,3) || '</bco>');
                pc_escreve_clob(' <ag>' || SUBSTR(rw_craprej.cdpesqbb,7,4) || '</ag>');
                pc_escreve_clob(' <cmp>' || SUBSTR(rw_craprej.cdpesqbb,1,3) || '</cmp>');
                pc_escreve_clob(' <alerta>' || gene0001.fn_busca_critica(pr_cdcritic => rw_craprej.cdcritic) || '</alerta>');
                pc_escreve_clob(' </rejeitados>');

                -- Alimenta contadores rejeitados
                vr_tot_qtregrej := vr_tot_qtregrej + 1;
                vr_tot_vlregrej := vr_tot_vlregrej + rw_craprej.vllanmto;
              end loop; -- Fim dos rejeitados
              close cr_craprej;

              -- Insere os totais gerais
              pc_escreve_clob(' <totais>');
              pc_escreve_clob(' <qtregrec>' || vr_tot_qtregrec || '</qtregrec>');
              pc_escreve_clob(' <vlregrec>' || vr_tot_vlregrec || '</vlregrec>');
              pc_escreve_clob(' <qtregint>' || vr_tot_qtregint || '</qtregint>');
              pc_escreve_clob(' <vlregint>' || vr_tot_vlregint || '</vlregint>');
              pc_escreve_clob(' <qtregrej>' || vr_tot_qtregrej || '</qtregrej>');
              pc_escreve_clob(' <vlregrej>' || vr_tot_vlregrej || '</vlregrej>');
              pc_escreve_clob(' </totais>');

              -- Fecha tag inicial
              pc_escreve_clob('</raiz>');

              -- Move arquivo lido para o diretorio salvar da cooperativa
              vr_des_comando := 'mv ' || vr_nmarquiv || ' ' || vr_dsdireto_salvar || ' 2> /dev/null';

              -- Executa comando para mover arquivo
              gene0001.pc_OScommand(pr_typ_comando => 'S'
                                   ,pr_des_comando => vr_des_comando);
              -- Solicita geracao do relatorio
              GENE0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                      --> Cooperativa conectada
                                         ,pr_cdprogra  => vr_cdprogra                      --> Programa chamador
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt              --> Data do movimento atual
                                         ,pr_dsxml     => vr_dsxmldad                      --> Arquivo XML de dados
                                         ,pr_dsxmlnode => '/raiz'  --> Nó do XML para iteração
                                         ,pr_dsjasper  => 'crrl522.jasper'                 --> Arquivo de layout do iReport
                                         ,pr_dsparams  => NULL                             --> Array de parametros diversos
                                         ,pr_dsarqsaid => vr_dsdireto_cooper || '/rl/crrl522_' || gene0002.fn_mask(vr_contado2, '99') ||'.lst'  --> Path/Nome do arquivo PDF gerado
                                         ,pr_flg_gerar => 'N'                              --> Gerar o arquivo na hora
                                         ,pr_qtcoluna  => 132                              --> Qtd colunas do relatório (80,132,234)
                                         ,pr_flg_impri=> 'S'                               --> Chamar a impressão (Imprim.p)
                                         ,pr_nrcopias  => 1                                --> Número de cópias para impressão
                                         ,pr_nrvergrl  => 1                                --> Numero da versão da função de geração de relatorio
                                         ,pr_des_erro  => vr_dscritic);                    --> Saída com erro

              -- Liberando a memória alocada pro CLOB
              dbms_lob.close(vr_dsxmldad);
              dbms_lob.freetemporary(vr_dsxmldad);

              -- Veriifca retorno de erro na geracao do relatorio
              if vr_dscritic is not null then
                raise vr_exc_saida;
              end if;

              -- Cópia do arquivo caso a tela seja a compefora
              if pr_nmtelant = 'COMPEFORA' then
                -- Monta comando
                vr_des_comando := 'cp ' || vr_nmarquiv || ' ' || vr_dsdireto_cooper || '/rlnsv';

                -- Executa comando para copiar arquivo
                gene0001.pc_OScommand(pr_typ_comando => 'S'
                                     ,pr_des_comando => vr_des_comando);
              end if;

              -- Incrementa contador de nome do arquivo
              vr_contado2 := vr_contado2 + 1;
              pr_cdempres := 11;

              -- Apaga registros da craprej
              begin
                DELETE
                  FROM craprej -- Cadastro de rejeitados na integracao - D23
                 WHERE craprej.cdcooper = pr_cdcooper
                   AND craprej.dtmvtolt = rw_crapdat.dtmvtolt
                   AND craprej.cdagenci = 537;
              exception
                when others then
                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> ATENCAO !! '
                                                             || 'Erro ao apagar registros da craprej: ' || sqlerrm);

              end;
              
            exception
              when vr_exc_saida then
                raise vr_exc_saida;
              when vr_exc_prox_arquivo then
                null; -- Ignora pulo de arquivo
              when others then
                vr_dscritic := 'Erro ao processar arquivos: ' || sqlerrm;
                raise vr_exc_saida;
            end;  
          end loop; -- Fim da lista de arquivos

        exception
          when vr_exc_saida then
            raise vr_exc_saida;

          when others then
            vr_dscritic := 'Erro ao processar arquivos: ' || sqlerrm;
            raise vr_exc_saida;
          end;
      end; -- pc_processa_arquivos

      -- FIM PROCEDIMENTOS --
    BEGIN
      -- Informa acesso
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS537'
                                ,pr_action => null);

      -- Valida a cooperativa
      open cr_crapcop;
      fetch cr_crapcop
        into rw_crapcop;
      if cr_crapcop%notfound then
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        close cr_crapcop;
        raise vr_exc_saida;
      end if;
      close cr_crapcop;

      -- Valida a data do programa
      open btch0001.cr_crapdat(pr_cdcooper);
      fetch btch0001.cr_crapdat
        into rw_crapdat;
      if btch0001.cr_crapdat%notfound then
        pr_cdcritic := 1;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        close btch0001.cr_crapdat;
        raise vr_exc_saida;
      end if;
      close btch0001.cr_crapdat;

      -- Valida Iniprg
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Sair do processo e abortar a cadeia
        RAISE vr_exc_saida;
      END IF;

      --Busca na crapdat se o programa pode ser executado.
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'EXECUTAABBC'
                                               ,pr_tpregist => 0);
      -- Se não encontrar registro
      if vr_dstextab is not null then
        if vr_dstextab <> 'SIM' then
          -- Sai do programa
          raise vr_exc_fimprg;
        end if;
      else
        -- Sai do programa
        raise vr_exc_fimprg;
      end if;

      -- Busca diretorio da cooperativa
      vr_dsdireto_cooper := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                  ,pr_cdcooper => pr_cdcooper);


      -- Busca diretorio integra da cooperativa
      vr_dsdireto_integra := vr_dsdireto_cooper || '/integra';

      -- Busca diretorio salvar da cooperativa
      vr_dsdireto_salvar := vr_dsdireto_cooper || '/salvar';



      -- Inicio da Regra de Negocio

      -- Inicia contado2
      vr_contado2 := 1;

      -- Busca código do Banco Central
      vr_cdbanctl := gene0002.fn_mask(rw_crapcop.cdbcoctl, '999');

      -- Verifica parametro
      if pr_nmtelant = 'COMPEFORA' then
        vr_dtauxili := to_char(rw_crapdat.dtmvtoan, 'yyyy') ||
                       to_char(rw_crapdat.dtmvtoan, 'mm')   ||
                       to_char(rw_crapdat.dtmvtoan, 'dd');
      else
        vr_dtauxili := to_char(rw_crapdat.dtmvtolt, 'yyyy') ||
                       to_char(rw_crapdat.dtmvtolt, 'mm')   ||
                       to_char(rw_crapdat.dtmvtolt, 'dd');
      end if;

      -- PROCESSA ARQUIVOS .REM
      --  Define nome da busca
      vr_nmarquiv := vr_dsdireto_integra ||
                     '/1' ||
                     gene0002.fn_mask(rw_crapcop.cdagectl, '9999') ||
                     '*.REM';

      -- Executa rotina para processar arquivos .REM
      pc_processa_arquivos( pr_nmextarq => 'REM');

      -- Apaga registros da craprej
      begin
        DELETE
          FROM craprej -- Cadastro de rejeitados na integracao - D23
         WHERE craprej.cdcooper = pr_cdcooper
           AND craprej.dtmvtolt = rw_crapdat.dtmvtolt
           AND craprej.cdagenci = 537;
      exception
        when others then
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> ATENCAO !! '
                                                     || 'Erro ao apagar registros da craprej: ' || sqlerrm);

      end;
      -- FIM PROCESSA ARQUIVOS .REM

      -- PROCESSA ARQUIVOS .NAC
      --  Define nome da busca
      vr_nmarquiv := vr_dsdireto_integra ||
                     '/1' ||
                     gene0002.fn_mask(rw_crapcop.cdagectl, '9999') ||
                     '*.NAC';

      -- Executa rotina para processar arquivos .REM
      pc_processa_arquivos( pr_nmextarq => 'NAC');
      -- FIM PROCESSA ARQUIVOS .NAC

      -- Fim da Regra de Negocio

      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      when vr_exc_saida then
         -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      when others then
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END PC_CRPS537;
/
