BEGIN
   
	INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	VALUES ('QBRSIG_OBT_REP_PROC', 'TELA_QBRSIG', 'pc_obtem_rep_procs', 'pr_cdcoptel,pr_nrdconta', '1744');

	UPDATE CRAPACA
	SET LSTPARAM = 'pr_cdcoptel,pr_nrdconta,pr_dtiniper,pr_dtfimper,pr_titinvestigado,pr_dsprotoc,pr_flgreppr' WHERE NMDEACAO = 'QBRSIG_QUEBRA_SIGILO';
   
	COMMIT;
	
END;