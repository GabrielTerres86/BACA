DECLARE
  
  --Tipo de Tabela de lancamentos de juros dos titulos
  TYPE typ_crawljt IS RECORD (
    nrdconta crapljt.nrdconta%TYPE,
    nrborder crapljt.nrborder%TYPE,
    nrctrlim crapljt.nrctrlim%TYPE,
    dtrefere crapljt.dtrefere%TYPE,
    dtmvtolt crapljt.dtmvtolt%TYPE,
    vldjuros NUMBER,
    vlrestit crapljt.vlrestit%TYPE,
    cdcooper crapljt.cdcooper%TYPE,
    cdbandoc crapljt.cdbandoc%TYPE,
    nrdctabb crapljt.nrdctabb%TYPE,
    nrcnvcob crapljt.nrcnvcob%TYPE,
    nrdocmto crapljt.nrdocmto%TYPE );

  TYPE typ_tab_crawljt IS TABLE OF typ_crawljt INDEX BY PLS_INTEGER;

  --Tabela de lancamentos de juros dos titulos
  vr_tab_crawljt typ_tab_crawljt;
  vr_tab_erro GENE0001.typ_tab_erro; --Tabela de erros
  vr_des_erro VARCHAR2(10);
  
  --Buscar informacoes de lote
  CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                    ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                    ,pr_cdagenci IN craplot.cdagenci%TYPE
                    ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                    ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT  craplot.nrdolote
           ,craplot.nrseqdig
           ,craplot.cdbccxlt
           ,craplot.dtmvtolt
           ,craplot.cdagenci
           ,craplot.rowid
    FROM craplot craplot
    WHERE craplot.cdcooper = pr_cdcooper
    AND   craplot.dtmvtolt = pr_dtmvtolt
    AND   craplot.cdagenci = pr_cdagenci
    AND   craplot.cdbccxlt = pr_cdbccxlt
    AND   craplot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;
  
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
  
  CURSOR cr_iofcpl_lcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                       ,pr_nrdconta IN craplcm.nrdconta%TYPE
                       --,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                       ,pr_nrdocmto IN craplcm.nrdocmto%TYPE
                       ) IS 
    select dtmvtolt,
           vllanmto 
    from craplcm 
    where cdcooper = pr_cdcooper 
    and nrdconta = pr_nrdconta 
    and cdhistor = 2321 
    and dtmvtolt > to_date('24/04/2019','DD/MM/RRRR')
    and dtmvtolt <= (select dtmvtolt from crapdat where cdcooper = pr_cdcooper)
    and nrdocmto = pr_nrdocmto;
  rw_iofcpl_lcm cr_iofcpl_lcm%ROWTYPE;
  
  CURSOR cr_titulo IS
    SELECT a.cdagenci,
           a.inpessoa,
           c.cdcooper,
           c.nrdconta,
           t.nrborder,
           c.nrdocmto,
           c.cdbandoc,
           t.nrcnvcob,
           t.nrdctabb,
           t.nrtitulo,
           t.dtvencto,
           c.dtvencto dtvencto_cob,
           c.dtdpagto dtdpagto_cob,
           
           t.vlsldtit,
           t.dtdebito,
           t.dtdpagto dtdpagto_tdb,
           t.dtvencto dtvencto_tdb,
           
           t.vltitulo,
           t.vlliquid,
           c.vldpagto,
           c.indpagto,
       nvl((SELECT sum(l.vllanmto)
          FROM tbdsct_lancamento_bordero l
         WHERE l.cdcooper = c.cdcooper
           AND l.nrdconta = c.nrdconta
           AND l.nrborder = t.nrborder
           AND l.nrdocmto = c.nrdocmto
           AND l.cdhistor IN (2672,2673)
           AND l.dtmvtolt < c.dtdpagto),0) PGO_ANTES_COB,
       nvl((SELECT sum(l.vllanmto)
          FROM tbdsct_lancamento_bordero l
         WHERE l.cdcooper = c.cdcooper
           AND l.nrdconta = c.nrdconta
           AND l.nrborder = t.nrborder
           AND l.nrdocmto = c.nrdocmto
           AND l.cdhistor IN (2671)
           AND l.dtmvtolt < c.dtdpagto),0) PGO_ANTES_CC,
       nvl((SELECT sum(l.vllanmto)
          FROM tbdsct_lancamento_bordero l
         WHERE l.cdcooper = c.cdcooper
           AND l.nrdconta = c.nrdconta
           AND l.nrborder = t.nrborder
           AND l.nrdocmto = c.nrdocmto
           AND l.cdhistor IN (2672,2673)
           AND l.dtmvtolt = c.dtdpagto),0) PGO_DIA_COB,
       nvl((SELECT sum(l.vllanmto)
          FROM tbdsct_lancamento_bordero l
         WHERE l.cdcooper = c.cdcooper
           AND l.nrdconta = c.nrdconta
           AND l.nrborder = t.nrborder
           AND l.nrdocmto = c.nrdocmto
           AND l.cdhistor IN (2671)
           AND l.dtmvtolt = c.dtdpagto),0) PGO_DIA_CC,
       nvl((SELECT sum(l.vllanmto)
          FROM tbdsct_lancamento_bordero l
         WHERE l.cdcooper = c.cdcooper
           AND l.nrdconta = c.nrdconta
           AND l.nrborder = t.nrborder
           AND l.nrdocmto = c.nrdocmto
           AND l.cdhistor IN (2672,2673)
           AND l.dtmvtolt > c.dtdpagto),0) PGO_DEPOIS_COB,
       nvl((SELECT sum(l.vllanmto)
          FROM tbdsct_lancamento_bordero l
         WHERE l.cdcooper = c.cdcooper
           AND l.nrdconta = c.nrdconta
           AND l.nrborder = t.nrborder
           AND l.nrdocmto = c.nrdocmto
           AND l.cdhistor IN (2671)
           AND l.dtmvtolt > c.dtdpagto),0) PGO_DEPOIS_CC,
       nvl((SELECT sum(l.vllanmto)
          FROM tbdsct_lancamento_bordero l
         WHERE l.cdcooper = c.cdcooper
           AND l.nrdconta = c.nrdconta
           AND l.nrborder = t.nrborder
           AND l.nrdocmto = c.nrdocmto
           AND l.cdhistor IN (2669)
           AND l.dtmvtolt > c.dtdpagto),0) APR_MULTA,
       nvl((SELECT sum(l.vllanmto)
          FROM tbdsct_lancamento_bordero l
         WHERE l.cdcooper = c.cdcooper
           AND l.nrdconta = c.nrdconta
           AND l.nrborder = t.nrborder
           AND l.nrdocmto = c.nrdocmto
           AND l.cdhistor IN (2682,2684)
           AND l.dtmvtolt > c.dtdpagto),0) PGO_MULTA,    
       nvl((SELECT sum(l.vllanmto)
          FROM tbdsct_lancamento_bordero l
         WHERE l.cdcooper = c.cdcooper
           AND l.nrdconta = c.nrdconta
           AND l.nrborder = t.nrborder
           AND l.nrdocmto = c.nrdocmto
           AND l.cdhistor IN (2668)
           AND l.dtmvtolt > c.dtdpagto),0) APR_MORA,
       nvl((SELECT sum(l.vllanmto)
          FROM tbdsct_lancamento_bordero l
         WHERE l.cdcooper = c.cdcooper
           AND l.nrdconta = c.nrdconta
           AND l.nrborder = t.nrborder
           AND l.nrdocmto = c.nrdocmto
           AND l.cdhistor IN (2686,2688)
           AND l.dtmvtolt > c.dtdpagto),0) PGO_MORA,            
       t.insittit,
       b.vltaxiof
       
      FROM crapcob c, craptdb t, crapass a, crapbdt b
     WHERE c.cdcooper = 1
       AND c.dtdpagto = '24/04/2019'
       AND t.cdcooper = c.cdcooper
       AND t.nrdconta = c.nrdconta
       AND t.CDBANDOC = c.CDBANDOC
       AND t.NRDCTABB = c.NRDCTABB
       AND t.NRCNVCOB = c.NRCNVCOB
       AND t.NRDOCMTO = c.NRDOCMTO
       AND a.cdcooper = c.cdcooper
       AND a.nrdconta = c.nrdconta
       AND b.cdcooper = t.cdcooper
       AND b.nrdconta = t.nrdconta
       AND b.nrborder = t.nrborder
