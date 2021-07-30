BEGIN

	/*
	 Cooperativa....: 13
     Conta..........: 385140
     Data...........: 23/07/2021
     Valor..........: 10
	 */
	 
	delete from tbcc_prejuizo_lancamento
	where cdcooper = 13
	and nrdconta = 385140
	and cdhistor = 2739
	and vllanmto = 10
	and dtmvtolt = to_date('28/07/2021', 'dd/mm/rrrr');
	
	COMMIT;
	
END;