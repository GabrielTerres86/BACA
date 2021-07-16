BEGIN 

  UPDATE crapprm 
     SET dsvlrprm = 'B'
   WHERE cdcooper IN (1,9,14)
     AND cdacesso = 'FLG_PAG_FGTS' ; 

  COMMIT; 
  
END;   