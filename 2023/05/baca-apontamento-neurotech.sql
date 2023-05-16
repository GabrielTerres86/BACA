BEGIN

	UPDATE crapprm t  
	SET t.dsvlrprm = 'hml-eapi-ailosmais-motorcredito/v1/motorcredito/aimaro/enviar'
	WHERE t.cdacesso = 'NOVOMOTOR_URI_WEBSRV';
	
	UPDATE crapprm t
	SET t.dsvlrprm = 'hml-eapi-ailosmais-motorcredito/v1/motorcredito/aimaro/webservice'
	WHERE t.cdacesso = 'NOVOMOTOR_URI_WSAYLLOS';
	
	UPDATE crapprm t 
	SET t.dsvlrprm = '/hml-eapi-ailosmais-motorcredito/v1/motorcredito/extrairDocumento'
	WHERE t.cdacesso = 'URL_MULE_DWLD_PDF';
	
	UPDATE crapprm t
	SET t.dsvlrprm = 'https://hml.integra.ailos.coop.br'
	WHERE t.cdacesso = 'NOVOMOTOR_HOST_WEBSRV';
	
	UPDATE crapprm t
	SET t.dsvlrprm = 'hml-eapi-ailosmais-motorcredito/v1/motorcredito/dadostelaunica'
	WHERE t.cdacesso = 'URL_MULE_DWLD_TELAUNICA';
	
	COMMIT;
	
END;
