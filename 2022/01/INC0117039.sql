declare
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  vr_cdcooper crapcop.cdcooper%TYPE := 13;
  vr_nrdconta crapass.nrdconta%TYPE := 242098;
  vr_nrctremp craplem.nrctremp%TYPE := 68876;
  vr_vllanmto craplem.vllanmto%TYPE := 403.38;
  vr_cdhistor craplem.cdhistor%TYPE := 1705;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  -- Cria o lancamento de estorno
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

  vr_vllanmto := 398.86;
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
                                  pr_nrparepr => 16,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_nrdconta := 249505;
  vr_nrctremp := 59898;
  vr_vllanmto := 206.65;
  vr_cdhistor := 1705;
  
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
                                  pr_nrparepr => 20,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_vllanmto := 205.64;
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
                                  pr_nrparepr => 20,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_vllanmto := 822.60;
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

  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    RAISE_application_error(-20500, vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
/
declare
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  vr_cdcooper crapcop.cdcooper%TYPE := 10;
  vr_nrdconta crapass.nrdconta%TYPE := 134090;
  vr_nrctremp craplem.nrctremp%TYPE := 16316;
  vr_vllanmto craplem.vllanmto%TYPE := 13086.97;
  vr_cdhistor craplem.cdhistor%TYPE := 1044;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  -- Cria o lancamento de estorno
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
  
  vr_vllanmto  := 7204.43;
  vr_cdhistor  := 1048;
  
  -- Cria o lancamento de estorno
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
  
  vr_vllanmto  := 325.68;
  vr_cdhistor  := 1041;
  
  -- Cria o lancamento de estorno
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
  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    RAISE_application_error(-20500, vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
/
declare
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  vr_cdcooper crapcop.cdcooper%TYPE := 1;
  vr_nrdconta crapass.nrdconta%TYPE := 9652620;
  vr_nrctremp craplem.nrctremp%TYPE := 2955850;
  vr_vllanmto craplem.vllanmto%TYPE := 452.02;
  vr_cdhistor craplem.cdhistor%TYPE := 1705;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 12,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_vllanmto := 452.02;
  vr_cdhistor := 1705;

  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 13,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_vllanmto := 452.02;
  vr_cdhistor := 1705;

  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 14,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_vllanmto := 452.02;
  vr_cdhistor := 1705;

  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 15,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_vllanmto := 442.56;
  vr_cdhistor := 1044;

  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 12,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_vllanmto := 9.46;
  vr_cdhistor := 1048;

  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 12,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_vllanmto := 434.78;
  vr_cdhistor := 1044;

  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 13,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_vllanmto := 17.24;
  vr_cdhistor := 1048;

  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 13,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_vllanmto := 427.39;
  vr_cdhistor := 1044;

  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 14,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_vllanmto := 24.63;
  vr_cdhistor := 1048;

  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 14,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_vllanmto := 419.88;
  vr_cdhistor := 1044;

  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 15,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_vllanmto := 32.14;
  vr_cdhistor := 1048;

  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 15,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_vllanmto := 1352.44;
  vr_cdhistor := 1041;

  -- Cria o lancamento de estorno
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

  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    RAISE_application_error(-20500, vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
/
declare
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  vr_cdcooper crapcop.cdcooper%TYPE := 10;
  vr_nrdconta crapass.nrdconta%TYPE := 143219;
  vr_nrctremp craplem.nrctremp%TYPE := 23899;
  vr_vllanmto craplem.vllanmto%TYPE := 327.89;
  vr_cdhistor craplem.cdhistor%TYPE := 1044;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 7,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_vllanmto  := 0.24;
  vr_cdhistor  := 2311;
  
  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 7,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_vllanmto  := 6.56;
  vr_cdhistor  := 1047;
  
  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 7,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_vllanmto  := 0.87;
  vr_cdhistor  := 1077;
  
  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 7,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
   vr_vllanmto  := 335.53;
  vr_cdhistor  := 1040;
  
  -- Cria o lancamento de estorno
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
  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    RAISE_application_error(-20500, vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
/
declare
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  vr_cdcooper crapcop.cdcooper%TYPE := 5;
  vr_nrdconta crapass.nrdconta%TYPE := 41297;
  vr_nrctremp craplem.nrctremp%TYPE := 31491;
  vr_vllanmto craplem.vllanmto%TYPE := 3.93;
  vr_cdhistor craplem.cdhistor%TYPE := 1705;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 11,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_cdcooper  := 10;
  vr_nrdconta  := 42641;
  vr_nrctremp  := 15890;
  vr_vllanmto  := 2.75;
  vr_cdhistor  := 1705;
  
   -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 14,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_cdcooper  := 10;
  vr_nrdconta  := 143219;
  vr_nrctremp  := 23899;
  vr_vllanmto  := 360.00;
  vr_cdhistor  := 1044;
  
   -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 8,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_cdcooper  := 10;
  vr_nrdconta  := 143219;
  vr_nrctremp  := 23899;
  vr_vllanmto  := 6.87;
  vr_cdhistor  := 1048;
  
   -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 8,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_cdcooper  := 10;
  vr_nrdconta  := 143219;
  vr_nrctremp  := 23899;
  vr_vllanmto  := 350.54;
  vr_cdhistor  := 1044;
  
   -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 9,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_cdcooper  := 10;
  vr_nrdconta  := 143219;
  vr_nrctremp  := 23899;
  vr_vllanmto  := 16.33;
  vr_cdhistor  := 1048;
  
   -- Cria o lancamento de estorno
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
                                  pr_nrparepr => 9,
                                  pr_flgincre => FALSE,
                                  pr_flgcredi => FALSE,
                                  pr_nrseqava => 0,
                                  pr_cdorigem => 5,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  vr_cdcooper  := 10;
  vr_nrdconta  := 143219;
  vr_nrctremp  := 23899;
  vr_vllanmto  := 710.54;
  vr_cdhistor  := 1040;
  
   -- Cria o lancamento de estorno
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
  
  vr_cdcooper  := 10;
  vr_nrdconta  := 143227;
  vr_nrctremp  := 21595;
  vr_vllanmto  := 6.38;
  vr_cdhistor  := 1705;
  
   -- Cria o lancamento de estorno
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

  vr_cdcooper  := 10;
  vr_nrdconta  := 143359;
  vr_nrctremp  := 21600;
  vr_vllanmto  := 5.11;
  vr_cdhistor  := 1705;
  
   -- Cria o lancamento de estorno
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


  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    RAISE_application_error(-20500, vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
/