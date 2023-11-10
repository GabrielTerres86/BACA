DECLARE
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  vr_cdcooper crapcop.cdcooper%TYPE := 10;
  vr_nrdconta crapass.nrdconta%TYPE := 37338;
  vr_nrctremp craplem.nrctremp%TYPE := 46437;
  vr_vllanmto craplem.vllanmto%TYPE := 0.15;
  vr_cdhistor craplem.cdhistor%TYPE := 1040;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
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
  
   UPDATE cecred.crapepr
     SET dtliquid = rw_crapdat.dtmvtolt
        ,inliquid = 1
        ,vlsdvctr = 0
        ,vlsdeved = 0
        ,qtprepag = 72
        ,qtprecal = 72
        ,qtpcalat = 72
   WHERE cdcooper = vr_cdcooper
         AND nrdconta = vr_nrdconta
         AND nrctremp = vr_nrctremp;

  UPDATE cecred.crappep
     SET inliquid = 1
        ,vlsdvpar = 0
        ,vlsdvatu = 0
        ,vlpagpar = 0.01
        ,dtultpag = rw_crapdat.dtmvtolt
   WHERE cdcooper = vr_cdcooper
         AND nrdconta = vr_nrdconta
         AND nrctremp = vr_nrctremp
         AND inliquid = 0;

  EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper
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
  
  UPDATE crapbpr bpr
   SET bpr.dtmvtolt = TO_DATE('26/09/2022','DD/MM/YYYY')
 WHERE bpr.cdcooper = 00009
   AND bpr.nrdconta = 000000000276456
   AND bpr.nrctrpro = 000000000073798
   AND bpr.tpctrpro = 90
   AND bpr.flgalien = 1;


  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
    RAISE_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
