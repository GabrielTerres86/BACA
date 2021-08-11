BEGIN
  UPDATE crapprm c
     SET c.dsvlrprm = 'verificar@ailos.coop.br'
   WHERE c.cdacesso = 'EMAIL_INTEGRA_PROGNUM';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
