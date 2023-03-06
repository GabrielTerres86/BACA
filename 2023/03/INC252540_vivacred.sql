BEGIN
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 432.10,
         pep.vlsdvpar = 432.10,
         pep.vlsdvsji = 432.10
   WHERE pep.nrdconta = 15015033
     AND pep.nrctremp = 6465917
     AND pep.cdcooper = 1; 
    
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 432.10,
         w.vlpreori = 432.10,
		 w.vliofepr = 54.67
   WHERE w.nrdconta = 15015033
     AND w.nrctremp = 6465917
     AND w.cdcooper = 1; 
   
  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 432.10,
    epr.vliofepr = 54.67,
    epr.vltariof = 54.67
   WHERE epr.nrdconta = 15015033
     AND epr.nrctremp = 6465917
     AND epr.cdcooper = 1;       
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
