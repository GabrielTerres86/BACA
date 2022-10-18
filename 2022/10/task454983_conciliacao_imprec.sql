BEGIN

	INSERT INTO cecred.crapaca
		(nmdeacao
		,nmpackag
		,nmproced
		,lstparam
		,nrseqrdr)
	VALUES
		('OBTER_CONCILIACAO_URS'
		,NULL
		,'credito.obterConciliacaoURsWeb'
		,'pr_dtinicial,pr_dtfinal,pr_instatus'
		,(SELECT NRSEQRDR
			 FROM craprdr
			WHERE upper(nmprogra) = 'TELA_IMPREC'));

	UPDATE CECRED.CRAPTEL
		 SET CDOPPTEL = CDOPPTEL || ',C'
				,LSOPPTEL = LSOPPTEL || ',CONCILIACAO'
	 WHERE NMDATELA = 'IMPREC';
	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		RAISE_application_error(-20500, SQLERRM);
		ROLLBACK;
END;