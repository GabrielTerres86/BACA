DECLARE
  vr_cdcooper cecred.crapcop.cdcooper%TYPE;
  vr_nrdconta cecred.crapass.nrdconta%TYPE;
  vr_nrctremp cecred.craplem.nrctremp%TYPE;
  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  rw_crapdat  cecred.btch0001.cr_crapdat%ROWTYPE;
  vr_exc_saida EXCEPTION;
  vr_qtprepag cecred.crapepr.qtprepag%TYPE;
  vr_vlpagpar cecred.crappep.vlpagpar%TYPE;
  vr_cdhistor cecred.craplem.cdhistor%TYPE;
  vr_vllanmto cecred.craplem.vllanmto%TYPE;

  CURSOR cr_pag(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
               ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE
               ,pr_nrctremp IN cecred.craplem.nrctremp%TYPE) IS
    SELECT pag.*
      FROM tbepr_consignado_pagamento pag
     WHERE pag.cdcooper = pr_cdcooper
       AND pag.nrdconta = pr_nrdconta
       AND pag.nrctremp = pr_nrctremp
       AND pag.nrparepr between 40 AND 48;
  rw_pag cr_pag%ROWTYPE;

  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN
  FOR i IN 1 .. 2 LOOP
    IF i = 1 THEN
      vr_cdcooper := 1;
      vr_nrdconta := 10878211;
      vr_nrctremp := 7225058;
      vr_qtprepag := 22;
      vr_vlpagpar := 113.13;
      vr_cdhistor := 3918;
      vr_vllanmto := 5.24;
    ELSE
      vr_cdcooper := 13;
      vr_nrdconta := 23388;
      vr_nrctremp := 259182;
      vr_qtprepag := 48;
      vr_vlpagpar := 467.99;
      vr_cdhistor := 3918;
      vr_vllanmto := 56.25;
    END IF;
  
    UPDATE CECRED.CRAPEPR
       SET QTPREPAG = vr_qtprepag
          ,VLSDEVED = 0.0000000000
          ,INLIQUID = 1
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = vr_nrdconta
       AND nrctremp = vr_nrctremp;
  
    UPDATE CECRED.CRAPPEP
       SET VLPAGPAR = vr_vlpagpar
          ,INLIQUID = 1
          ,VLSDVATU = 0.0000000000
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = vr_nrdconta
       AND nrctremp = vr_nrctremp
       AND inliquid = 0;
  
    OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH cecred.btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE cecred.btch0001.cr_crapdat;
  
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
    CLOSE cr_crapass;
  
    IF i = 1 THEN
    
      cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
                                             pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                             pr_cdagenci => rw_crapass.cdagenci,
                                             pr_cdbccxlt => 100,
                                             pr_cdoperad => 1,
                                             pr_cdpactra => rw_crapass.cdagenci,
                                             pr_tplotmov => 5,
                                             pr_nrdolote => 600031,
                                             pr_nrdconta => vr_nrdconta,
                                             pr_cdhistor => vr_cdhistor,
                                             pr_nrctremp => vr_nrctremp,
                                             pr_vllanmto => vr_vllanmto,
                                             pr_dtpagemp => rw_crapdat.dtmvtolt,
                                             pr_txjurepr => 0,
                                             pr_vlpreemp => 0,
                                             pr_nrsequni => 0,
                                             pr_nrparepr => 0,
                                             pr_flgincre => FALSE,
                                             pr_flgcredi => FALSE,
                                             pr_nrseqava => 0,
                                             pr_cdorigem => 5,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);
    ELSE
      OPEN cr_pag(pr_cdcooper => vr_cdcooper,
                  pr_nrdconta => vr_nrdconta,
                  pr_nrctremp => vr_nrctremp);
      LOOP
        FETCH cr_pag
          INTO rw_pag;
        EXIT WHEN cr_pag%NOTFOUND;
      
        cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
                                               pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                               pr_cdagenci => rw_crapass.cdagenci,
                                               pr_cdbccxlt => 100,
                                               pr_cdoperad => 1,
                                               pr_cdpactra => rw_crapass.cdagenci,
                                               pr_tplotmov => 5,
                                               pr_nrdolote => 600031,
                                               pr_nrdconta => vr_nrdconta,
                                               pr_cdhistor => 3027,
                                               pr_nrctremp => vr_nrctremp,
                                               pr_vllanmto => rw_pag.vlparepr,
                                               pr_dtpagemp => rw_crapdat.dtmvtolt,
                                               pr_txjurepr => 0,
                                               pr_vlpreemp => 0,
                                               pr_nrsequni => 0,
                                               pr_nrparepr => 0,
                                               pr_flgincre => FALSE,
                                               pr_flgcredi => FALSE,
                                               pr_nrseqava => 0,
                                               pr_cdorigem => 5,
                                               pr_cdcritic => vr_cdcritic,
                                               pr_dscritic => vr_dscritic);
      END LOOP;
      CLOSE cr_pag;
      cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
                                             pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                             pr_cdagenci => rw_crapass.cdagenci,
                                             pr_cdbccxlt => 100,
                                             pr_cdoperad => 1,
                                             pr_cdpactra => rw_crapass.cdagenci,
                                             pr_tplotmov => 5,
                                             pr_nrdolote => 600031,
                                             pr_nrdconta => vr_nrdconta,
                                             pr_cdhistor => vr_cdhistor,
                                             pr_nrctremp => vr_nrctremp,
                                             pr_vllanmto => vr_vllanmto,
                                             pr_dtpagemp => rw_crapdat.dtmvtolt,
                                             pr_txjurepr => 0,
                                             pr_vlpreemp => 0,
                                             pr_nrsequni => 0,
                                             pr_nrparepr => 0,
                                             pr_flgincre => FALSE,
                                             pr_flgcredi => FALSE,
                                             pr_nrseqava => 0,
                                             pr_cdorigem => 5,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);
    
    END IF;
  
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    COMMIT;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;