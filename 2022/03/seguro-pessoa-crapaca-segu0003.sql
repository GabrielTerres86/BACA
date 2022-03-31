BEGIN
	
	UPDATE crapaca a 
	   SET a.lstparam = 'pr_nrdconta,pr_tpcustei,pr_flggarad,pr_nrregist,pr_nriniseq'  
	 WHERE a.nmdeacao='BUSCA_CONTRATOS_PRESTAMISTA'; 	
	 
	 
	INSERT INTO crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    VALUES ((SELECT MAX(NRSEQACA) + 1 FROM crapaca), 'EFETIVA_PROPOSTA_SEGURO', 'SEGU0003','pc_busca_efetiva_proposta_sp','pr_cdcooper,pr_nrdconta,pr_nrctrato',
   (SELECT nrseqrdr from CRAPRDR WHERE nmprogra = 'SEGU0003'));   
	 
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/

