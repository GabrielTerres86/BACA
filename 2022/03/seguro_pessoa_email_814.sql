BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     '0',
     'CRRL814_EMAIL',
     'Email para envio do relatorio CRRL814',
     'seguros.vida@ailos.coop.br');
  COMMIT;
END;
/
