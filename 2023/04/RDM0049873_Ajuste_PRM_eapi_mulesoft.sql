BEGIN
  UPDATE crapprm t
   SET t.dsvlrprm = 'eapi-ailosmais-motorcredito/motorcredito/v1/aimaro/enviar'
  WHERE t.cdacesso = 'NOVOMOTOR_URI_WEBSRV';

  UPDATE crapprm t
   SET t.dsvlrprm = 'eapi-ailosmais-motorcredito/motorcredito/v1/aimaro/webservice'
  WHERE t.cdacesso = 'NOVOMOTOR_URI_WSAYLLOS';

  UPDATE crapprm t
   SET t.dsvlrprm = '/eapi-ailosmais-motorcredito/motorcredito/v1/extrairDocumento'
  WHERE t.cdacesso = 'URL_MULE_DWLD_PDF';

  COMMIT;
END;

