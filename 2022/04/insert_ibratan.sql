BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm)
  VALUES
    ('CRED',
     0,
     'URL_IBRATAN',
     'URL para acesso ao webservice de comunicacao com a Ibratan');
  COMMIT;
END;
/
