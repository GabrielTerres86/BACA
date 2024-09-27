DECLARE
  vr_registros      cecred.GENE0002.typ_split;
  vr_aux_reg        cecred.GENE0002.typ_split;
  vr_indexreg       INTEGER;
  vr_cdcooper       crapcop.cdcooper%TYPE;
  vr_progress_recid crapass.progress_recid%TYPE;  
  vr_nrborder       crapbdt.nrborder%TYPE;
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_cdcritic       crapcri.cdcritic%TYPE;
  vr_nrdrowid       ROWID;

  
  CURSOR cr_crapass(pr_cdcooper       IN cecred.crapass.cdcooper%TYPE,
                    pr_nrborder       IN cecred.crapbdt.nrborder%TYPE
                   ,pr_progress_recid IN cecred.crapass.progress_recid%TYPE) IS
    SELECT a.nrdconta
      FROM cecred.crapass a,
           cecred.crapbdt b
     WHERE a.cdcooper = b.cdcooper
       AND b.nrborder = pr_nrborder
       AND a.cdcooper = pr_cdcooper
       AND a.progress_recid = pr_progress_recid;
  rw_crapass cr_crapass%ROWTYPE;
  
  
   PROCEDURE pc_transferir_prejuizo (pr_cdcooper IN crapcop.cdcooper%TYPE    
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE    
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE 
                                    ,pr_dscritic OUT VARCHAR2) IS
                                    
    vr_cdhistordsct_principal           CONSTANT craphis.cdhistor%TYPE := 2754; 
    vr_cdhistordsct_juros_60_rem        CONSTANT craphis.cdhistor%TYPE := 2755; 
    vr_cdhistordsct_juros_60_mor        CONSTANT craphis.cdhistor%TYPE := 2761; 
    vr_cdhistordsct_multa_atraso        CONSTANT craphis.cdhistor%TYPE := 2764; 
    vr_cdhistordsct_juros_mora          CONSTANT craphis.cdhistor%TYPE := 2765; 
    vr_cdhistordsct_juros_60_mul        CONSTANT craphis.cdhistor%TYPE := 2879; 
    vr_cdhistordsct_aprop_tit           CONSTANT craphis.cdhistor%TYPE := 2667; 
    vr_cdhistordsct_juros_atuali        CONSTANT craphis.cdhistor%TYPE := 2763; 
    vr_cdhistordsct_rec_principal       CONSTANT craphis.cdhistor%TYPE := 2770; 
    vr_cdhistordsct_rec_jur_60          CONSTANT craphis.cdhistor%TYPE := 2771; 
    vr_cdhistordsct_rec_jur_atuali      CONSTANT craphis.cdhistor%TYPE := 2772; 
    vr_cdhistordsct_rec_mult_atras      CONSTANT craphis.cdhistor%TYPE := 2773; 
    vr_cdhistordsct_rec_jur_mora        CONSTANT craphis.cdhistor%TYPE := 2774; 
    vr_cdhistordsct_rec_abono           CONSTANT craphis.cdhistor%TYPE := 2689; 
    vr_cdhistordsct_rec_preju           CONSTANT craphis.cdhistor%TYPE := 2876; 
    vr_cdhistordsct_recup_preju         CONSTANT craphis.cdhistor%TYPE := 2386; 
    vr_cdhistordsct_recup_iof           CONSTANT craphis.cdhistor%TYPE := 2317; 
    vr_cdhistordsct_est_rec_princi      CONSTANT craphis.cdhistor%TYPE := 2387; 
    vr_cdhistordsct_est_principal       CONSTANT craphis.cdhistor%TYPE := 2775; 
    vr_cdhistordsct_est_jur_60          CONSTANT craphis.cdhistor%TYPE := 2776; 
    vr_cdhistordsct_est_jur_prej        CONSTANT craphis.cdhistor%TYPE := 2777; 
    vr_cdhistordsct_est_mult_atras      CONSTANT craphis.cdhistor%TYPE := 2778; 
    vr_cdhistordsct_est_jur_mor         CONSTANT craphis.cdhistor%TYPE := 2779; 
    vr_cdhistordsct_est_abono           CONSTANT craphis.cdhistor%TYPE := 2690; 
    vr_cdhistordsct_est_preju           CONSTANT craphis.cdhistor%TYPE := 2877; 
                                                                    
    CURSOR cr_crapbdt IS
      SELECT
        bdt.rowid AS id,
        bdt.nrborder,
        bdt.nrdconta,
        bdt.cdcooper,
        bdt.inprejuz,
        bdt.dtlibbdt,
        bdt.insitbdt,
        bdt.qtdirisc,
        bdt.nrinrisc
      FROM
        crapbdt bdt
      WHERE
        bdt.nrborder = pr_nrborder
        AND bdt.cdcooper = pr_cdcooper;
    rw_crapbdt cr_crapbdt%ROWTYPE;

    CURSOR cr_crapbdt_prej (pr_nrdconta craptdb.nrdconta%TYPE, pr_cdcooper craptdb.cdcooper%TYPE, pr_nrborder craptdb.nrborder%TYPE)  IS
      SELECT
        SUM(tdb.vlprejuz) AS vlprejuz,
        SUM(tdb.vlsdprej) AS vlsdprej,
        SUM(tdb.vlttmupr) AS vlttmupr,
        SUM(tdb.vlttjmpr) AS vlttjmpr,
        SUM(tdb.vliofprj) AS vliofprj,
        SUM((vljura60 - vlpgjm60)) AS sdjura60
      FROM
        craptdb tdb
      WHERE
        tdb.nrdconta = pr_nrdconta
        AND tdb.cdcooper = pr_cdcooper
        AND tdb.nrborder = pr_nrborder
      GROUP BY
        tdb.nrborder,
        tdb.cdcooper,
        tdb.nrdconta
      ;
    rw_crapbdt_prej cr_crapbdt_prej%ROWTYPE;


    CURSOR cr_tdb60 (pr_cdcooper crapbdt.cdcooper%TYPE, pr_dtmvtolt crapdat.dtmvtolt%TYPE, pr_nrborder crapbdt.nrborder%TYPE, pr_nrdconta crapbdt.nrdconta%TYPE) IS
      SELECT
         SUM((x.dtvencto-x.dtvenmin60+1)*txdiaria*vltitulo) AS vljurrec, 
         cdcooper,
         nrborder,
         nrdconta,
         rowtdb
      FROM (
          SELECT UNIQUE
            tdb.dtvencto,
            tdb.vltitulo,
            tdb.cdcooper,
            tdb.nrborder,
            tdb.nrdconta,
            (tdb.dtvencto-tdb.dtlibbdt) AS qtd_dias, 
            (tdv.dtvenmin+60) AS dtvenmin60,
            ((bdt.txmensal/100)/30) AS txdiaria,
            tdb.rowid rowtdb
          FROM
            craptdb tdb
            INNER JOIN (SELECT cdcooper
                              ,nrdconta
                              ,nrborder
                              ,MIN(dtvencto) dtvenmin
                        FROM craptdb
                        WHERE (dtvencto+60) < pr_dtmvtolt
                          AND insittit = 4
                          AND cdcooper = pr_cdcooper
                          AND nrborder = pr_nrborder
                          AND nrdconta = pr_nrdconta
                         GROUP BY cdcooper
                                 ,nrdconta
                                 ,nrborder
                        ) tdv ON tdb.cdcooper = tdv.cdcooper 
                             AND tdb.nrdconta = tdv.nrdconta 
                             AND tdb.nrborder = tdv.nrborder
            INNER JOIN crapbdt bdt ON bdt.nrborder=tdb.nrborder AND bdt.cdcooper=tdb.cdcooper AND bdt.flverbor=1
            INNER JOIN crapass ass ON bdt.nrdconta=ass.nrdconta AND bdt.cdcooper=ass.cdcooper
          WHERE 1=1
            AND tdb.insittit = 4
            AND tdb.dtvencto >= (tdv.dtvenmin+60)
            AND tdb.nrborder = pr_nrborder
            AND tdb.nrdconta = pr_nrdconta
            AND tdb.cdcooper = pr_cdcooper
        ) x
        GROUP BY
          cdcooper,
          nrborder,
          nrdconta,
          rowtdb ;
    rw_craptdb60 cr_tdb60%ROWTYPE;

    CURSOR cr_craptdb (pr_nrborder craptdb.nrborder%TYPE,pr_nrdconta craptdb.nrdconta%TYPE, pr_cdcooper craptdb.cdcooper%TYPE) IS
      SELECT
        ROWID id,
        (craptdb.vlmtatit - craptdb.vlpagmta) AS vlmtatit_restante,
        (craptdb.vlmratit - craptdb.vlpagmra) AS vlmratit_restante,
        vlmratit,
        nrtitulo,
        cdcooper,
        nrdconta,
        nrborder,
        cdbandoc,
        nrdctabb,
        nrcnvcob,
        nrdocmto,
        dtvencto,
        vltitulo
      FROM
        craptdb
      WHERE
        craptdb.nrborder = pr_nrborder
        AND craptdb.nrdconta = pr_nrdconta
        AND craptdb.insittit = 4 
        AND craptdb.cdcooper = pr_cdcooper;

    CURSOR cr_lancboraprop(pr_cdcooper IN craptdb.cdcooper%TYPE 
                          ,pr_nrdconta IN crapass.nrdconta%TYPE 
                          ,pr_nrborder IN crapbdt.nrborder%TYPE 
                          ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE 
                          ,pr_cdhistor IN craphis.cdhistor%TYPE 
                          ,pr_cdbandoc IN craptdb.cdbandoc%TYPE 
                          ,pr_nrdctabb IN craptdb.nrdctabb%TYPE 
                          ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE 
                          ,pr_nrdocmto IN craptdb.nrdocmto%TYPE 
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
       AND lcb.dtmvtolt <= pr_dtmvtolt
       AND lcb.dtestorn IS NULL;
    rw_lancboraprop cr_lancboraprop%ROWTYPE;

    CURSOR cr_crapljt(pr_cdcooper IN craptdb.cdcooper%TYPE     
                     ,pr_nrdconta IN crapass.nrdconta%TYPE     
                     ,pr_nrborder IN crapbdt.nrborder%TYPE     
                     ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS 
      SELECT SUM(ljt.vldjuros) vldjuro
        FROM crapljt ljt 
       WHERE cdcooper = pr_cdcooper 
         AND nrdconta = pr_nrdconta
         AND nrborder = pr_nrborder
         AND dtrefere >= pr_dtmvtolt;
    rw_crapljt   cr_crapljt%ROWTYPE;

    rw_crapdat   btch0001.cr_crapdat%rowtype;

    vr_jurmor60 NUMBER;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION;

    BEGIN
      
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;

      OPEN cr_crapbdt;
      FETCH cr_crapbdt INTO rw_crapbdt;
      IF (cr_crapbdt%NOTFOUND) THEN
        CLOSE cr_crapbdt;
        vr_cdcritic := 1166;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapbdt;

      IF (rw_crapbdt.inprejuz=1) THEN
        vr_dscritic := 'Bordero ja esta em prejuizo';
        RAISE vr_exc_erro;
      END IF;

      IF (rw_crapbdt.insitbdt<>3) THEN
        vr_cdcritic := 1175; 
        RAISE vr_exc_erro;
      END IF;

      UPDATE
        crapbdt
      SET
        inprejuz = 1,
        dtprejuz = rw_crapdat.dtmvtolt,
        nrinrisc = 10,
        qtdirisc = 0
      WHERE
        ROWID = rw_crapbdt.id
      ;


      UPDATE
        craptdb
      SET
        vlprejuz = vlsldtit + (vlmratit - vlpagmra) - (vljura60 - vlpgjm60),
        vlsdprej = vlsldtit, 
        vlttmupr = vlmtatit - vlpagmta,
        vljrmprj = 0, 
        vlttjmpr = vlmratit - vlpagmra, 
        vlpgjmpr = 0,
        vlpgmupr = 0, 
        vlsprjat = 0, 
        vljraprj = 0, 
        vliofprj = (vliofcpl - vlpagiof), 
        vliofppr = 0,
        vlpgjrpr = 0 
      WHERE nrborder = rw_crapbdt.nrborder
        AND nrdconta = rw_crapbdt.nrdconta
        AND insittit = 4 
        AND cdcooper = rw_crapbdt.cdcooper;    

      vr_jurmor60 := 0;
      OPEN cr_tdb60(pr_nrdconta => rw_crapbdt.nrdconta
                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                   ,pr_cdcooper => rw_crapbdt.cdcooper
                   ,pr_nrborder => rw_crapbdt.nrborder);
      LOOP
        FETCH cr_tdb60 INTO rw_craptdb60;
        EXIT WHEN cr_tdb60%NOTFOUND;
        
        vr_jurmor60 := vr_jurmor60 + rw_craptdb60.vljurrec;

        UPDATE craptdb tdb
           SET vlprejuz = vlprejuz - rw_craptdb60.vljurrec
         WHERE tdb.rowid = rw_craptdb60.rowtdb;
      END LOOP;
      CLOSE cr_tdb60;
      vr_jurmor60 := round(vr_jurmor60,2);

      IF (vr_jurmor60 > 0) THEN
        DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_crapbdt.nrdconta
                                     ,pr_nrborder => rw_crapbdt.nrborder
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdorigem => 5
                                     ,pr_cdhistor => vr_cdhistordsct_juros_60_rem
                                     ,pr_vllanmto => vr_jurmor60
                                     ,pr_dscritic => vr_dscritic );
        IF (TRIM(vr_dscritic) IS NOT NULL) THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      
      OPEN cr_crapbdt_prej(pr_nrdconta => rw_crapbdt.nrdconta, pr_cdcooper => rw_crapbdt.cdcooper, pr_nrborder => rw_crapbdt.nrborder);
      FETCH cr_crapbdt_prej INTO rw_crapbdt_prej;
      CLOSE cr_crapbdt_prej;

      IF (rw_crapbdt_prej.sdjura60 > 0) THEN
        DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_crapbdt.nrdconta
                                     ,pr_nrborder => rw_crapbdt.nrborder
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdorigem => 5
                                     ,pr_cdhistor => vr_cdhistordsct_juros_60_mor
                                     ,pr_vllanmto => rw_crapbdt_prej.sdjura60
                                     ,pr_dscritic => vr_dscritic );
        IF (TRIM(vr_dscritic) IS NOT NULL) THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_crapbdt.nrdconta
                                            ,pr_nrborder => rw_crapbdt.nrborder
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_cdorigem => 5
                                            ,pr_cdhistor => vr_cdhistordsct_principal
                                            ,pr_vllanmto => rw_crapbdt_prej.vlprejuz
                                            ,pr_dscritic => vr_dscritic );
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
      DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_crapbdt.nrdconta
                                   ,pr_nrborder => rw_crapbdt.nrborder
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdorigem => 5
                                   ,pr_cdhistor => vr_cdhistordsct_multa_atraso
                                   ,pr_vllanmto => rw_crapbdt_prej.vlttmupr
                                   ,pr_dscritic => vr_dscritic );
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
      DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_crapbdt.nrdconta
                                   ,pr_nrborder => rw_crapbdt.nrborder
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdorigem => 5
                                   ,pr_cdhistor => vr_cdhistordsct_juros_60_mul
                                   ,pr_vllanmto => rw_crapbdt_prej.vlttmupr
                                   ,pr_dscritic => vr_dscritic );
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
      DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_crapbdt.nrdconta
                                   ,pr_nrborder => rw_crapbdt.nrborder
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdorigem => 5
                                   ,pr_cdhistor => vr_cdhistordsct_juros_mora
                                   ,pr_vllanmto => rw_crapbdt_prej.sdjura60
                                   ,pr_dscritic => vr_dscritic );
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;


      OPEN cr_crapljt(pr_cdcooper => rw_crapbdt.cdcooper
                     ,pr_nrdconta => rw_crapbdt.nrdconta
                     ,pr_nrborder => rw_crapbdt.nrborder
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
      FETCH cr_crapljt INTO rw_crapljt;
      CLOSE cr_crapljt;
      
      IF rw_crapljt.vldjuro > 0 THEN 
        DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => rw_crapbdt.cdcooper
                                              ,pr_nrdconta => rw_crapbdt.nrdconta
                                              ,pr_nrborder => rw_crapbdt.nrborder
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              ,pr_cdorigem => 5
                                              ,pr_cdhistor => vr_cdhistordsct_aprop_tit
                                              ,pr_vllanmto => rw_crapljt.vldjuro
                                              ,pr_dscritic => vr_dscritic );
        IF (TRIM(vr_dscritic) IS NOT NULL) THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;


      FOR rw_craptdb IN cr_craptdb (pr_nrborder => rw_crapbdt.nrborder,
                                     pr_nrdconta => rw_crapbdt.nrdconta,
                                     pr_cdcooper => pr_cdcooper) LOOP
        
        IF rw_craptdb.vlmtatit_restante > 0 THEN
          DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => rw_craptdb.cdcooper
                                       ,pr_nrdconta => rw_craptdb.nrdconta
                                       ,pr_nrborder => rw_craptdb.nrborder
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_cdbandoc => rw_craptdb.cdbandoc
                                       ,pr_nrdctabb => rw_craptdb.nrdctabb
                                       ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                       ,pr_nrdocmto => rw_craptdb.nrdocmto
                                       ,pr_nrtitulo => rw_craptdb.nrtitulo
                                       ,pr_cdorigem => 5
                                       ,pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurmta
                                       ,pr_vllanmto => rw_craptdb.vlmtatit_restante
                                       ,pr_dscritic => vr_dscritic );


          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;
        IF rw_craptdb.vlmratit_restante > 0  THEN
          OPEN cr_lancboraprop(pr_cdcooper => rw_craptdb.cdcooper
                              ,pr_nrdconta => rw_craptdb.nrdconta
                              ,pr_nrborder => rw_craptdb.nrborder
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurmra
                              ,pr_cdbandoc => rw_craptdb.cdbandoc
                              ,pr_nrdctabb => rw_craptdb.nrdctabb
                              ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                              ,pr_nrdocmto => rw_craptdb.nrdocmto
                              );
          FETCH cr_lancboraprop INTO rw_lancboraprop;
          CLOSE cr_lancboraprop;

          DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => rw_craptdb.cdcooper
                                       ,pr_nrdconta => rw_craptdb.nrdconta
                                       ,pr_nrborder => rw_craptdb.nrborder
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_cdbandoc => rw_craptdb.cdbandoc
                                       ,pr_nrdctabb => rw_craptdb.nrdctabb
                                       ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                       ,pr_nrdocmto => rw_craptdb.nrdocmto
                                       ,pr_nrtitulo => rw_craptdb.nrtitulo
                                       ,pr_cdorigem => 5
                                       ,pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurmra
                                       ,pr_vllanmto => (rw_craptdb.vlmratit - nvl(rw_lancboraprop.vllanmto,0))
                                       ,pr_dscritic => vr_dscritic );


          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END LOOP;

      PREJ0005.pc_bloqueio_conta_corrente(pr_cdcooper => rw_crapbdt.cdcooper
                                 ,pr_nrdconta => rw_crapbdt.nrdconta
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
      IF (nvl(vr_cdcritic,0)>0 OR vr_dscritic IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao não tratado na rotina pc_transferir_prejuizo: ' ||SQLERRM;
  END pc_transferir_prejuizo;

    
  
BEGIN 
  vr_registros := cecred.GENE0002.fn_quebra_string(pr_string  =>
'6;1061612;24410|' ||
'6;1061612;24496|' ||
'6;1061612;24375|' ||
'6;1061612;24141|' ||
'6;1061612;23828|' ||
'6;1061612;23766|' ||
'6;1061612;24437|' ||
'6;1061612;23598|' ||
'6;1061612;23722|' ||
'6;1061612;23640|' ||
'6;1061612;24024|' ||
'6;1061612;23778|' ||
'6;1061612;23813|' ||
'6;1061612;24302|' ||
'6;1061612;24275|'
,pr_delimit => '|');


  FOR vr_indexreg IN 1..(vr_registros.COUNT-1) LOOP  
    
      vr_aux_reg := gene0002.fn_quebra_string(vr_registros(vr_indexreg),';');                                                                                          

      vr_cdcooper       := vr_aux_reg(1);
      vr_progress_recid := vr_aux_reg(2);
      vr_nrborder       := vr_aux_reg(3);

      OPEN cr_crapass(pr_cdcooper       => vr_cdcooper
                     ,pr_nrborder       => vr_nrborder
                     ,pr_progress_recid => vr_progress_recid);
      FETCH cr_crapass
       INTO rw_crapass;
          IF cr_crapass%FOUND THEN
            
             pc_transferir_prejuizo(pr_cdcooper => vr_cdcooper
                                   ,pr_nrborder => vr_nrborder
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);

             IF (NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL) THEN
 
               GENE0001.pc_gera_log(pr_cdcooper =>  vr_cdcooper
                                   ,pr_cdoperad => '1'
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                                   ,pr_dstransa => 'Erro ao transferir bordero para prejuizo - bordero:' || vr_nrborder
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_flgtrans => 1
                                   ,pr_hrtransa => gene0002.fn_busca_time
                                   ,pr_idseqttl => 1
                                   ,pr_nmdatela => 'Script'
                                   ,pr_nrdconta => rw_crapass.nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);
                                 
             END IF;

          END IF;
      
      CLOSE cr_crapass;   
      COMMIT;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    Raise_Application_Error(-20002, 'Erro Geral no Script. Erro: ' || sqlerrm);
END;
