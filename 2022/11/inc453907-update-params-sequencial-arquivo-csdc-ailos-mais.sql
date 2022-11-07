BEGIN
  UPDATE CECRED.crapprm prm
     SET DSVLRPRM = 'https://dev.integra.ailos.coop.br/dev-sapi-ailosmais-foundation/cartoes'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper = 0
     AND prm.cdacesso = 'HOST_WEBSRV_CSDC';

  UPDATE CECRED.crapprm prm
     SET DSVLRPRM = 'PUT'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper = 0
     AND prm.cdacesso = 'MET_WEBSRV_CSDC';

  UPDATE CECRED.crapprm prm
     SET DSVLRPRM = 'arquivos/sequencial/2'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper = 0
     AND prm.cdacesso = 'URI_WEBSRV_CSDC';

  COMMIT;
END;
/
