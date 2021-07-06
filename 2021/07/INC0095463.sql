BEGIN
	--INC0095463
	--remover 2 lançamentos na craplem
	DELETE FROM craplem
	 WHERE cdcooper = 5
	   AND nrdconta = 127744
	   AND nrctremp = 14792
	   AND dtmvtolt = to_date('22/06/2021')
	   AND vllanmto = 42.83;
	   
	 COMMIT;
 
END;
