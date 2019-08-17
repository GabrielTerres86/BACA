DECLARE
  vr_vlpagmto NUMBER;
  
  -- Constantes
  vr_cdhistordsct_iofspriadic    CONSTANT craphis.cdhistor%TYPE := 2320; --IOF S/ DESCONTO DE TITULOS (PRINCIPAL E ADICIONAL)
  vr_cdhistordsct_iofscomplem    CONSTANT craphis.cdhistor%TYPE := 2321; --IOF S/ DESCONTO DE TITULOS (COMPLEMENTAR)
  vr_cdhistordsct_credito        CONSTANT craphis.cdhistor%TYPE := 2664; --CREDITO DESCONTO DE TITULO
  vr_cdhistordsct_liberacred     CONSTANT craphis.cdhistor%TYPE := 2665; --LIBERACAO DO CREDITO DESCONTO DE TITULO
  vr_cdhistordsct_rendaapropr    CONSTANT craphis.cdhistor%TYPE := 2666; --RENDA A APROPRIAR SOBRE DESCONTO DE TITULO
  vr_cdhistordsct_apropjurrem    CONSTANT craphis.cdhistor%TYPE := 2667; --APROPR. JUROS REMUNERATORIOS DESCONTO DE TITULO
  vr_cdhistordsct_apropjurmra    CONSTANT craphis.cdhistor%TYPE := 2668; --APROPR. JUROS DE MORA DESCONTO DE TITULO
  vr_cdhistordsct_apropjurmta    CONSTANT craphis.cdhistor%TYPE := 2669; --APROPR. MULTA DESCONTO DE TITULO
  vr_cdhistordsct_pgtocc         CONSTANT craphis.cdhistor%TYPE := 2670; --PAGTO DESCONTO DE TITULO (conta cooperado)
  vr_cdhistordsct_pgtoopc        CONSTANT craphis.cdhistor%TYPE := 2671; --PAGTO DESCONTO DE TITULO (operacao credito)
  vr_cdhistordsct_pgtocompe      CONSTANT craphis.cdhistor%TYPE := 2672; --PAGTO DESCONTO TITULO VIA COMPE
  vr_cdhistordsct_pgtocooper     CONSTANT craphis.cdhistor%TYPE := 2673; --PAGTO DESCONTO DE TITULO VIA COOPERATIVA (Caixa/IB/TAA)
  vr_cdhistordsct_pgtoavalcc     CONSTANT craphis.cdhistor%TYPE := 2674; --PAGTO DESCONTO DE TITULO AVAL  (conta cooperado)
  vr_cdhistordsct_pgtoavalopc    CONSTANT craphis.cdhistor%TYPE := 2675; --PAGTO DESCONTO DE TITULO AVAL  (operacao credito)
  vr_cdhistordsct_resgatetitdsc  CONSTANT craphis.cdhistor%TYPE := 2678; -- RESGATE DE TÍTULO DESCONTADO
  vr_cdhistordsct_rendapgtoant   CONSTANT craphis.cdhistor%TYPE := 2680; --RENDA SOBRE PGTO ANTECIPADO DESCONTO DE TITULO (conta cooperado)
  vr_cdhistordsct_pgtomultacc    CONSTANT craphis.cdhistor%TYPE := 2681; --PAGTO DE MULTA SOBRE DESCONTO DE TITULO (conta cooperado)
  vr_cdhistordsct_pgtomultaopc   CONSTANT craphis.cdhistor%TYPE := 2682; --PAGTO DE MULTA SOBRE DESCONTO DE TITULO (operacao credito)
  vr_cdhistordsct_pgtomultaavcc  CONSTANT craphis.cdhistor%TYPE := 2683; --PAGTO DE MULTA SOBRE DESCONTO DE TITULO AVAL (conta cooperado)
  vr_cdhistordsct_pgtomultaavopc CONSTANT craphis.cdhistor%TYPE := 2684; --PAGTO DE MULTA SOBRE DESCONTO DE TITULO AVAL (operacao credito)
  vr_cdhistordsct_pgtojuroscc    CONSTANT craphis.cdhistor%TYPE := 2685; --PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO (conta cooperado)
  vr_cdhistordsct_pgtojurosopc   CONSTANT craphis.cdhistor%TYPE := 2686; --PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO (operacao credito)
  vr_cdhistordsct_pgtojurosavcc  CONSTANT craphis.cdhistor%TYPE := 2687; --PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO AVAL (conta cooperado)
  vr_cdhistordsct_pgtojurosavopc CONSTANT craphis.cdhistor%TYPE := 2688; --PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO AVAL (operacao credito)
  vr_cdhistordsct_credpagmaior   CONSTANT craphis.cdhistor%TYPE := 2758; --CREDITO DESCONTO DE TITULO PAGO A MAIOR (pagamento dentro da cooperativa)
  vr_cdhistordsct_credpagmaiorIF CONSTANT craphis.cdhistor%TYPE := 2790; --CREDITO DESCONTO DE TITULO PAGO A MAIOR (pagamento em outra IF / COMPE)
  vr_cdhistordsct_jratuprejuz    CONSTANT craphis.cdhistor%TYPE := 2763; --JUROS DE ATUALIZAÇÃO PREJUIZO S/DESCONTO DE TITULO
  vr_cdhistordsct_sumjratuprejuz CONSTANT craphis.cdhistor%TYPE := 2798; --SOMATORIO DOS JUROS DE ATUALIZAÇÃO PREJUIZO S/DESCONTO DE TITULO
  vr_cdhistordsct_credabonodscto CONSTANT craphis.cdhistor%TYPE := 2799; --ABONO DESCONTO DE TITULO (BOLETAGEM MASSIVA)
  vr_cdhistordsct_deboppagmaior  CONSTANT craphis.cdhistor%TYPE := 2804; --AJUSTE DE VALOR A MAIOR DO PAGAMENTO
  vr_cdhistordsct_iofcompleoper  CONSTANT craphis.cdhistor%TYPE := 2800; --DEBITO DE IOF COMPLEMENTAR NA OPERACAO
  -- Estorno
  vr_cdhistorlcm_pgto            CONSTANT craphis.cdhistor%TYPE := 2805; -- LCM --  EST.PAGAMENTO  ESTORNO DE PAGAMENTO DESCONTO DE TITULO  ESTORNO PGTO DESC.TIT   -- Estorno da 2670
  vr_cdhistorlcm_multa           CONSTANT craphis.cdhistor%TYPE := 2806; -- LCM --  EST.MULTA  ESTORNO DE PAGAMENTO MULTA DESCONTO DE TITULO  ESTORNO MULTA DESC.   -- Estorno da 2681
  vr_cdhistorlcm_juros           CONSTANT craphis.cdhistor%TYPE := 2807; -- LCM --  EST.JUROS  ESTORNO DE PAGAMENTO JUROS MORA DESCONTO DE TITULO  ESTORNO JUROS DESC.   -- Estorno da 2685
  vr_cdhistorlcm_pgto_ava        CONSTANT craphis.cdhistor%TYPE := 2808; -- LCM --  EST.PGTO AVAL  ESTORNO DE PAGAMENTO DESCONTO DE TITULO AVAL  ESTORNO PGTO DESC.TIT   -- Estorno da 2674
  vr_cdhistorlcm_multa_ava       CONSTANT craphis.cdhistor%TYPE := 2809; -- LCM --  EST.MULTA  ESTORNO DE PAGAMENTO MULTA DESCONTO DE TITULO AVAL  ESTORNO MULTA DESC.   -- Estorno da 2683
  vr_cdhistorlcm_juros_ava       CONSTANT craphis.cdhistor%TYPE := 2810; -- LCM --  EST.JUROS  ESTORNO DE PGTO JUROS MORA DESCONTO DE TITULO AVAL  ESTORNO JUROS DESC.   -- Estorno da 2687
  vr_cdhistordsct_est_pgto       CONSTANT craphis.cdhistor%TYPE := 2811; --  EST.PAGAMENTO  ESTORNO DE PAGAMENTO DESCONTO DE TITULO  ESTORNO PGTO DESC.TIT  2671
  vr_cdhistordsct_est_multa      CONSTANT craphis.cdhistor%TYPE := 2812; --  EST. MULTA  ESTORNO DE PAGAMENTO MULTA DESCONTO DE TITULO  ESTORNO MULTA DESC.  2682
  vr_cdhistordsct_est_juros      CONSTANT craphis.cdhistor%TYPE := 2813; --  EST.JUROS  ESTORNO DE PAGAMENTO JUROS MORA DESCONTO DE TITULO  ESTORNO JUROS DESC.  2686
  vr_cdhistordsct_est_pgto_ava   CONSTANT craphis.cdhistor%TYPE := 2814; --  EST.PGTO AVAL  ESTORNO DE PAGAMENTO DESCONTO DE TITULO AVAL  ESTORNO PGTO DESC.TIT  2675
  vr_cdhistordsct_est_multa_ava  CONSTANT craphis.cdhistor%TYPE := 2815; --  EST. MULTA  ESTORNO DE PAGAMENTO MULTA DESCONTO DE TITULO AVAL  ESTORNO MULTA DESC.  2684
  vr_cdhistordsct_est_juros_ava  CONSTANT craphis.cdhistor%TYPE := 2816; --  EST.JUROS  ESTORNO DE PGTO JUROS MORA DESCONTO DE TITULO AVAL  ESTORNO JUROS DESC.  2688
  vr_cdhistordsct_est_apro_multa CONSTANT craphis.cdhistor%TYPE := 2880; --  ESTORNO APROPRIACAO DE MULTA - EST.PAGTO
  vr_cdhistordsct_est_apro_juros CONSTANT craphis.cdhistor%TYPE := 2881; --  ESTORNO APROPRIACAO DE JUROS DE MORA - EST.PAGTO

  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
  
  -- Busca dos dados do associado
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0
                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE DEFAULT 0) IS
   SELECT crapass.cdcooper
         ,crapass.nrdconta
         ,crapass.inpessoa
         ,crapass.vllimcre
         ,crapass.nmprimtl
         ,crapass.nrcpfcgc
         ,crapass.dtdemiss
         ,crapass.inadimpl
     FROM crapass
    WHERE crapass.cdcooper = pr_cdcooper
      AND crapass.nrdconta = DECODE(pr_nrdconta,0,crapass.nrdconta,pr_nrdconta)
      AND crapass.nrcpfcgc = DECODE(pr_nrcpfcgc,0,crapass.nrcpfcgc,pr_nrcpfcgc);
  rw_crapass cr_crapass%ROWTYPE;
  
  
  
  PROCEDURE pc_pagar_titulo_operacao ( pr_cdcooper    IN crapcop.cdcooper%TYPE           --Codigo Cooperativa
                            ,pr_cdagenci    IN INTEGER                         --Codigo Agencia
                            ,pr_nrdcaixa    IN INTEGER                         --Numero Caixa
                            ,pr_idorigem    IN INTEGER                         --Origem sistema
                            ,pr_cdoperad    IN VARCHAR2                        --Codigo operador
                            ,pr_nrdconta    IN craptdb.nrdconta%TYPE           --Número da conta do cooperado
                            ,pr_nrborder    IN craptdb.nrborder%TYPE           --Número do borderô
                            ,pr_cdbandoc    IN craptdb.cdbandoc%TYPE           --Codigo do banco impresso no boleto
                            ,pr_nrdctabb    IN craptdb.nrdctabb%TYPE           --Numero da conta base do titulo
                            ,pr_nrcnvcob    IN craptdb.nrcnvcob%TYPE           --Numero do convenio de cobranca
                            ,pr_nrdocmto    IN craptdb.nrdocmto%TYPE           --Numero do documento
                            ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE           --Data Movimento
                            ,pr_inproces    IN crapdat.inproces%TYPE DEFAULT 1 --Indicador do processo
                            ,pr_indpagto    IN crapcob.indpagto%TYPE DEFAULT 0 --Indica de onde vem o pagamento
                            ,pr_vlpagmto    IN OUT NUMBER                      --Valor do pagamento
                            ,pr_cdcritic    OUT INTEGER                        --Codigo Critica
                            ,pr_dscritic    OUT VARCHAR2) IS
                            
  /* ................................................................................
     Programa: pc_pagar_titulo_operacao
     Sistema : Crédito
     Sigla   : CRED

     Autor   : Luis Fernando (GFT)
     Data    : 01/11/2018

     Dados referentes ao programa:
     Frequencia: Sempre que for chamado
     Objetivo  :  Realiza o pagamento de um título através do processamento de importacao da 538

     Alterações: 
                 27/11/2018 - Adicionado pagamento de juros60 para futuras contabilizacoes de prejuizo (Luis Fernando - GFT)
  ..................................................................................*/
    vr_dtmvtolt DATE;
    
    -- CURSORES
    CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%type
                      ,pr_nrborder IN crapbdt.nrborder%type) IS
      SELECT crapbdt.txmensal,
             crapbdt.flverbor,
             crapbdt.vltaxiof,
             crapbdt.vltxmult,
             crapbdt.vltxmora,
             crapbdt.inprejuz
        FROM crapbdt
       WHERE crapbdt.cdcooper = pr_cdcooper
         AND crapbdt.nrborder = pr_nrborder;
    rw_crapbdt cr_crapbdt%ROWTYPE;

    -- Sumarizar os juros no desconto do cheque
    CURSOR cr_craptdb_total(pr_cdcooper IN craptdb.cdcooper%TYPE
                           ,pr_nrdconta IN craptdb.nrdconta%TYPE
                           ,pr_nrborder IN craptdb.nrborder%TYPE) IS
      SELECT NVL(SUM(craptdb.vlliquid),0)
        FROM craptdb
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrborder = pr_nrborder;
    vr_vltotal_liquido craptdb.vlliquid%TYPE;

    CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN craptdb.nrdconta%TYPE
                     ,pr_nrborder IN craptdb.nrborder%TYPE
                     ,pr_cdbandoc IN craptdb.cdbandoc%TYPE
                     ,pr_nrdctabb IN craptdb.nrdctabb%TYPE
                     ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE
                     ,pr_nrdocmto IN craptdb.nrdocmto%TYPE) IS
      SELECT ROWID,
             craptdb.nrdocmto,
             craptdb.dtvencto,
             craptdb.dtlibbdt,
             craptdb.nrtitulo,
             craptdb.vltitulo,
             craptdb.vlsldtit,
             craptdb.vliofcpl,
             craptdb.vlmtatit,
             craptdb.vlmratit,
             craptdb.vlpagiof,
             craptdb.vlpagmta,
             craptdb.vlpagmra,
             craptdb.vlsldtit + (craptdb.vliofcpl - craptdb.vlpagiof) +
             (craptdb.vlmtatit - craptdb.vlpagmta) + (craptdb.vlmratit - craptdb.vlpagmra) AS vltitulo_total,
             (craptdb.vliofcpl - craptdb.vlpagiof) AS vliofcpl_restante,
             (craptdb.vlmtatit - craptdb.vlpagmta) AS vlmtatit_restante,
             (craptdb.vlmratit - craptdb.vlpagmra) AS vlmratit_restante,
             (craptdb.vljura60 - craptdb.vlpgjm60) AS vljura60_restante
        FROM craptdb
       WHERE craptdb.cdcooper = pr_cdcooper
         AND craptdb.nrdconta = pr_nrdconta
         AND craptdb.nrborder = pr_nrborder
         AND craptdb.cdbandoc = pr_cdbandoc
         AND craptdb.nrdctabb = pr_nrdctabb
         AND craptdb.nrcnvcob = pr_nrcnvcob
         AND craptdb.nrdocmto = pr_nrdocmto
         AND craptdb.insittit = 4;
    rw_craptdb cr_craptdb%ROWTYPE;

    CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE
                     ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
     SELECT crapjur.natjurid
           ,crapjur.tpregtrb
       FROM crapjur
      WHERE crapjur.cdcooper = pr_cdcooper
        AND crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;

    CURSOR cr_lancboraprop(pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                          ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                          ,pr_nrborder IN crapbdt.nrborder%TYPE --> numero do bordero
                          ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                          ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo do historico do lancamento
                          ,pr_cdbandoc IN craptdb.cdbandoc%TYPE --> Codigo do banco impresso no boleto
                          ,pr_nrdctabb IN craptdb.nrdctabb%TYPE --> Numero da conta base do titulo
                          ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE --> Numero do convenio de cobranca
                          ,pr_nrdocmto IN craptdb.nrdocmto%TYPE --> Numero do documento
                          ) IS
    SELECT SUM(lcb.vllanmto) vllanmto
      FROM tbdsct_lancamento_bordero lcb
     WHERE lcb.cdcooper = pr_cdcooper
       AND lcb.nrdconta = pr_nrdconta
       AND lcb.nrborder = pr_nrborder
       AND lcb.cdbandoc = pr_cdbandoc
       AND lcb.nrdctabb = pr_nrdctabb
       AND lcb.nrcnvcob = pr_nrcnvcob
       AND lcb.nrdocmto = pr_nrdocmto
       AND lcb.cdhistor = pr_cdhistor
       AND lcb.dtmvtolt <= pr_dtmvtolt;
    rw_lancboraprop cr_lancboraprop%ROWTYPE;
    
    -- TYPES
    TYPE typ_dados_tarifa IS RECORD
      (cdfvlcop crapcop.cdcooper%TYPE
      ,cdhistor craphis.cdhistor%TYPE
      ,vlrtarif NUMBER
      ,vltottar NUMBER);

    -- VARIÁVEIS LOCAIS
    vr_cdbattar     VARCHAR2(1000);
    vr_cdhisest     INTEGER;
    vr_dtdivulg     DATE;
    vr_dtvigenc     DATE;

    vr_rowid_craplat  ROWID;

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    vr_tab_erro GENE0001.typ_tab_erro; --Tabela de erros
    vr_des_erro VARCHAR2(10);

    vr_vlsldtit NUMBER; -- Saldo devedor atual do título
    vr_vlpagmto NUMBER; -- Valor disponível para pagamento do título

    vr_flbaixar BOOLEAN; -- Indica se o título deve sofrer baixa ou não
    --vr_flraspar BOOLEAN; -- Indica se o processo de raspada deve continuar ou não

    vr_vliofpri NUMBER; -- Valor do IOF principal
    vr_vliofadi NUMBER; -- Valor do IOF adicional
    vr_vliofcpl NUMBER; -- Valor do IOF complementar

    vr_vlpagiof NUMBER; -- Valor pago do IOF complementar
    vr_vlpagmta NUMBER; -- Valor pago da multa
    vr_vlpagmra NUMBER; -- Valor pago dos juros de mora
    vr_vlpagtit NUMBER; -- Valor pago do título
    vr_vlpagm60 NUMBER; -- Valor pago do juros 60

    vr_insittit craptdb.insittit%TYPE;
    --vr_dtdebito craptdb.dtdebito%TYPE;
    vr_dtdpagto craptdb.dtdpagto%TYPE;

    vr_cdhistor_opc INTEGER; -- Histórico de lançamento do titulo

    vr_vltxiofatra NUMBER;

    vr_dados_tarifa typ_dados_tarifa;

    vr_flgimune PLS_INTEGER;

    --vr_cdpesqbb     VARCHAR2(1000);

    vr_dtmvtolt_lcm craplcm.dtmvtolt%TYPE;
    vr_cdagenci_lcm craplcm.cdagenci%TYPE;
    vr_cdbccxlt_lcm craplcm.cdbccxlt%TYPE;
    vr_nrdolote_lcm craplcm.nrdolote%TYPE;
    --vr_nrseqdig_lcm craplcm.nrseqdig%TYPE;

    -- EXCEÇÕES
    vr_exc_erro  EXCEPTION;

    /* FUNÇÕES */

    --Verifica se eh titulo de cobranca com registro
    FUNCTION fn_verifica_cobranca_reg(pr_cdcooper  crapcop.cdcooper%TYPE
                                     ,pr_nrcnvcob  crapcco.nrconven%TYPE) RETURN BOOLEAN IS
      CURSOR cr_crapcco(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrconven crapcco.nrconven%TYPE) IS
        SELECT 1
          FROM crapcco cco
         WHERE cco.cdcooper = pr_cdcooper
           AND cco.nrconven = pr_nrconven
           AND cco.flgregis = 1;
      rw_crapcco cr_crapcco%ROWTYPE;
    BEGIN

      OPEN cr_crapcco(pr_cdcooper => pr_cdcooper
                     ,pr_nrconven => pr_nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;

      IF cr_crapcco%NOTFOUND THEN
         CLOSE cr_crapcco;
         RETURN FALSE;
      END IF;

      CLOSE cr_crapcco;
      RETURN TRUE;
    END fn_verifica_cobranca_reg;

  BEGIN
    --Verifica se a conta existe
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9; --Associado n cadastrado: --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;

    -- Busca dados de pessoa jurídica
    OPEN cr_crapjur(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapjur INTO rw_crapjur;
    CLOSE cr_crapjur;

    -- Valida a existência do título
    OPEN cr_craptdb (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrborder => pr_nrborder
                    ,pr_cdbandoc => pr_cdbandoc
                    ,pr_nrdctabb => pr_nrdctabb
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_nrdocmto => pr_nrdocmto);
    FETCH cr_craptdb INTO rw_craptdb;

    IF cr_craptdb%NOTFOUND THEN
      CLOSE cr_craptdb;
      vr_cdcritic := 1108;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_craptdb;

    -- Valida existência do borderô do respectivo título
    OPEN cr_crapbdt (pr_cdcooper => pr_cdcooper
                    ,pr_nrborder => pr_nrborder);
    FETCH cr_crapbdt INTO rw_crapbdt;

    IF cr_crapbdt%NOTFOUND THEN
      vr_cdcritic := 1166; --Bordero nao encontrado. Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      CLOSE cr_crapbdt;
    RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapbdt;

    vr_flbaixar := FALSE;

    vr_vlpagmto := pr_vlpagmto;
    
    SELECT dtmvtolt into vr_dtmvtolt from crapdat where cdcooper = pr_cdcooper;
    
    vr_vlpagiof := 0;
    vr_vlpagmta := 0;
    vr_vlpagmra := 0;
    vr_vlsldtit := rw_craptdb.vlsldtit;
    vr_vlpagtit := 0;
    vr_vlpagm60 := 0;

    -- 0) Crédito na operação 
    IF pr_indpagto = 0 THEN
      vr_cdhistor_opc := vr_cdhistordsct_pgtocompe; -- Compe
    ELSE
      vr_cdhistor_opc := vr_cdhistordsct_pgtocooper; -- Caixa/IB/TAA
    END IF;
    
    -- Adiciona o crédito do pagamento na operação 
    -- Lançar valor total do crédito do da operação título nos lançamentos do borderô
    DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrborder => pr_nrborder
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_cdbandoc => pr_cdbandoc
                                 ,pr_nrdctabb => pr_nrdctabb
                                 ,pr_nrcnvcob => pr_nrcnvcob
                                 ,pr_nrdocmto => pr_nrdocmto
                                 ,pr_nrtitulo => rw_craptdb.nrtitulo
                                 ,pr_cdorigem => pr_idorigem
                                 ,pr_cdhistor => vr_cdhistor_opc
                                 ,pr_vllanmto => vr_vlpagmto
                                 ,pr_dscritic => vr_dscritic );
    -- Condicao para verificar se houve critica
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    dbms_output.put_line('* (Operação) Histórico: ' || vr_cdhistor_opc || ', Valor:  ' || vr_vlpagmto || ', Data: ' || pr_dtmvtolt);
      
    -- 1) IOF

    vr_vltotal_liquido := 0;
    OPEN cr_craptdb_total(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrborder => pr_nrborder);
    FETCH cr_craptdb_total INTO vr_vltotal_liquido;
    CLOSE cr_craptdb_total;

    TIOF0001.pc_calcula_valor_iof_prg (pr_tpproduto            => 2 -- Desconto de títulos
                                      ,pr_tpoperacao           => 2 -- Pagamento em atraso
                                      ,pr_cdcooper             => pr_cdcooper
                                      ,pr_nrdconta             => pr_nrdconta
                                      ,pr_inpessoa             => rw_crapass.inpessoa
                                      ,pr_natjurid             => rw_crapjur.natjurid
                                      ,pr_tpregtrb             => rw_crapjur.tpregtrb
                                      ,pr_dtmvtolt             => pr_dtmvtolt
                                      ,pr_qtdiaiof             => 0
                                      ,pr_vloperacao           => (rw_craptdb.vlsldtit + rw_craptdb.vlmratit_restante)
                                      ,pr_vltotalope           => vr_vltotal_liquido
                                      ,pr_vltaxa_iof_atraso    => NVL(rw_crapbdt.vltaxiof,0)
                                      ,pr_vliofpri             => vr_vliofpri
                                      ,pr_vliofadi             => vr_vliofadi
                                      ,pr_vliofcpl             => vr_vliofcpl
                                      ,pr_vltaxa_iof_principal => vr_vltxiofatra
                                      ,pr_flgimune             => vr_flgimune
                                      ,pr_dscritic             => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro realizar cálculo do IOF em atraso : '||SQLERRM;
      RAISE vr_exc_erro;
    END IF;
    
    IF rw_craptdb.vliofcpl_restante > 0 AND vr_vlpagmto > 0 AND vr_flgimune <= 0 THEN
      IF rw_craptdb.vliofcpl_restante > vr_vlpagmto THEN
        vr_vlpagiof := vr_vlpagmto;
        --vr_flraspar := FALSE;
      ELSE
        vr_vlpagiof := rw_craptdb.vliofcpl_restante;
      END IF;

      vr_vlpagmto := vr_vlpagmto - vr_vlpagiof;
      
      -- Lançar valor da operação do IOF
      DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => pr_idorigem
                                   ,pr_cdhistor => vr_cdhistordsct_iofcompleoper
                                   ,pr_vllanmto => vr_vlpagiof
                                   ,pr_dscritic => vr_dscritic );
      
      dbms_output.put_line('* (Operação) Histórico: ' || vr_cdhistordsct_iofcompleoper || ', Valor:  ' || vr_vlpagiof || ', Data: ' || pr_dtmvtolt);
    
      
      -- Insere dados do iof para o BI                             
      TIOF0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                            ,pr_nrdconta     => pr_nrdconta
                            ,pr_dtmvtolt     => pr_dtmvtolt
                            ,pr_tpproduto    => 2   --> Desconto de Titulo
                            ,pr_nrcontrato   => pr_nrborder
                            ,pr_dtmvtolt_lcm => vr_dtmvtolt_lcm
                            ,pr_cdagenci_lcm => vr_cdagenci_lcm
                            ,pr_cdbccxlt_lcm => vr_cdbccxlt_lcm
                            ,pr_nrdolote_lcm => vr_nrdolote_lcm
                            ,pr_nrseqdig_lcm => rw_craptdb.nrtitulo
                            ,pr_vliofcpl     => vr_vlpagiof
                            ,pr_flgimune     => vr_flgimune -- Merge 1 - 15/02/2018 - Chamado 851591
                            ,pr_cdcritic     => vr_cdcritic
                            ,pr_dscritic     => vr_dscritic);

      -- Condicao para verificar se houve critica
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- 2) Multa
    IF rw_craptdb.vlmtatit_restante > 0 AND vr_vlpagmto > 0 THEN
      IF rw_craptdb.vlmtatit_restante > vr_vlpagmto THEN
        vr_vlpagmta := vr_vlpagmto;
      ELSE
        vr_vlpagmta := rw_craptdb.vlmtatit_restante;
      END IF;

      vr_vlpagmto := vr_vlpagmto - vr_vlpagmta;
      

      -- Lançar valor de apropriação da multa nos lançamentos do borderô
      DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => pr_idorigem
                                   ,pr_cdhistor => vr_cdhistordsct_apropjurmta
                                   ,pr_vllanmto => vr_vlpagmta
                                   ,pr_dscritic => vr_dscritic );
      
      dbms_output.put_line('* (Operação) Histórico: ' || vr_cdhistordsct_apropjurmta || ', Valor:  ' || vr_vlpagmta || ', Data: ' || pr_dtmvtolt);
    

      -- Condicao para verificar se houve critica
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- 3) Juros
    IF rw_craptdb.vlmratit_restante > 0 AND vr_vlpagmto > 0 THEN
      --Faz o pagamento do juros 60 (apenas no campo) para fazer a diferenciacao contabil em prejuizo
      --vljura60
      IF (rw_craptdb.vljura60_restante > vr_vlpagmto) THEN
        vr_vlpagm60 := vr_vlpagmto;
      ELSE
        vr_vlpagm60 := rw_craptdb.vljura60_restante;
      END IF;
      vr_vlpagmto := vr_vlpagmto - vr_vlpagm60;
      
      rw_craptdb.vlmratit_restante := rw_craptdb.vlmratit_restante - vr_vlpagm60;

      IF rw_craptdb.vlmratit_restante > vr_vlpagmto THEN
        vr_vlpagmra := vr_vlpagmto;
      ELSE
        vr_vlpagmra := rw_craptdb.vlmratit_restante;
      END IF;

      vr_vlpagmto := vr_vlpagmto - vr_vlpagmra;
      

      OPEN cr_lancboraprop(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrborder => pr_nrborder
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurmra
                          ,pr_cdbandoc => pr_cdbandoc
                          ,pr_nrdctabb => pr_nrdctabb
                          ,pr_nrcnvcob => pr_nrcnvcob
                          ,pr_nrdocmto => pr_nrdocmto
                          );
      FETCH cr_lancboraprop INTO rw_lancboraprop;
      CLOSE cr_lancboraprop;
      
      -- Lançar valor de apropriação dos juros nos lançamentos do borderô
      DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => pr_idorigem
                                   ,pr_cdhistor => vr_cdhistordsct_apropjurmra
                                   ,pr_vllanmto => (rw_craptdb.vlmratit - nvl(rw_lancboraprop.vllanmto,0))
                                   ,pr_dscritic => vr_dscritic );
                                   
      dbms_output.put_line('* (Operação) Histórico: ' || vr_cdhistordsct_apropjurmra || ', Valor:  ' || (rw_craptdb.vlmratit - nvl(rw_lancboraprop.vllanmto,0)) || ', Data: ' || pr_dtmvtolt);
    

      -- Condicao para verificar se houve critica
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

    -- 4) Valor do título
    IF rw_craptdb.vlsldtit > 0 AND vr_vlpagmto > 0 THEN
      IF rw_craptdb.vlsldtit > vr_vlpagmto THEN
        vr_vlpagtit := vr_vlpagmto;
        vr_vlsldtit := rw_craptdb.vlsldtit - vr_vlpagmto;
      ELSE
        vr_vlpagtit := rw_craptdb.vlsldtit;
        vr_vlsldtit := 0;
        vr_flbaixar := TRUE;
      END IF;

      vr_vlpagmto := vr_vlpagmto - vr_vlpagtit;

      -- Se a data de vencimento for maior que a data de pagamento, significa um pagamento adiantado, então
      -- realizar o lançamento de estorno na conta do cooperador dos juros cobrados até o vencimento
      IF rw_craptdb.dtvencto >= pr_dtmvtolt AND vr_flbaixar THEN
        dsct0001.pc_abatimento_juros_titulo(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrborder => pr_nrborder
                                           ,pr_cdbandoc => pr_cdbandoc
                                           ,pr_nrdctabb => pr_nrdctabb
                                           ,pr_nrcnvcob => pr_nrcnvcob
                                           ,pr_nrdocmto => pr_nrdocmto
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdagenci => pr_cdagenci -- apenas para o produto novo
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_cdorigpg => 1 -- operacao de credito
                                           ,pr_dtdpagto => pr_dtmvtolt
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic );
        -- Condicao para verificar se houve critica
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    END IF;

    -- se o valor pago do boleto for maior que o saldo restante,
    IF (vr_vlpagmto > 0) THEN
      -- Faz o débito na operação do crédito que foi dado para o cooperado
      DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => pr_idorigem
                                   ,pr_cdhistor => vr_cdhistordsct_deboppagmaior
                                   ,pr_vllanmto => vr_vlpagmto
                                   ,pr_dscritic => vr_dscritic );
      -- Condicao para verificar se houve critica
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      dbms_output.put_line('* (Operação) Histórico: ' || vr_cdhistordsct_deboppagmaior || ', Valor:  ' || vr_vlpagmto || ', Data: ' || pr_dtmvtolt);
    
      
      -- então lançar o saldo restante como crédito na conta corrente do cooperado
      DSCT0003.pc_efetua_lanc_cc(pr_dtmvtolt => vr_dtmvtolt
                       ,pr_cdagenci => pr_cdagenci
                       ,pr_cdbccxlt => 100
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_vllanmto => vr_vlpagmto
                       ,pr_cdhistor => vr_cdhistordsct_credpagmaior
                       ,pr_cdcooper => pr_cdcooper
                       ,pr_cdoperad => pr_cdoperad
                       ,pr_nrborder => pr_nrborder
                       ,pr_cdpactra => 0
                       ,pr_nrdocmto => rw_craptdb.nrdocmto
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
      -- Condicao para verificar se houve critica
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      dbms_output.put_line('* (LCM) Histórico: ' || vr_cdhistordsct_credpagmaior || ', Valor:  ' || vr_vlpagmto || ', Data: ' || vr_dtmvtolt);
    
      
    END IF;

    pr_vlpagmto := vr_vlpagmto;

    -- chama a rotina de baixa do titulo
    vr_dtdpagto := null;
    IF vr_flbaixar THEN
        vr_insittit := 2;
        vr_dtdpagto := pr_dtmvtolt;
    ELSE
      vr_insittit := 4;
    END IF;

    BEGIN
      -- Atualiza as informações do título
      UPDATE craptdb
         SET craptdb.insittit = vr_insittit,
             craptdb.vlpagiof = craptdb.vlpagiof + vr_vlpagiof,
             craptdb.vlpagmta = craptdb.vlpagmta + vr_vlpagmta,
             craptdb.vlpagmra = craptdb.vlpagmra + vr_vlpagmra + vr_vlpagm60,
             craptdb.vlsldtit = vr_vlsldtit,
             craptdb.dtdpagto = nvl(vr_dtdpagto,craptdb.dtdpagto),
             craptdb.vlultmra = craptdb.vlmratit,
             craptdb.dtultpag = pr_dtmvtolt,
             craptdb.vlpgjm60 = craptdb.vlpgjm60 + vr_vlpagm60
       WHERE craptdb.rowid    = rw_craptdb.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar craptdb: '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_erro;
    END;
    
    BEGIN
      -- Atualiza as informações do borderô
      UPDATE crapbdt bdt
         SET bdt.dtultpag = pr_dtmvtolt
       WHERE bdt.cdcooper = pr_cdcooper
         AND bdt.nrdconta = pr_nrdconta
         AND bdt.nrborder = pr_nrborder;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar craptdb: '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_erro;
    END;
    
    -- se o título foi baixado
    IF vr_flbaixar THEN

      -- Define qual tipo de tarifa a ser cobrada
      IF fn_verifica_cobranca_reg(pr_cdcooper => pr_cdcooper, pr_nrcnvcob => pr_nrcnvcob) THEN
        IF rw_crapass.inpessoa = 1 THEN
          vr_cdbattar:= 'DSTTITCRPF';
        ELSE
          vr_cdbattar:= 'DSTTITCRPJ';
        END IF;
      ELSE
        IF rw_crapass.inpessoa = 1 THEN
          vr_cdbattar:= 'DSTTITSRPF';
        ELSE
          vr_cdbattar:= 'DSTTITSRPJ';
        END IF;
      END IF;

      /*  Busca valor da tarifa sem registro*/
      TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper               --Codigo Cooperativa
                                            ,pr_cdbattar  => vr_cdbattar               --Codigo Tarifa
                                            ,pr_vllanmto  => 1                         --Valor Lancamento
                                            ,pr_cdprogra  => NULL                      --Codigo Programa
                                            ,pr_cdhistor  => vr_dados_tarifa.cdhistor  --Codigo Historico
                                            ,pr_cdhisest  => vr_cdhisest               --Historico Estorno
                                            ,pr_vltarifa  => vr_dados_tarifa.vlrtarif  --Valor tarifa
                                            ,pr_dtdivulg  => vr_dtdivulg               --Data Divulgacao
                                            ,pr_dtvigenc  => vr_dtvigenc               --Data Vigencia
                                            ,pr_cdfvlcop  => vr_dados_tarifa.cdfvlcop  --Codigo faixa valor cooperativa
                                            ,pr_cdcritic  => vr_cdcritic               --Codigo Critica
                                            ,pr_dscritic  => vr_dscritic               --Descricao Critica
                                            ,pr_tab_erro  => vr_tab_erro);             --Tabela erros

      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        vr_dscritic := vr_dscritic||' pr_nrdconta:' || pr_nrdconta || ' ,pr_nrborder:' || pr_nrborder||',';
        RAISE vr_exc_erro;
      END IF;

      IF vr_dados_tarifa.vlrtarif > 0 THEN --Lancamento Tarifa Cobranca Reg PF
         /* Gera Tarifa de titulos descontados */
         TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                          ,pr_nrdconta => pr_nrdconta  --Numero da Conta
                                          ,pr_dtmvtolt => pr_dtmvtolt          --Data Lancamento
                                          ,pr_cdhistor => vr_dados_tarifa.cdhistor --Codigo Historico
                                          ,pr_vllanaut => vr_dados_tarifa.vlrtarif --Valor lancamento automatico
                                          ,pr_cdoperad => 1          --Codigo Operador
                                          ,pr_cdagenci => pr_cdagenci          --Codigo Agencia
                                          ,pr_cdbccxlt => 100                  --Codigo banco caixa
                                          ,pr_nrdolote => 8452                 --Numero do lote
                                          ,pr_tpdolote => 1                    --Tipo do lote
                                          ,pr_nrdocmto => 0                    --Numero do documento
                                          ,pr_nrdctabb => pr_nrdconta  --Numero da conta
                                          ,pr_nrdctitg => gene0002.fn_mask(pr_nrdconta,'99999999') --Numero da conta integracao
                                          ,pr_cdpesqbb => pr_nrdocmto          --Codigo pesquisa
                                          ,pr_cdbanchq => 0                    --Codigo Banco Cheque
                                          ,pr_cdagechq => 0                    --Codigo Agencia Cheque
                                          ,pr_nrctachq => 0                    --Numero Conta Cheque
                                          ,pr_flgaviso => FALSE                --Flag aviso
                                          ,pr_tpdaviso => 0                    --Tipo aviso
                                          ,pr_cdfvlcop => vr_dados_tarifa.cdfvlcop --Codigo cooperativa
                                          ,pr_inproces => pr_inproces  --Indicador processo
                                          ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                          ,pr_tab_erro => vr_tab_erro          --Tabela retorno erro
                                          ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                          ,pr_dscritic => vr_dscritic);        --Descricao Critica
         --Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           vr_dscritic := vr_dscritic||' pr_nrdconta:' || pr_nrdconta || ' ,pr_nrborder:' || pr_nrborder||',';
           RAISE vr_exc_erro;
         END IF;

       END IF;

      -- Verifica se deve liquidar o bordero caso sim Liquida
      DSCT0001.pc_efetua_liquidacao_bordero (pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                            ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                            ,pr_nrdcaixa => pr_nrdcaixa  --Numero do Caixa
                                            ,pr_cdoperad => pr_cdoperad  --Codigo Operador
                                            ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                            ,pr_idorigem => pr_idorigem  --Identificador Origem
                                            ,pr_nrdconta => pr_nrdconta  --Numero da Conta
                                            ,pr_nrborder => pr_nrborder  --Numero do Bordero
                                            ,pr_tab_erro => vr_tab_erro   --Tabela de erros
                                            ,pr_des_erro => vr_des_erro   --identificador de erro
                                            ,pr_cdcritic => vr_cdcritic   --Código do erro
                                            ,pr_dscritic => vr_dscritic); --Descricao do erro;

      IF NVL(LENGTH(TRIM(vr_dscritic)),0) > 0 THEN -- Merge 02/05/2018 - Chamado 851591
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 -- Sequencia
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
      END IF;

      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        vr_dscritic := vr_dscritic||' pr_nrdconta:' || pr_nrdconta || ' ,pr_nrborder:' || pr_nrborder||',';
        RAISE vr_exc_erro;
      END IF;

    END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
      vr_cdcritic := NVL(vr_cdcritic, 0);
      IF vr_cdcritic > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
            
    --END;
  END pc_pagar_titulo_operacao;
  
  
  
BEGIN
  vr_vlpagmto := 438.10; 

  pc_pagar_titulo_operacao(pr_cdcooper => 14
                          ,pr_cdagenci => 5
                          ,pr_nrdcaixa => 100
                          ,pr_idorigem => 5
                          ,pr_cdoperad => '1'
                          ,pr_nrdconta => 5916
                          ,pr_nrborder => 38104
                          ,pr_cdbandoc => 85
                          ,pr_nrdctabb => 113004
                          ,pr_nrcnvcob => 113004
                          ,pr_nrdocmto => 1329
                          ,pr_dtmvtolt => to_date('27/05/2019','DD/MM/RRRR')
                          ,pr_inproces => NULL
                          ,pr_indpagto => 1
                          ,pr_vlpagmto => vr_vlpagmto
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic );
  -- Condicao para verificar se houve critica                             
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;
  COMMIT;
    
END;
