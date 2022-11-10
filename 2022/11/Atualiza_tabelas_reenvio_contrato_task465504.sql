BEGIN
  
  UPDATE cecred.crawepr w
     SET
         w.txminima = 1.99,
         w.txbaspre = 1.99,
         w.txmensal = 1.99,
         w.txorigin = 1.99
   WHERE w.nrdconta = 73458
     AND w.nrctremp = 42314
     AND w.cdcooper = 10;

  UPDATE cecred.crapepr epr
     SET epr.txmensal = 1.99
   WHERE epr.nrdconta = 73458
     AND epr.nrctremp = 42314
     AND epr.cdcooper = 10;
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
