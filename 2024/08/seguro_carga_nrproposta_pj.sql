BEGIN
  INSERT INTO CECRED.crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     1,
     'PROPOSTA_API_ICATU_JURID',
     'Quantidade de n�mero de proposta dispon�vel at� a pr�xima carga',
     'S');

  INSERT INTO CECRED.crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     1,
     'PROPOSTA_API_ICATU_QNTDJ',
     'Quantidade de n�mero de proposta dispon�vel at� a pr�xima carga',
     15);
  COMMIT;
END;
/
