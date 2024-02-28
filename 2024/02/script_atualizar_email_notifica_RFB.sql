BEGIN         
  UPDATE cecred.crapprm
     SET dsvlrprm = 'jose.zunino@ailos.coop.br;jeferson.nunes@ailos.coop.br'
   WHERE nmsistem = 'CRED'
     AND cdcooper IN(3,0)
     AND cdacesso = 'EMAIL_REM_RFB';

  COMMIT;
END;    