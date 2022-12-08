BEGIN
  
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 372.14,
         pep.vlsdvpar = 372.14,
         pep.vlsdvsji = 372.14
   WHERE pep.nrdconta = 7427557
     AND pep.nrctremp = 6355634
     AND pep.cdcooper = 1;
   
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 372.14,
         w.vlpreori = 372.14,
         w.vliofepr = 290.21
   WHERE w.nrdconta = 7427557
     AND w.nrctremp = 6355634
     AND w.cdcooper = 1;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 372.14,
         epr.vliofepr = 290.21,
         epr.vltariof = 290.21
   WHERE epr.nrdconta = 7427557
     AND epr.nrctremp = 6355634
     AND epr.cdcooper = 1;
   
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
