DECLARE

  vr_cdcooper cecred.crapcop.cdcooper%TYPE := 8;
  vr_nrdconta cecred.crapass.nrdconta%TYPE := 57347;
  vr_nrctremp cecred.crawepr.nrctremp%TYPE := 14695;

BEGIN

  UPDATE cecred.crawepr wepr
     SET wepr.vliofepr = 358.58
   WHERE wepr.cdcooper = vr_cdcooper
     AND wepr.nrdconta = vr_nrdconta
     AND wepr.nrctremp = vr_nrctremp;

  UPDATE cecred.crapepr epr
     SET epr.vliofepr = 358.58
        ,epr.vltariof = 358.58
   WHERE epr.cdcooper = vr_cdcooper
     AND epr.nrdconta = vr_nrdconta
     AND epr.nrctremp = vr_nrctremp;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    ROLLBACK;
  
END;
