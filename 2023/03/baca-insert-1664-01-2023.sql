DECLARE
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  vr_cdcooper crapcop.cdcooper%TYPE := 0;
  vr_nrdconta crapass.nrdconta%TYPE := 0;
  vr_nrctremp craplem.nrctremp%TYPE := 0;
  vr_vllanmto craplem.vllanmto%TYPE := 0;
  vr_cdhistor craplem.cdhistor%TYPE := 0;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM CECRED.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN

  vr_cdcooper := 13;
  vr_nrdconta := 148040;
  vr_nrctremp := 248733;
  vr_vllanmto := 23.13;
  vr_cdhistor := 1041;

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;

  CECRED.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
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

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_cdcooper := 10;
  vr_nrdconta := 103594;
  vr_nrctremp := 11004;
  vr_vllanmto := 20.16;
  vr_cdhistor := 2382;

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;

  CECRED.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
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

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_cdcooper := 10;
  vr_nrdconta := 103616;
  vr_nrctremp := 11001;
  vr_vllanmto := 13.93;
  vr_cdhistor := 2382;

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;

  CECRED.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
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
