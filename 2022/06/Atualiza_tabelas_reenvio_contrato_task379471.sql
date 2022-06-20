BEGIN
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 645.32,
         pep.vlsdvpar = 645.32,
         pep.vlsdvsji = 645.32
   WHERE pep.nrdconta = 708160
     AND pep.nrctremp = 499865
     AND pep.cdcooper = 16; 
    
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 645.32,
         w.vlpreori = 645.32,
         w.txminima = 1.60,
         w.txbaspre = 1.60,
         w.txmensal = 1.60,
         w.txorigin = 1.60
   WHERE w.nrdconta = 708160
     AND w.nrctremp = 499865
     AND w.cdcooper = 16; 

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 645.32,
         epr.txmensal = 1.60
   WHERE epr.nrdconta = 708160
     AND epr.nrctremp = 499865
     AND epr.cdcooper = 16;       
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
