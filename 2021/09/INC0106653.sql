BEGIN
	--INC0106653
	--Viacredi Alto Vale c/c 350052 excluir lançamentos do dia 02/09 (multa e pg. Multa) ambos no valor de R$ 169,22
	DELETE FROM craplem
	 WHERE cdcooper = 16
	   AND nrdconta = 350052
	   AND nrctremp = 132801
	   AND dtmvtolt = to_date('02/09/2021','dd/mm/rrrr')       
	   AND vllanmto = 169.22;
     

	-- Acentra c/c 127744 excluir lançamentos do dia 16/09 (multa e pg. Multa) ambos no valor de R$ 45,39
	DELETE FROM craplem
	 WHERE cdcooper = 5
	   AND nrdconta = 127744
	   AND nrctremp = 14792
	   AND dtmvtolt = to_date('16/09/2021','dd/mm/rrrr')  
	   AND vllanmto = 45.39;
	
	COMMIT;
	
END;