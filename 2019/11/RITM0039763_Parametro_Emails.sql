BEGIN
	INSERT INTO crapprm
		(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
	VALUES
		('CRED'
		,3
		,'CRPS330_EMAIL'
		,'E-mail para monitoramento da rotina CRPS330.'
		,'cobranca@ailos.coop.br');
    COMMIT;
END;
