BEGIN

	--excluir lançamento do dia 01/10 Multa e PG. Multa, ambos no valor de R$ 174,98
	DELETE FROM craplem lem
	   WHERE lem.cdcooper = 16
		 AND lem.nrdconta = 350052
		 AND lem.nrctremp = 132801
		 AND lem.dtmvtolt = to_date('01/10/2021')
		 AND lem.vllanmto = 174.98;
		 
	 COMMIT;
END;