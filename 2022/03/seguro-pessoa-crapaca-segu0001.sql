BEGIN

	INSERT INTO craprdr(nmprogra, dtsolici) VALUES ('SEGU0001', SYSDATE);
	 
	INSERT INTO crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    VALUES ((SELECT MAX(NRSEQACA) + 1 FROM crapaca), 'CRIA_PROPOSTA_SEGURO', 'SEGU0001','pc_busca_criar_proposta_sp','pr_cdcooper,pr_nrdconta,pr_nrctrato',
    (SELECT nrseqrdr FROM CRAPRDR WHERE nmprogra = 'SEGU0001')); 
	 
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
  