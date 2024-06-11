BEGIN
  INSERT INTO cecred.crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED', 0, 'CONV_URL_AUT', 'Processo busca comprovantes - string para autenticacao', '/auth/token?');

  UPDATE cecred.crapprm
     SET dsvlrprm = '503;504;505;'
   WHERE nmsistem = 'CRED'
     AND cdcooper = 0
     AND cdacesso = 'CONVENIO_PROC_REPROC';

  COMMIT;
END;