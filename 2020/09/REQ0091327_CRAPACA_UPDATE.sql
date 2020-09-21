BEGIN
	UPDATE crapaca aca
	   SET aca.lstparam = aca.lstparam || ', pr_fimvigen, pr_taxpermor, pr_taxperinv'
	 WHERE aca.nmdeacao = 'TAB049_ALTERAR';
	COMMIT;
END;