CREATE OR REPLACE PROCEDURE CECRED.pc_crps651(pr_cdcooper IN crapcop.cdcooper%TYPE     --> COOPERATIVA SOLICITADA
                                      ,pr_flgresta IN PLS_INTEGER               --> FLAG PADRÃO PARA UTILIZAÇÃO DE RESTART
                                      ,pr_stprogra OUT PLS_INTEGER              --> SAÍDA DE TERMINO DA EXECUÇÃO
                                      ,pr_infimsol OUT PLS_INTEGER              --> SAÍDA DE TERMINO DA SOLICITAÇÃO
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> CRITICA ENCONTRADA
                                      ,pr_dscritic OUT VARCHAR2) IS             --> TEXTO DE ERRO/CRITICA ENCONTRADA
BEGIN

  /* ............................................................................

   Programa: fontes/crps651.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Carlos Henrique
   Data    : Julho/2013                       Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Gerar relatorio crrl662. Este programa deverá gerar o relatório
               mensal crrl662.lst de arrecadaçao de consórcio nas cooperativas,
               correrá em todas as cooperativas. Programa deverá ler a tabela
               craplcm com os historicos 1230, 1231, 1232, 1233 e 1234 de todo
               o mes em questao.
               Sol. 55  / Ordem 2
   Alteracoes:
               20/06/2014 - Conversão Progress >> PLSQL (Renato - Supero).

  ............................................................................. */
  DECLARE

    ------------------------------- CURSORES ---------------------------------
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.nmrescop, cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper; -- CODIGO DA COOPERATIVA
    rw_crapcop     cr_crapcop%ROWTYPE;

    -- Buscar os lançamentos para a data espcificada
    CURSOR cr_craplcm(pr_dtmvtolt  DATE) IS
      SELECT cdcooper
           , nrdconta
           , nrdocmto
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.cdhistor IN (1230,1231,1232,1233,1234);

    -- Buscar dados de consórcio
    CURSOR cr_crapcns(pr_cdcooper   NUMBER
                     ,pr_nrdconta   NUMBER
                     ,pr_nrdocmto   NUMBER) IS
      SELECT crapcns.cdcooper
           , crapcns.nrdconta
           , crapcns.tpconsor
           , crapcns.nrctacns
           , crapcns.nrcotcns
           , crapcns.qtparcns
           , crapcns.vlparcns
           , crapcns.vlrcarta
        FROM crapcns
       WHERE crapcns.cdcooper = pr_cdcooper
         AND crapcns.nrdconta = pr_nrdconta
         AND crapcns.nrctrato = pr_nrdocmto
       ORDER BY crapcns.cdcooper
              , crapcns.nrdgrupo
              , crapcns.nrctacns
              , crapcns.nrcotcns
              , crapcns.nrctrato;
    rw_crapcns      cr_crapcns%ROWTYPE;

    -- Buscar o registro do associado
    CURSOR cr_crapass(pr_cdcooper  NUMBER
                     ,pr_nrdconta  NUMBER ) IS
      SELECT crapass.cdagenci
           , crapass.nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass      cr_crapass%ROWTYPE;

    -- TIPOS
    -- Registro para relatório
    TYPE rc_relato IS RECORD (cdagenci  crapass.cdagenci%TYPE
                             ,nrctacns  crapcns.nrctacns%TYPE
                             ,nrdconta  craplcm.nrdconta%TYPE
                             ,nmprimtl  crapass.nmprimtl%TYPE
                             ,dsconsor  VARCHAR2(15) -- Descrição do tipo de consórcio
                             ,nrcotcns  crapcns.nrcotcns%TYPE
                             ,qtparcns  crapcns.qtparcns%TYPE
                             ,vlparcns  crapcns.vlparcns%TYPE
                             ,vlrcarta  crapcns.vlrcarta%TYPE);
    -- Tabela de dados de relatório
    TYPE tb_relato IS TABLE OF rc_relato INDEX BY VARCHAR2(50);

    -- CURSOR GENÉRICO DE CALENDÁRIO
    rw_crapdat      btch0001.cr_crapdat%ROWTYPE;

    -- VARIÁVEIS
    -- Código do programa
    vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS651';
    -- Variáveis do relatório a ser gerado pelo programa
    vr_nmrelato     CONSTANT VARCHAR2(15) := 'crrl662.lst';
    vr_dsjasper     CONSTANT VARCHAR2(15) := 'crrl662.jasper';
    vr_tbrelato     tb_relato; -- dados para geração do relatório
    vr_dsdirrel      VARCHAR2(100);
    vr_des_xml       CLOB;               --> XML do relatorio
    vr_txtcompleto   VARCHAR2(32600);    --> Variável para armazenar os dados do XML antes de incluir no CLOB
    -- Variáveis diversas
    vr_nrdocmto     NUMBER;
    vr_nrindice     VARCHAR2(50);
    vr_dtiniper     DATE;
    vr_dtfimper     DATE;
    vr_dsconsor     VARCHAR2(15);
    -- TRATAMENTO DE ERROS
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);


  BEGIN

    -- INCLUIR NOME DO MÓDULO LOGADO
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);

    -- VERIFICA SE A COOPERATIVA ESTA CADASTRADA
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;

    -- SE NÃO ENCONTRAR
    IF cr_crapcop%NOTFOUND THEN
      -- FECHAR O CURSOR POIS HAVERÁ RAISE
      CLOSE cr_crapcop;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE cr_crapcop;
    END IF;

    -- LEITURA DO CALENDÁRIO DA COOPERATIVA
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;

    -- SE NÃO ENCONTRAR
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
      CLOSE btch0001.cr_crapdat;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- VALIDAÇÕES INICIAIS DO PROGRAMA
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);

    -- SE A VARIAVEL DE ERRO É <> 0
    IF vr_cdcritic <> 0 THEN
      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      RAISE vr_exc_saida;
    END IF;

    /* Data inicial e final do mes. O programa é executado no último dia útil */
    vr_dtiniper := trunc(rw_crapdat.dtmvtolt,'MM');
    vr_dtfimper := rw_crapdat.dtmvtolt;

    -- Limpar registro de memória
    vr_tbrelato.DELETE;

    LOOP
      -- Buscar e percorrer todos os lançamentos para a data
      FOR rw_craplcm IN cr_craplcm(vr_dtiniper) LOOP

        -- Definir o número de documento
        vr_nrdocmto := TO_NUMBER(SUBSTR(to_char(rw_craplcm.nrdocmto, 'FM0000000000000000000000'), 1, 8));

        -- Buscar as informações de consórcio
        OPEN  cr_crapcns(rw_craplcm.cdcooper  -- pr_cdcooper
                        ,rw_craplcm.nrdconta  -- pr_nrdconta
                        ,vr_nrdocmto);        -- pr_nrdocmto
        FETCH cr_crapcns INTO rw_crapcns;

        -- Se encontrar registro de consórcio
        IF cr_crapcns%FOUND THEN

          -- Busca o registro do associado
          OPEN  cr_crapass(rw_crapcns.cdcooper, rw_crapcns.nrdconta);
          FETCH cr_crapass INTO rw_crapass;

          -- Se encontrar registro do associado
          IF cr_crapass%FOUND THEN

            -- Definir a descrição do consórcio conforme o tipo
            IF    rw_crapcns.tpconsor = 1 THEN
              vr_dsconsor := 'MOTO';
            ELSIF rw_crapcns.tpconsor = 2 THEN
              vr_dsconsor := 'AUTO';
            ELSIF rw_crapcns.tpconsor = 3 THEN
              vr_dsconsor := 'CAMINHOES';
            ELSIF rw_crapcns.tpconsor = 4 THEN
              vr_dsconsor := 'IMOVEIS';
            ELSIF rw_crapcns.tpconsor = 5 THEN
              vr_dsconsor := 'SERVICOS';
            ELSE
              vr_dsconsor := 'SEM CAD.';
            END IF;

            -- Definir o índice do registro de memória
            vr_nrindice := LPAD(rw_crapass.cdagenci, 5,'0')||
                           LPAD(rw_crapcns.nrctacns,10,'0');
            -- Carregar o registro com os dados do consórcio
            vr_tbrelato(vr_nrindice).cdagenci := rw_crapass.cdagenci;
            vr_tbrelato(vr_nrindice).nrctacns := rw_crapcns.nrctacns; -- Conta consórcio
            vr_tbrelato(vr_nrindice).nrdconta := rw_craplcm.nrdconta;
            vr_tbrelato(vr_nrindice).nmprimtl := rw_crapass.nmprimtl;
            vr_tbrelato(vr_nrindice).dsconsor := vr_dsconsor;
            vr_tbrelato(vr_nrindice).nrcotcns := rw_crapcns.nrcotcns;
            vr_tbrelato(vr_nrindice).qtparcns := rw_crapcns.qtparcns;
            vr_tbrelato(vr_nrindice).vlparcns := rw_crapcns.vlparcns;
            vr_tbrelato(vr_nrindice).vlrcarta := rw_crapcns.vlrcarta;

          END IF; -- cr_crapass

          -- Fecha o cursor
          CLOSE cr_crapass;

        END IF; -- cr_crapcns

        -- Fecha o cursor
        CLOSE cr_crapcns;

      END LOOP;

      -- Sai quando processar a última data do mês
      EXIT WHEN vr_dtfimper = vr_dtiniper;
      -- Próximo dia
      vr_dtiniper := vr_dtiniper + 1;
    END LOOP;

    -- Se há registro para serem escritos no relatório
    IF vr_tbrelato.COUNT() > 0 THEN

      -- Definir o diretório para o relatório
      vr_dsdirrel := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => 1
                                          ,pr_nmsubdir => 'rl');

      -- Montar o XML
      -- Inicializar o CLOB
      vr_des_xml     := NULL;
      vr_txtcompleto := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Inicializa o XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompleto,
                              '<?xml version="1.0" encoding="utf-8"?><registros>');

      -- Primeiro índice a ser percorrido na tabela de memória
      vr_nrindice := vr_tbrelato.FIRST();

      -- Percorrer os registros em memória
      LOOP
        -- Dados relatório
        gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompleto,
                              '<consorcio>'||
                                '<cdagenci>'||vr_tbrelato(vr_nrindice).cdagenci||'</cdagenci>'||
                                '<nrctacns>'||GENE0002.fn_mask_conta(vr_tbrelato(vr_nrindice).nrctacns)||'</nrctacns>'||
                                '<nrdconta>'||GENE0002.fn_mask_conta(vr_tbrelato(vr_nrindice).nrdconta)||'</nrdconta>'||
                                '<nmprimtl>'||SUBSTR(vr_tbrelato(vr_nrindice).nmprimtl,1,37)||'</nmprimtl>'||
                                '<dsconsor>'||vr_tbrelato(vr_nrindice).dsconsor||'</dsconsor>'||
                                '<nrcotcns>'||vr_tbrelato(vr_nrindice).nrcotcns||'</nrcotcns>'||
                                '<qtparcns>'||vr_tbrelato(vr_nrindice).qtparcns||'</qtparcns>'||
                                '<vlparcns>'||TO_CHAR(vr_tbrelato(vr_nrindice).vlparcns,'FM9G999G999G990D00')||'</vlparcns>'||
                                '<vlrcarta>'||TO_CHAR(vr_tbrelato(vr_nrindice).vlrcarta,'FM9G999G999G990D00')||'</vlrcarta>'||
                              '</consorcio>');

        -- Sair quando chegar ao último registro
        EXIT WHEN vr_nrindice = vr_tbrelato.LAST();
        -- Próximo índice
        vr_nrindice := vr_tbrelato.NEXT(vr_nrindice);
      END LOOP;

      -- Fecha XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompleto,
                              '</registros>', TRUE);

      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/registros/consorcio',         --> No base do XML para leitura dos dados
                                  pr_dsjasper  => vr_dsjasper,                    --> Arquivo de layout do iReport
                                  pr_dsparams  => NULL,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_dsdirrel||'/'||vr_nmrelato,  --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                  pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                  pr_nmformul  => NULL,                           --> Nome do formulario
                                  pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                  pr_nrcopias  => 1,                              --> Numero de copias
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      -- Se ocorrer erros
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

    END IF;

    -- PROCESSO OK, DEVEMOS CHAMAR A FIMPRG
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- SALVAR INFORMAÇÕES ATUALIZADAS
    COMMIT;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRIÇÃO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- ERRO TRATATO
                                ,pr_des_log      => to_char(sysdate,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);

      -- CHAMAMOS A FIMPRG PARA ENCERRARMOS O PROCESSO SEM PARAR A CADEIA
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- EFETUAR COMMIT
      COMMIT;
    WHEN vr_exc_saida THEN
      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRIÇÃO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- DEVOLVEMOS CÓDIGO E CRITICA ENCONTRADAS DAS VARIAVEIS LOCAIS
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      -- EFETUAR ROLLBACK
      ROLLBACK;
    WHEN OTHERS THEN
      -- EFETUAR RETORNO DO ERRO NÃO TRATADO
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- EFETUAR ROLLBACK
      ROLLBACK;
  END;

END pc_crps651;
/

