DECLARE

  vr_cdcooper cecred.crapepr.cdcooper%TYPE := 2;
  vr_nrdconta cecred.crapepr.nrdconta%TYPE := 896489;
  vr_nrctremp cecred.crapepr.nrctremp%TYPE := 314559;
  vr_nrparepr cecred.crappep.nrparepr%TYPE := 22;

BEGIN

  UPDATE cecred.crappep pep
     SET pep.vlmtapar = 98.01
        ,pep.vlmrapar = 34.56
        ,pep.vlpagpar = 4900.42
        ,pep.vlpagmra = 34.56
        ,pep.vlsdvpar = 0.00
   WHERE pep.cdcooper = vr_cdcooper
     AND pep.nrdconta = vr_nrdconta
     AND pep.nrctremp = vr_nrctremp
     AND pep.nrparepr = vr_nrparepr;

  UPDATE cecred.crapepr epr
     SET epr.vlsdeved = epr.vlsdeved + 4723.23
        ,epr.qtprepag = 22
   WHERE epr.cdcooper = vr_cdcooper
     AND epr.nrdconta = vr_nrdconta
     AND epr.nrctremp = vr_nrctremp;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    RAISE_application_error(-20500, SQLCODE || ' - ' || SQLERRM);
  
    ROLLBACK;
  
END;
