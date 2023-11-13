BEGIN

  UPDATE CECRED.CRAPPRM
  SET   DSVLRPRM='dev-eapi-ailosmais-motorcredito/v1/motorcredito/aimaro/enviar'
  WHERE CDCOOPER = 0
  AND   CDACESSO = 'NOVOMOTOR_URI_WEBSRV'
  AND   NMSISTEM='CRED';


  UPDATE CECRED.CRAPPRM
  SET   DSVLRPRM='dev-eapi-ailosmais-motorcredito/v1/motorcredito/aimaro/webservice'
  WHERE CDCOOPER = 0
  AND   CDACESSO = 'NOVOMOTOR_URI_WSAYLLOS'
  AND   NMSISTEM='CRED';

  COMMIT;

END;