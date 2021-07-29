BEGIN
	--INC0099543 Credicomin - 53554 - 15/07/2021
	delete from tbcc_prejuizo_lancamento
	where cdcooper = 10
	and nrdconta = 53554
	and cdhistor = 2738
	and vllanmto = 10.39
	and dtmvtolt = '27/07/2021';
	
	COMMIT;

END;
