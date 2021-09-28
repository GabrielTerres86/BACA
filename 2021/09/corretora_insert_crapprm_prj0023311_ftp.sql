BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     3,
     'DELPHOS_FTP_ENDERECO',
     'Endereço de conexão FTP',
     'ftp.delphos.com.br');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NULL;    
END;
/
BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     3,
     'DELPHOS_FTP_LOGIN',
     'Nome do usuário',
     'sftpdphailos');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NULL;
END;
/
BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     3,
     'DELPHOS_FTP_SENHA',
     'Senha do usuário',
     'ailos@2020');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NULL;
END;
/
BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'DELPHOS_FTP_DIR_DESTINO',
     'Diretório destinatado o arquivo',
     '/usr/sistemas/CreditoImobiliario/Seguros');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NULL;
END;
/
BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'DELPHOS_FTP_SEGURADORA',
     'Diretório destinatado o arquivo',
     'ICATU,SOMPO');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NULL;
END;
/
