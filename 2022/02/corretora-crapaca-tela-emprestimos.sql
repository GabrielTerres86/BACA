BEGIN
	UPDATE crapaca c
       SET c.lstparam = lstparam || ',pr_vlemprst'
     WHERE c.nmpackag = 'TELA_ATENDA_SEGURO'
       AND c.nmdeacao = 'CONSULTA_CRAPLCR_TPCUSPR';
	
	INSERT INTO crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	VALUES ((select max(NRSEQACA) + 1 from crapaca), 'ATUALIZA_PROPOSTA_PREST', 'TELA_ATENDA_SEGURO','pc_atualiza_dados_prest','pr_cdcooper,pr_nrdconta,pr_nrctrato,pr_flggarad,pr_flgassum,pr_tpcustei',
	(SELECT nrseqrdr from CRAPRDR WHERE nmprogra = 'TELA_ATENDA_SEGURO')); 
	
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
