BEGIN
  INSERT INTO crapprm
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES
    ('CRED',
     0,
     'HOST_WEBSRV_MOTOR_CHEQUE',
     'URLs de acesso ao Web Service Ibratan - Motor de Credito - Bordero Cheque',
     'https://cecred-agent-homolog.capacitor.digital');

  INSERT INTO crapprm
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES
    ('CRED',
     0,
     'URI_WEBSRV_MOTOR_CHEQUE',
     'URI de acesso aos Recursos do Web Service Ibratan - Motor de Credito - Bordero Cheque',
     'api/commands-raw/ProcessarBordero?idPolitica=');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
