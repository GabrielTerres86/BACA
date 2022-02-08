BEGIN
  UPDATE crapaca c
     SET c.lstparam = lstparam || ', pr_flgassum, pr_flggarad'
   WHERE c.nmpackag = 'TELA_ATENDA_SIMULACAO'
     AND c.nmdeacao = 'SIMULA_GRAVA_SIMULACAO';
	 
  INSERT INTO crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	VALUES ((select max(NRSEQACA) + 1 from crapaca), 'CONSULTA_CRAPLCR_TPCUSPR','TELA_ATENDA_SEGURO','pc_retorna_tpcuspr','pr_cdcooper,pr_cdlcremp,pr_nrdconta,pr_nrctremp',
	(SELECT nrseqrdr from CRAPRDR WHERE nmprogra = 'TELA_ATENDA_SEGURO')); 
	
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
