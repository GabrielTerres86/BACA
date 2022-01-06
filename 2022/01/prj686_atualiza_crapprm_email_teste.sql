BEGIN
	UPDATE crapprm prm set prm.dsvlrprm = 'vitor.schlindwein@ailos.coop.br'
		where prm.cdacesso = 'EMAIL_TESTE';
	
	commit;
END;