BEGIN
	--RDR
	insert into craprdr (NMPROGRA, DTSOLICI)
	values ('GRVM0002', SYSDATE);
	
	--PRG
	insert into CRAPPRG (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'GRVM0002', 'Definições de contratos/imagens', ' ', ' ', ' ', 50, 10001, 1, 0, 0, 0, 0, 0, 1, 3, null);

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('VALIDA_INCLUSAO_CONTRATO', 'GRVM0002', 'pc_valida_inclusao_contrato', 'pr_cdcooper,pr_nrdconta,pr_nrctrpro,pr_tpctrpro,pr_idseqbem,pr_cddopcao,pr_tpinclus', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'GRVM0002'));
	
	COMMIT;
END;