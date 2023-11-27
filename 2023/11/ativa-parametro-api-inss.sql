BEGIN
  UPDATE cecred.crapprm
     SET dsvlrprm = 'S'
   WHERE cdcooper = 0
     AND nmsistem = 'CRED'
     AND cdacesso = 'ATIVO_CADASTRO_API_INSS';

  COMMIT;
END;
