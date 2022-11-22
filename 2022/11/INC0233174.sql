BEGIN
	UPDATE CRAPASS
	SET NMPRIMTL = 'TAINARA KETHELEN FRANCESCONI'
	where cdcooper = 1
	and nrdconta = 13468375;

	UPDATE CRAPTTL
	SET nmextttl = 'TAINARA KETHELEN FRANCESCONI'
	where cdcooper = 1
	and nrdconta = 13468375;  
	
	commit;
END;