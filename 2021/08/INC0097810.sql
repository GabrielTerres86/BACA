BEGIN
	-- INC0097810 - remover 2 registros de R$164,85 lançados no dia: 05/07/2021 
	DELETE FROM craplem lem
	 WHERE lem.cdcooper = 16
	   AND lem.nrdconta = 350052
	   AND lem.nrctremp = 132801
	   AND lem.dtmvtolt = to_date('05/07/2021','dd/mm/rrrr');
	   AND lem.vllanmto = 164.85;

	COMMIT;
END;