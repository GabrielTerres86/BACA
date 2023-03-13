BEGIN
  UPDATE cecred.crawepr w
     SET w.vliofepr = 131.78
   WHERE w.nrdconta = 162256
     AND w.nrctremp = 80043
     AND w.cdcooper = 9; 
   
  UPDATE cecred.crapepr epr
     SET epr.vliofepr = 131.78,
    epr.vltariof = 131.78
   WHERE epr.nrdconta = 162256
     AND epr.nrctremp = 80043
     AND epr.cdcooper = 9;       
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
