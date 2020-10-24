BEGIN
  
  UPDATE crapprg t 
     SET t.nrsolici = 88
       , t.nrordprg = 26
   WHERE t.cdprogra = 'CRPS691'
     AND t.cdcooper = 1;
     
  COMMIT;
  
END;
