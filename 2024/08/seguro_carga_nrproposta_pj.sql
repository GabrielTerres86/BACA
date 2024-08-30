BEGIN
  INSERT INTO CECRED.crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     1,
     'PROPOSTA_API_ICATU_JURID',
     'Quantidade de número de proposta disponível até a próxima carga',
     'S');

  INSERT INTO CECRED.crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     1,
     'PROPOSTA_API_ICATU_QNTDJ',
     'Quantidade de número de proposta disponível até a próxima carga',
     15);
  COMMIT;
END;
/
