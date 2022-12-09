BEGIN
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 251.85,
         pep.vlsdvpar = 251.85,
         pep.vlsdvsji = 251.85
   WHERE pep.nrdconta = 13202502
     AND pep.nrctremp = 6350446
     AND pep.cdcooper = 1;
   
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 251.85,
         w.vlpreori = 251.85,
         w.vliofepr = 133.68
   WHERE w.nrdconta = 13202502
     AND w.nrctremp = 6350446
     AND w.cdcooper = 1;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 251.85,
         epr.vliofepr = 133.68,
         epr.vltariof = 133.68
   WHERE epr.nrdconta = 13202502
     AND epr.nrctremp = 6350446
     AND epr.cdcooper = 1;
     
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
