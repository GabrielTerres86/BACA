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

  
  vr_cdcooper := 9;
  vr_nrdconta := 501166;
  vr_nrctremp := 21100098;

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  
  
  vr_nrparepr := 1;
  vr_vllanmto := 103.99;
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
  
  
  vr_vllanmto := 0.92;
  vr_cdhistor := 2311;
  
  
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
  
  
  vr_vllanmto := 2.08;
  vr_cdhistor := 1047;
  
  
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
  
  
  vr_vllanmto := 2.76;
  vr_cdhistor := 1077;
  
  
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
  
  
  vr_cdcooper := 9;
  vr_nrdconta := 504939;
  vr_nrctremp := 20100546;
  
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  
  
  vr_nrparepr := 1;
  vr_vllanmto := 47.13;
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
  
  
  vr_vllanmto := 0.25;
  vr_cdhistor := 2311;
  
  
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
  
  
  vr_vllanmto := 0.94;
  vr_cdhistor := 1047;
  
  
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

  vr_vllanmto := 0.76;
  vr_cdhistor := 1077;
  
  
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
  
  vr_cdcooper := 9;
  vr_nrdconta := 500992;
  vr_nrctremp := 21100184;
  
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  
  
  vr_nrparepr := 2;
  vr_vllanmto := 259.74;
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
  
  
  vr_vllanmto := 1.36;
  vr_cdhistor := 2311;
  
  
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
  
  
  vr_vllanmto := 5.19;
  vr_cdhistor := 1047;
  
  
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
  
  vr_vllanmto := 4.17;
  vr_cdhistor := 1077;
  
  
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
  
  vr_vllanmto := 197.43;
  vr_cdhistor := 1041;
  
  
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
  
  vr_cdcooper := 9;
  vr_nrdconta := 512591;
  vr_nrctremp := 19100716;
  
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  
  
  vr_nrparepr := 1;
  vr_vllanmto := 271.15;
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
  
  
  vr_vllanmto := 2.42;
  vr_cdhistor := 2311;
  
  
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
  
  
  vr_vllanmto := 5.42;
  vr_cdhistor := 1047;
  
  
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
  
  vr_vllanmto := 7.29;
  vr_cdhistor := 1077;
  
  
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
  
  vr_vllanmto := 1.83;
  vr_cdhistor := 1041;
  
  
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
  
  vr_cdcooper := 9;
  vr_nrdconta := 503550;
  vr_nrctremp := 20100548;
  
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  
  
  vr_nrparepr := 1;
  vr_vllanmto := 177.98;
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
  
  
  vr_vllanmto := 1.65;
  vr_cdhistor := 2311;
  
  
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
  
  
  vr_vllanmto := 3.56;
  vr_cdhistor := 1047;
  
  
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
  
  vr_vllanmto := 4.96;
  vr_cdhistor := 1077;
  
  
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
  
  vr_vllanmto := 0.20;
  vr_cdhistor := 1041;
  
  
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
  
   
  vr_cdcooper := 9;
  vr_nrdconta := 504971;
  vr_nrctremp := 21100042;
  
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  
  
  vr_nrparepr := 0;
  vr_vllanmto := 0.6;
  vr_cdhistor := 1041;
  
  
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
