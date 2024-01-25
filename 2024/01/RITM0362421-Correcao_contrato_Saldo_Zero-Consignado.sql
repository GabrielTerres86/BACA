DECLARE

  pr_cdcooper cecred.crapcop.cdcooper%TYPE := 13;
  pr_nrdconta cecred.crapass.nrdconta%TYPE := 16739230;
  pr_nrctremp cecred.craplem.nrctremp%TYPE := 337959;

BEGIN

  UPDATE CECRED.CRAPEPR
     SET dtultpag = trunc(sysdate)
        ,QTPREPAG = 120
        ,VLPAGMES = 3818.71
        ,VLSDEVED = 0
        ,INLIQUID = 1
        ,DTLIQUID = trunc(sysdate)
   WHERE cdcooper = pr_cdcooper
     and nrdconta = pr_nrdconta
     AND nrctremp = pr_nrctremp;

  UPDATE CECRED.CRAPPEP
     SET DTULTPAG = trunc(sysdate)
        ,VLPAGPAR = 65.31
        ,INLIQUID = 1
        ,VLSDVPAR = 0
   WHERE cdcooper = pr_cdcooper
     and nrdconta = pr_nrdconta
     AND nrctremp = pr_nrctremp;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
