DECLARE

  vr_exc_saida EXCEPTION;

  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  rw_crapdat cecred.btch0001.cr_crapdat%ROWTYPE;

  vr_cdcooper cecred.crapcop.cdcooper%TYPE := 1;
  vr_nrdconta cecred.crapass.nrdconta%TYPE := 89702239; --conta prod 10297707
  vr_nrctremp cecred.craplem.nrctremp%TYPE := 3093689;

  vr_cdhistor cecred.craplem.cdhistor%TYPE;
  vr_vllanmto cecred.craplem.vllanmto%TYPE;

  vr_nrparepr cecred.crappep.nrparepr%TYPE;
  vr_vlparepr cecred.crappep.vlparepr%TYPE;
  vr_vlmtapar cecred.crappep.vlmtapar%TYPE;
  vr_vlmrapar cecred.crappep.vlmrapar%TYPE;

  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  PROCEDURE pc_update_crappep_crapepr(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                                     ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE
                                     ,pr_nrctremp IN cecred.craplem.nrctremp%TYPE
                                     ,pr_nrparepr IN cecred.crappep.nrparepr%TYPE
                                     ,pr_vlparepr IN cecred.crappep.vlparepr%TYPE
                                     ,pr_vlmtapar IN cecred.crappep.vlmtapar%TYPE
                                     ,pr_vlmrapar IN cecred.crappep.vlmrapar%TYPE) IS
  BEGIN
  
    UPDATE cecred.crappep pep
       SET pep.vlparepr = pr_vlparepr
          ,pep.vlsdvatu = pr_vlparepr
          ,pep.vlsdvpar = pr_vlparepr
          ,pep.vlmtapar = pr_vlmtapar
          ,pep.vlmrapar = pr_vlmrapar
          ,pep.vlpagmta = 0.00
          ,pep.vlpagmra = 0.00
          ,pep.inliquid = 0 --??
          ,pep.dtultpag = NULL --??
          ,pep.vlpagpar = 0.00
     WHERE pep.cdcooper = pr_cdcooper
       AND pep.nrdconta = pr_nrdconta
       AND pep.nrctremp = pr_nrctremp
       AND pep.nrparepr = pr_nrparepr;
  
    UPDATE cecred.crapepr epr
       SET epr.vlsdevat = epr.vlsdevat + pr_vlparepr + pr_vlmtapar + pr_vlmrapar
          ,epr.vlsdeved = epr.vlsdeved + pr_vlparepr
     WHERE epr.cdcooper = pr_cdcooper
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctremp;
  
  EXCEPTION
  
    WHEN OTHERS THEN
    
      RAISE vr_exc_saida;
    
  END pc_update_crappep_crapepr;

BEGIN

  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH cecred.btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE cecred.btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;

  vr_cdhistor := 3274;
  vr_vllanmto := 3423.29;

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
                                         pr_nrparepr => NULL,
                                         pr_flgincre => FALSE,
                                         pr_flgcredi => FALSE,
                                         pr_nrseqava => 0,
                                         pr_cdorigem => 5,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_nrparepr := 24;
  vr_vlparepr := 3.423.29; --??
  vr_vlmtapar := 72.68;
  vr_vlmrapar := 161.46;

  pc_update_crappep_crapepr(pr_cdcooper => vr_cdcooper,
                            pr_nrdconta => vr_nrdconta,
                            pr_nrctremp => vr_nrctremp,
                            pr_nrparepr => vr_nrparepr,
                            pr_vlparepr => vr_vlparepr,
                            pr_vlmtapar => vr_vlmtapar,
                            pr_vlmrapar => vr_vlmrapar);

  COMMIT;

EXCEPTION

  WHEN vr_exc_saida THEN
  
    ROLLBACK;
  
  WHEN OTHERS THEN
  
    ROLLBACK;
  
END;
