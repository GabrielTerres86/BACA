DECLARE
  vr_cdcritic CECRED.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat CECRED.BTCH0001.cr_crapdat%ROWTYPE;

  vr_cdcooper CECRED.crapcop.cdcooper%TYPE;
  vr_nrdconta CECRED.crapass.nrdconta%TYPE;
  vr_nrctremp CECRED.craplem.nrctremp%TYPE;
  vr_vllanmto CECRED.craplem.vllanmto%TYPE;
  vr_cdhistor CECRED.craplem.cdhistor%TYPE;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM CECRED.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN
  
  vr_cdcooper := 1;
  vr_nrdconta := 12834521;
  vr_nrctremp := 6299419;
  vr_vllanmto := 82.91;
  vr_cdhistor := 2382;

  OPEN CECRED.btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH CECRED.btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE CECRED.btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;

  CECRED.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdagenci => rw_crapass.cdagenci
                                        ,pr_cdbccxlt => 100
                                        ,pr_cdoperad => 1
                                        ,pr_cdpactra => rw_crapass.cdagenci
                                        ,pr_tplotmov => 5
                                        ,pr_nrdolote => 600031
                                        ,pr_nrdconta => vr_nrdconta
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_nrctremp => vr_nrctremp
                                        ,pr_vllanmto => vr_vllanmto
                                        ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                        ,pr_txjurepr => 0
                                        ,pr_vlpreemp => 0
                                        ,pr_nrsequni => 0
                                        ,pr_nrparepr => 0
                                        ,pr_flgincre => FALSE
                                        ,pr_flgcredi => FALSE
                                        ,pr_nrseqava => 0
                                        ,pr_cdorigem => 5
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_cdcooper := 9;
  vr_nrdconta := 506206;
  vr_nrctremp := 20200014;
  vr_vllanmto := 802.92;
  vr_cdhistor := 1041;

  OPEN CECRED.btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH CECRED.btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE CECRED.btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;

  CECRED.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdagenci => rw_crapass.cdagenci
                                        ,pr_cdbccxlt => 100
                                        ,pr_cdoperad => 1
                                        ,pr_cdpactra => rw_crapass.cdagenci
                                        ,pr_tplotmov => 5
                                        ,pr_nrdolote => 600031
                                        ,pr_nrdconta => vr_nrdconta
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_nrctremp => vr_nrctremp
                                        ,pr_vllanmto => vr_vllanmto
                                        ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                        ,pr_txjurepr => 0
                                        ,pr_vlpreemp => 0
                                        ,pr_nrsequni => 0
                                        ,pr_nrparepr => 0
                                        ,pr_flgincre => FALSE
                                        ,pr_flgcredi => FALSE
                                        ,pr_nrseqava => 0
                                        ,pr_cdorigem => 5
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;



  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
    RAISE_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
