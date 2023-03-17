DECLARE

BEGIN

  UPDATE cecred.crappep pep
     SET pep.vlparepr = 395.27
        ,pep.vlsdvpar = 395.27
        ,pep.vlsdvsji = 395.27
   WHERE pep.nrdconta = 12967467
     AND pep.nrctremp = 6613536
     AND pep.cdcooper = 1;

  UPDATE cecred.crawepr w
     SET w.vlpreemp = 395.27
        ,w.vlpreori = 395.27
        ,w.vliofepr = 334.00
   WHERE w.nrdconta = 12967467
     AND w.nrctremp = 6613536
     AND w.cdcooper = 1;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 395.27
        ,epr.vliofepr = 334.00
        ,epr.vltariof = 334.00
   WHERE epr.nrdconta = 12967467
     AND epr.nrctremp = 6613536
     AND epr.cdcooper = 1;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    ROLLBACK;
  
END;
