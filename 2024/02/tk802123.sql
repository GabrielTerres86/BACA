DECLARE
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  vr_cdcooper crapcop.cdcooper%TYPE := 9;
  vr_nrdconta crapass.nrdconta%TYPE := 525774;
  vr_nrctremp craplem.nrctremp%TYPE := 20100533;
  vr_nrparepr crappep.nrparepr%TYPE := 30;

BEGIN

  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  UPDATE cecred.crapepr
     SET qtprepag = 30
        ,vlsdeved = 0.00
        ,inliquid = 1
        ,qtprecal = 30
        ,vlsdvctr = 0.00
        ,qtpcalat = 30
        ,vlsdevat = 0.00
        ,dtliquid = rw_crapdat.dtmvtolt
   WHERE cdcooper = vr_cdcooper
     AND nrdconta = vr_nrdconta
     AND nrctremp = vr_nrctremp
     AND inliquid = 0;

  UPDATE cecred.crappep
     SET vlmtapar = 0.00
        ,vlmrapar = 0.00
        ,dtultpag = trunc(to_date('14/02/2024', 'dd/mm/yyyy'))
        ,vlpagpar = 170.60
        ,inliquid = 1
        ,vlsdvpar = 0.00
        ,vlsdvatu = 0.00
   WHERE cdcooper = vr_cdcooper
     AND nrdconta = vr_nrdconta
     AND nrctremp = vr_nrctremp
     AND nrparepr = vr_nrparepr
     AND inliquid = 0;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
