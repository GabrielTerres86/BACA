BEGIN
	insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ((select max(c.nrseqaca) + 1 from crapaca c), 'BUSCASEGAUTOSIGAS', 'TELA_ATENDA_SEGURO', 'pc_detalha_seguro_auto_sigas', 'pr_nrdconta, pr_cdcooper, pr_idcontrato', 504);
	
	insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ((select max(c.nrseqaca) + 1 from crapaca c), 'BUSCASEGEMPRSIGAS', 'TELA_ATENDA_SEGURO', 'pc_detalha_seguro_empr_sigas', 'pr_nrdconta, pr_cdcooper, pr_idcontrato', 504);
	
	COMMIT;
END;