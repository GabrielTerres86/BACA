BEGIN
	UPDATE CRAPACA
	SET LSTPARAM = 'pr_nrdconta, pr_cddopcao, pr_nrctrpro, pr_tpctrpro, pr_idseqbem, pr_dschassi, pr_ufdplaca, pr_nrdplaca, pr_nrrenava, pd_dsjustif, pr_dsanotac, pr_flblqjud'
	WHERE
		NMDEACAO = 'BLQLIBGRAVAM' 
	AND NMPACKAG = 'GRVM0001' 
	AND NMPROCED = 'pc_gravames_blqjud';

	ALTER TABLE CECRED.crapbpr
    ADD RECIDOBS NUMBER DEFAULT NULL;

	COMMENT ON COLUMN CECRED.crapbpr.RECIDOBS
  	is 'Referência PROGRESS_RECID da tabela CRAPOBS';

	COMMIT;
END;