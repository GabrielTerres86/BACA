BEGIN
  
  UPDATE crapcop t 
     SET t.iniopstr = 36000
   WHERE t.cdcooper = 13;
  
  COMMIT;
END;
    
