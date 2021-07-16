BEGIN 

  UPDATE crapprm 
     SET dsvlrprm = 'B'
   WHERE cdcooper IN (1,9,14); 

  COMMIT; 
  
END;   