BEGIN
  
  UPDATE crapprm t 
     SET t.dsvlrprm = 0
   WHERE t.cdcooper IN (3,8,9)
     AND t.nmsistem = 'CRED'
     AND t.cdacesso = 'QTD_EXEC_CRPS538_1';
     
  COMMIT;
  
END;
