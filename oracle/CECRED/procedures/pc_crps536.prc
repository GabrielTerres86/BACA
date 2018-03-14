CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS536(
                                   pr_cdcooper  IN craptab.cdcooper%TYPE
                                  ,pr_nmtelant  IN VARCHAR2 DEFAULT NULL
                                  ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                  ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                  ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT VARCHAR2) AS
   /*..............................................................................

   Programa: PC_CRPS536    Antigo: fontes/crps536.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Novembro/2009                     Ultima atualizacao: 09/02/2018.

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Receber arquivos de devolucao de titulos Nossa Remessa - ABBC.
               Emite relatorio crrl521.

   Alteracoes: 09/06/2010 - Acerto no tratamento do Header do Arquivo (Ze).

               17/06/2010 - Tratamento do campo dtliquid (Ze).

               06/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)

               13/09/2010 - Acerto p/ gerar relatorio no diretorio rlnsv
                            (Vitor)

               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            na leitura e gravacao dos arquivos (Elton).

               23/03/2012 - Importar todos arqs 2*.DVN - ref CAF (Guilherme)

               26/08/2013 - Conversão Progress >> Oracle PL/SQL (Renato - Supero).

               24/10/2013 - Copiar relatorio para o diretorio rlnsv quando a tela
                            for a COMPEFORA (Douglas Pagel).

               18/11/2013 - Ajustes no campo data pois estava enviando sem formato
                            (Marcos-Supero)

               25/11/2013 - Limpar parametros de saida de critica no caso da
                            exceção vr_exc_fimprg (Marcos-Supero)

               05/12/2013 - Implementar nova metodologia de listagem de
                            arquivos (Petter - Supero).

               06/12/2013 - Correção de problema de leitura em pltable sem
                            contagem prévia dos registros (Marcos-Supero).

               19/06/2014 - Inserido a criação dos lancamentos para o lote
                            10131 banco 85 historico 465 - 
                            Projeto automatiza compe (Tiago/Aline).
                            
               04/07/2014 - Inserido tratamento na busca dos dados da captit
                            para nao pegar contas zeradas (nrdconta > 0)
                            Projeto automatiza compe (Tiago/Aline).         

               14/07/2014 - Correção na lógica da coluna Lancador (Marcos-Supero)

               31/08/2015 - Projeto para tratamento dos programas que geram 
                            criticas que necessitam de lancamentos manuais 
                            pela contabilidade. (Jaison/Marcos-Supero)

               10/10/2016 - Alteração do diretório para geração de arquivo contábil.
                            P308 (Ricardo Linhares). 

			   13/10/2016 - Alterada leitura da tabela de parâmetros para utilização
							da rotina padrão. (Rodrigo)
              
               27/03/2017 - Alterar a geração do arquivo AAMMDD_CRITICAS.txt para considerar valores 
                            de devolução de recebimento de cobrança que já foram lançados na conta do associado
                            P307 (Jonatas - Supero).               

               01/09/2017 - SD737676 - Para evitar duplicidade devido o Matera mudar
			               o nome do arquivo apos processamento, iremos gerar o arquivo
						   _Criticas com o sufixo do crrl gerado por este (Marcos-Supero)
						   
               09/02/2018 - Adicionado coluna cdagenci no relatorio 521 - Chamado 751963 - (Mateus Zimmermann - Mouts)

.............................................................................*/

  -- CURSORES
  -- Buscar informações da cooperativa
  CURSOR cr_crapcop IS
    SELECT crapcop.dsdircop
         , LPAD(crapcop.cdbcoctl,3,0) cdbcoctl
         , crapcop.cdagectl
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;

  -- Buscar o titulo
  CURSOR cr_gncptit(PR_DTMVTOLT  gncptit.dtmvtolt%TYPE
                   ,PR_CDDBANCO  gncptit.cdbandst%TYPE
                   ,PR_NRDVCDBR  gncptit.nrdvcdbr%TYPE
                   ,PR_CDFATVEN  gncptit.cdfatven%TYPE
                   ,PR_VLTITULO  gncptit.vltitulo%TYPE
                   ,PR_DSCODBAR  gncptit.dscodbar%TYPE) IS
    SELECT ROWID  gncptit_rowid
      FROM gncptit
     WHERE gncptit.cdcooper = PR_CDCOOPER -- Cooperativa: parametro da rotina
       AND gncptit.dtmvtolt = PR_DTMVTOLT
       AND gncptit.cdbandst = PR_CDDBANCO
       AND gncptit.nrdvcdbr = PR_NRDVCDBR
       AND gncptit.cdfatven = PR_CDFATVEN
       AND gncptit.vltitulo = PR_VLTITULO
       AND gncptit.dscodbar = PR_DSCODBAR
       AND gncptit.cdtipreg = 2
     ORDER BY PROGRESS_RECID DESC;
     
  -- cursor de titulos   
  CURSOR cr_craptit (pr_cdcooper  IN craptit.cdcooper%TYPE      --> Código cooperativa
                    ,pr_dtmvtolt  IN craptit.dtmvtolt%TYPE      --> Data movimento
                    ,pr_dscodbar  IN craptit.dscodbar%TYPE      --> Código barra
                    ,pr_vldpagto  IN craptit.vldpagto%TYPE) IS  --> Valor de pagamento
    SELECT tit.nrdconta,
           tit.nrdocmto
      FROM craptit tit
     WHERE tit.cdbccxlt = 11
       AND tit.nrdolote = 16900
       AND tit.cdagenci IN(90,91)
       AND tit.dscodbar = pr_dscodbar
       AND tit.dtmvtolt = pr_dtmvtolt
       AND tit.cdcooper = pr_cdcooper
       AND tit.vldpagto = pr_vldpagto
       AND tit.nrdconta > 0;
  rw_craptit cr_craptit%ROWTYPE;
  
  -- cursor de capas de lote
  CURSOR cr_craplot (pr_cdcooper  IN craplrg.cdcooper%TYPE      --> Código cooperativa
                    ,pr_dtmvtolt  IN craplrg.dtresgat%TYPE      --> Data movimento atual
                    ,pr_cdagenci  IN craplap.cdagenci%TYPE      --> código agência
                    ,pr_cdbccxlt  IN craplap.cdbccxlt%TYPE      --> Código caixa/banco
                    ,pr_nrdolote  IN craplap.nrdolote%TYPE) IS  --> Número do lote
    SELECT co.nrseqdig
          ,co.vlinfodb
          ,co.vlcompdb
          ,co.tplotmov
          ,co.qtinfoln
          ,co.qtcompln
          ,co.vlinfocr
          ,co.vlcompcr
          ,ROWID
     FROM craplot co
    WHERE co.cdcooper = pr_cdcooper
      AND co.dtmvtolt = pr_dtmvtolt
      AND co.cdagenci = pr_cdagenci
      AND co.cdbccxlt = pr_cdbccxlt
      AND co.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;

  --Selecionar informacoes dos lancamentos na conta
  CURSOR cr_craplcm (pr_cdcooper craplcm.cdcooper%TYPE
                    ,pr_dtmvtolt craplcm.dtmvtolt%TYPE
                    ,pr_cdagenci craplcm.cdagenci%TYPE
                    ,pr_cdbccxlt craplcm.cdbccxlt%TYPE
                    ,pr_nrdolote craplcm.nrdolote%TYPE
                    ,pr_nrdctabb craplcm.nrdctabb%TYPE
                    ,pr_nrdocmto craplcm.nrdocmto%TYPE) IS
    SELECT /*+ INDEX (craplcm craplcm##craplcm1) */
          craplcm.vllanmto
     FROM craplcm craplcm
    WHERE cdcooper = pr_cdcooper
      AND dtmvtolt = pr_dtmvtolt
      AND cdagenci = pr_cdagenci
      AND cdbccxlt = pr_cdbccxlt
      AND nrdolote = pr_nrdolote
      AND nrdctabb = pr_nrdctabb
      AND nrdocmto = pr_nrdocmto;
  rw_craplcm cr_craplcm%ROWTYPE;
	
	CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE
                    ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT crapass.cdagenci
     FROM crapass crapass
    WHERE crapass.cdcooper = pr_cdcooper
      AND crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  -- REGISTROS
  rw_crapcop      cr_crapcop%ROWTYPE;
  rw_gncptit      cr_gncptit%ROWTYPE;

  -- TIPOS
  -- Define um registro para guardar as linhas dos arquivos
  TYPE typ_arquivo IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  TYPE rec_relato  IS RECORD(cddbanco   VARCHAR2(3) -- "Banco"
                            ,dtmvtolt   DATE        -- "Data Mov."
                            ,vldocmto   NUMBER      -- "Valor Docmto"
                            ,vltitulo   NUMBER      -- "Valor Titulo"
                            ,cdmotivo   NUMBER      -- "Motivo"
                            ,linhadig   VARCHAR2(50)-- "Linha Digitavel"
                            ,nrdvcdbr   NUMBER      -- "Digito verificador do codigo de barras."
                            ,cdfatven   NUMBER      -- "Codigo do fator de vencimento."
                            ,dscodbar   VARCHAR2(50)-- "Código de barra"
                            ,nrdolote   NUMBER      -- "Lote"
                            ,nrseqdig   NUMBER      -- "Sequencial do lote"
                            ,cdmoeda    NUMBER      -- "Moeda"
                            ,tpcaptur   NUMBER      -- "Tipo de Captura" (1 - titulo liquidado no caixa, 3 - liquidado via internet)
                            ,tpdocmto   NUMBER      -- "Tipo do Documento"
                            ,nrseqarq   NUMBER      -- "Seq. Arq."
							,cdagenci   NUMBER      -- "Numero do PA"
              ,flglanca   VARCHAR2(3));-- Lançado (SIM/NAO)
  -- Registro para guardar os valores processados
  TYPE typ_relato IS TABLE OF rec_relato INDEX BY BINARY_INTEGER;
  
  -- VARIÁVEIS
  -- Codigo do programa
  vr_cdprogra      VARCHAR2(10);
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;
  vr_dtmvtoan      crapdat.dtmvtoan%TYPE;
  vr_dtmvtaux      crapdat.dtmvtolt%TYPE;
  -- Arquivo
  vr_nmarquiv      VARCHAR2(200);
  vr_diretori      VARCHAR2(200);
  vr_dircop_rlnsv  VARCHAR2(200);
  vr_nom_direto    VARCHAR2(200);
  -- Validação de erros
  vr_typ_saida     VARCHAR2(100);
  vr_des_saida     VARCHAR2(2000);
  -- Lista de arquivos
  vr_array_arquivo  gene0002.typ_split;
  vr_dsselect       VARCHAR2(32000); -- Ordenar arquivos no padrão UNIX
  vr_cursor         SYS_REFCURSOR; -- Cursor dinamico
  vr_nmauxarq       VARCHAR2(320);
  -- Array para guardar as linhas dos arquivos
  vr_arquivo       typ_arquivo;
  -- Guardar os valores a serem inseridos no banco de dados
  vr_relato        typ_relato;
  vr_indice        NUMBER;
  -- Indice auxiliar para o Array
  vr_nrindice      NUMBER;
  -- Indice da linha do arquivo
  vr_nrlinha       NUMBER;
  -- Arquivo lido
  vr_utlfileh      UTL_FILE.file_type;
  vr_listarq       VARCHAR2(32767);
  
  --rowid da craplot
  vr_rowid_craplot VARCHAR2(50);
  
  -- Tratamento de erros
  vr_exc_saida     EXCEPTION;
  vr_exc_fimprg    EXCEPTION;

  --variaveis para controle de arquivos
  vr_dircon VARCHAR2(200);
  vr_arqcon VARCHAR2(200);
  
  vr_dstextab craptab.dstextab%TYPE;   

