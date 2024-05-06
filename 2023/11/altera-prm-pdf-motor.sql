BEGIN
	
	UPDATE Crapprm
	SET    Dsvlrprm = '/dev-eapi-ailosmais-motorcredito/v1/motorcredito/extrairDocumento'
	WHERE  Cdacesso = 'URL_MULE_DWLD_PDF';

  COMMIT;
END;
