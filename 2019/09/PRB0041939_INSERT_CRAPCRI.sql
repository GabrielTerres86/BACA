/*
* PRB0041939_INSERT_CRAPCRI
* PRB0041939 - Foi criado uma regra no backend para que caso as mesmas 
* informações de boleto cheguem em um período menor que 1 minuto, 
* será impedido a geração e apresentará erro para o cooperado.
*/
BEGIN
	BEGIN
		INSERT INTO crapcri
		  (cdcritic
		  ,dscritic
		  ,tpcritic
		  ,flgchama)
		VALUES
		  (2100
		  ,'Você acabou de gerar um boleto com os mesmos dados (valor, pagador e vencimento). Para emitir novamente um boleto igual, aguarde um minuto.'
		  ,4
		  ,0);
		  
	EXCEPTION
		WHEN OTHERS THEN
		  ROLLBACK;  
	END;
	COMMIT;
END;