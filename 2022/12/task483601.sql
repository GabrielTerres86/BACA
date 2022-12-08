BEGIN

  UPDATE cecred.crappep pep
     SET pep.vlparepr = 773.68,
         pep.vlsdvpar = 773.68,
         pep.vlsdvsji = 773.68
   WHERE pep.nrdconta = 10066497
     AND pep.nrctremp = 6300813
     AND pep.cdcooper = 1;
   
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 773.68,
         w.vlpreori = 773.68,
         w.vliofepr = 176.75
   WHERE w.nrdconta = 10066497
     AND w.nrctremp = 6300813
     AND w.cdcooper = 1;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 773.68,
         epr.vliofepr = 176.75,
         epr.vltariof = 176.75
   WHERE epr.nrdconta = 10066497
     AND epr.nrctremp = 6300813
     AND epr.cdcooper = 1;  


  COMMIT;

EXCEPTION
  
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
