BEGIN
	--INC0101887
	--Viacredi Alto Vale c/c 350052 excluir lançamentos do dia 03/08 (multa e pg. Multa) ambos no valor de R$ 169,22
	DELETE FROM craplem
	 WHERE cdcooper = 16
	   AND nrdconta = 350052
	   AND nrctremp = 132801
	   AND dtmvtolt = to_date('03/08/2021','dd/mm/rrrr')       
	   AND vllanmto = 169.22;
     

	-- Acentra c/c 127744 excluir lançamentos do dia 17/08 (multa e pg. Multa) ambos no valor de R$ 43,93
	DELETE FROM craplem
	 WHERE cdcooper = 5
	   AND nrdconta = 127744
	   AND nrctremp = 14792
	   AND dtmvtolt = to_date('17/08/2021','dd/mm/rrrr')  
	   AND vllanmto = 43.93;
	
	COMMIT;
	
END;