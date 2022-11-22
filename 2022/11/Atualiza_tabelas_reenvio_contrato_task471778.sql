BEGIN
  
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 462.69,
         pep.vlsdvpar = 462.69,
         pep.vlsdvsji = 462.69
   WHERE pep.nrdconta = 15028364
     AND pep.nrctremp = 6261179
     AND pep.cdcooper = 1;
   
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 462.69,
         w.vlpreori = 462.69,
         w.vliofepr = 31.38
   WHERE w.nrdconta = 15028364
     AND w.nrctremp = 6261179
     AND w.cdcooper = 1;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 462.69,
		 epr.vliofepr = 31.38,
		 epr.vltariof = 31.38
   WHERE epr.nrdconta = 15028364
     AND epr.nrctremp = 6261179
     AND epr.cdcooper = 1;
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
