BEGIN

  UPDATE crapprm a
     SET a.dsvlrprm = 'emanuele.schatz@ailos.coop.br'
   WHERE a.cdacesso = 'EMAIL_TESTE';

  COMMIT;

END;
