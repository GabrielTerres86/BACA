BEGIN
  
  INSERT INTO cecred.crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
VALUES
  ('CRED',
   0,
   'ATIVO_VALIDA_INSS_H',
   'Indica se o servi�o de valida��o de cadastro de CPFs na tela INSS opcao H com base na chamada de API Sicredi est� ativo.',
   'S');
   
COMMIT;   
END;
