/*
* PRB0041939_ROLLBACK_CRAPCRI_2100
* PRB0041939 - Foi criado uma regra no backend para que caso as mesmas 
* informações de boleto cheguem em um período menor que 1 minuto, 
* será impedido a geração e apresentará erro para o cooperado.
*/
BEGIN
	BEGIN
		DELETE FROM crapcri WHERE cdcritic = 2100; 
	EXCEPTION
		WHEN OTHERS THEN
		  ROLLBACK;  
	END;
	COMMIT;
END;	