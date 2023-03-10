BEGIN
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 776.11,
         pep.vlsdvpar = 776.11,
         pep.vlsdvsji = 776.11
   WHERE pep.nrdconta = 4060768
     AND pep.nrctremp = 6439451
     AND pep.cdcooper = 1; 
    
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 776.11,
         w.vlpreori = 776.11,
		 w.vliofepr = 153.95
   WHERE w.nrdconta = 4060768
     AND w.nrctremp = 6439451
     AND w.cdcooper = 1; 
   
  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 776.11,
    epr.vliofepr = 153.95,
    epr.vltariof = 153.95
   WHERE epr.nrdconta = 4060768
     AND epr.nrctremp = 6439451
     AND epr.cdcooper = 1;       
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
