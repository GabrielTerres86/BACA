BEGIN
  DELETE crapprm
   WHERE cdcooper = 0
     AND cdacesso = 'ATIVO_CADASTRO_API_INSS';
  COMMIT;
    
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'ATIVO_CADASTRO_API_INSS',
     'Indica se o serviço via API INSS está ativo (S/N)',
     'N');
  COMMIT;
END;
