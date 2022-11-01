BEGIN
  INSERT INTO CRAPPRM
  (
     NMSISTEM,
     CDACESSO,
     DSTEXPRM,
     DSVLRPRM,
     CDCOOPER
  )
  VALUES
  (
     'CRED',
     'HOST_WEBSRV_CSDC',
     'URL de acesso ao WS Ailos+ para consulta de sequencial de arquivo',
     'https://cartoesapi.dev.awscloud.ailos.coop.br',
     0
  );
  
  INSERT INTO CRAPPRM
  (
     NMSISTEM,
     CDACESSO,
     DSTEXPRM,
     DSVLRPRM,
     CDCOOPER
  )
  VALUES
  (
     'CRED',
     'URI_WEBSRV_CSDC',
     'URI de acesso ao WS Ailos+ para consulta de sequencial de arquivos',
     '/v1/arquivos/controle/',
     0
  );
  
  INSERT INTO CRAPPRM
  (
     NMSISTEM,
     CDACESSO,
     DSTEXPRM,
     DSVLRPRM,
     CDCOOPER
  )
  VALUES
  (
     'CRED',
     'MET_WEBSRV_CSDC',
     'METHOD de acesso ao WS Ailos+ para consulta de sequencial de arquivos',
     'GET',
     0
  );
  
  INSERT INTO CRAPPRM
  (
     NMSISTEM,
     CDACESSO,
     DSTEXPRM,
     DSVLRPRM,
     CDCOOPER
  )
  VALUES
  (
     'CRED',
     'CLIENT_ID_CSDC',
     'Código de CLIENT_ID de acesso ao WS Ailos+ para consulta de sequencial de arquivos',
     '364094d69e6442e6ab2654048dcf7830',
     0
  );
  
  INSERT INTO CRAPPRM
  (
     NMSISTEM,
     CDACESSO,
     DSTEXPRM,
     DSVLRPRM,
     CDCOOPER
  )
  VALUES
  (
     'CRED',
     'CLIENT_SECRET_CSDC',
     'Código de CLIENT_SECRET de acesso ao WS Ailos+ para consulta de sequencial de arquivos',
     '2E8ADB69A67b40A78ab35Bc661aBe817',
     0
  );
  
  COMMIT;
END;
/
