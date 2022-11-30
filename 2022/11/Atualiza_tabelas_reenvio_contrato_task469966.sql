BEGIN
  
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 939.44,
         pep.vlsdvpar = 939.44,
         pep.vlsdvsji = 939.44
   WHERE pep.nrdconta = 6639402
     AND pep.nrctremp = 6244365
     AND pep.cdcooper = 1;
   
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 939.44,
         w.vlpreori = 939.44,
         w.vliofepr = 218.29
   WHERE w.nrdconta = 6639402
     AND w.nrctremp = 6244365
     AND w.cdcooper = 1;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 939.44,
         epr.vliofepr = 218.29,
         epr.vltariof = 218.29
   WHERE epr.nrdconta = 6639402
     AND epr.nrctremp = 6244365
     AND epr.cdcooper = 1;  
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
