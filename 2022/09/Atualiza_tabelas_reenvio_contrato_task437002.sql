BEGIN
  
  UPDATE cecred.crawepr w
     SET w.txminima = 1.62,
         w.txbaspre = 1.62,
         w.txmensal = 1.62,
         w.txorigin = 1.62
   WHERE w.nrdconta = 3519201
     AND w.nrctremp = 6056883
     AND w.cdcooper = 1; 

  UPDATE cecred.crapepr epr
     SET epr.txmensal = 1.62
   WHERE epr.nrdconta = 3519201
     AND epr.nrctremp = 6056883
     AND epr.cdcooper = 1;       
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
