BEGIN
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 162.84,
         pep.vlsdvpar = 162.84,
         pep.vlsdvsji = 162.84
   WHERE pep.nrdconta = 199036
     AND pep.nrctremp = 82432
     AND pep.cdcooper = 5; 
    
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 162.84,
         w.vlpreori = 162.84,
         w.txminima = 1.60,
         w.txbaspre = 1.60,
         w.txmensal = 1.60,
         w.txorigin = 1.60
   WHERE w.nrdconta = 199036
     AND w.nrctremp = 82432
     AND w.cdcooper = 5; 

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 162.84,
         epr.txmensal = 1.60
   WHERE epr.nrdconta = 199036
     AND epr.nrctremp = 82432
     AND epr.cdcooper = 5;       
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
