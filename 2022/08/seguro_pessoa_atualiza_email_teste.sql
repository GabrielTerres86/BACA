BEGIN
  UPDATE crapprm p
     SET p.dsvlrprm = 'marjelli.prada@ailos.coop.br'
   WHERE p.cdacesso = 'EMAIL_TESTE';
  COMMIT;
END;
/
