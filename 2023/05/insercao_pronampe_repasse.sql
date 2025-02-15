BEGIN

	INSERT INTO CREDITO.TBCRED_REPASSADOR_CREDITO
		(NMREPASSADOR
		,DSREPASSADOR)
	VALUES
		('BB',
		'Banco do Brasil');

	INSERT INTO CREDITO.TBCRED_REPASSADOR_PRODUTO
		(CDPRODUTO_REPASSE
		,IDREPASSADOR_CREDITO
		,NMPRODUTO_REPASSE)
	VALUES
		(0
		,(SELECT IDREPASSADOR_CREDITO
			 FROM CREDITO.TBCRED_REPASSADOR_CREDITO
			WHERE NMREPASSADOR = 'BB')
		,'PRONAMPE');

	INSERT INTO CREDITO.TBCRED_REPASSADOR_SUBPRODUTO
		(IDREPASSADOR_PRODUTO
		,DSLINHA_REPASSE
		,CDCONDICAO_OPERACIONAL
		,DSCONDICAO_OPERACIONAL)
	VALUES
		((SELECT IDREPASSADOR_PRODUTO
			 FROM CREDITO.TBCRED_REPASSADOR_PRODUTO
			WHERE NMPRODUTO_REPASSE = 'PRONAMPE')
		,'PRONAMPE'
		,0
		,NULL);

	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		RAISE_APPLICATION_ERROR(-20500, SQLERRM);
END;