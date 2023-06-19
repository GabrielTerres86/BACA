DECLARE
  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat CECRED.BTCH0001.cr_crapdat%ROWTYPE;

  vr_cdcooper cecred.crapcop.cdcooper%TYPE := 1;
  vr_nrdconta cecred.crapass.nrdconta%TYPE := 12857939;
  vr_nrctremp cecred.craplem.nrctremp%TYPE := 6232273;
  vr_cdhistor cecred.craplem.cdhistor%TYPE := 1705;
  vr_vllanmto cecred.craplem.vllanmto%TYPE;
  vr_nrparepr cecred.craplem.nrparepr%TYPE;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM CECRED.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN

  UPDATE cecred.crappep
     SET vlpagpar = 0
        ,inliquid = 0
        ,dtultpag = NULL
        ,vlsdvpar = 699.06
        ,vlsdvsji = 699.06
        ,vlpagjin = 0
        ,vlmtapar = 0
        ,vlmrapar = 0
        ,vlpagmta = 0
        ,vlpagmra = 0
        ,vlpagiof = 0
        ,vlsdvatu = 0
   WHERE cdcooper = 1
         AND nrdconta = 12857939
         AND nrctremp = 6232273
         AND nrparepr IN (1, 2, 3, 4, 5);

  UPDATE cecred.crapepr
     SET dtultpag = NULL
        ,qtprepag = 0
        ,vlsdeved = 7385.76
        ,vlpapgat = 0
        ,vlppagat = 0
   WHERE cdcooper = 1
         AND nrdconta = 12857939
         AND nrctremp = 6232273;

  vr_nrparepr := 1;
  vr_vllanmto := 887.66;

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
                                        ,pr_nrparepr => vr_nrparepr
                                        ,pr_flgincre => FALSE
                                        ,pr_flgcredi => FALSE
                                        ,pr_nrseqava => 0
                                        ,pr_cdorigem => 5
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_nrparepr := 2;
  vr_vllanmto := 846.77;

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
                                        ,pr_nrparepr => vr_nrparepr
                                        ,pr_flgincre => FALSE
                                        ,pr_flgcredi => FALSE
                                        ,pr_nrseqava => 0
                                        ,pr_cdorigem => 5
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_nrparepr := 3;
  vr_vllanmto := 807.10;

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
                                        ,pr_nrparepr => vr_nrparepr
                                        ,pr_flgincre => FALSE
                                        ,pr_flgcredi => FALSE
                                        ,pr_nrseqava => 0
                                        ,pr_cdorigem => 5
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_nrparepr := 4;
  vr_vllanmto := 769.12;

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
                                        ,pr_nrparepr => vr_nrparepr
                                        ,pr_flgincre => FALSE
                                        ,pr_flgcredi => FALSE
                                        ,pr_nrseqava => 0
                                        ,pr_cdorigem => 5
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  vr_nrparepr := 5;
  vr_vllanmto := 732.84;

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
                                        ,pr_nrparepr => vr_nrparepr
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
