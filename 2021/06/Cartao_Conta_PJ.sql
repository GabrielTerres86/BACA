BEGIN
	UPDATE crapcrd
	SET crapcrd.cdcooper = 16
	,crapcrd.nrdconta = 205001
	,crapcrd.nrcpftit = 00904280993
	,cdadmcrd = 15
	WHERE crapcrd.nrcrcard = 5161620000587872; --Djonata

	 
	UPDATE crawcrd
	SET crawcrd.cdcooper = 16
	,crawcrd.nrdconta = 205001
	,crawcrd.nrcpftit = 00904280993
	,cdadmcrd = 15
	WHERE crawcrd.nrcrcard = 5161620000587872;

	COMMIT;
END;