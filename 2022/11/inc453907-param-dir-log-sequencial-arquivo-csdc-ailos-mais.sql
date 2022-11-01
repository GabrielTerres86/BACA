BEGIN
  INSERT INTO CRAPPRM
  (
    NMSISTEM,
    CDCOOPER,
    CDACESSO,
    DSTEXPRM,
    DSVLRPRM
  )
  VALUES
  (
    'CRED',
    0,
    'DIR_LOG_CSDC',
    'Diretório do arquivo de log do processo.',
    '/usr/coop/cecred/log/webservices'
  );
  
  COMMIT;
END;
/
