DECLARE
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto VARCHAR(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_nrdconta crapass.nrdconta%TYPE;
  vr_nrctremp craplem.nrctremp%TYPE;
  vr_vllanmto craplem.vllanmto%TYPE;
  vr_cdhistor craplem.cdhistor%TYPE;
  vr_nrparepr craplem.nrparepr%TYPE;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN
  
  vr_cdcooper := 1;
  vr_nrdconta := 8273332;
  vr_nrctremp := 4248100;

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  
  vr_nrparepr := 0;
  vr_vllanmto := 7792.47;
  vr_cdhistor := 1044;
  
  EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
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
                                  pr_nrparepr => vr_nrparepr,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_nrparepr := 0;
  vr_vllanmto := 3334.93;
  vr_cdhistor := 1048;
  
  EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
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
                                  pr_nrparepr => vr_nrparepr,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
   
  vr_nrparepr := 0;
  vr_vllanmto := 41.91;
  vr_cdhistor := 1040;
  
  EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
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
                                  pr_nrparepr => vr_nrparepr,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_cdcooper := 1;
  vr_nrdconta := 80214118;
  vr_nrctremp := 2956035;

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  
  vr_nrparepr := 0;
  vr_vllanmto := 39.59;
  vr_cdhistor := 3027;
  
  EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
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
                                  pr_nrparepr => vr_nrparepr,
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
    RAISE_application_error(-20500, vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;