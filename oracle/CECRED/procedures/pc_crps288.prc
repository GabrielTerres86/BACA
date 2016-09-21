CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS288" ( pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Código da cooperativa
                                          ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                          ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                          ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
BEGIN
  /* ..........................................................................

   Programa: PC_CRPS288      Antigo: Fontes/crps288.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : 12/04/2000                        Ultima atualizacao: 22/11/2013

   Dados referentes ao programa:

   Frequencia: Mensal de relatorios.
   Objetivo  : Atende a solicitacao 4.
               Atende carta circular 2904 do banco central do brasil.

   Alteracoes: 16/11/2000 - Alterar o periodo de leitura dos lancamentos
                            (Eduardo).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               09/06/2006 - Alteracao no tratamento do crapper, dtiniper e
                            dtfimper, podem nao ser dia util (Julio).

               27/04/2007 - Criado arquivo da movimentacao de CPMF para
                            contabilidade (Elton).

               06/06/2007 - Nao lista aliquotas que possuam valor zero (Elton).

               09/06/2008 - Incluído o mecanismo de pesquisa no "for each" na
                            tabela CRAPHIS para buscar primeiro pela chave de
                            acesso (craphis.cdcooper = glb_cdcooper).
                            - Kbase IT Solutions - Paulo Ricardo Maciel.

               03/01/2012 - Aumentado o tamanho do extent da variavel
                            aux_inclasse (Tiago).

               04/07/2013 - Conversão Progress -> Oracle - Petter (Supero)

               09/08/2013 - Troca da busca do mes por extenso com to_char para
                            utilizarmos o vetor gene0001.vr_vet_nmmesano (Marcos-Supero)

               09/08/2013 - copiar arquivo da "contab" também para o diretorio
                            definido no crapprm = "CRPS288_COPIA" (Odirlei-AMcom)

               18/11/2013 - Ajustes na chamada do crrl236 para que o relatório
                            fique com 80 colunas (Marcos-Supero)

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)

  ............................................................................. */
  DECLARE
    -- Definir tipo para gerar array de inteiros
    TYPE typ_tab_inteiros IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;

    vr_nmdir        VARCHAR2(400);               --> Path para salvar relatórios
    vr_nmformul     VARCHAR2(400);               --> Nome do formulário
    vr_nrcopias     PLS_INTEGER;                 --> Número de cópias
    vr_linhadet     VARCHAR2(400);               --> Linha de controle
    vr_con_dtmvtopr VARCHAR2(20);                --> Data de movimento prioritário
    vr_con_dtmvtolt VARCHAR2(20);                --> Data de movimento
    vr_vlalinor     NUMBER(20,2) := 0;           --> Valor de linha
    vr_vlalizer     NUMBER(20,2) := 0;           --> Valor de linha 2
    vr_vlalinao     NUMBER(20,2) := 0;           --> Valor de não linha
    vr_vlaliout     NUMBER(20,2) := 0;           --> Valor de linha - outras
    vr_vltotais     NUMBER(20,2) := 0;           --> Valor de totais
    vr_inclasse     typ_tab_inteiros;            --> Dentro da classe
    vr_rel_dsperiod VARCHAR2(30);                --> Descrição do período
    vr_rel_nmmesref VARCHAR2(400);               --> nome do relatório para o relatório
    vr_dtiniper     DATE;                        --> Data inicial do período
    vr_dtfimper     DATE;                        --> Data final do período
    vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS288'; --> Identificador do programa
    vr_exc_erro     EXCEPTION;                   --> Controle de exceção personalizado
    vr_exc_fimprg   EXCEPTION;
    vr_cdcritic     crapcri.cdcritic%TYPE;
    vr_dscritic     VARCHAR2(4000);
    rw_crapdat      btch0001.cr_crapdat%ROWTYPE; --> Retorno de cursor para informações gerais de execução
    vr_saida        EXCEPTION;                   --> Controle para saído de LOOP
    vr_xml          CLOB;                        --> Variável para armazenar o XML
    vr_xmltxt       CLOB;                        --> Variável para armazenar o XML do arquivo texto
    vr_dspathcp     VARCHAR2(200);               --> Diretorio para copiar o arq. da contab

    /* Buscar dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Código da cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Buscar dados de histórico */
    CURSOR cr_craphis(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Código da cooperativa
      SELECT ch.inclasse
            ,ch.cdhistor
      FROM craphis ch
      WHERE ch.cdcooper = pr_cdcooper;

    /* Buscar dados da data real inicial de apuração */
    CURSOR cr_crapper(pr_cdcooper IN craptab.cdcooper%TYPE     --> Código da cooperativa
                     ,pr_dtmvtolt IN crapper.dtfimper%TYPE) IS --> Data do movimento
      SELECT cr.dtiniper
      FROM crapper cr
      WHERE cr.cdcooper =  pr_cdcooper
        AND ROWNUM = 1
        AND cr.dtfimper > last_day(add_months(pr_dtmvtolt, -1));
    rw_crapper cr_crapper%ROWTYPE;

    /* Buscar dados da data real final de apuração */
    CURSOR cr_crapperf(pr_cdcooper IN craptab.cdcooper%TYPE     --> Código da cooperativa
                      ,pr_dtmvtolt IN crapper.dtfimper%TYPE) IS --> Data do movimento
      SELECT MAX(cp.dtfimper) dtfimper
      FROM crapper cp
      WHERE cp.cdcooper = pr_cdcooper
        AND cp.dtfimper < pr_dtmvtolt
      ORDER BY cp.dtfimper DESC;
    rw_crapperf cr_crapperf%ROWTYPE;

    /* Buscar dados dos lançamentos para os associados */
    CURSOR cr_assoc(pr_cdcooper IN craptab.cdcooper%TYPE      --> Código da cooperativa
                   ,pr_dtiniper IN craplcm.dtmvtolt%TYPE      --> Data inicial do período
                   ,pr_dtfimper IN craplcm.dtmvtolt%TYPE) IS  --> Data final do período
      SELECT cs.nrdconta
            ,cs.iniscpmf
            ,cm.cdhistor
            ,cm.vllanmto
      FROM crapass cs, craplcm cm
      WHERE cs.cdcooper = cm.cdcooper
        AND cs.nrdconta = cm.nrdconta
        AND cm.cdcooper  = pr_cdcooper
        AND cm.dtmvtolt >= pr_dtiniper
        AND cm.dtmvtolt <= pr_dtfimper
      ORDER BY cs.nrdconta, cm.cdhistor, cm.vllanmto;

    -- Procedure para escrever texto na variável CLOB do XML
    PROCEDURE pc_xml_tag(pr_des_dados IN VARCHAR2                --> String que será adicionada ao CLOB
                        ,pr_clob      IN OUT NOCOPY CLOB) IS     --> CLOB que irá receber a string
    BEGIN
      dbms_lob.writeappend(pr_clob, length(pr_des_dados), pr_des_dados);
    END pc_xml_tag;

  BEGIN

    vr_nmformul := '';
    vr_nrcopias := 1;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => '');

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;

      -- Montar mensagem de critica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;

      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1--true
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);

    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Buscar descrição da crítica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      -- Envio centralizado de log de erro
      RAISE vr_exc_erro;
    END IF;

    -- Armazenar informações dos históricos da cooperativa conectada
    FOR rw_craphis IN cr_craphis(pr_cdcooper) LOOP
      vr_inclasse(rw_craphis.cdhistor) := rw_craphis.inclasse;
    END LOOP;

    -- Buscar a data real inicial
    OPEN cr_crapper(pr_cdcooper, rw_crapdat.dtmvtolt);
    FETCH cr_crapper INTO rw_crapper;

    -- Verifica se a tupla retornou registro
    IF cr_crapper%NOTFOUND THEN
      CLOSE cr_crapper;

      -- Levanta exceção
      RAISE vr_exc_fimprg;
    ELSE
      CLOSE cr_crapper;

      -- Atribui valor
      vr_dtiniper := rw_crapper.dtiniper;
    END IF;

    -- Buscar a data real final
    OPEN cr_crapperf(pr_cdcooper, rw_crapdat.dtmvtopr);
    FETCH cr_crapperf INTO rw_crapperf;

    -- Verifica se a tupla retornou registro
    IF cr_crapperf%NOTFOUND THEN
      CLOSE cr_crapperf;

      -- Levanta exceção
      RAISE vr_exc_fimprg;
    ELSE
      CLOSE cr_crapperf;

      -- Atribui valor
      vr_dtfimper := rw_crapperf.dtfimper;
    END IF;

    -- Atribui valores acerca das datas
    vr_rel_nmmesref := gene0001.vr_vet_nmmesano(to_char(vr_dtfimper, 'MM')) || to_char(vr_dtfimper, '/RRRR');
    vr_rel_dsperiod := to_char(vr_dtiniper, 'DD/MM/RRRR') || ' A ' || to_char(vr_dtfimper, 'DD/MM/RRRR');
    vr_con_dtmvtolt := '52' || substr(to_char(rw_crapdat.dtmvtolt, 'RRRR'), 3, 2) || to_char(rw_crapdat.dtmvtolt, 'MMDD');
    vr_con_dtmvtopr := '52' || substr(to_char(rw_crapdat.dtmvtopr, 'RRRR'), 3, 2) || to_char(rw_crapdat.dtmvtopr, 'MMDD');

    -- Buscar dados dos lançamentos da conta para os associados
    FOR rw_assoc IN cr_assoc(pr_cdcooper => pr_cdcooper
                            ,pr_dtiniper => vr_dtiniper
                            ,pr_dtfimper => vr_dtfimper) LOOP
      BEGIN
        -- Verifica o código do histórico
        IF vr_inclasse(rw_assoc.cdhistor) = 0 THEN
          RAISE vr_saida;
        END IF;

        -- Para conta 820024
        IF rw_assoc.iniscpmf = 1 THEN
          -- Verifica o código do histórico para soma do valor
          IF gene0002.fn_existe_valor(pr_base      => '10,110,20,30,40,50,90,120,130'
                                     ,pr_busca     => vr_inclasse(rw_assoc.cdhistor)
                                     ,pr_delimite  => ',') = 'S' THEN
            vr_vlaliout := vr_vlaliout + rw_assoc.vllanmto;
          END IF;

          RAISE vr_saida;
        END IF;

        -- Outras cooperativas
        IF rw_assoc.iniscpmf = 2 THEN
          IF gene0002.fn_existe_valor(pr_base      => '10,110,20,30,40,50,90,120,130'
                                     ,pr_busca     => vr_inclasse(rw_assoc.cdhistor)
                                     ,pr_delimite  => ',') = 'S' THEN
            vr_vlalizer := vr_vlalizer + rw_assoc.vllanmto;
          END IF;

          RAISE vr_saida;
        END IF;

        -- Valida valores de lançamento
        IF gene0002.fn_existe_valor(pr_base      => '10,110,20,30,40,50,90,120,130'
                                   ,pr_busca     => vr_inclasse(rw_assoc.cdhistor)
                                   ,pr_delimite  => ',') = 'S' THEN
          vr_vlalinor := vr_vlalinor + rw_assoc.vllanmto;
        ELSIF gene0002.fn_existe_valor(pr_base      => '60,70,80,100'
                                      ,pr_busca     => vr_inclasse(rw_assoc.cdhistor)
                                      ,pr_delimite  => ',') = 'S' THEN
          vr_vlalinao := vr_vlalinao + rw_assoc.vllanmto;
        END IF;
      EXCEPTION
        WHEN vr_saida THEN
          -- Apenas passa para a próxima iteração do LOOP
          NULL;
        WHEN OTHERS THEN
          -- Captura erro e levanta exceção
          vr_dscritic := vr_dscritic || 'Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    END LOOP;

    -- Sumariza valores
    vr_vltotais := vr_vlalinor + vr_vlalizer + vr_vlalinao + vr_vlaliout;

    -- Inicializar os CLOBs
    dbms_lob.createtemporary(vr_xml, TRUE);
    dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

    dbms_lob.createtemporary(vr_xmltxt, TRUE);
    dbms_lob.open(vr_xmltxt, dbms_lob.lob_readwrite);

    pc_xml_tag(pr_des_dados => '<?xml version="1.0" encoding="utf-8"?><valores>'
              ,pr_clob      => vr_xmltxt);

    pc_xml_tag(pr_des_dados => '<?xml version="1.0" encoding="utf-8"?><totais><rel_nmmesref>' || vr_rel_nmmesref || '</rel_nmmesref>' ||
                               '<rel_dsperiod>' || vr_rel_dsperiod || '</rel_dsperiod>' ||
                               '<vr_vlalinor>' || to_char(nvl(vr_vlalinor, 0), 'FM999G999G999G999G990D00') || '</vr_vlalinor>' ||
                               '<vr_vlalizer>' || to_char(nvl(vr_vlalizer, 0), 'FM999G999G999G999G990D00') || '</vr_vlalizer>' ||
                               '<vr_vlalinao>' || to_char(nvl(vr_vlalinao, 0), 'FM999G999G999G999G990D00') || '</vr_vlalinao>' ||
                               '<vr_vlaliout>' || to_char(nvl(vr_vlaliout, 0), 'FM999G999G999G999G990D00') || '</vr_vlaliout>' ||
                               '<vr_vltotais>' || to_char(nvl(vr_vltotais, 0), 'FM999G999G999G999G990D00') || '</vr_vltotais></totais>'
              ,pr_clob      => vr_xml);

    -- Verifica valor de linha
    IF vr_vlalinor <> 0 THEN
      -- Gerar valor de linha
      vr_linhadet := to_char(vr_con_dtmvtolt) || ',' || to_char(rw_crapdat.dtmvtolt, 'DDMMRR') || ',3951,9252,' ||
                     REPLACE(to_char(vr_vlalinor, 'FM999999999999990D00'),',','.') || ',1434,"ALIQUOTA NORMAL"';

      -- Gerar linha no relatório
      pc_xml_tag(pr_des_dados => '<vr_vlalinor>' || vr_linhadet || '</vr_vlalinor>'
                ,pr_clob      => vr_xmltxt);

      -- Gerar valor de linha
      vr_linhadet := to_char(vr_con_dtmvtopr) || ',' || to_char(rw_crapdat.dtmvtopr, 'DDMMRR') || ',9252,3951,' ||
                     REPLACE(to_char(vr_vlalinor, 'FM999999999999990D00'),',','.') || ',1434,"ALIQUOTA NORMAL"';

      -- Gerar linha no relatório
      pc_xml_tag(pr_des_dados => '<vr_vlalinor2>' || vr_linhadet || '</vr_vlalinor2>'
                ,pr_clob      => vr_xmltxt);
    ELSE
      pc_xml_tag(pr_des_dados => '<vr_vlalinor></vr_vlalinor><vr_vlalinor2></vr_vlalinor2>'
                ,pr_clob      => vr_xmltxt);
    END IF;

    -- Verifica valor de análise
    IF vr_vlalizer <> 0 THEN
      -- Gerar valor de linha
      vr_linhadet := to_char(vr_con_dtmvtolt) || ',' || to_char(rw_crapdat.dtmvtolt, 'DDMMRR') || ',3952,9252,' ||
                     REPLACE(to_char(vr_vlalizer, 'FM999999999999990D00'),',','.') || ',1434,"ALIQUOTA ZERO"';

      -- Gerar linha no relatório
      pc_xml_tag(pr_des_dados => '<vr_vlalizer>' || vr_linhadet || '</vr_vlalizer>'
                ,pr_clob      => vr_xmltxt);

      -- Gerar valor de linha
      vr_linhadet := to_char(vr_con_dtmvtopr) || ',' || to_char(rw_crapdat.dtmvtopr, 'DDMMRR') || ',9252,3952,' ||
                     REPLACE(to_char(vr_vlalizer, 'FM999999999999990D00'),',','.') || ',1434,"ALIQUOTA ZERO"';

      -- Gerar linha no relatório
      pc_xml_tag(pr_des_dados => '<vr_vlalizer2>' || vr_linhadet || '</vr_vlalizer2>'
                ,pr_clob      => vr_xmltxt);
    ELSE
      pc_xml_tag(pr_des_dados => '<vr_vlalizer></vr_vlalizer><vr_vlalizer2></vr_vlalizer2>'
                ,pr_clob      => vr_xmltxt);
    END IF;

    -- Verifica valor de não incidência
    IF vr_vlalinao <> 0 THEN
      -- Gerar valor de linha
      vr_linhadet := to_char(vr_con_dtmvtolt) || ',' || to_char(rw_crapdat.dtmvtolt, 'DDMMRR') || ',3953,9252,' ||
                     REPLACE(to_char(vr_vlalinao, 'FM999999999999990D00'),',','.') || ',1434,"NAO INCIDENCIA"';

      -- Gerar linha no relatório
      pc_xml_tag(pr_des_dados => '<vr_vlalinao>' || vr_linhadet || '</vr_vlalinao>'
                ,pr_clob      => vr_xmltxt);


      -- Gerar valor de linha
      vr_linhadet := to_char(vr_con_dtmvtopr) || ',' || to_char(rw_crapdat.dtmvtopr, 'DDMMRR') || ',9252,3953,' ||
                     REPLACE(to_char(vr_vlalinao, 'FM999999999999990D00'),',','.') || ',1434,"NAO INCIDENCIA"';

      -- Gerar linha no relatório
      pc_xml_tag(pr_des_dados => '<vr_vlalinao2>' || vr_linhadet || '</vr_vlalinao2>'
                ,pr_clob      => vr_xmltxt);
    ELSE
      pc_xml_tag(pr_des_dados => '<vr_vlalinao></vr_vlalinao><vr_vlalinao2></vr_vlalinao2>'
                ,pr_clob      => vr_xmltxt);
    END IF;

    -- Verifica valor de outros
    IF vr_vlaliout <> 0 THEN
      -- Gerar valor de linha
      vr_linhadet := to_char(vr_con_dtmvtolt) || ',' || to_char(rw_crapdat.dtmvtolt, 'DDMMRR') || ',3954,9252,' ||
                     REPLACE(to_char(vr_vlaliout, 'FM999999999999990D00'),',','.') || ',1434,"OUTROS"';

      -- Gerar linha no relatório
      pc_xml_tag(pr_des_dados => '<vr_vlaliout>' || vr_linhadet || '</vr_vlaliout>'
                ,pr_clob      => vr_xmltxt);


      -- Gerar valor de linha
      vr_linhadet := to_char(vr_con_dtmvtopr) || ',' || to_char(rw_crapdat.dtmvtopr, 'DDMMRR') || ',9252,3954,' ||
                     REPLACE(to_char(vr_vlaliout, 'FM999999999999990D00'),',','.') || ',1434,"OUTROS"';

      -- Gerar linha no relatório
      pc_xml_tag(pr_des_dados => '<vr_vlaliout2>' || vr_linhadet || '</vr_vlaliout2>'
                ,pr_clob      => vr_xmltxt);
    ELSE
      pc_xml_tag(pr_des_dados => '<vr_vlaliout></vr_vlaliout><vr_vlaliout2></vr_vlaliout2>'
                ,pr_clob      => vr_xmltxt);
    END IF;

    pc_xml_tag(pr_des_dados => '</valores>'
              ,pr_clob      => vr_xmltxt);

    -- Capturar o path do arquivo
    vr_nmdir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                     ,pr_cdcooper => pr_cdcooper
                                     ,pr_nmsubdir => '/rl');

    -- Criar arquivo princial com dados armazenados
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => vr_cdprogra
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               ,pr_dsxml     => vr_xml
                               ,pr_dsxmlnode => '/totais'
                               ,pr_dsjasper  => 'crrl236.jasper'
                               ,pr_dsparams  => NULL
                               ,pr_dsarqsaid => vr_nmdir || '/crrl236.lst'
                               ,pr_flg_gerar => 'N'
                               ,pr_qtcoluna  => 80
                               ,pr_sqcabrel  => 1
                               ,pr_cdrelato  => NULL
                               ,pr_flg_impri => 'S'
                               ,pr_nmformul  => vr_nmformul
                               ,pr_nrcopias  => vr_nrcopias
                               ,pr_dspathcop => NULL
                               ,pr_dsmailcop => NULL
                               ,pr_dsassmail => NULL
                               ,pr_dscormail => NULL
                               ,pr_flsemqueb => 'N'
                               ,pr_des_erro  => vr_dscritic);

    -- Verifica se ocorreram erros
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Capturar o path do arquivo
    vr_nmdir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                     ,pr_cdcooper => pr_cdcooper
                                     ,pr_nmsubdir => '/contab');

     -- buscar diretorio para onde deve ser copiado os arquivo.
    vr_dspathcp := gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/contab');

    -- Criar arquivo princial com dados armazenados
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => vr_cdprogra
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               ,pr_dsxml     => vr_xmltxt
                               ,pr_dsxmlnode => '/valores'
                               ,pr_dsjasper  => 'rel_06.jasper'
                               ,pr_dsparams  => NULL
                               ,pr_dsarqsaid => vr_nmdir || '/' || SUBSTR(vr_con_dtmvtolt, 3, 6) || '_6.txt'
                               ,pr_flg_gerar => 'N'
                               ,pr_qtcoluna  => 132
                               ,pr_sqcabrel  => 1
                               ,pr_dspathcop => vr_dspathcp
                               ,pr_fldoscop  => 'S'          --> Converter para DOS
                               ,pr_des_erro  => vr_dscritic);

    -- Verifica se ocorreram erros
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Liberar dados do CLOB da memória
    dbms_lob.close(vr_xml);
    dbms_lob.freetemporary(vr_xml);
    dbms_lob.close(vr_xmltxt);
    dbms_lob.freetemporary(vr_xmltxt);

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
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

    WHEN vr_exc_erro THEN
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
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      -- Efetuar rollback
      ROLLBACK;
  END;
END PC_CRPS288;
/

