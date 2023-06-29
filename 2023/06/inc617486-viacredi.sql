BEGIN
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 818.33,
         pep.vlsdvpar = 818.33,
         pep.vlsdvsji = 818.33
   WHERE pep.nrdconta = 13022318
     AND pep.nrctremp = 6759409
     AND pep.cdcooper = 1; 
    
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 818.33,
         w.vlpreori = 818.33,
     w.vliofepr = 705.50
   WHERE w.nrdconta = 13022318
     AND w.nrctremp = 6759409
     AND w.cdcooper = 1; 
   
  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 818.33,
    epr.vliofepr = 705.50,
    epr.vltariof = 705.50
   WHERE epr.nrdconta = 13022318
     AND epr.nrctremp = 6759409
     AND epr.cdcooper = 1;       
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