AND a.nrdconta IN (7168004,
                          2259591,
                          2577518,
                          6381715,
                          9924701,
                          1985000,
                          10083910,
                          3581055,
                          2348578,
                          2892022,
                          3069060,
                          6123490,
                          6196420,
                          8112185,
                          8524700,
                          8973709,
                          3910989,
                          80280161,
                          80495192,
                          7836937)
    
     ORDER BY c.vldpagto
     ;
  rw_titulo cr_titulo%ROWTYPE;   
  
  CURSOR cr_lbd (pr_cdcooper IN tbdsct_lancamento_bordero.cdcooper%TYPE
                ,pr_nrdconta IN tbdsct_lancamento_bordero.nrdconta%TYPE
                ,pr_nrborder IN tbdsct_lancamento_bordero.nrborder%TYPE
                ,pr_nrdctabb IN tbdsct_lancamento_bordero.nrdctabb%TYPE
                ,pr_nrcnvcob IN tbdsct_lancamento_bordero.nrcnvcob%TYPE
                ,pr_cdbandoc IN tbdsct_lancamento_bordero.cdbandoc%TYPE
                ,pr_nrdocmto IN tbdsct_lancamento_bordero.nrdocmto%TYPE
                ,pr_dtmvtolt IN tbdsct_lancamento_bordero.dtmvtolt%TYPE
                )IS
    SELECT lbd.rowid,
           lbd.vllanmto,
           lbd.cdhistor,
           his.dsextrat,
           lbd.dtmvtolt
      FROM tbdsct_lancamento_bordero lbd
 INNER JOIN craphis his ON his.cdcooper = lbd.cdcooper AND his.cdhistor = lbd.cdhistor    
     WHERE lbd.cdcooper = pr_cdcooper
        AND lbd.nrdconta = pr_nrdconta
        AND lbd.nrborder = pr_nrborder
        AND lbd.nrdctabb = pr_nrdctabb
        AND lbd.nrcnvcob = pr_nrcnvcob
        AND lbd.cdbandoc = pr_cdbandoc
        AND lbd.nrdocmto = pr_nrdocmto
        AND lbd.cdhistor IN (2671,2672,2673,2686,2688,2682,2684,2668,2669)
        AND lbd.dtmvtolt > pr_dtmvtolt
     ORDER BY lbd.dtmvtolt   
        ; 
  rw_lbd cr_lbd%ROWTYPE;
  
  CURSOR cr_crapljt (pr_cdcooper IN crapljt.cdcooper%type
                    ,pr_nrdconta IN crapljt.nrdconta%type
                    ,pr_nrborder IN crapljt.nrborder%type
                    ,pr_dtrefere IN crapljt.dtrefere%type
                    ,pr_cdbandoc IN crapljt.cdbandoc%type
                    ,pr_nrdctabb IN crapljt.nrdctabb%type
                    ,pr_nrcnvcob IN crapljt.nrcnvcob%type
                    ,pr_nrdocmto IN crapljt.nrdocmto%TYPE) IS
    SELECT crapljt.ROWID
          ,crapljt.vldjuros
          ,crapljt.vlrestit
          ,crapljt.dtrefere
    FROM crapljt
    WHERE crapljt.cdcooper = pr_cdcooper
    AND   crapljt.nrdconta = pr_nrdconta
    AND   crapljt.nrborder = pr_nrborder
    AND   crapljt.dtrefere >= pr_dtrefere
    AND   crapljt.cdbandoc = pr_cdbandoc
    AND   crapljt.nrdctabb = pr_nrdctabb
    AND   crapljt.nrcnvcob = pr_nrcnvcob
    AND   crapljt.nrdocmto = pr_nrdocmto;
  rw_crapljt cr_crapljt%ROWTYPE;
  
  CURSOR cr_pagto_antecipado (pr_cdcooper IN craplcm.cdcooper%TYPE
                             ,pr_nrdconta IN craplcm.nrdconta%TYPE
                             ,pr_nrdocmto IN craplcm.nrdocmto%TYPE
                             ,pr_vllanmto IN craplcm.vllanmto%TYPE
                             )IS
    SELECT lcm.vllanmto
      FROM craplcm lcm
     WHERE lcm.cdcooper = pr_cdcooper
       AND lcm.nrdconta = pr_nrdconta
       AND lcm.nrdocmto = pr_nrdocmto 
       AND lcm.cdhistor = 2680
       AND lcm.dtmvtolt = to_date('24/04/2019','DD/MM/RRRR')
       
       ;
  rw_pagto_antecipado cr_pagto_antecipado%ROWTYPE;
  
  CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE
                   ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
   SELECT crapjur.natjurid
         ,crapjur.tpregtrb
     FROM crapjur
    WHERE crapjur.cdcooper = pr_cdcooper
      AND crapjur.nrdconta = pr_nrdconta;
  rw_crapjur cr_crapjur%ROWTYPE;
  
  /* Cursor genérico de calendário */
  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt
          ,dat.dtmvtopr
          ,dat.dtmvtoan
          ,dat.inproces
          ,dat.qtdiaute
          ,dat.cdprgant
          ,dat.dtmvtocd
          ,trunc(dat.dtmvtolt,'mm')               dtinimes -- Pri. Dia Mes Corr.
          ,trunc(Add_Months(dat.dtmvtolt,1),'mm') dtpridms -- Pri. Dia mes Seguinte
          ,last_day(add_months(dat.dtmvtolt,-1))  dtultdma -- Ult. Dia Mes Ant.
          ,last_day(dat.dtmvtolt)                 dtultdia -- Utl. Dia Mes Corr.
          ,rowid
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;
  
  vr_vliofpri NUMBER; -- Valor do IOF principal
  vr_vliofadi NUMBER; -- Valor do IOF adicional
  vr_vliofcpl NUMBER; -- Valor do IOF complementar

  
  vr_cdcritic     crapcri.cdcritic%TYPE;
  vr_dscritic     crapcri.dscritic%TYPE;
  vr_incrineg  INTEGER;
  
  vr_insittit craptdb.insittit%TYPE;
  vr_dtdebito craptdb.dtdebito%TYPE;
  vr_dtdpagto craptdb.dtdpagto%TYPE;
  vr_cdhistor craphis.cdhistor%TYPE;
  vr_vljurosljt crapljt.vldjuros%TYPE;
  vr_vlrestitljt crapljt.vlrestit%TYPE;
  vr_vltxiofatra NUMBER;

  
  vr_vllanmto_soma_depois NUMBER; 
  vr_vllanmto_soma_depois_tit NUMBER; 
  vr_flgpagamento VARCHAR2(100);
  vr_vlrestit_soma NUMBER;
  
  vr_vlpagiof craptdb.vlpagiof%TYPE;
  
  vr_flgimune PLS_INTEGER;
  
  PROCEDURE pc_abatimento_juros_titulo(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrborder  IN crapbdt.nrborder%TYPE --> Numero do bordero
                                      ,pr_cdbandoc  IN craptdb.cdbandoc%TYPE
                                      ,pr_nrdctabb  IN craptdb.nrdctabb%TYPE
                                      ,pr_nrcnvcob  IN craptdb.nrcnvcob%TYPE
                                      ,pr_nrdocmto  IN craptdb.nrdocmto%TYPE
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                      ,pr_cdagenci  IN crapass.cdagenci%TYPE
                                      ,pr_cdoperad  IN VARCHAR2              --> Codigo operador
                                      ,pr_cdorigpg  IN NUMBER DEFAULT 0      --> Código da origem do pagamento
                                      ,pr_dtdpagto  IN craptdb.dtdpagto%TYPE DEFAULT NULL --> Data de pagamento
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_abatimento_juros_titulo
      Sistema  : Ayllos
      Sigla    : DSCT
      Autor    : Paulo Penteado (GFT)
      Data     : Junho/2018
  
      Objetivo  : Efetuar o abatimento de juros do título do borderô
     
               pr_cdorigpg: Código da origem do pagamento 
                            0 - Conta-Corrente
                            1 - Operação de Crédito
  
      Alteração : 09/06/2018 - Criação (Paulo Penteado (GFT))
                  11/09/2018 - Fix removendo histórico de lançamento de borderô - (Andrew Albuquerque - GFT)
  
    ----------------------------------------------------------------------------------------------------------*/
    vr_cdhistor   craphis.cdhistor%TYPE;
    vr_dtperiod   DATE;
    vr_dtrefjur   DATE;
    vr_dtultdat   DATE;
    vr_flgachou   BOOLEAN;
    vr_incrawljt  PLS_INTEGER;
    vr_nrdocmtolt craptdb.nrdocmto%TYPE;
    vr_nrdolote   craplot.nrdolote%TYPE;
    vr_qtdprazo   INTEGER;
    vr_txdiaria   NUMBER;
    vr_vldjuros   NUMBER;
    vr_vltitulo   NUMBER;
    vr_vltotjur   NUMBER;
    
    rw_craplcm craplcm%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
  
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
      
    --Selecionar Bordero de titulos
    CURSOR cr_crapbdt IS
      SELECT crapbdt.txmensal
            ,crapbdt.vltaxiof
            ,crapbdt.flverbor
      FROM crapbdt
      WHERE crapbdt.cdcooper = pr_cdcooper
      AND   crapbdt.nrborder = pr_nrborder;
    rw_crapbdt cr_crapbdt%ROWTYPE;
    
    CURSOR cr_craptdb IS
      SELECT craptdb.dtvencto
            ,craptdb.vltitulo
            ,craptdb.nrdconta
            ,craptdb.nrdocmto
            ,craptdb.cdcooper
            ,craptdb.insittit
            --,nvl(craptdb.dtdpagto, pr_dtdpagto) dtdpagto
            ,pr_dtdpagto as dtdpagto
            ,craptdb.nrborder
            ,craptdb.dtlibbdt
            ,craptdb.cdbandoc
            ,craptdb.nrdctabb
            ,craptdb.nrcnvcob
            ,craptdb.rowid
            ,craptdb.vlliquid
            ,craptdb.nrtitulo
            ,COUNT(*) OVER (PARTITION BY craptdb.cdcooper) qtdreg
      FROM craptdb
      WHERE craptdb.cdcooper = pr_cdcooper
      AND   craptdb.cdbandoc = pr_cdbandoc
      AND   craptdb.nrdctabb = pr_nrdctabb
      AND   craptdb.nrcnvcob = pr_nrcnvcob
      AND   craptdb.nrdconta = pr_nrdconta
      AND   craptdb.nrdocmto = pr_nrdocmto
      AND   craptdb.dtresgat IS NULL;
    rw_craptdb cr_craptdb%ROWTYPE;

    --Selecionar lancamento juros desconto titulo
    CURSOR cr_crapljt (pr_cdcooper IN crapljt.cdcooper%type
                      ,pr_nrdconta IN crapljt.nrdconta%type
                      ,pr_nrborder IN crapljt.nrborder%type
                      ,pr_dtrefere IN crapljt.dtrefere%type
                      ,pr_cdbandoc IN crapljt.cdbandoc%type
                      ,pr_nrdctabb IN crapljt.nrdctabb%type
                      ,pr_nrcnvcob IN crapljt.nrcnvcob%type
                      ,pr_nrdocmto IN crapljt.nrdocmto%TYPE
                      ,pr_tipo     IN INTEGER) IS
      SELECT crapljt.ROWID
            ,crapljt.vldjuros
            ,crapljt.vlrestit
      FROM crapljt
      WHERE crapljt.cdcooper = pr_cdcooper
      AND   crapljt.nrdconta = pr_nrdconta
      AND   crapljt.nrborder = pr_nrborder
      AND   ((pr_tipo = 1 AND crapljt.dtrefere = pr_dtrefere) OR
             (pr_tipo = 2 AND crapljt.dtrefere > pr_dtrefere))
      AND   crapljt.cdbandoc = pr_cdbandoc
      AND   crapljt.nrdctabb = pr_nrdctabb
      AND   crapljt.nrcnvcob = pr_nrcnvcob
      AND   crapljt.nrdocmto = pr_nrdocmto;
    rw_crapljt cr_crapljt%ROWTYPE;
     
  BEGIN
    OPEN  cr_crapbdt;
    FETCH cr_crapbdt INTO rw_crapbdt;
    IF    cr_crapbdt%NOTFOUND THEN
          CLOSE cr_crapbdt;
          vr_cdcritic := 1166; --Bordero nao encontrado.
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_erro;
    END   IF;
    CLOSE cr_crapbdt;
    
    OPEN  cr_craptdb;
    FETCH cr_craptdb INTO rw_craptdb;
    IF    cr_craptdb%NOTFOUND THEN
          CLOSE cr_craptdb;
          vr_cdcritic := 1108; 
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_erro;
    END   IF;
    CLOSE cr_craptdb;

    /**** ABATIMENTO DE JUROS ****/
    --Zerar valor total juros
    vr_vltotjur:= 0;
    IF (rw_crapbdt.flverbor=0) THEN
       vr_txdiaria := APLI0001.fn_round((POWER(1 + (rw_crapbdt.txmensal / 100),1 / 30) - 1),7);
    ELSE
       vr_txdiaria := (rw_crapbdt.txmensal / 100)/30;
    END IF;
    --Quantidade dias prazo
    vr_qtdprazo:= TO_NUMBER(rw_craptdb.dtvencto - rw_craptdb.dtlibbdt) -
                  TO_NUMBER(rw_craptdb.dtvencto - rw_craptdb.dtdpagto);
    IF vr_qtdprazo < 0 THEN
      vr_qtdprazo:= TO_NUMBER(rw_craptdb.dtvencto - rw_craptdb.dtlibbdt) -
                    TO_NUMBER(rw_craptdb.dtdpagto - rw_craptdb.dtvencto);
    END IF;
    --Valor Titulo
    vr_vltitulo:= rw_craptdb.vltitulo;
    --Data Periodo
    vr_dtperiod:= rw_craptdb.dtlibbdt;
    --Zerar valor juros
    vr_vldjuros:= 0;

    /* Houve pagamento antecipado e data de pagamento maior que data de liberação do bordero (vr_qtdprazo>0) */
    IF vr_qtdprazo > 0 AND rw_craptdb.dtdpagto < rw_craptdb.dtvencto  THEN
      --Percorrer todo o prazo
      FOR vr_contador IN 1..vr_qtdprazo LOOP
        --Valor juros
        IF (rw_crapbdt.flverbor=0) THEN
          --Valor Titulo recebe valor juros
          vr_vldjuros:= APLI0001.fn_round(vr_vltitulo * vr_txdiaria,2);
          vr_vltitulo:= vr_vltitulo + vr_vldjuros;
        ELSE
          vr_vldjuros:= vr_vltitulo * vr_txdiaria;
        END IF;
        --Data Periodo
        vr_dtperiod:= vr_dtperiod + 1;
        --data referencia juros
        vr_dtrefjur:= Last_Day(vr_dtperiod);
        --Marcar que nao encontrou
        vr_flgachou:= FALSE;
        --Selecionar Lancamento Juros Desconto Titulo
        FOR idx IN 1..vr_tab_crawljt.Count LOOP
          IF vr_tab_crawljt(idx).cdcooper = rw_craptdb.cdcooper AND
             vr_tab_crawljt(idx).nrdconta = rw_craptdb.nrdconta AND
             vr_tab_crawljt(idx).nrborder = rw_craptdb.nrborder AND
             vr_tab_crawljt(idx).dtrefere = vr_dtrefjur         AND
             vr_tab_crawljt(idx).cdbandoc = rw_craptdb.cdbandoc AND
             vr_tab_crawljt(idx).nrdctabb = rw_craptdb.nrdctabb AND
             vr_tab_crawljt(idx).nrcnvcob = rw_craptdb.nrcnvcob AND
             vr_tab_crawljt(idx).nrdocmto = rw_craptdb.nrdocmto THEN
            --Marcar que encontrou
            vr_flgachou:= TRUE;
            --Acumular valor juros
            vr_tab_crawljt(idx).vldjuros:= vr_tab_crawljt(idx).vldjuros + vr_vldjuros;
          END IF;
        END LOOP;
        /*Se nao encontrou cria */
        IF NOT vr_flgachou THEN
          --Selecionar indice
          vr_incrawljt:= vr_tab_crawljt.Count+1;
          --Gravar dados tabela memoria
          vr_tab_crawljt(vr_incrawljt).cdcooper:= rw_craptdb.cdcooper;
          vr_tab_crawljt(vr_incrawljt).nrdconta:= rw_craptdb.nrdconta;
          vr_tab_crawljt(vr_incrawljt).nrborder:= rw_craptdb.nrborder;
          vr_tab_crawljt(vr_incrawljt).dtrefere:= vr_dtrefjur;
          vr_tab_crawljt(vr_incrawljt).cdbandoc:= rw_craptdb.cdbandoc;
          vr_tab_crawljt(vr_incrawljt).nrdctabb:= rw_craptdb.nrdctabb;
          vr_tab_crawljt(vr_incrawljt).nrcnvcob:= rw_craptdb.nrcnvcob;
          vr_tab_crawljt(vr_incrawljt).nrdocmto:= rw_craptdb.nrdocmto;
          vr_tab_crawljt(vr_incrawljt).vldjuros:= vr_vldjuros;
        END IF;
      END LOOP;  --vr_contador IN 1..vr_qtdprazo
      /*  Atualiza registro de provisao de juros ..........  */
      FOR idx IN 1..vr_tab_crawljt.Count LOOP
        --Se for a mesma cooperativa
        IF (rw_crapbdt.flverbor=1) THEN
          vr_tab_crawljt(idx).vldjuros := APLI0001.fn_round(vr_tab_crawljt(idx).vldjuros,2);
        END IF;
        --Se for a mesma cooperativa
        IF vr_tab_crawljt(idx).cdcooper = pr_cdcooper THEN
          --Selecionar lancamento juros desconto titulo
                OPEN cr_crapljt (pr_cdcooper => vr_tab_crawljt(idx).cdcooper
                                ,pr_nrdconta => vr_tab_crawljt(idx).nrdconta
                                ,pr_nrborder => vr_tab_crawljt(idx).nrborder
                                ,pr_dtrefere => vr_tab_crawljt(idx).dtrefere
                                ,pr_cdbandoc => vr_tab_crawljt(idx).cdbandoc
                                ,pr_nrdctabb => vr_tab_crawljt(idx).nrdctabb
                                ,pr_nrcnvcob => vr_tab_crawljt(idx).nrcnvcob
                                ,pr_nrdocmto => vr_tab_crawljt(idx).nrdocmto
                          ,pr_tipo     => 1);
          --Posicionar no proximo registro
          FETCH cr_crapljt INTO rw_crapljt;
          --Se nao encontrar
          IF cr_crapljt%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_crapljt;
            --Mensagem erro              
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1170; --Registro crapljt nao encontrado.
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            -- Excluido GENE0001.pc_gera_erro esta no final da rotina - 15/02/2018 - Chamado 851591 
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapljt;
          --Se o valor dos juros mudou
          IF rw_crapljt.vldjuros <> vr_tab_crawljt(idx).vldjuros THEN
            --Se valor juros tabela eh maior encontrado
            IF  rw_crapljt.vldjuros > vr_tab_crawljt(idx).vldjuros THEN
              --Atualizar tabela juros
              BEGIN 
                UPDATE crapljt SET crapljt.vlrestit = NVL(crapljt.vldjuros,0) - NVL(vr_tab_crawljt(idx).vldjuros,0)
                                  ,crapljt.vldjuros = nvl(vr_tab_crawljt(idx).vldjuros,0)
                WHERE crapljt.ROWID = rw_crapljt.ROWID
                RETURNING crapljt.vlrestit INTO rw_crapljt.vlrestit;
              EXCEPTION
                WHEN OTHERS THEN
                  -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                  CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
                  -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                  vr_cdcritic := 1035;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)|| 
                                 'crapljt(1):'||
                                 ' vlrestit:'  || 'NVL(crapljt.vldjuros,0) - ' || NVL(vr_tab_crawljt(idx).vldjuros,0) ||
                                 ' ,vldjuros:' || nvl(vr_tab_crawljt(idx).vldjuros,0) ||
                                 ' ,ROWID   :' || rw_crapljt.ROWID  || 
                                 '. ' ||sqlerrm; 
                  --Levantar Excecao
                  RAISE vr_exc_erro;
              END;
              /* Juros a ser restituido */
              vr_vltotjur:= rw_crapljt.vlrestit;
            ELSE
              --Mensagem erro
              -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
              vr_cdcritic := 367; --Erro - Juros negativo:
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||
                             rw_crapljt.vldjuros;
              -- Excluido GENE0001.pc_gera_erro esta no final da rotina - 15/02/2018 - Chamado 851591                      
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
          --Data de Referencia
          vr_dtultdat:= vr_tab_crawljt(idx).dtrefere;
          --Excluir registro da tabela memoria
          vr_tab_crawljt.DELETE(idx);
        END IF;
      END LOOP;
    --#489111 início
    /* Houve pagamento antecipado e data de pagamento igual a data de liberação do bordero (vr_qtdprazo=0) */
    ELSIF vr_qtdprazo = 0 AND rw_craptdb.dtdpagto < rw_craptdb.dtvencto  THEN
      --data referencia juros
      vr_dtrefjur:= Last_Day(rw_craptdb.dtdpagto);
      /* Restitui o juro que seria apropriado no mês do pagamento do título */
            FOR rw_crapljt IN cr_crapljt (pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => rw_craptdb.nrdconta
                                         ,pr_nrborder => rw_craptdb.nrborder
                                         ,pr_dtrefere => vr_dtrefjur
                                         ,pr_cdbandoc => rw_craptdb.cdbandoc
                                         ,pr_nrdctabb => rw_craptdb.nrdctabb
                                         ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                         ,pr_nrdocmto => rw_craptdb.nrdocmto
                                   ,pr_tipo     => 1) LOOP
        --Acumular total juros
        vr_vltotjur:= Nvl(vr_vltotjur,0) + Nvl(rw_crapljt.vldjuros,0);
        --Atualizar tabela lancamento juros desconto titulos
        BEGIN
          UPDATE crapljt SET crapljt.vlrestit = crapljt.vldjuros
                            ,crapljt.vldjuros = 0
          WHERE crapljt.ROWID = rw_crapljt.ROWID;
        EXCEPTION
          WHEN Others THEN
            -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)  || 
                           'crapljt(2):'||
                           ' vlrestit:'  || 'crapljt.vldjuros' ||
                           ', vldjuros:' || '0' ||
                           ', ROWID:'    || rw_crapljt.ROWID  || 
                           '. ' ||sqlerrm; 
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END LOOP;
      --Data de Referencia
      vr_dtultdat:= vr_dtrefjur;
    --#489111 fim
    ELSE
      /* o juros sempre eh referente ao ultimo dia do mes */
      vr_dtultdat:= Last_Day(rw_craptdb.dtdpagto);
    END IF;
    /* Restitui o juro que seria apropriado no(s) periodo(s) seguinte(s) */
          FOR rw_crapljt IN cr_crapljt (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => rw_craptdb.nrdconta
                                       ,pr_nrborder => rw_craptdb.nrborder
                                       ,pr_dtrefere => vr_dtultdat
                                       ,pr_cdbandoc => rw_craptdb.cdbandoc
                                       ,pr_nrdctabb => rw_craptdb.nrdctabb
                                       ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                       ,pr_nrdocmto => rw_craptdb.nrdocmto
                                 ,pr_tipo     => 2) LOOP
      --Acumular total juros
      vr_vltotjur:= Nvl(vr_vltotjur,0) + Nvl(rw_crapljt.vldjuros,0);
      --Atualizar tabela lancamento juros desconto titulos
      BEGIN
        UPDATE crapljt SET crapljt.vlrestit = crapljt.vldjuros
                          ,crapljt.vldjuros = 0
        WHERE crapljt.ROWID = rw_crapljt.ROWID;
      EXCEPTION
        WHEN Others THEN
          -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
          -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          vr_cdcritic := 1035;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)|| 
                         'crapljt(3):'||
                         ' vlrestit:'  || 'crapljt.vldjuros' ||
                         ', vldjuros:' || '0' ||
                         ' ,ROWID:'    || rw_crapljt.ROWID  || 
                         '. ' ||sqlerrm; 
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
    END LOOP;
    --Se valor total juros positivo
    IF vr_vltotjur > 0 THEN
      -- conta corrente
      IF nvl(pr_cdorigpg,0) = 0 THEN
        vr_cdhistor   := 597;
        vr_nrdolote   := 10300;
        vr_nrdocmtolt := NULL;
      ELSE -- operação de crédito
        vr_cdhistor := dsct0003.vr_cdhistordsct_rendapgtoant;
        vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                  ,pr_nmdcampo => 'NRDOLOTE'
                                  ,pr_dsdchave => TO_CHAR(pr_cdcooper)|| ';' 
                                                  || TO_CHAR(pr_dtmvtolt,'DD/MM/RRRR') || ';'
                                                  || TO_CHAR(pr_cdagenci)|| ';'
                                                  || '100');
        vr_nrdocmtolt := rw_craptdb.nrdocmto;
      END IF;
            
      /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
      PAGA0001.pc_efetua_debitos_paralelo, que é chamada na rotina PC_CRPS509. Tem por finalidade definir
      se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
      da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
      a agencia do cooperado*/
            
      if not paga0001.fn_exec_paralelo then
        /* Leitura do lote */
        OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                        ,pr_dtmvtolt => pr_dtmvtolt
                        ,pr_cdagenci => pr_cdagenci
                        ,pr_cdbccxlt => 100
                        ,pr_nrdolote => vr_nrdolote);
        --Posicionar no proximo registro
        FETCH cr_craplot INTO rw_craplot;
        --Se encontrou registro
        IF cr_craplot%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_craplot;
          --Criar lote
          
          BEGIN 
            INSERT INTO craplot
              (craplot.cdcooper
              ,craplot.dtmvtolt
              ,craplot.cdagenci
              ,craplot.cdbccxlt
              ,craplot.nrdolote
              ,craplot.cdoperad
              ,craplot.tplotmov
              ,craplot.cdhistor)
            VALUES
              (pr_cdcooper
              ,pr_dtmvtolt
              ,pr_cdagenci
              ,100
              ,vr_nrdolote
              ,pr_cdoperad
              ,1
              ,vr_cdhistor)
            RETURNING ROWID
              ,craplot.dtmvtolt
              ,craplot.cdagenci
              ,craplot.cdbccxlt
              ,craplot.nrdolote
              ,craplot.nrseqdig
            INTO rw_craplot.ROWID
              ,rw_craplot.dtmvtolt
              ,rw_craplot.cdagenci
              ,rw_craplot.cdbccxlt
              ,rw_craplot.nrdolote
              ,rw_craplot.nrseqdig;
          EXCEPTION
            WHEN Dup_Val_On_Index THEN
              --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
              vr_cdcritic := 59; --Lote ja cadastrado.
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              RAISE vr_exc_erro;
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
              -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
              vr_cdcritic := 1034;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             'craplot(6):'||
                             ' cdcooper:'  || pr_cdcooper ||
                             ', dtmvtolt:' || pr_dtmvtolt ||
                             ', cdagenci:' || '1'         ||
                             ', cdbccxlt:' || '100'       ||
                             ', nrdolote:' || vr_nrdolote ||
                             ', cdoperad:' || pr_cdoperad ||
                             ', tplotmov:' || '1'         ||
                             ', cdhistor:' || vr_cdhistor ||
                             '. ' ||sqlerrm; 
              RAISE vr_exc_erro;
          END;
          
        END IF;
        --Fechar Cursor
        IF cr_craplot%ISOPEN THEN
          CLOSE cr_craplot;
        END IF;
        rw_craplot.nrseqdig:= rw_craplot.nrseqdig + 1; -- projeto ligeirinho
      ELSE
        paga0001.pc_insere_lote_wrk (pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => pr_dtmvtolt,
                                     pr_cdagenci => 1,
                                     pr_cdbccxlt => 100,
                                     pr_nrdolote => vr_nrdolote,
                                     pr_cdoperad => pr_cdoperad,
                                     pr_nrdcaixa => NULL,
                                     pr_tplotmov => 1,
                                     pr_cdhistor => vr_cdhistor,
                                     pr_cdbccxpg => null,
                                     pr_nmrotina => 'DSCT0001.PC_ABATIMENTO_JUROS_TITULO');
                            
        rw_craplot.dtmvtolt := pr_dtmvtolt;                  
        rw_craplot.cdagenci := 1;                   
        rw_craplot.cdbccxlt := 100;                  
        rw_craplot.nrdolote := vr_nrdolote;  
        rw_craplot.nrseqdig := PAGA0001.fn_seq_parale_craplcm; 
      END IF;
			
      dbms_output.put_line('  * Inserir lançamento do histórico ' || vr_cdhistor || ' no valor de ' || vr_vltotjur || ' na conta corrente do cooperado por pagamento antecipado');
      
      -- atualizar apropriação de juros remuneratórios na mensal de abril
      UPDATE tbdsct_lancamento_bordero lbd
         SET lbd.vllanmto = lbd.vllanmto - vr_vltotjur
       WHERE lbd.cdcooper = pr_cdcooper
         AND lbd.cdhistor = 2667
         AND lbd.dtmvtolt = to_date('30/04/2019','DD/MM/RRRR')
         AND lbd.nrdconta = rw_craptdb.nrdconta
         AND lbd.nrborder = rw_craptdb.nrborder;
      COMMIT;
           
      
      --Gravar lancamento
      BEGIN 
        INSERT INTO craplcm
            (craplcm.dtmvtolt
            ,craplcm.cdagenci
            ,craplcm.cdbccxlt
            ,craplcm.nrdolote
            ,craplcm.nrdconta
            ,craplcm.nrdocmto
            ,craplcm.vllanmto
            ,craplcm.cdhistor
            ,craplcm.nrseqdig
            ,craplcm.nrdctabb
            ,craplcm.nrautdoc
            ,craplcm.cdcooper
            ,craplcm.cdpesqbb)
        VALUES
            (rw_craplot.dtmvtolt
            ,rw_craplot.cdagenci
            ,rw_craplot.cdbccxlt
            ,rw_craplot.nrdolote
            ,rw_craptdb.nrdconta
            ,nvl(vr_nrdocmtolt, Nvl(rw_craplot.nrseqdig,0))
            ,vr_vltotjur
            ,vr_cdhistor
            ,Nvl(rw_craplot.nrseqdig,0) -- Merge 02/05/2018 - Chamado 851591 
            ,rw_craptdb.nrdconta
            ,0
            ,pr_cdcooper
            ,rw_craptdb.nrdocmto)
        RETURNING craplcm.nrseqdig
                 ,craplcm.vllanmto
        INTO rw_craplcm.nrseqdig

            ,rw_craplcm.vllanmto;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
          -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          vr_cdcritic := 1034;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             'craplcm(6):'||
                             ' dtmvtolt:'  || rw_craplot.dtmvtolt ||
                             ', cdagenci:' || rw_craplot.cdagenci ||
                             ', cdbccxlt:' || rw_craplot.cdbccxlt ||
                             ', nrdolote:' || rw_craplot.nrdolote ||
                             ', nrdconta:' || rw_craptdb.nrdconta ||
                             ', nrdocmto:' || nvl(vr_nrdocmtolt, Nvl(rw_craplot.nrseqdig,0) || ' + 1') ||
                             ', vllanmto:' || vr_vltotjur ||
                             ', cdhistor:' || vr_cdhistor ||
                             ', nrseqdig:' || Nvl(rw_craplot.nrseqdig,0) || ' + 1' ||
                             ', nrdctabb:' || rw_craptdb.nrdconta ||
                             ', nrautdoc:' || '0' ||
                             ', cdcooper:' || pr_cdcooper ||
                             ', cdpesqbb:' || rw_craptdb.nrdocmto ||
                             '. ' ||sqlerrm; 
          RAISE vr_exc_erro;
      END;
            
      /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
      PAGA0001.pc_efetua_debitos_ligeir, que é chamada na rotina PC_CRPS509. Tem por finalidade definir se este update
      deve ser feito agora ou somente no final. da execução da PC_CRPS509 (chamada da paga0001.pc_atualiz_lote)*/
            
      if not paga0001.fn_exec_paralelo then
        -- Atualiza o lote na craplot
        BEGIN 
          UPDATE craplot SET craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                          ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                          ,craplot.nrseqdig = Nvl(rw_craplcm.nrseqdig,0)
                          ,craplot.vlinfodb = Nvl(craplot.vlinfodb,0) + vr_vltotjur
                          ,craplot.vlcompdb = Nvl(craplot.vlcompdb,0) + vr_vltotjur
          WHERE craplot.ROWID = rw_craplot.ROWID
          RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                         'craplot(5):'||
                         ' qtinfoln:'  || 'Nvl(craplot.qtinfoln,0) + 1' ||
                         ', qtcompln:' || 'Nvl(craplot.qtcompln,0) + 1' ||
                         ', nrseqdig:' || Nvl(rw_craplcm.nrseqdig,0) ||
                         ', vlinfodb:' || 'Nvl(craplot.vlinfodb,0) +' || vr_vltotjur ||
                         ', vlcompdb:' || 'Nvl(craplot.vlcompdb,0) +' || vr_vltotjur ||
                         ', ROWID:'    || rw_craplot.ROWID || 
                         '. ' ||sqlerrm; 
          --Levantar Excecao
          RAISE vr_exc_erro;
        END;
      END IF;
      
    END IF;
  EXCEPTION
    WHEN vr_exc_erro then
         IF  vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;
  
    WHEN OTHERS THEN
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := 'Erro nao tratado na rotina DSCT0001.pc_abatimento_juros_titulo: '||SQLERRM;
  END pc_abatimento_juros_titulo;
   
