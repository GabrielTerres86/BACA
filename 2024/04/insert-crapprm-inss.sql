BEGIN
  
  INSERT INTO cecred.crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
VALUES
  ('CRED',
   0,
   'ATIVO_VALIDA_INSS_H',
   'Indica se o serviço de validação de cadastro de CPFs na tela INSS opcao H com base na chamada de API Sicredi está ativo.',
   'S');
   
COMMIT;   
END;
