DECLARE

  vr_cdcooper cecred.crappep.cdcooper%TYPE;
  vr_nrdconta cecred.crappep.nrdconta%TYPE;
  vr_nrctremp cecred.crappep.nrctremp%TYPE;
  vr_nrparepr cecred.crappep.nrparepr%TYPE;

  PROCEDURE pc_lancamento(pr_cdcooper IN cecred.crappep.cdcooper%TYPE
                         ,pr_nrdconta IN cecred.crappep.nrdconta%TYPE
                         ,pr_nrctremp IN cecred.crappep.nrctremp%TYPE
                         ,pr_nrparepr IN cecred.crappep.nrparepr%TYPE
                         ,pr_cdhistor IN cecred.craplem.cdhistor%TYPE
                         ,pr_vllanmto IN cecred.craplem.vllanmto%TYPE) IS
  
    vr_cdcritic cecred.crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_exc_saida EXCEPTION;
    rw_crapdat cecred.btch0001.cr_crapdat%ROWTYPE;
  
    CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                     ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
      SELECT ass.cdagenci
        FROM cecred.crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  BEGIN
  
    OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH cecred.btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE cecred.btch0001.cr_crapdat;
  
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
    CLOSE cr_crapass;
  
    cecred.empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper,
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                           pr_cdagenci => rw_crapass.cdagenci,
                                           pr_cdbccxlt => 100,
                                           pr_cdoperad => 1,
                                           pr_cdpactra => rw_crapass.cdagenci,
                                           pr_tplotmov => 5,
                                           pr_nrdolote => 600031,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_cdhistor => pr_cdhistor,
                                           pr_nrctremp => pr_nrctremp,
                                           pr_vllanmto => pr_vllanmto,
                                           pr_dtpagemp => rw_crapdat.dtmvtolt,
                                           pr_txjurepr => 0,
                                           pr_vlpreemp => 0,
                                           pr_nrsequni => 0,
                                           pr_nrparepr => pr_nrparepr,
                                           pr_flgincre => FALSE,
                                           pr_flgcredi => FALSE,
                                           pr_nrseqava => 0,
                                           pr_cdorigem => 5,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
  
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE_application_error(-20500, vr_dscritic);
    END IF;
  
  EXCEPTION
  
    WHEN OTHERS THEN
      RAISE_application_error(-20500, SQLCODE || ' ' || SQLERRM);
    
  END;

BEGIN

  vr_cdcooper := 13;
  vr_nrdconta := 33294;
  vr_nrctremp := 116931;
  vr_nrparepr := 18;

  pc_lancamento(pr_cdcooper => vr_cdcooper,
                pr_nrdconta => vr_nrdconta,
                pr_nrctremp => vr_nrctremp,
                pr_nrparepr => vr_nrparepr,
                pr_cdhistor => 3027,
                pr_vllanmto => 79.71);

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLCODE || ' ' || SQLERRM);
    ROLLBACK;
  
END;
