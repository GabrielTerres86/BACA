BEGIN
  INSERT INTO cecred.crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'ATIVO_CADASTRO_API_INSS',
     'Indica se o servi�o via API INSS est� ativo (S/N)',
     'N');
  COMMIT;
END;