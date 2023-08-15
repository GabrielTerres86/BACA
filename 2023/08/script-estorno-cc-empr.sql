DECLARE
  vr_cdcritic CECRED.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  CECRED.BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto VARCHAR(3);
  vr_tab_erro CECRED.GENE0001.typ_tab_erro;

  vr_cdcooper CECRED.crapcop.cdcooper%TYPE := 1;

  vr_nrdconta CECRED.crapass.nrdconta%TYPE := 9100520;
  vr_nrctremp CECRED.craplem.nrctremp%TYPE := 3898527;
  vr_vllanmto CECRED.craplem.vllanmto%TYPE := 19460.31;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN
  OPEN CECRED.btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH CECRED.btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE CECRED.btch0001.cr_crapdat;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;

  cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdagenci => rw_crapass.cdagenci
                                        ,pr_cdbccxlt => 100
                                        ,pr_cdoperad => 1
                                        ,pr_cdpactra => rw_crapass.cdagenci
                                        ,pr_tplotmov => 5
                                        ,pr_nrdolote => 600031
                                        ,pr_nrdconta => vr_nrdconta
                                        ,pr_cdhistor => 3273
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

  CECRED.EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => vr_cdcooper
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_cdagenci => rw_crapass.cdagenci
                                       ,pr_cdbccxlt => 100
                                       ,pr_cdoperad => 1
                                       ,pr_cdpactra => rw_crapass.cdagenci
                                       ,pr_nrdolote => 600031
                                       ,pr_nrdconta => vr_nrdconta
                                       ,pr_cdhistor => 362
                                       ,pr_vllanmto => vr_vllanmto
                                       ,pr_nrparepr => 0
                                       ,pr_nrctremp => vr_nrctremp
                                       ,pr_nrseqava => 0
                                       ,pr_des_reto => vr_des_reto
                                       ,pr_tab_erro => vr_tab_erro);

  IF vr_des_reto <> 'OK' THEN
    RAISE vr_exc_saida;
  END IF;

  UPDATE cecred.crappep c
     SET vlsdvatu = 4445.59
        ,vlsdvpar = 4445.59
        ,inliquid = 0
        ,dtultpag = NULL
        ,vlpagpar = 0
        ,vlpagmta = 0
        ,vlpagmra = 0
   WHERE c.cdcooper = vr_cdcooper
         AND c.nrdconta = vr_nrdconta
         AND c.nrctremp = vr_nrctremp
         AND c.nrparepr IN (20, 21, 22, 23);

  UPDATE cecred.crapepr
     SET crapepr.vlsdevat = crapepr.vlsdevat + vr_vllanmto
        ,crapepr.vlsdeved = crapepr.vlsdeved + vr_vllanmto
        ,crapepr.qtprecal = 19
        ,crapepr.qtprepag = 19
   WHERE crapepr.cdcooper = vr_cdcooper
         AND crapepr.nrdconta = vr_nrdconta
         AND crapepr.nrctremp = vr_nrctremp;

  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
END;
