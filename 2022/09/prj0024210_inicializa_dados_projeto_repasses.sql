BEGIN

	INSERT INTO CREDITO.TBCRED_REPASSADOR_CREDITO
	  (NMREPASSADOR, DSREPASSADOR)
	VALUES
	  ('BNDES', 'Banco Nacional de Desenvolvimento Econ�mico e Social');
	  
	INSERT INTO CREDITO.TBCRED_REPASSADOR_CREDITO
	  (NMREPASSADOR, DSREPASSADOR)
	VALUES
	  ('Finep', 'Financiadora de Estudos e Projetos');
	  
	INSERT INTO CREDITO.TBCRED_REPASSADOR_PRODUTO
	  (CDPRODUTO_REPASSE, IDREPASSADOR_CREDITO, NMPRODUTO_REPASSE)
	VALUES
	  (24000, 1, 'BNDES Autom�tico');
	  
	INSERT INTO CREDITO.TBCRED_REPASSADOR_SUBPRODUTO
	  (IDREPASSADOR_PRODUTO,DSLINHA_REPASSE,CDCONDICAO_OPERACIONAL,DSCONDICAO_OPERACIONAL)
	VALUES
	  (1, 'Cr�dito Pequenas Empresas', 393, 'PO2020/01');  
  
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;