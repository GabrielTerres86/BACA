BEGIN
  INSERT INTO CECRED.crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'DIR_658_ENVIA_TOPAZ',
     'Diretorio que enviar os arquivos de convenios com TOPAZ',
     '/usr/connect/sicredi/recebidos');

  COMMIT;
END;
/
