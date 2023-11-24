BEGIN
  UPDATE cecred.crapprm
     SET dsvlrprm = 'S'
   WHERE cdacesso = 'ATIVO_CADASTRO_API_INSS'
     AND cdcooper = 0
     AND nmsistem = 'CRED';
  COMMIT;
END;
