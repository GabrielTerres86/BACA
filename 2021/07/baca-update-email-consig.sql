BEGIN
  
	UPDATE crapprm
	   SET dsvlrprm = 'katia.heckmann@ailos.coop.br'
	 WHERE cdacesso LIKE '%EMAIL_TESTE%';

	COMMIT;
	
END;