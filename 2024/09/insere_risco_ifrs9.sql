BEGIN
	INSERT INTO TB_CENTRAL_RISCO_OPERACAO_MOTOR
	(IDCENTRAL_RISCO_OPERACAO_MOTOR, 
	 CDCOOPER, 
	 DTREFERENCIA, 
	 NRDCONTA, 
	 NRCONTRATO, 
	 CDPRODUTO, 
	 CDMODALIDADE_BACEN, 
	 CDCARTEIRA_FINANCEIRA, 
	 CDSUBCARTEIRA_FINANCEIRA, 
	 CDESTAGIO_INSTRUMENTO, 
	 CDESTAGIO_INSTRUMENTO_ARRASTO, 
	 CDSEGMENTO, 
	 FLATIVO_PROBLEMATICO, 
	 FLALOCACAO_ESTAGIO1, 
	 FLTRATAMENTO_ISOLADO, 
	 PEPE_PISO, 
	 PEPE_MODELO, 
	 PEPE_AGRAVAMENTO, 
	 PEPE_OPERACAO, 
	 PEPE_PISO_ARRASTO, 
	 PEPE_MODELO_ARRASTO, 
	 PEPERDA_ESPERADA, 
	 VLPERDA_ESPERADA, 
	 DTPE_FINAL, 
	 DHREGISTRO)
	VALUES(SYS_GUID() , 
	       16,
	       TO_DATE('2024-05-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 
	       81312890, 
	       285124, 
	       0, 
	       '1902', 
	       '11', 
	       '1', 
	       '1', 
	       1 , 
	       'IMPLEMENTOS', 
	       1 , 
	       1, 
	       1, 
	       1, 
	       1, 
	       1, 
	       1, 
	       1, 
	       1, 
	       79.05, 
	       2300, 
	       TO_DATE('2024-05-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 
	       TO_DATE('2024-05-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
	      
	COMMIT;

END;
/