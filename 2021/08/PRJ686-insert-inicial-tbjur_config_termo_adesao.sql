BEGIN
	insert into juridico.tbjur_config_termo_adesao (IDCONFIG_TERMO_ADESAO, TPTERMO_ADESAO, NRVERSAO, NMVIEW, NMDOMINIO)
	values (1, 1, 1, 'VWIB_TERMO_MULT_CONTAS', 'CECRED');

	commit;
END;
