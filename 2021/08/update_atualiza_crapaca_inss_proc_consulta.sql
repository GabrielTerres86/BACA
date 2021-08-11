BEGIN
	UPDATE crapaca SET lstparam = 'pr_cdcooper, pr_nrdconta, pr_nrrecben' WHERE nmdeacao = 'CONSULTAR_NOTIF_INSS';

	COMMIT;
END;

