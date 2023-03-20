DECLARE

BEGIN

  UPDATE cecred.crappep pep
     SET pep.vlparepr = 609.22
        ,pep.vlsdvpar = 609.22
        ,pep.vlsdvsji = 609.22
   WHERE pep.nrdconta = 16264495
     AND pep.nrctremp = 440710
     AND pep.cdcooper = 2;

  UPDATE cecred.crawepr w
     SET w.vlpreemp = 609.22
        ,w.vlpreori = 609.22
        ,w.vliofepr = 327.51
   WHERE w.nrdconta = 16264495
     AND w.nrctremp = 440710
     AND w.cdcooper = 2;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 609.22
        ,epr.vliofepr = 327.51
        ,epr.vltariof = 327.51
   WHERE epr.nrdconta = 16264495
     AND epr.nrctremp = 440710
     AND epr.cdcooper = 2;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    ROLLBACK;
  
END;
