BEGIN
	insert into juridico.tbjur_termos_adesao (IDTERMO_ADESAO, TPTERMO_ADESAO, NRVERSAO, DSCOMPLETA, DSRESUMIDA)
	values (3, 1, 1, 'Descricao completa do termo de adesao', 'Descricao resumida do termo de adesao');

	commit;
END;
