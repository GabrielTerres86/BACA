BEGIN
  insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ((select max(NRSEQACA) + 1 from crapaca), 'ATUALIZA_PROPOSTA_PREST', 'TELA_ATENDA_SEGURO','pc_atualiza_dados_prest','pr_cdcooper,pr_nrdconta,pr_nrctrato,pr_flggarad,pr_flgassum,pr_tpcustei',
	(select nrseqrdr from CRAPRDR WHERE nmprogra = 'TELA_ATENDA_SEGURO')); 
	
	insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ((select max(NRSEQACA) + 1 from crapaca), 'CONSULTA_CRAPLCR_TPCUSPR', 'TELA_ATENDA_SEGURO','pc_retorna_tpcuspr','pr_cdcooper,pr_cdlcremp,pr_nrdconta,pr_nrctremp,pr_vlemprst,pr_qtpreemp',
	(select nrseqrdr from CRAPRDR WHERE nmprogra = 'TELA_ATENDA_SEGURO')); 
	
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
