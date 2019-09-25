/*
* PRB0042054_INSERT_CRAPCRI
* PRB0042054 - Identificamos um padrão de erros não
*              tratados nos logs do serviço, que acompanham 
*		       os registros de transações offline.
*/
BEGIN
	BEGIN
		INSERT INTO crapcri
		  (cdcritic
		  ,dscritic
		  ,tpcritic
		  ,flgchama)
		VALUES
		  (2101
		  ,'2101 - Erro na conversão de valores tipo {P1}.'
		  ,4
		  ,0);
		  
	EXCEPTION
		WHEN OTHERS THEN
		  ROLLBACK;  
	END;
	COMMIT;
END;