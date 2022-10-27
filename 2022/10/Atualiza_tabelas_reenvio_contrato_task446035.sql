BEGIN
  
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 895.73,
         pep.vlsdvpar = 895.73,
         pep.vlsdvsji = 895.73
   WHERE pep.nrdconta = 8153159
     AND pep.nrctremp = 6104579
     AND pep.cdcooper = 1; 
    
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 895.73,
         w.vlpreori = 895.73,
         w.txminima = 2.21,
         w.txbaspre = 2.21,
         w.txmensal = 2.21,
         w.txorigin = 2.21
   WHERE w.nrdconta = 8153159
     AND w.nrctremp = 6104579
     AND w.cdcooper = 1; 

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 895.73,
         epr.txmensal = 2.21
   WHERE epr.nrdconta = 8153159
     AND epr.nrctremp = 6104579
     AND epr.cdcooper = 1;    
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
