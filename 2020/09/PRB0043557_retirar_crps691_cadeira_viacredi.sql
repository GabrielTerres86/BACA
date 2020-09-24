BEGIN
  
  UPDATE crapprg t 
     SET t.nrsolici = 999 -- Retirar da execução do processo batch
   WHERE t.cdprogra = 'CRPS691'
     AND t.cdcooper = 1;
     
  COMMIT;
  
END;
