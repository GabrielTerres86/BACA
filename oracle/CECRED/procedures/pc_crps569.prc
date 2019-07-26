CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS569(pr_cdcooper in crapcop.cdcooper%type
                                      ,pr_flgresta  IN PLS_INTEGER
                                      ,pr_stprogra OUT PLS_INTEGER
                                      ,pr_infimsol OUT PLS_INTEGER
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT VARCHAR2) AS
  /* ............................................................................

     Programa: PC_CRPS569                   Antigo: fontes/crps569.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Irlan
     Data    : Maio/2010                    Ultima atualizacao: 02/07/2019

     Dados referentes ao programa:

     Frequencia: Mensal
     Objetivo  : Gerar arquivo(3045) de cooperados para consulta no Bacen.
                 Solicitacao : 86
                 Ordem do programa na solicitacao = 54
                 Paralelo

     Alteracoes : 27/05/2010 - Busca das informações nas tabelas
                               crapttl. Eliminacao de cpfs duplicados (Irlan).

                  01/07/2010 - Gerar o cabecalho com o CNPJ da Cecred e
                               carregar as informacoes de todas cooperativas.
                               Gerar multiplos arquivos quando qtd registro
                               maior que 50000 (Irlan).

                  16/07/2010 - Eliminar repetição dos CNPJs com os 8 primeiros
                               caracteres iguais (Irlan).

                  02/08/2010 - Incluir a chamada ao fimprg.p quando nao for
                               o dia correto para geracao dos arquivos (Irlan).

                  28/01/2011 - Incluido o atributo AutConsCli (Adriano).

                  30/08/2011 - Alterado Cab. 3081 para 3045 e Conteúdo da Tag
                               <Cli> passa a estar no atributo "Cd" da Tag <Cli>
                               (Adriano).

                  08/05/2012 - Incluida procedure 'envia_cpfcnpj' (Tiago).

                  13/01/2014 - Alteracao referente a integracao Progress X
                              Dataserver Oracle
                              Inclusao do VALIDATE ( Andre Euzebio / SUPERO)

                  21/03/2014 - Conversao progress -> Oracle (Gabriel)
                  
                  24/04/2017 - Modificado a qtd max de registros poor arquivo
                               de 50000 para 1000000 (Tiago/Rodrigo)

                  06/10/2017 - Alterado para gerar com data Base da consulta 
                               sempre 1 mes antes. (Jaison/James - M446)

                  02/07/2019 - Adicionar todos os CPF e CNPJ de cooperados que possuem 
                               contratos na central de risco na mensal do arquivo 
                               (independente do cooperado estar demitido ou não). 
                               (Heckmann/AMcom - P450)
  ............................................................................*/
  BEGIN
    DECLARE
      -- Variaveis de uso no programa
      vr_cdprogra crapprg.cdprogra%TYPE := 'CRPS569';  -- Codigo do presente programa
      vr_cdcritic        crapcri.cdcritic%TYPE;        -- Codigo da critica
      vr_dscritic        VARCHAR2(2000);               -- Descricao da critica
      vr_dtrefere        DATE;                         -- Data de referencia
      vr_dtmvtolt        DATE;                         -- Data de movimento
      vr_dsdtbase        VARCHAR2(20);                 -- Descricao da data base
      vr_nrqtd           NUMBER(10);                   -- Quantidade para o relatorio
      vr_nrseqarq        NUMBER(10);                   -- Sequencia do arquivo
      vr_nrqtdmax        NUMBER(10);                   -- Quantidade maxima
      vr_dscpfce         VARCHAR2(20);                 -- CNPJ da central
      vr_dsdecpf         VARCHAR2(20);                 -- CPF
      vr_dsantind        VARCHAR2(50);                 -- Indice anterior
      vr_dsindice        VARCHAR2(50);                 -- Indice
      vr_dsdireto_salvar VARCHAR2(50);                 -- Diretorio do arquivo no salvar
      vr_dsdireto_contab VARCHAR2(50);                 -- Diretorio do arquivo no /micros/contab
      vr_nmarqsai        VARCHAR2(100);                -- Nome do arquivo 3045
      vr_exc_saida       EXCEPTION;                    -- Exeption parar cadeia
      vr_exc_fimprg      EXCEPTION;                    -- Exception para rodar fimprf
      vr_indmaster       VARCHAR2(100);
      vr_indcrapttl      VARCHAR2(100);
      --controle de clob
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600);


      -- Cursor da cooperativa logada
      CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrdocnpj
              ,cop.cdcooper
          FROM crapcop cop
          WHERE cop.cdcooper = pr_cdcooper;

      -- Dados do cooperado
      CURSOR cr_crapass IS
        SELECT crapass.cdcooper
              ,crapass.nrdconta
              ,crapass.inpessoa
              ,crapass.nrcpfcgc
          FROM crapass
         WHERE crapass.dtdemiss IS NULL
        -- P450 CPF e CNPJ de cooperados que possuem 
        -- contratos na central de risco na mensal do arquivo   
         UNION
        SELECT crapass.cdcooper
              ,crapass.nrdconta
              ,crapass.inpessoa
              ,crapass.nrcpfcgc
          FROM crapass
              ,crapris
         WHERE crapass.cdcooper = crapris.cdcooper
           AND crapass.nrdconta = crapris.nrdconta
           AND crapris.inddocto = 1
           AND crapris.dtrefere = vr_dtmvtolt;

      -- Cursor contento os titulares
      CURSOR cr_crapttl IS
        SELECT ttl.nrdconta
              ,ttl.nrcpfcgc
              ,ttl.cdcooper
          FROM crapttl ttl
        ORDER BY ttl.cdcooper
                ,ttl.nrdconta;

      -- CPFs/CNPJs enviados p/ consulta
      CURSOR cr_crapces(pr_dtmvtolt IN DATE) IS
        SELECT crapces.dtrefere
              ,crapces.nrcpfcgc
          FROM crapces
         WHERE crapces.dtrefere = pr_dtmvtolt;

      -- Registro para manter dados dos associados
      TYPE typ_reg_crapass IS
        RECORD(nrcpfcgc crapass.nrcpfcgc%TYPE
              ,inpessoa crapass.inpessoa%TYPE);

      -- Tabela tipo crapass
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
          INDEX BY VARCHAR2(50); --> Nossa chave será apenas o código da conta

      -- Estrutura de registro para manter dados dos CPFs/CNPJs enviados p/ consulta
      TYPE typ_reg_crapces IS
        RECORD(dtrefere DATE
              ,nrcpfcgc crapces.nrcpfcgc%TYPE);

      -- Tipo de registro para manter CPFs/CNPJs enviados p/ consulta
      TYPE typ_tab_crapces IS
        TABLE OF typ_reg_crapces
          INDEX BY VARCHAR2(100);

      -- Tipo de registro para manter CPFs/CNPJs enviados p/ consulta
      TYPE typ_tab_crapttl IS
        TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);

      --Estrutura de registro para armazenar todos os cpfs
      --dos titulares da conta utilizando uma temp-table dentro da outra
      TYPE typ_reg_crapttl_master IS
        RECORD( regcrapttl typ_tab_crapttl);

      -- tipo de registro para armazenar titulares da conta
      TYPE typ_tab_crapttl_master IS
        TABLE OF typ_reg_crapttl_master INDEX BY VARCHAR2(100);

      -- Vetor que armazenará uma instancia com o formato da crapass
      vr_tab_crapass typ_tab_crapass;

      --tabela temporaria para armazenar informacoes dos CPFs/CNPJs enviados p/ consulta
      vr_tab_crapces typ_tab_crapces;

      -- Dados da data da cooperativa logada
      rw_crapdat btch0001.cr_crapdat%rowtype;

      -- Dados da cooperativa
      rw_crapcop cr_crapcop%rowtype;

      --tabela temporaria para armazenar todos os cpfs de cada conta
      vr_tab_crapttl_master typ_tab_crapttl_master;

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_envia_cpfcnpj(pr_nrcpfcgc crapttl.nrcpfcgc%TYPE
                                ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      BEGIN
        DECLARE
          vr_indcrapces VARCHAR2(100);
        BEGIN
          vr_indcrapces := LPAD(TRIM(pr_nrcpfcgc),25,'0');

          -- Verificar se o CPF/CNPJ já foi enviado p/ consulta
          -- Se nao foi, criar
          IF NOT vr_tab_crapces.EXISTS(vr_indcrapces)  THEN

            --insere novo registro na crapcess
            BEGIN
              INSERT INTO crapces(nrcpfcgc
                                 ,dtrefere)
              VALUES ( pr_nrcpfcgc
                      ,pr_dtmvtolt);
            EXCEPTION
              WHEN OTHERS THEN
                --descricao do erro
                vr_dscritic := 'Erro ao inserir dados na crapces. '||SQLERRM;
                --aborta a execucao do programa
                RAISE vr_exc_saida;
            END;

            --insere também na tabela temporaria para posterior consulta
            vr_tab_crapces(LPAD(TRIM(pr_nrcpfcgc),25,'0')).dtrefere := pr_dtmvtolt;
            vr_tab_crapces(LPAD(TRIM(pr_nrcpfcgc),25,'0')).nrcpfcgc := pr_nrcpfcgc;

          END IF;
        END;
      END pc_envia_cpfcnpj;

      -- Escrever uma linha de dados no arquivo 3045
      PROCEDURE pc_escreve_arquivo (pr_dsddados varchar2, pr_grava BOOLEAN DEFAULT FALSE) IS
      BEGIN
        -- iniciando o arquivo xml para gerar o lst
        gene0002.pc_escreve_xml(vr_des_xml,
                                vr_texto_completo,
                                pr_dsddados,
                                pr_grava);

      END pc_escreve_arquivo;

      -- cria novo arquivo
      PROCEDURE pc_cria_arquivo( pr_dtrefere date
                                ,pr_nrseqarq number
                                ,pr_dsdtbase varchar2
                                ,pr_nrcpfcgc varchar2) IS
      BEGIN
        -- Diretorio salvar
        vr_dsdireto_salvar :=  gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                    ,pr_cdcooper => pr_cdcooper
                                                    ,pr_nmsubdir => 'salvar');

        -- Nome do arquivo
        vr_nmarqsai := '3045' ||  to_char(pr_dtrefere,'mm')    ||
                       to_char(pr_dtrefere,'yy')   ||
                       '_' || to_char(pr_nrseqarq) || '.xml';

        --instanciando o clob
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -- Inicio do XML do arquivo
        pc_escreve_arquivo('<?xml version="1.0" encoding="ISO-8859-1"?>'||chr(13));

        pc_escreve_arquivo('<Doc3045 DtBase="' || pr_dsdtbase || '" CNPJ="' || pr_nrcpfcgc || '">'||chr(13));

      END pc_cria_arquivo;

      --cria novo atributo xml no arquivo
      PROCEDURE pc_cria_registro (pr_inpessoa crapass.inpessoa%type
                                 ,pr_nrcpfcgc crapass.nrcpfcgc%type) IS
      BEGIN
        IF  pr_inpessoa = 1  THEN -- Pessoa fisica
          pc_escreve_arquivo('<Cli Cd="' || ltrim(to_char(pr_nrcpfcgc,'00000000000')) || '" Tp="1" AutConsCli="S"/>'||chr(13));
        ELSIF pr_inpessoa = 2  THEN -- Pessoa juridica
          pc_escreve_arquivo('<Cli Cd="' || ltrim(to_char(pr_nrcpfcgc,'00000000')) || '" Tp="2" AutConsCli="S"/>'||chr(13));
        END IF;
      END pc_cria_registro;

      --fecha o arquivo
      PROCEDURE pc_finaliza_arquivo IS
      BEGIN

        --tag de encerramento do xml
        pc_escreve_arquivo('</Doc3045>'||chr(13), TRUE);

        --criando o arquivo fisico na pasta salvar
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                     ,pr_caminho  => vr_dsdireto_salvar
                                     ,pr_arquivo  => vr_nmarqsai
                                     ,pr_des_erro => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);

        -- Obtem o diretorio micros/coop/contab
        vr_dsdireto_contab := gene0001.fn_diretorio(pr_tpdireto => 'M'
                                                   ,pr_cdcooper => 3
                                                   ,pr_nmsubdir => 'contab');

        -- Move para a pasta micro acessivel ao usuario
        gene0001.pc_OScommand_Shell(pr_des_comando => 'ux2dos  < '         || vr_dsdireto_salvar || '/' || vr_nmarqsai  ||
                                                      ' | tr -d "\032" > ' || vr_dsdireto_contab || '/' || vr_nmarqsai  ||
                                                      ' 2>/dev/null'
                                    ,pr_flg_aguard => 'S');
      END pc_finaliza_arquivo;

    BEGIN

      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                                ,pr_action => NULL);

      -- Obter os dados da cooperativa CECRED
      OPEN cr_crapcop (pr_cdcooper => 3);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Realizar as validacoes do iniprg
      btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                                 pr_flgbatch => 1,
                                 pr_cdprogra => vr_cdprogra,
                                 pr_infimsol => pr_infimsol,
                                 pr_cdcritic => vr_cdcritic);

      -- Se possui critica, buscar a descricao e jogar ao log
      IF  vr_cdcritic <> 0  THEN

        RAISE vr_exc_saida;

      END IF;

      -- Só deve rodar no dia 23 ou proximidade caso não seja dia util.
      IF NOT (to_number(to_char(rw_crapdat.dtmvtolt,'dd')) <= 23
        AND to_number(to_char(rw_crapdat.dtmvtopr,'dd')) > 23) THEN
        --encerra a execucao do programa
        RAISE vr_exc_fimprg;
      END IF;

      -- Data de referencia e quantidade maxima
      vr_dtrefere := rw_crapdat.dtmvtolt;

      --quantidade maxima de registros no arquivo (1000000)      
      vr_nrqtdmax := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                               pr_cdcooper => 0,
                                               pr_cdacesso => 'QTD_COOPERADOS_ARQ_3045');

      -- A Data Base da consulta eh sempre 1 mes antes
      vr_dtmvtolt := vr_dtrefere - to_number(to_char(vr_dtrefere,'dd'));
      vr_dsdtbase := to_char(vr_dtmvtolt,'yyyy') || '-' || to_char(vr_dtmvtolt,'mm');

      --limpando a tabela temporaria
      vr_tab_crapces.delete;
      --carregando tabela temporaria de consultas
      FOR rw_crapces IN cr_crapces(pr_dtmvtolt => vr_dtmvtolt) LOOP
        vr_tab_crapces(LPAD(TRIM(rw_crapces.nrcpfcgc),25,'0')).dtrefere := rw_crapces.dtrefere;
        vr_tab_crapces(LPAD(TRIM(rw_crapces.nrcpfcgc),25,'0')).nrcpfcgc := rw_crapces.nrcpfcgc;
      END LOOP;

      --limpando a tabela temporaria
      vr_tab_crapttl_master.delete;
      --carrega a tabela temporaria de titulares da conta
      FOR rw_crapttl IN cr_crapttl LOOP
        --indice da tabela mestre
        vr_indmaster := LPAD(rw_crapttl.cdcooper,10,'0')||LPAD(rw_crapttl.nrdconta,10,'0');
        --carregando o numero do cpf do titular da conta
        vr_tab_crapttl_master(vr_indmaster).regcrapttl(rw_crapttl.nrcpfcgc) := rw_crapttl.nrcpfcgc;
      END LOOP;

      -- CNPJ da cooperativa
      vr_dscpfce  := substr(to_char(rw_crapcop.nrdocnpj,'00000000000000'),1,9);
      vr_dsindice := '';

      -- Percorrer dados do associado
      FOR rw_crapass IN cr_crapass LOOP

        -- Se pessoa fisica
        IF  rw_crapass.inpessoa = 1  THEN
          --monta o indice de busca
          vr_indmaster :=  LPAD(rw_crapass.cdcooper,10,'0')||LPAD(rw_crapass.nrdconta,10,'0');

          --posiciona na conta do associado
          IF vr_tab_crapttl_master.EXISTS(vr_indmaster) THEN

            vr_indcrapttl := vr_tab_crapttl_master(vr_indmaster).regcrapttl.first;
            LOOP
              EXIT WHEN vr_indcrapttl IS NULL;
              -- CPF da conta e contador para a PL TABLE
              vr_dsdecpf  := ltrim(to_char(vr_tab_crapttl_master(vr_indmaster).regcrapttl(vr_indcrapttl),'00000000000000'));
              vr_dsindice := ltrim(to_char(rw_crapass.inpessoa,'9')) || ltrim(vr_dsdecpf);

              -- Armazenar cooperado
              vr_tab_crapass(vr_dsindice).inpessoa := rw_crapass.inpessoa;
              vr_tab_crapass(vr_dsindice).nrcpfcgc := vr_dsdecpf;

              --verifica o registro na tabela crapces
              pc_envia_cpfcnpj(pr_nrcpfcgc => vr_tab_crapttl_master(vr_indmaster).regcrapttl(vr_indcrapttl)
                              ,pr_dtmvtolt => vr_dtmvtolt);

              --posiciona no proximo registro da tabela temporária
              vr_indcrapttl := vr_tab_crapttl_master(vr_indmaster).regcrapttl.NEXT(vr_indcrapttl);

            END LOOP;
          END IF;

        -- Se juridica ou conta admn.
        ELSIF rw_crapass.inpessoa IN (2,3)  THEN

          -- CNPJ da conta e contador para a PL TABLE
          vr_dsdecpf  := to_char(rw_crapass.nrcpfcgc,'00000000000000');
          vr_dsdecpf  := ltrim(substr(vr_dsdecpf,1,9));

          --monta o indice da tabela temporaria
          vr_dsindice := '2' ||  vr_dsdecpf;

          -- Armazenar cooperado
          vr_tab_crapass(vr_dsindice).inpessoa := 2;
          vr_tab_crapass(vr_dsindice).nrcpfcgc := vr_dsdecpf;

          --verifica o registro na tabela crapces
          pc_envia_cpfcnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc
                          ,pr_dtmvtolt => vr_dtmvtolt);

        END IF;

      END LOOP;

      -- Contadores para o arquivo
      vr_nrqtd    := 0;
      vr_nrseqarq := 1;
      vr_dsantind := '';

      -- Posiciona no primeiro registro
      vr_dsindice := vr_tab_crapass.FIRST;

      -- Percorrer todos os cooperados com limite e admitidos
      LOOP
        -- Quebrar laço se nao tiver mais registros
        EXIT WHEN vr_dsindice IS NULL;

        IF  vr_dsindice = vr_dsantind  THEN
          -- Proximo indice
          vr_dsindice := vr_tab_crapass.NEXT(vr_dsindice);
          CONTINUE;
        END IF;

        vr_dsantind := vr_dsindice;

        -- Se atingiu o limite de registros/linhas por arquivo
        -- cria novo arquivo
        IF  vr_nrqtd = 0  OR
           (vr_nrqtd <> 0 AND (vr_nrqtd MOD vr_nrqtdmax = 0)) THEN
          --criando novo registro
          pc_cria_arquivo (pr_dtrefere => vr_dtrefere
                          ,pr_nrseqarq => vr_nrseqarq
                          ,pr_dsdtbase => vr_dsdtbase
                          ,pr_nrcpfcgc => vr_dscpfce);
        END IF;

        --incrementa o contador de registros
        vr_nrqtd := vr_nrqtd + 1;

        -- Dados do detalhe
        pc_cria_registro (pr_inpessoa => vr_tab_crapass(vr_dsindice).inpessoa
                         ,pr_nrcpfcgc => vr_tab_crapass(vr_dsindice).nrcpfcgc);

        -- Fechar arquivo
        IF  vr_nrqtd = vr_nrqtdmax THEN
          vr_nrqtd := 0;
          vr_nrseqarq := vr_nrseqarq + 1;

          --fecha o arquivo
          pc_finaliza_arquivo;
        END IF;

        -- Proximo indice
        vr_dsindice := vr_tab_crapass.NEXT(vr_dsindice);

      END LOOP;

      -- Fecha o arquivo para os ultimos registros com total < 50000
      IF  vr_nrqtd > 0  THEN
        --encerra o arquivo
        pc_finaliza_arquivo;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Comitando a transacao
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
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
        -- Efetuar commit pois gravaremos o que foi processo até então
        COMMIT;

      WHEN vr_exc_saida THEN
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

      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END PC_CRPS569;
/
