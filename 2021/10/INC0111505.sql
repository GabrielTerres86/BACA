BEGIN
	UPDATE CRAPASS
	SET NMPRIMTL = 'THAMIRES DOS SANTOS RICARDO'
	where cdcooper = 1
	and nrdconta = 11931396;

	UPDATE CRAPTTL
	SET nmextttl = 'THAMIRES DOS SANTOS RICARDO'
	where cdcooper = 1
	and nrdconta = 11931396;  
	
	commit;
END;
