DECLARE

BEGIN

  UPDATE cecred.crappep pep
     SET pep.vlparepr = 233.30
        ,pep.vlsdvpar = 233.30
        ,pep.vlsdvsji = 233.30
   WHERE pep.nrdconta = 2944219
     AND pep.nrctremp = 6614381
     AND pep.cdcooper = 1;

  UPDATE cecred.crawepr w
     SET w.vlpreemp = 233.30
        ,w.vlpreori = 233.30
        ,w.vliofepr = 241.70
   WHERE w.nrdconta = 2944219
     AND w.nrctremp = 6614381
     AND w.cdcooper = 1;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 233.30
        ,epr.vliofepr = 241.70
        ,epr.vltariof = 241.70
   WHERE epr.nrdconta = 2944219
     AND epr.nrctremp = 6614381
     AND epr.cdcooper = 1;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    ROLLBACK;
  
END;
