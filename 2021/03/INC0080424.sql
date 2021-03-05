BEGIN
  UPDATE crapprm 
     SET dsvlrprm = 'Ailos@2020' 
   WHERE cdcooper IN (3,10,14) 
     AND cdacesso = 'SENHA_AUTH_REG_CTR';
  COMMIT;
END;