BEGIN
  -- Código do programa
  vr_cdprogra := 'CRPS536';
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => pr_cdcritic);

  -- Se retornou algum erro
  IF pr_cdcritic <> 0 THEN
    -- Buscar descricão do erro
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;
  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CPRS536',
                             pr_action => vr_cdprogra);

  -- Buscar a data do movimento
  OPEN  btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;

  -- Se não encontrar o registro de movimento
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- 001 - Sistema sem data de movimento.
    pr_cdcritic := 1;
    -- Buscar descricão do erro
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

    CLOSE btch0001.cr_crapdat;

    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  ELSE
    -- Atribuir os valores as variáveis
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
    vr_dtmvtoan := btch0001.rw_crapdat.dtmvtoan;
  END IF;

  CLOSE btch0001.cr_crapdat;

  -- Indica o parametro COMPEFORA do progress
  IF pr_nmtelant = 'COMPEFORA' THEN
    vr_dtmvtaux := vr_dtmvtoan;
  ELSE
    vr_dtmvtaux := vr_dtmvtolt;
  END IF;

  -- Buscar os dados da cooperativa
  OPEN  cr_crapcop;
  FETCH cr_crapcop INTO rw_crapcop;

  -- Se não encontrar registros
  IF cr_crapcop%NOTFOUND THEN
    pr_cdcritic := 651;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    CLOSE cr_crapcop;
    RAISE vr_exc_saida;
  END IF;

  CLOSE cr_crapcop;

  -- Verifica se a Cooperativa esta preparada para executa COMPE 85 - ABBC
  vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
									       ,pr_nmsistem => 'CRED'
										   ,pr_tptabela => 'GENERI'
										   ,pr_cdempres => 0
										   ,pr_cdacesso => 'EXECUTAABBC'
										   ,pr_tpregist => 0);

  -- Se não encontrar registros ou o registro encontrado está com
  -- indicador igual a SIM, sai do programa
  IF NVL(vr_dstextab,'N') <> 'SIM' THEN
    RAISE vr_exc_fimprg;
  END IF;

  -- Busca do diretório base da cooperativa para a geração de relatórios
  vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper);
  -- Define o diretório do arquivo
  vr_diretori := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/integra/') ;

  -- Define o nome do arquivo
  vr_nmarquiv := vr_diretori||'/'||'2*.DVN';
  
  -- Remove os arquivos ".q" caso existam
  gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmarquiv||'.q 2> /dev/null'
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_des_saida);


  -- Se retornar uma indicação de erro
  IF NVL(vr_typ_saida,' ') = 'ERR' THEN
    -- Incluir erro no log
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2  -- Erro tratado
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || 'Erro pc_OScommand_Shell: '||vr_des_saida);
  END IF;

  -- Retorna um array com todos os arquivos do diretório
  gene0001.pc_lista_arquivos(pr_path      => vr_diretori
                            ,pr_pesq      => '2%.DVN'
                            ,pr_listarq   => vr_listarq
                            ,pr_des_erro  => pr_dscritic);


  -- Verifica se ocorreram erros no processo de lsitagem de arquivos
  IF TRIM(pr_dscritic) IS NOT NULL THEN
    -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' || pr_dscritic );
  END IF;

  -- Verifica se encontrou arquivos
  IF TRIM(vr_listarq) IS NOT NULL THEN
    vr_array_arquivo := gene0002.fn_quebra_string(pr_string => vr_listarq, pr_delimit => ',');

    -- Ordenar o nome dos arquivos conforme o padrão Unix, onde números vem antes de letras
    -- Montar select dinamico
    vr_dsselect := 'SELECT * FROM (';

    -- Percorre os arquivos encontrados
    FOR ind IN vr_array_arquivo.FIRST..vr_array_arquivo.LAST LOOP

      -- Montar o trecho do select dinamico
      vr_dsselect := vr_dsselect || 'SELECT '''||vr_array_arquivo(ind)||''' str from dual ';

      -- Se for o ultimo sai do loop
      EXIT WHEN ind = vr_array_arquivo.LAST;

      -- Adicionar o union ao select
      vr_dsselect := vr_dsselect || ' UNION ';
    END LOOP;
    -- Finaliza a montagem do select dinamico
    vr_dsselect := vr_dsselect || ') ORDER BY  NLSSORT(str, ''NLS_SORT=BINARY_AI'') ';

    -- Limpar a tab de arquivos, para receber os mesmos com nova ordenação
    vr_array_arquivo := GENE0002.typ_split();

    -- Limpar a variável com o nome do arquivo
    vr_nmauxarq := NULL;

    -- Executar o select dinamico com o nome dos arquivos
    --Abre o cursor com o select da variável
    OPEN vr_cursor FOR vr_dsselect;
    -- Percorrer registros retornados
    LOOP

      -- Joga os valores das colunas no registro de memória
      FETCH vr_cursor INTO vr_nmauxarq;

      -- Caso não tenha mais dados sai do cursor
      EXIT WHEN vr_cursor%NOTFOUND;

      -- Inserir o novo elemento no registro de memória
      vr_array_arquivo.EXTEND;
      -- Guarda o nome do arquivo, ordenado
      vr_array_arquivo(vr_array_arquivo.COUNT) := vr_nmauxarq;

    END LOOP;

    -- Fecha o cursor
    CLOSE vr_cursor;
  ELSE
    pr_cdcritic := 182;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    RAISE vr_exc_fimprg;
  END IF;

  -- Somente se encontrou registros
  IF vr_array_arquivo.COUNT > 0 THEN

    -- Guarda o primeiro indice
    vr_nrindice := vr_array_arquivo.first();

    -- Percorrer os arquivos 2*.DVN
    LOOP

      -- Abrir o arquivo
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_diretori
                              ,pr_nmarquiv => vr_array_arquivo(vr_nrindice)
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_utlfileh
                              ,pr_des_erro => pr_dscritic);

      -- Verifica se houve erro ao abrir o arquivo
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Limpar o registro de memória, Caso possua registros
      IF vr_arquivo.COUNT() > 0 THEN
        vr_arquivo.DELETE;
      END IF;

      -- Se o arquivo estiver aberto, percorre o mesmo e guarda todas as linhas
      -- em um registro de memória
      IF  utl_file.IS_OPEN(vr_utlfileh) THEN

        -- Ler todas as linhas do arquivo
        LOOP

          BEGIN
            -- Guarda todas as linhas do arquivo no array
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh --> Handle do arquivo aberto
                                        ,pr_des_text => vr_arquivo(vr_arquivo.count()+1)); --> Texto lido
          EXCEPTION
            WHEN no_data_found THEN -- não encontrar mais linhas
              EXIT;
            WHEN OTHERS THEN
              pr_dscritic := 'Erro arquivo ['||vr_nmarquiv||']: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END LOOP;

        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh); --> Handle do arquivo aberto;
      END IF;
      --
      -- Remover as linhas em branco do arquivo
      -- Enquanto a ultima linha possuir menos de 100 posições
      WHILE (length(vr_arquivo(vr_arquivo.last())) < 100 AND vr_arquivo.COUNT() > 0) LOOP
        -- Exclui a ultima linha lida no arquivo
        vr_arquivo.delete(vr_arquivo.last());
      END LOOP;

      -- Verifica se encontrou linhas no arquivo
      IF vr_arquivo.count() > 0 THEN

        -- Verifica se o arquivo está completo
        IF SUBSTR(vr_arquivo(vr_arquivo.last()),1,10) <> '9999999999' THEN
          -- Remove os arquivos ".q" caso existam 
          gene0001.pc_OScommand_Shell(pr_des_comando => 'rm ' + vr_nmarquiv + '.q 2> /dev/null'
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_des_saida);

          -- Se retornar uma indicação de erro
          IF NVL(vr_typ_saida,' ') = 'ERR' THEN
            -- Incluir erro no log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2  -- Erro tratado
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' --> '
                                                          || 'Erro pc_OScommand_Shell: '||vr_des_saida);
          END IF;

          -- Gerar a Crítica
          pr_cdcritic := 258;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
          RAISE vr_exc_fimprg;
        END IF; -- Se ultima linha diferente de '9999999999'

        -- Inicializa
        pr_cdcritic := 0;

        -- Valida o arquivo, conforme informações da primeira linha
        IF    SUBSTR(vr_arquivo(vr_arquivo.first()), 1,10) <> '0000000000' THEN
          pr_cdcritic := 468;
        ELSIF SUBSTR(vr_arquivo(vr_arquivo.first()),48,06) <> 'DVC615'    THEN
          pr_cdcritic := 181;
        ELSIF SUBSTR(vr_arquivo(vr_arquivo.first()),61,03) <> rw_crapcop.cdbcoctl THEN
          pr_cdcritic := 057;
        ELSIF SUBSTR(vr_arquivo(vr_arquivo.first()),66,08) <> to_char(vr_dtmvtaux,'YYYYMMDD') THEN
          pr_cdcritic := 013;
        END IF;

        -- Se houve alguma critica
        IF pr_cdcritic <> 0 THEN
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

          -- Incluir o arquivo na mensagem de retorno de erro 
          pr_dscritic := pr_dscritic||' - Arquivo: '||vr_diretori||'/'||vr_array_arquivo(vr_nrindice);


          -- Gerar Log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 1, -- Processo normal
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || pr_dscritic);

          -- Reinicializa a variável de críticas
          pr_cdcritic := 0;
          pr_dscritic := NULL;

          -- Verifica e sai se for o último arquivo
          EXIT WHEN vr_array_arquivo.last = vr_nrindice;

          -- Próximo índice
          vr_nrindice := vr_array_arquivo.NEXT(vr_nrindice);

          -- Pula para o próximo arquivo
          CONTINUE;

        END IF;

        -- Cria um log de execução
        pr_cdcritic := 219; -- "219 - INTEGRANDO ARQUIVO"
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

        -- Gerar Log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 1, -- Processo normal
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || pr_dscritic||' - Arquivo: '
                                                         || vr_diretori||vr_array_arquivo(vr_nrindice));
        pr_cdcritic := 0;
        pr_dscritic := NULL;

        -- Aponta para a segunda linha
        vr_nrlinha := vr_arquivo.next(vr_arquivo.first());

        -- Percorrer as linhas do arquivo
        LOOP

          -- Se encontrar a linha de finalização do arquivo
          EXIT WHEN SUBSTR(vr_arquivo(vr_nrlinha),1,10) = '9999999999';

          BEGIN

            -- Define um novo indice para os dados
            vr_indice := vr_relato.count() + 1;

            -- Leitura dos valores(char)
            vr_relato(vr_indice).linhadig := SUBSTR(vr_arquivo(vr_nrlinha), 1,44);
            vr_relato(vr_indice).dscodbar := SUBSTR(vr_arquivo(vr_nrlinha),20,25);
            -- Leitura dos valores(date)
            vr_relato(vr_indice).dtmvtolt := TO_DATE(SUBSTR(vr_arquivo(vr_nrlinha),71,8),'YYYYMMDD');
            -- Leitura dos valores(numbers)
            vr_relato(vr_indice).cddbanco := TO_NUMBER(TRIM(SUBSTR(vr_arquivo(vr_nrlinha),  1, 3)));
            vr_relato(vr_indice).cdmoeda  := TO_NUMBER(TRIM(SUBSTR(vr_arquivo(vr_nrlinha),  4, 1)));
            vr_relato(vr_indice).nrdvcdbr := TO_NUMBER(TRIM(SUBSTR(vr_arquivo(vr_nrlinha),  5, 1)));
            vr_relato(vr_indice).cdfatven := TO_NUMBER(TRIM(SUBSTR(vr_arquivo(vr_nrlinha),  6, 4)));
            vr_relato(vr_indice).vldocmto := TO_NUMBER(TRIM(SUBSTR(vr_arquivo(vr_nrlinha), 10,10))) / 100;
            vr_relato(vr_indice).tpdocmto := TO_NUMBER(TRIM(SUBSTR(vr_arquivo(vr_nrlinha), 45, 2)));
            vr_relato(vr_indice).tpcaptur := TO_NUMBER(TRIM(SUBSTR(vr_arquivo(vr_nrlinha), 50, 1)));
            vr_relato(vr_indice).cdmotivo := TO_NUMBER(TRIM(SUBSTR(vr_arquivo(vr_nrlinha), 51, 2)));
            vr_relato(vr_indice).nrdolote := TO_NUMBER(TRIM(SUBSTR(vr_arquivo(vr_nrlinha), 61, 7)));
            vr_relato(vr_indice).nrseqdig := TO_NUMBER(TRIM(SUBSTR(vr_arquivo(vr_nrlinha), 68, 3)));
            vr_relato(vr_indice).vltitulo := TO_NUMBER(TRIM(SUBSTR(vr_arquivo(vr_nrlinha), 85,12))) / 100;
            vr_relato(vr_indice).nrseqarq := TO_NUMBER(TRIM(SUBSTR(vr_arquivo(vr_nrlinha),151,10)));
            -- Default não lançado
            vr_relato(vr_indice).flglanca := 'NAO';

          EXCEPTION
            WHEN OTHERS THEN
              pr_cdcritic := 843;
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

              -- Gerar Log
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- Erro tratado
                                         pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                   || vr_cdprogra || ' --> '
                                                                   || pr_dscritic ||
                                                                   ' - Arquivo: '||vr_array_arquivo(vr_nrindice)
                                                                   ||' - Seq: '||SUBSTR(vr_arquivo(vr_nrlinha),151,10));
              pr_cdcritic := 0;
              pr_dscritic := NULL;

              vr_nrlinha := vr_arquivo.next(vr_nrlinha);

              -- Se criou o registro de memória, apaga o mesmo
              IF vr_relato.EXISTS(vr_indice) THEN
                vr_relato.DELETE(vr_indice);
              END IF;

              -- Proxima linha do arquivo
              CONTINUE;
          END;

          -- Busca pelos dados para verificar se o registro já existe
          OPEN  cr_gncptit(vr_relato(vr_indice).dtmvtolt   -- PR_DTMVTOLT
                          ,vr_relato(vr_indice).cddbanco   -- PR_CDDBANCO
                          ,vr_relato(vr_indice).nrdvcdbr   -- PR_NRDVCDBR
                          ,vr_relato(vr_indice).cdfatven   -- PR_CDFATVEN
                          ,vr_relato(vr_indice).vltitulo   -- PR_VLTITULO
                          ,vr_relato(vr_indice).dscodbar); -- PR_DSCODBAR
          FETCH cr_gncptit INTO rw_gncptit;

          -- Se encontrar o registro
          IF cr_gncptit%FOUND THEN
            BEGIN
              -- Atualiza os dados
              UPDATE gncptit
                 SET gncptit.cdmotdev = nvl(vr_relato(vr_indice).cdmotivo,0)
                   , gncptit.flgconci = 1 -- TRUE
                   , gncptit.dtliquid = vr_dtmvtolt
               WHERE ROWID = rw_gncptit.gncptit_rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Buscar descricão do erro
                pr_dscritic := 'Erro ao atualizar GNCPTIT: '||SQLERRM;
                -- Envio centralizado de log de erro
                RAISE vr_exc_saida;
            END;
          ELSE

            BEGIN
              -- Inserir dados
              INSERT INTO gncptit
                           (dtliquid
                           ,cdcooper
                           ,cdagenci
                           ,dtmvtolt
                           ,cdbandst
                           ,cddmoeda
                           ,nrdvcdbr
                           ,dscodbar
                           ,tpcaptur
                           ,cdagectl
                           ,nrdolote
                           ,nrseqdig
                           ,vldpagto
                           ,tpdocmto
                           ,nrseqarq
                           ,nmarquiv
                           ,cdoperad
                           ,hrtransa
                           ,vltitulo
                           ,cdtipreg
                           ,flgconci
                           ,cdcritic
                           ,cdmotdev
                           ,flgpcctl
                           ,cdfatven
                           ,cdcrictl)
                   VALUES  (vr_dtmvtolt                            -- dtliquid
                           ,pr_cdcooper                            -- cdcooper
                           ,0                                      -- cdagenci
                           ,vr_relato(vr_indice).dtmvtolt          -- dtmvtolt
                           ,nvl(vr_relato(vr_indice).cddbanco,0)   -- cdbandst
                           ,nvl(vr_relato(vr_indice).cdmoeda,0)    -- cddmoeda
                           ,nvl(vr_relato(vr_indice).nrdvcdbr,0)   -- nrdvcdbr
                           ,nvl(vr_relato(vr_indice).dscodbar,' ') -- dscodbar
                           ,nvl(vr_relato(vr_indice).tpcaptur,0)   -- tpcaptur
                           ,nvl(rw_crapcop.cdagectl,0)             -- cdagectl
                           ,nvl(vr_relato(vr_indice).nrdolote,0)   -- nrdolote
                           ,nvl(vr_relato(vr_indice).nrseqdig,0)   -- nrseqdig
                           ,nvl(vr_relato(vr_indice).vltitulo,0)   -- vldpagto
                           ,nvl(vr_relato(vr_indice).tpdocmto,0)   -- tpdocmto
                           ,nvl(vr_relato(vr_indice).nrseqarq,0)   -- nrseqarq
                           ,nvl(vr_array_arquivo(vr_nrindice),' ') -- nmarquiv
                           ,'1'                                    -- cdoperad
                           ,TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))    -- hrtransa
                           ,nvl(vr_relato(vr_indice).vldocmto,0)   -- vltitulo
                           ,2                                      -- cdtipreg
                           ,1                                      -- flgconci
                           ,927                                    -- cdcritic
                           ,nvl(vr_relato(vr_indice).cdmotivo,0)   -- cdmotdev
                           ,0                                      -- flgpcctl
                           ,nvl(vr_relato(vr_indice).cdfatven,0)   -- cdfatven
                           ,0);                                    -- cdcrictl
            EXCEPTION
              WHEN OTHERS THEN
                -- Buscar descricão do erro
                pr_dscritic := 'Erro ao inserir GNCPTIT: '||SQLERRM;
                -- Envio centralizado de log de erro
                RAISE vr_exc_saida;
            END;
          END IF; -- IF cr_gncptit%FOUND

          -- Fecha o cursor
          CLOSE cr_gncptit;
        
        --Busca titulo  
        OPEN cr_craptit(pr_cdcooper => pr_cdcooper,
                        pr_dtmvtolt => vr_relato(vr_indice).dtmvtolt,
                        pr_dscodbar => vr_relato(vr_indice).linhadig,
                        pr_vldpagto => vr_relato(vr_indice).vltitulo);
        FETCH cr_craptit INTO rw_craptit;                                
          -- Se encontrar, é Internet
          IF  cr_craptit%FOUND THEN          
            -- Fechar cursor não usado mais
            CLOSE cr_craptit;

            -- Abre o cursor de capas de lote
            OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                         pr_dtmvtolt => vr_dtmvtolt,
                         pr_cdagenci => 1,
                         pr_cdbccxlt => 85,
                         pr_nrdolote => 10131);
            FETCH cr_craplot INTO rw_craplot;        
            -- Se nao existir insere a capa de lote  
            IF cr_craplot%NOTFOUND THEN 
              BEGIN
                INSERT INTO craplot
                  (dtmvtolt,
                   dtmvtopg,
                   cdagenci,
                   cdbccxlt,
                   cdoperad,
                   nrdolote,
                   tplotmov,
                   tpdmoeda,
                   cdhistor,
                   cdcooper)
                VALUES
                  (vr_dtmvtolt,                   --dtmvtolt
                   vr_relato(vr_indice).dtmvtolt, --dtmvtopg
                   1,                             --cdagenci
                   85,                            --cdbccxlt
                   1,                             --cdoperad
                   10131,                         --nrdolote
                   20,                            --tplotmov
                   1,                             --tpdmoeda
                   465,                           --cdhistor
                   pr_cdcooper)                   --cdcooper
                 RETURNING ROWID INTO vr_rowid_craplot;
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao inserir CRAPLOT: ' ||SQLERRM;
                  RAISE vr_exc_saida;
              END;
            ELSE
              vr_rowid_craplot := rw_craplot.rowid;
            END IF;
              
            CLOSE cr_craplot;

            -- Atualiza a tabela de capas de lote
            BEGIN
              UPDATE craplot
                 SET nrseqdig = nrseqdig + 1,
                     qtcompln = qtcompln + 1,
                     qtinfoln = qtinfoln + 1,
                     vlcompdb = vlcompdb + vr_relato(vr_indice).vltitulo,
                     vlcompcr = 0,
                     vlinfodb = vlcompdb + vr_relato(vr_indice).vltitulo,
                     vlinfocr = 0
               WHERE ROWID = vr_rowid_craplot;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar CRAPLOT: ' ||SQLERRM;
                RAISE vr_exc_saida;
            END;
            -- Verifica se já não existe a craplcm  
            OPEN cr_craplcm(pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => vr_dtmvtolt
                           ,pr_cdagenci => 1
                           ,pr_cdbccxlt => 85
                           ,pr_nrdolote => 10131
                           ,pr_nrdctabb => nvl(rw_craptit.nrdconta,0)
                           ,pr_nrdocmto => nvl(rw_craptit.nrdocmto,0));
            FETCH cr_craplcm INTO rw_craplcm;
            -- Se nao existir insere lancamento          
            IF cr_craplcm%NOTFOUND THEN 
              -- Fecha Cursor
              CLOSE cr_craplcm;
              -- insere a devdoc na tabela de lancamentos
              BEGIN
                INSERT INTO craplcm
                  (dtmvtolt,
                   cdagenci,
                   cdbccxlt,
                   nrdolote,
                   nrdconta,
                   nrdocmto,
                   cdhistor,
                   nrseqdig,
                   vllanmto,
                   nrdctabb,
                   nrdctitg,
                   cdcooper,
                   dtrefere,
                   cdoperad)
                VALUES
                  (vr_dtmvtolt,                                       --dtmvtolt
                   1,                                                 --cdagenci            
                   85,                                                --cdbccxlt
                   10131,                                             --nrdolote
                   nvl(rw_craptit.nrdconta,0),                        --nrdconta
                   nvl(rw_craptit.nrdocmto,0),                        --nrdocmto
                   465,                                               --cdhistor  
                   nvl(rw_craplot.nrseqdig,0) + 1,                    --nrseqdig
                   vr_relato(vr_indice).vltitulo,                     --vllanmto  
                   nvl(rw_craptit.nrdconta,0),                        --nrdctabb  
                   gene0002.fn_mask(nvl(rw_craptit.nrdconta,0),'99999999'),  --nrdctitg
                   pr_cdcooper,                                       --cdcooper
                   vr_dtmvtolt,                                       --dtrefere
                   '1');                                              --cdoperad
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao inserir CRAPLCM: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
            ELSE
              -- Fecha Cursor
              CLOSE cr_craplcm;
            END IF;
			
			-- Buscar o numero do PA(cdagenci)
            OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_craptit.nrdconta);
            FETCH cr_crapass INTO rw_crapass;
            
            --Se nao encontrou 
            IF cr_crapass%NOTFOUND THEN
              vr_relato(vr_indice).cdagenci := 0;
            ELSE
              vr_relato(vr_indice).cdagenci := rw_crapass.cdagenci;
            END IF;
			--Fechar Cursor
            CLOSE cr_crapass;
				
            -- Registro lançado
            vr_relato(vr_indice).flglanca := 'SIM';  
                
          ELSE
            --Fecha cursor     
            CLOSE cr_craptit;  
          END IF;   
 
          -- Se for a última linha a ser lida do arquivo
          EXIT WHEN vr_nrlinha = vr_arquivo.LAST;
          vr_nrlinha := vr_arquivo.next(vr_nrlinha); -- Próximo
        END LOOP; -- Fim LOOP linhas do arquivo

        -- Cria um log de execução
        pr_cdcritic := 190; -- "190 - ARQUIVO INTEGRADO COM SUCESSO"
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        -- Gerar Log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 1, -- Processo normal
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || pr_dscritic
                                                         || ' - Arquivo: integra/' || vr_array_arquivo(vr_nrindice));
                                                 
        pr_cdcritic := 0;
        pr_dscritic := NULL;

      END IF; -- vr_arquivo.count() > 0

      -- Move o arquivo lido para o diretório salvar 
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_diretori||'/'||vr_array_arquivo(vr_nrindice)||' '||vr_nom_direto||'/salvar 2> /dev/null'
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_saida);

      -- Se houve sucesso no mv ao salvar
      IF NVL(vr_typ_saida,'OK') <> 'ERR' THEN
        -- Gravar a cada arquivo movido
        COMMIT;
      ELSE    
        -- Sair com erro
        pr_dscritic := 'Erro ao mover arquivo integra/' || vr_array_arquivo(vr_nrindice) || '. Erro: '||vr_des_saida;
      END IF;

      -- Sair ao chegar ao final do arquivo
      EXIT WHEN vr_array_arquivo.last = vr_nrindice;
      -- Próximo índice
      vr_nrindice := vr_array_arquivo.NEXT(vr_nrindice);
    END LOOP;
  END IF;

  -- Salvar copia relatorio para "/rlnsv" 
  IF pr_nmtelant = 'COMPEFORA' THEN
    -- Guardar o rlnsv
    vr_dircop_rlnsv := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rlnsv');
  END IF;

  ---- GERAÇÃO DO RELATÓRIO COM OS DADOS PROCESSADOS ----
  -- Se há registros para serem inseridos no relatório
  IF vr_relato.COUNT() > 0 THEN

    -- Bloco responsável pela estruturação do XML para geração do relatório
    DECLARE

      -- Variáveis
      vr_clobxml     CLOB;
      vr_clobcri     CLOB;
      vr_dscaptur    VARCHAR2(25);
      vr_des_erro    VARCHAR2(4000);

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

    BEGIN

      -- Preparar o CLOB para armazenar as infos do arquivo
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><crps536>');

      -- Preparar o CLOB para armazenar as infos do arquivo
      dbms_lob.createtemporary(vr_clobcri, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobcri, dbms_lob.lob_readwrite);

      -- Percorre as informações guardadas na memória para montar o XML
      FOR ind IN vr_relato.first..vr_relato.last LOOP

        -- Definir o tipo de captura
        IF    vr_relato(ind).tpcaptur = 1  THEN
          vr_dscaptur := 'CAIXA';
        ELSIF vr_relato(ind).tpcaptur = 3  THEN
          vr_dscaptur := 'INTERNET';
        ELSE
          vr_dscaptur := 'OUTROS';
        END IF;

        -- Titulo
        pc_escreve_clob(vr_clobxml,'<titulo>'
                                 ||'  <cddbanco>'||LPAD(vr_relato(ind).cddbanco,3,'0')||'</cddbanco>'
                                 ||'  <dtmvtolt>'||to_char(vr_relato(ind).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'
                                 ||'  <vldocmto>'||to_char(vr_relato(ind).vldocmto,'FM9G999G999G990D00')||'</vldocmto>'
                                 ||'  <vltitulo>'||to_char(vr_relato(ind).vltitulo,'FM9G999G999G990D00')||'</vltitulo>'
                                 ||'  <cdmotivo>'||vr_relato(ind).cdmotivo||'</cdmotivo>'
                                 ||'  <linhadig>'||vr_relato(ind).linhadig||'</linhadig>'
                                 ||'  <dscaptur>'||vr_dscaptur||'</dscaptur>'
                                 ||'  <nrdolote>'||LPAD(vr_relato(ind).nrdolote,7,'0')||'</nrdolote>'
                                 ||'  <nrseqarq>'||LPAD(vr_relato(ind).nrseqarq,9,'0')||'</nrseqarq>'
                                 ||'  <flglanca>'||vr_relato(ind).flglanca||'</flglanca>'
								 ||'  <cdagenci>'||nvl(vr_relato(ind).cdagenci,0)||'</cdagenci>'
                                 ||'</titulo>');
        
        -- Se NAO foi lancado corretamente
        --IF vr_relato(ind).flglanca = 'NAO' THEN
          pc_escreve_clob(vr_clobcri,'50' || TO_CHAR(vr_dtmvtolt,'DDMMRR') || ',' || TO_CHAR(vr_dtmvtolt,'DDMMRR') ||
                                     ',1455,4894,' || TO_CHAR(vr_relato(ind).vltitulo,'fm9999999990d00','NLS_NUMERIC_CHARACTERS=.,') ||
                                     ',157,"DEVOLUCAO RECEBIMENTO COBRANCA (CONFORME CRITICA RELATORIO 521)"' || chr(10));
        --END IF;

      END LOOP;

      -- Fecha a tag geral
      pc_escreve_clob(vr_clobxml,'</crps536>');

      -- Submeter o relatório 536
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtolt                          --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crps536/titulo'                    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl521.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl521.lst'     --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'                             --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_dspathcop => vr_dircop_rlnsv                      --> Enviar para o rlnsv cfme tela chamada
								 ,pr_nrvergrl => 1                                     --> Numero da versão da função de geração de relatorio
                                 ,pr_des_erro  => vr_des_erro);                        --> Saída com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);

      -- Verifica se ocorreram erros na geração do relatório
      IF vr_des_erro IS NOT NULL THEN

        pr_dscritic := vr_des_erro;

        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Se possuir conteudo de critica no CLOB
      IF LENGTH(vr_clobcri) > 0 THEN
        -- Arquivo de saida
        vr_nmarquiv := TO_CHAR(vr_dtmvtolt,'RRMMDD') || '_CRITICAS.txt';

    -- Busca o diretório para contabilidade
        vr_dircon := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');

        vr_arqcon := TO_CHAR(vr_dtmvtolt,'RRMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_CRITICAS_521.txt';

        -- Chama a geracao do TXT
        GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper              --> Cooperativa conectada
                                           ,pr_cdprogra  => vr_cdprogra              --> Programa chamador
                                           ,pr_dtmvtolt  => vr_dtmvtolt              --> Data do movimento atual
                                           ,pr_dsxml     => vr_clobcri               --> Arquivo XML de dados
                                           ,pr_dsarqsaid => vr_nom_direto || '/contab/' || vr_arqcon    --> Arquivo final com o path
                                           ,pr_cdrelato  => NULL                     --> Código fixo para o relatório
                                           ,pr_flg_gerar => 'N'                      --> Apenas submeter
                                           ,pr_dspathcop => vr_dircon
                                           ,pr_fldoscop  => 'S'                                           
                                           ,pr_des_erro  => vr_des_erro);
                                   --> Saída com erro
                                   
          -- Verifica se ocorreram erros na geracao do TXT
          IF vr_des_erro IS NOT NULL THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> ERRO NA GERACAO DO ' || vr_arqcon || ': '
                                                       || vr_des_erro );
             END IF;           

      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobcri);
      dbms_lob.freetemporary(vr_clobcri);


    END;
  END IF; -- vr_relato.COUNT() > 0

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  -- Desfazer as alterações
  COMMIT;  

EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || pr_dscritic );
    END IF;
    -- Limpar variaveis de saida de critica pois eh um erro tratado
    pr_cdcritic := 0;
    pr_dscritic := null;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT; 
    
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS536;
/
