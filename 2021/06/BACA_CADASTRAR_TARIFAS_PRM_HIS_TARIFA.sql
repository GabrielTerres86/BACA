BEGIN
	INSERT INTO tbcontab_prm_his_tarifa (cdhistor, dscontabil, nrctadeb_pf, nrctacrd_pf, nrctadeb_pj, nrctacrd_pj ) 
	VALUES (1593, 'TARIFA SAQUE NACIONAL - REDE CIRRUS', 8384, 1242, 8384, 1242);

	INSERT INTO tbcontab_prm_his_tarifa (cdhistor, dscontabil, nrctadeb_pf, nrctacrd_pf, nrctadeb_pj, nrctacrd_pj ) 
	VALUES (1604, 'TARIFA CONSULTA NACIONAL - REDE CIRRUS', 8384, 1242, 8384, 1242);

	UPDATE tbcrd_his_vinculo_bancoob
		 SET cdhistor = 1611
	 WHERE cdtrnbcb = 308;

	UPDATE craphcb h
		 SET h.cdhistor = 1611,
		     h.dstrnbcb = REPLACE(h.dstrnbcb, 'CONS', 'SAQ.')
	 WHERE h.cdtrnbcb = 308;

COMMIT;

END;
