BEGIN
  
  UPDATE crapprg t 
     SET t.nrsolici = 999 -- Retirar da execu��o do processo batch
   WHERE t.cdprogra = 'CRPS691'
     AND t.cdcooper = 1;
     
  COMMIT;
  
END;
