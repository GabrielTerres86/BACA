BEGIN 
  UPDATE crapprm t 
     SET t.dsvlrprm = '29/04/2024#0'
   WHERE t.cdacesso = 'CTRL_CRPS538_EXEC'
     AND t.cdcooper IN (3,9)
     AND t.nmsistem = 'CRED';
  COMMIT;
END;
