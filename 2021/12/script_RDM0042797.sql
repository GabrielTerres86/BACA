BEGIN
  UPDATE 
   crapprm  SET dsvlrprm = 'investimentos@ailos.coop.br'
  WHERE cdacesso = 'CRRL043_EMAIL';
  
  COMMIT;
END;


