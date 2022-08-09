BEGIN
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 1831.03,
         pep.vlsdvpar = 1831.03,
         pep.vlsdvsji = 1831.03
   WHERE pep.nrdconta = 2688140
     AND pep.nrctremp = 527599
     AND pep.cdcooper = 16; 
    
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 1831.03,
         w.vlpreori = 1831.03,
         w.txminima = 1.33,
         w.txbaspre = 1.33,
         w.txmensal = 1.33,
         w.txorigin = 1.33
   WHERE w.nrdconta = 2688140
     AND w.nrctremp = 527599
     AND w.cdcooper = 16; 

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 1831.03,
         epr.txmensal = 1.33
   WHERE epr.nrdconta = 2688140
     AND epr.nrctremp = 527599
     AND epr.cdcooper = 16;       
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
