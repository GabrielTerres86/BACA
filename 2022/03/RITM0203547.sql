BEGIN

	UPDATE CRAPPCO
	SET DSCONTEU = 'Cooperado, para atualizar seus dados entre em contato pelo WhatsApp (47) 99180-8959.'
	where cdpartar = 68
	and cdcooper = 16;

	commit;
END;
