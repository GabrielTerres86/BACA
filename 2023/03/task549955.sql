DECLARE

BEGIN

  UPDATE cecred.crappep pep
     SET pep.vlparepr = 502.26
        ,pep.vlsdvpar = 502.26
        ,pep.vlsdvsji = 502.26
   WHERE pep.nrdconta = 15400107
     AND pep.nrctremp = 6621201
     AND pep.cdcooper = 1;

  UPDATE cecred.crawepr w
     SET w.vlpreemp = 502.26
        ,w.vlpreori = 502.26
        ,w.vliofepr = 265.48
   WHERE w.nrdconta = 15400107
     AND w.nrctremp = 6621201
     AND w.cdcooper = 1;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 502.26
        ,epr.vliofepr = 265.48
        ,epr.vltariof = 265.48
   WHERE epr.nrdconta = 15400107
     AND epr.nrctremp = 6621201
     AND epr.cdcooper = 1;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    ROLLBACK;
  
END;
