BEGIN
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 439.29,
         pep.vlsdvpar = 439.29,
         pep.vlsdvsji = 439.29
   WHERE pep.nrdconta = 350605
     AND pep.nrctremp = 233793
     AND pep.cdcooper = 13; 
    
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 439.29,
         w.vlpreori = 439.29
   WHERE w.nrdconta = 350605
     AND w.nrctremp = 233793
     AND w.cdcooper = 13; 

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 439.29
   WHERE epr.nrdconta = 350605
     AND epr.nrctremp = 233793
     AND epr.cdcooper = 13;       
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