BEGIN
  
  vr_vllanmto_soma_depois := 0;
  
  OPEN  cr_crapdat(pr_cdcooper => 1);
  FETCH cr_crapdat into rw_crapdat;
  CLOSE cr_crapdat;
  
  FOR rw_titulo IN cr_titulo LOOP
    vr_vllanmto_soma_depois_tit :=0;
    vr_vlrestit_soma := 0;
    vr_vljurosljt := 0;
    vr_vlrestitljt :=0;
    
    -- títulos que estão OK
    IF rw_titulo.insittit = 2 AND rw_titulo.pgo_dia_cob > 0 AND rw_titulo.pgo_depois_cc = 0 THEN
      CONTINUE;
    END IF;  
    
    IF rw_titulo.indpagto = 0 THEN
      vr_cdhistor := 2672;
    ELSE
      vr_cdhistor := 2673;
    END IF;  
    
    vr_flgpagamento := '';
    IF (rw_titulo.dtvencto < to_date('24/04/2019','DD/MM/RRRR')) THEN
      vr_flgpagamento := 'PAGO EM ATRASO';
    ELSIF rw_titulo.dtvencto > to_date('24/04/2019','DD/MM/RRRR') THEN
      vr_flgpagamento := 'PAGO ANTECIPADO';
    ELSE
      vr_flgpagamento := 'PAGO EM DIA';    
    END IF;  
    
    dbms_output.put_line('Conta : ' || rw_titulo.nrdconta || 
                         ' Borderô : ' || rw_titulo.nrborder || 
                         ' Título : ' || rw_titulo.nrdocmto ||
                         ' Valor : ' || rw_titulo.vltitulo ||
                         ' Vencimento : ' || rw_titulo.dtvencto ||
                         ' (' || vr_flgpagamento || ')'
                         );
    
    dbms_output.put_line('');
    
    -- Tratativas do IOF Complementar
    IF vr_flgpagamento = 'PAGO EM ATRASO' THEN
      
      -- Busca dados de pessoa jurídica
      OPEN cr_crapjur(pr_cdcooper => rw_titulo.cdcooper,
                      pr_nrdconta => rw_titulo.nrdconta);
      FETCH cr_crapjur INTO rw_crapjur;
      CLOSE cr_crapjur;
      
      vr_vltotal_liquido := 0;
      OPEN cr_craptdb_total(pr_cdcooper => rw_titulo.cdcooper
                           ,pr_nrdconta => rw_titulo.nrdconta
                           ,pr_nrborder => rw_titulo.nrborder);
      FETCH cr_craptdb_total INTO vr_vltotal_liquido;
      CLOSE cr_craptdb_total;

      TIOF0001.pc_calcula_valor_iof_prg (pr_tpproduto            => 2 -- Desconto de títulos
                                        ,pr_tpoperacao           => 2 -- Pagamento em atraso
                                        ,pr_cdcooper             => rw_titulo.cdcooper
                                        ,pr_nrdconta             => rw_titulo.nrdconta
                                        ,pr_inpessoa             => rw_titulo.inpessoa
                                        ,pr_natjurid             => rw_crapjur.natjurid
                                        ,pr_tpregtrb             => rw_crapjur.tpregtrb
                                        ,pr_dtmvtolt             => to_date('24/04/2019','DD/MM/RRRR')
                                        ,pr_qtdiaiof             => (to_date('24/04/2019','DD/MM/RRRR') - rw_titulo.dtvencto)
                                        ,pr_vloperacao           => (rw_titulo.vltitulo)
                                        ,pr_vltotalope           => vr_vltotal_liquido
                                        ,pr_vltaxa_iof_atraso    => NVL(rw_titulo.vltaxiof,0)
                                        ,pr_vliofpri             => vr_vliofpri
                                        ,pr_vliofadi             => vr_vliofadi
                                        ,pr_vliofcpl             => vr_vliofcpl
                                        ,pr_vltaxa_iof_principal => vr_vltxiofatra
                                        ,pr_flgimune             => vr_flgimune
                                        ,pr_dscritic             => vr_dscritic);
      
      vr_vlpagiof := vr_vliofcpl;
    ELSE 
      vr_vliofcpl := 0;
      vr_vlpagiof := 0;
      
    END IF;  
          
    IF vr_flgpagamento = 'PAGO ANTECIPADO' THEN
      
      FOR rw_crapljt IN cr_crapljt (pr_cdcooper => rw_titulo.cdcooper
                                   ,pr_nrdconta => rw_titulo.nrdconta
                                   ,pr_nrborder => rw_titulo.nrborder
                                   ,pr_dtrefere => last_day(to_date('24/04/2019','DD/MM/RRRR'))
                                   ,pr_cdbandoc => rw_titulo.cdbandoc
                                   ,pr_nrdctabb => rw_titulo.nrdctabb
                                   ,pr_nrcnvcob => rw_titulo.nrcnvcob
                                   ,pr_nrdocmto => rw_titulo.nrdocmto) LOOP
        
        vr_vlrestit_soma := vr_vlrestit_soma + rw_crapljt.vlrestit;
        vr_vljurosljt := rw_crapljt.vldjuros + rw_crapljt.vlrestit; 
        vr_vlrestitljt := vr_vlrestitljt + rw_crapljt.vlrestit;
                            
      END LOOP;
      
      -- Se o valor a restituir já está calculado na crapljt, é porque apenas não ocorreu o lançamento do histórico 2680 na conta do cooperado 
      IF vr_vlrestitljt = 0 THEN
      
        pc_abatimento_juros_titulo (pr_cdcooper => rw_titulo.cdcooper
                                   ,pr_nrdconta => rw_titulo.nrdconta
                                   ,pr_nrborder => rw_titulo.nrborder
                                   ,pr_cdbandoc => rw_titulo.cdbandoc
                                   ,pr_nrdctabb => rw_titulo.nrdctabb
                                   ,pr_nrcnvcob => rw_titulo.nrcnvcob
                                   ,pr_nrdocmto => rw_titulo.nrdocmto
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdagenci => rw_titulo.cdagenci -- apenas para o produto novo
                                   ,pr_cdoperad => '1'
                                   ,pr_cdorigpg => 1 -- operacao de credito
                                   ,pr_dtdpagto => to_date('24/04/2019','DD/MM/RRRR')
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic );
      
      ELSE
       
        dbms_output.put_line('  * Inserir lançamento do histórico 2680 no valor de ' || vr_vlrestitljt || ' na conta corrente do cooperado por pagamento antecipado');
        
        -- então lançar o saldo restante como crédito na conta corrente do cooperado
        DSCT0003.pc_efetua_lanc_cc (pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdagenci => rw_titulo.cdagenci
                                   ,pr_cdbccxlt => 100
                                   ,pr_nrdconta => rw_titulo.nrdconta
                                   ,pr_vllanmto => vr_vlrestitljt
                                   ,pr_cdhistor => 2680
                                   ,pr_cdcooper => rw_titulo.cdcooper
                                   ,pr_cdoperad => '1'
                                   ,pr_nrborder => rw_titulo.nrborder
                                   ,pr_cdpactra => 0
                                   ,pr_nrdocmto => rw_titulo.nrdocmto
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
        -- Condicao para verificar se houve critica
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
          RETURN;
        END IF;
        
      END IF;
      
    END IF;
    
    
    -- títulos que houveram pagamentos na cc mas não ocorreram na operação
    IF rw_titulo.pgo_depois_cc > 0 
      AND NOT (rw_titulo.nrdconta= 2577518 AND rw_titulo.nrborder = 561658 AND rw_titulo.nrdocmto = 1081) 
      THEN
    
      FOR rw_lbd IN cr_lbd  (pr_cdcooper => rw_titulo.cdcooper
                            ,pr_nrdconta => rw_titulo.nrdconta
                            ,pr_nrborder => rw_titulo.nrborder
                            ,pr_nrdctabb => rw_titulo.nrdctabb
                            ,pr_nrcnvcob => rw_titulo.nrcnvcob
                            ,pr_cdbandoc => rw_titulo.cdbandoc
                            ,pr_nrdocmto => rw_titulo.nrdocmto
                            --,pr_cdhistor => 2671
                            ,pr_dtmvtolt => to_date('23/04/2019','DD/MM/RRRR')) LOOP
        
        vr_vllanmto_soma_depois := vr_vllanmto_soma_depois + rw_lbd.vllanmto;
        vr_vllanmto_soma_depois_tit := vr_vllanmto_soma_depois_tit + rw_lbd.vllanmto;
        
        IF rw_lbd.dtmvtolt > to_date('24/04/2019','DD/MM/RRRR') THEN
          dbms_output.put_line('  * Deletar lançamento do histórico ' || rw_lbd.cdhistor || ' (' ||  rw_lbd.dsextrat || ') no valor de ' || rw_lbd.vllanmto || ' ocorrido em ' || rw_lbd.dtmvtolt || ' na operação');
          DELETE FROM tbdsct_lancamento_bordero lbd WHERE lbd.rowid = rw_lbd.rowid;    
        END IF;
      END LOOP;                      
       
    END IF;
    
    -- inserir lançamento de pagamento dentro da operação com data de 24/04/2019
    IF rw_titulo.pgo_dia_cob = 0 AND rw_titulo.pgo_dia_cc = 0 AND rw_titulo.pgo_antes_cc = 0  THEN
      --dbms_output.put_line('insere lançamento');
      dbms_output.put_line('  * Inserir lançamento do histórico ' || vr_cdhistor || ' no valor de ' || rw_titulo.vldpagto || ' ocorrido em ' || to_date('24/04/2019','DD/MM/RRRR') || ' na operação');
          
      DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => rw_titulo.cdcooper
                                             ,pr_nrdconta => rw_titulo.nrdconta
                                             ,pr_nrborder => rw_titulo.nrborder
                                             ,pr_dtmvtolt => to_date('24/04/2019','DD/MM/RRRR')
                                             ,pr_cdbandoc => rw_titulo.cdbandoc
                                             ,pr_nrdctabb => rw_titulo.nrdctabb
                                             ,pr_nrcnvcob => rw_titulo.nrcnvcob
                                             ,pr_nrdocmto => rw_titulo.nrdocmto
                                             ,pr_nrtitulo => rw_titulo.nrtitulo
                                             ,pr_cdorigem => 5
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_vllanmto => rw_titulo.vldpagto
                                             ,pr_dscritic => vr_dscritic );

      -- Condicao para verificar se houve critica                             
      
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
        RETURN;
      END IF;
      
      IF rw_titulo.vldpagto > rw_titulo.vltitulo THEN
        
        dbms_output.put_line('  * Inserir lançamento do histórico 2804 no valor de ' || (rw_titulo.vldpagto - rw_titulo.vltitulo) || ' na operação por pagamento a maior');
        
        DSCT0003.pc_inserir_lancamento_bordero (pr_cdcooper => rw_titulo.cdcooper
                                               ,pr_nrdconta => rw_titulo.nrdconta
                                               ,pr_nrborder => rw_titulo.nrborder
                                               ,pr_dtmvtolt => to_date('24/04/2019','DD/MM/RRRR')
                                               ,pr_cdbandoc => rw_titulo.cdbandoc
                                               ,pr_nrdctabb => rw_titulo.nrdctabb
                                               ,pr_nrcnvcob => rw_titulo.nrcnvcob
                                               ,pr_nrdocmto => rw_titulo.nrdocmto
                                               ,pr_nrtitulo => rw_titulo.nrtitulo
                                               ,pr_cdorigem => 5
                                               ,pr_cdhistor => 2804
                                               ,pr_vllanmto => (rw_titulo.vldpagto - rw_titulo.vltitulo)
                                               ,pr_dscritic => vr_dscritic );
          
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
          RETURN;
        END IF;
        
        dbms_output.put_line('  * Inserir lançamento do histórico 2758 no valor de ' || (rw_titulo.vldpagto - rw_titulo.vltitulo) || ' na conta do cooperado por pagamento a maior');
        
        -- então lançar o saldo restante como crédito na conta corrente do cooperado
        DSCT0003.pc_efetua_lanc_cc (pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdagenci => rw_titulo.cdagenci
                                   ,pr_cdbccxlt => 100
                                   ,pr_nrdconta => rw_titulo.nrdconta
                                   ,pr_vllanmto => (rw_titulo.vldpagto - rw_titulo.vltitulo)
                                   ,pr_cdhistor => 2758
                                   ,pr_cdcooper => rw_titulo.cdcooper
                                   ,pr_cdoperad => '1'
                                   ,pr_nrborder => rw_titulo.nrborder
                                   ,pr_cdpactra => 0
                                   ,pr_nrdocmto => rw_titulo.nrdocmto
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
        -- Condicao para verificar se houve critica
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
          RETURN;
        END IF;
      END IF;
    END IF;   
    
    IF rw_titulo.pgo_dia_cc > 0 OR rw_titulo.pgo_antes_cc > 0  THEN
      vr_insittit := 3;
      vr_dtdebito := to_date('24/04/2019','DD/MM/RRRR');
      vr_dtdpagto := NULL;
    ELSE
      vr_insittit := 2;
      vr_dtdebito := NULL;
      vr_dtdpagto := to_date('24/04/2019','DD/MM/RRRR');
    END IF;
   
    
    UPDATE craptdb tdb
       SET tdb.vlsldtit = 0,
           tdb.insittit = vr_insittit,
           tdb.dtdebito = vr_dtdebito,
           tdb.dtdpagto = vr_dtdpagto,
           tdb.vliofcpl = vr_vliofcpl,
           tdb.vlpagiof = vr_vlpagiof,
           
           tdb.vlpagmra = nvl((SELECT SUM(lbd.vllanmto) 
                          FROM tbdsct_lancamento_bordero lbd 
                         WHERE lbd.cdcooper = rw_titulo.cdcooper
                           and lbd.nrdconta = rw_titulo.nrdconta
                           and lbd.nrborder = rw_titulo.nrborder
                           and lbd.nrdocmto = rw_titulo.nrdocmto
                           and lbd.cdbandoc = rw_titulo.cdbandoc
                           and lbd.nrcnvcob = rw_titulo.nrcnvcob
                           and lbd.nrdctabb = rw_titulo.nrdctabb
                           AND lbd.cdhistor IN (2686, 2688)),0),
           tdb.vlmratit = nvl((SELECT SUM(lbd.vllanmto) 
                          FROM tbdsct_lancamento_bordero lbd 
                         WHERE lbd.cdcooper = rw_titulo.cdcooper
                           and lbd.nrdconta = rw_titulo.nrdconta
                           and lbd.nrborder = rw_titulo.nrborder
                           and lbd.nrdocmto = rw_titulo.nrdocmto
                           and lbd.cdbandoc = rw_titulo.cdbandoc
                           and lbd.nrcnvcob = rw_titulo.nrcnvcob
                           and lbd.nrdctabb = rw_titulo.nrdctabb 
                           AND lbd.cdhistor IN (2668)),0),
           tdb.vlpagmta = nvl((SELECT SUM(lbd.vllanmto) 
                          FROM tbdsct_lancamento_bordero lbd 
                         WHERE lbd.cdcooper = rw_titulo.cdcooper
                           and lbd.nrdconta = rw_titulo.nrdconta
                           and lbd.nrborder = rw_titulo.nrborder
                           and lbd.nrdocmto = rw_titulo.nrdocmto
                           and lbd.cdbandoc = rw_titulo.cdbandoc
                           and lbd.nrcnvcob = rw_titulo.nrcnvcob
                           and lbd.nrdctabb = rw_titulo.nrdctabb 
                           AND lbd.cdhistor IN (2682, 2684)),0),
           tdb.vlmtatit = nvl((SELECT SUM(lbd.vllanmto) 
                          FROM tbdsct_lancamento_bordero lbd 
                         WHERE lbd.cdcooper = rw_titulo.cdcooper
                           and lbd.nrdconta = rw_titulo.nrdconta
                           and lbd.nrborder = rw_titulo.nrborder
                           and lbd.nrdocmto = rw_titulo.nrdocmto
                           and lbd.cdbandoc = rw_titulo.cdbandoc
                           and lbd.nrcnvcob = rw_titulo.nrcnvcob
                           and lbd.nrdctabb = rw_titulo.nrdctabb 
                           AND lbd.cdhistor IN (2669)),0)                 
     WHERE tdb.cdcooper = rw_titulo.cdcooper
       AND tdb.nrdconta = rw_titulo.nrdconta
       AND tdb.nrborder = rw_titulo.nrborder
       AND tdb.nrcnvcob = rw_titulo.nrcnvcob
       AND tdb.nrdocmto = rw_titulo.nrdocmto
       AND tdb.nrdctabb = rw_titulo.nrdctabb
       AND tdb.cdbandoc = rw_titulo.cdbandoc;
       
    --END IF;  
    
     DSCT0001.pc_efetua_liquidacao_bordero (pr_cdcooper => rw_titulo.cdcooper  --Codigo Cooperativa
                                           ,pr_cdagenci => rw_titulo.cdagenci  --Codigo Agencia
                                           ,pr_nrdcaixa => 0  --Numero do Caixa
                                           ,pr_cdoperad => 0  --Codigo Operador
                                           ,pr_dtmvtolt => to_date('24/04/2019','DD/MM/RRRR')  --Data Movimento
                                           ,pr_idorigem => 5  --Identificador Origem
                                           ,pr_nrdconta => rw_titulo.nrdconta  --Numero da Conta
                                           ,pr_nrborder => rw_titulo.nrborder  --Numero do Bordero
                                           ,pr_tab_erro => vr_tab_erro   --Tabela de erros
                                           ,pr_des_erro => vr_des_erro   --identificador de erro
                                           ,pr_cdcritic => vr_cdcritic   --Código do erro
                                           ,pr_dscritic => vr_dscritic); --Descricao do erro;
    
    IF NVL(LENGTH(TRIM(vr_dscritic)),0) > 0 THEN -- Merge 02/05/2018 - Chamado 851591
      GENE0001.pc_gera_erro(pr_cdcooper => rw_titulo.cdcooper
                           ,pr_cdagenci => rw_titulo.cdagenci
                           ,pr_nrdcaixa => 0
                           ,pr_nrsequen => 1 -- Sequencia
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => vr_tab_erro);
    END IF;

    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
       dbms_output.put_line(vr_dscritic||' pr_nrdconta:' || rw_titulo.nrdconta || ' ,pr_nrborder:' || rw_titulo.nrborder||',');
       RETURN;
    END IF;
    
    dbms_output.put_line('');
    
          
  END LOOP;
  
  COMMIT;
        
END;     
