BEGIN
  UPDATE CECRED.crapprm t
   SET t.dsvlrprm = 'eapi-ailosmais-motorcredito/v1/motorcredito/aimaro/enviar'
  WHERE t.cdacesso = 'NOVOMOTOR_URI_WEBSRV';

  UPDATE CECRED.crapprm t
   SET t.dsvlrprm = 'eapi-ailosmais-motorcredito/v1/motorcredito/aimaro/webservice'
  WHERE t.cdacesso = 'NOVOMOTOR_URI_WSAYLLOS';

  UPDATE CECRED.crapprm t
   SET t.dsvlrprm = '/eapi-ailosmais-motorcredito/v1/motorcredito/extrairDocumento'
  WHERE t.cdacesso = 'URL_MULE_DWLD_PDF';

  UPDATE CECRED.crapprm t
   SET t.dsvlrprm = '1'
  WHERE t.cdacesso = 'NOVOMOTOR_ID_MULE';

  UPDATE CECRED.crapprm t
   SET t.dsvlrprm = '2'
  WHERE t.cdacesso = 'NOVOMOTOR_SECRET_MULE';

  COMMIT;
END;
