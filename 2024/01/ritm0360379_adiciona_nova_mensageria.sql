BEGIN

	INSERT INTO cecred.crapaca
		(nmdeacao
		,nmpackag
		,nmproced
		,lstparam
		,nrseqrdr)
	VALUES
		('OBTER_PARAMETRO_NAO_FINANCIA_IOF'
		,NULL
		,'credito.obterParametroNaoFinanciaIOF'
		,'pr_cdcooper'
		,(SELECT NRSEQRDR
			 FROM craprdr
			WHERE upper(nmprogra) = 'TELA_ATENDA_EMPRESTIMO'));
	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		RAISE_application_error(-20500, SQLERRM);
END;