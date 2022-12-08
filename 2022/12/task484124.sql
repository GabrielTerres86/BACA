BEGIN
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 233.96,
         pep.vlsdvpar = 233.96,
         pep.vlsdvsji = 233.96
   WHERE pep.nrdconta = 13458922
     AND pep.nrctremp = 6360161
     AND pep.cdcooper = 1;
   
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 233.96,
         w.vlpreori = 233.96,
         w.vliofepr = 240.47
   WHERE w.nrdconta = 13458922
     AND w.nrctremp = 6360161
     AND w.cdcooper = 1;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 233.96,
         epr.vliofepr = 240.47,
         epr.vltariof = 240.47
   WHERE epr.nrdconta = 13458922
     AND epr.nrctremp = 6360161
     AND epr.cdcooper = 1;  
   
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
