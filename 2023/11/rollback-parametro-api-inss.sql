BEGIN
  DELETE crapprm
   WHERE cdcooper = 0
     AND cdacesso = 'ATIVO_CADASTRO_API_INSS';
  COMMIT;
END;
