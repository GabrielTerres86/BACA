BEGIN
  UPDATE crapprm p
     SET p.dsvlrprm = NULL
   WHERE p.cdacesso = 'EMAIL_TESTE';
  COMMIT;
END;
/
