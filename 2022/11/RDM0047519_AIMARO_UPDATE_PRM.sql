BEGIN
  UPDATE crapprm t
   SET t.dsvlrprm = 'eapi-ailosmais-frontoffice/motorcredito/v1/aimaro/enviar'
  WHERE t.cdacesso = 'NOVOMOTOR_URI_WEBSRV';

  UPDATE crapprm t
   SET t.dsvlrprm = 'eapi-ailosmais-frontoffice/motorcredito/v1/aimaro/webservice'
  WHERE t.cdacesso = 'NOVOMOTOR_URI_WSAYLLOS';

  COMMIT;
END;
