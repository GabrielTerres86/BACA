BEGIN

	INSERT INTO cecred.crapaca
		(nmdeacao
		,nmpackag
		,nmproced
		,lstparam
		,nrseqrdr)
	VALUES
		('OBTER_PARAMETRO_CARENCIA_POS'
		,NULL
		,'credito.obterParametroCarenciaPOS'
		,'pr_cdcooper'
		,(SELECT NRSEQRDR
			 FROM craprdr
			WHERE upper(nmprogra) = 'TELA_ATENDA_EMPRESTIMO'));
	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		RAISE_application_error(-20500, SQLERRM);
		ROLLBACK;
END;