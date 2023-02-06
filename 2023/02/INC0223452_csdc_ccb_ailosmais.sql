BEGIN
    delete from crapprm where cdacesso = 'CSDC_AILOSMAIS';
    delete from crapprm where cdacesso = 'HOST_WEBSRV_CSDC';
    delete from crapprm where cdacesso = 'URI_WEBSRV_CSDC';	
    delete from crapprm where cdacesso = 'MET_WEBSRV_CSDC';
    delete from crapprm where cdacesso = 'CLIENT_ID_CSDC';
    delete from crapprm where cdacesso = 'CLIENT_SECRET_CSDC';
    delete from crapprm where cdacesso = 'DIR_LOG_CSDC';

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 3, 'CSDC_AILOSMAIS', 'Ativar convivio do arquivo CSDC com ailos+ (1=Ativar, 0=Inativar)', '0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 0, 'HOST_WEBSRV_CSDC', 'Host Webservice CSDC', 'https://integra.ailos.coop.br/sapi-ailosmais-foundation/cartoes');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 0, 'URI_WEBSRV_CSDC', 'URI Webservice CSDC', 'arquivos/sequencial/2');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 0, 'MET_WEBSRV_CSDC', 'Metodo Webservice CSDC', 'PUT');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 0, 'CLIENT_ID_CSDC', 'Client ID Webservice CSDC', '364094d69e6442e6ab2654048dcf7830');
    
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 0, 'CLIENT_SECRET_CSDC', 'Client Secret Webservice CSDC', '2E8ADB69A67b40A78ab35Bc661aBe817');
    
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 0, 'DIR_LOG_CSDC', 'Diretorio Log Webservice CSDC', '/usr/coop/cecred/log/webservices');

    delete from crapprm where cdacesso = 'CCB_AILOSMAIS';
    
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 3, 'CCB_AILOSMAIS', 'Ativar convivio do arquivo CCB com ailos+ (1=Ativar, 0=Inativar)', '0');	
    
    COMMIT;
END;
/
