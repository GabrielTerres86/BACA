BEGIN
	
	UPDATE crapprm t
	SET t.dsvlrprm = '/hml-eapi-ailosmais-motorcredito/v1/motorcredito/dadostelaunica'
	WHERE t.cdacesso = 'URL_MULE_DWLD_TELAUNICA';
	
	COMMIT;
	
END;
