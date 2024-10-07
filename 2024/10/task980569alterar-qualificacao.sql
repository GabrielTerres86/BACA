BEGIN
  UPDATE cecred.crapepr epr
     SET epr.idquaprc = 3
   WHERE epr.cdcooper = 7
     AND epr.nrdconta = 15684393 
     AND epr.nrctremp = 143458;
  
  UPDATE cecred.crawepr epr
     SET epr.idquapro = 3
   WHERE epr.cdcooper = 7
     AND epr.nrdconta = 15684393 
     AND epr.nrctremp = 143458;
     
  COMMIT;
     
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500, SQLERRM);      
END;
