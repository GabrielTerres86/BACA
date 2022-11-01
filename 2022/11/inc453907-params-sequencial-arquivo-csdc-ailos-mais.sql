BEGIN
  INSERT INTO CRAPPRM
  (
     NMSISTEM,
     CDACESSO,
     DSTEXPRM,
     DSVLRPRM
  )
  VALUES
  (
     'CRED',
     'HOST_WEBSRV_CSDC',
     'URL de acesso ao WS Ailos+ para consulta de sequencial de arquivo',
     'https://cartoesapi.dev.awscloud.ailos.coop.br'
  );
  
  INSERT INTO CRAPPRM
  (
     NMSISTEM,
     CDACESSO,
     DSTEXPRM,
     DSVLRPRM
  )
  VALUES
  (
     'CRED',
     'URI_WEBSRV_CSDC',
     'URI de acesso ao WS Ailos+ para consulta de sequencial de arquivos',
     '/v1/arquivos/controle/'
  );
  
  INSERT INTO CRAPPRM
  (
     NMSISTEM,
     CDACESSO,
     DSTEXPRM,
     DSVLRPRM
  )
  VALUES
  (
     'CRED',
     'MET_WEBSRV_CSDC',
     'METHOD de acesso ao WS Ailos+ para consulta de sequencial de arquivos',
     'GET'
  );
  
  INSERT INTO CRAPPRM
  (
     NMSISTEM,
     CDACESSO,
     DSTEXPRM,
     DSVLRPRM
  )
  VALUES
  (
     'CRED',
     'CLIENT_ID_CSDC',
     'Código de CLIENT_ID de acesso ao WS Ailos+ para consulta de sequencial de arquivos',
     '364094d69e6442e6ab2654048dcf7830'
  );
  
  INSERT INTO CRAPPRM
  (
     NMSISTEM,
     CDACESSO,
     DSTEXPRM,
     DSVLRPRM
  )
  VALUES
  (
     'CRED',
     'CLIENT_SECRET_CSDC',
     'Código de CLIENT_SECRET de acesso ao WS Ailos+ para consulta de sequencial de arquivos',
     '2E8ADB69A67b40A78ab35Bc661aBe817'
  );
  
  COMMIT;
END;
/
