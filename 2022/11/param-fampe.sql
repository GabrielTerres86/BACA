BEGIN
INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CNPJ_FAMPE',
     'CNPJ do fundo garantidor FAMPE',
     '00330845000650');
INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'PERCENTUAL_FAMPE',
     'Percentual da garantia FAMPE',
     '80.00');
  COMMIT;
END;

