BEGIN

	UPDATE crapprm p
	set p.dsvlrprm = 'vitor.schlindwein@ailos.coop.br'
	where p.cdacesso = 'EMAIL_TESTE';
	commit;
END;