BEGIN
	UPDATE cecred.crapepr
	   SET vlemprst = 1294.62			
	 WHERE cdcooper = 1
	   AND nrdconta = 822116
	   AND nrctremp = 227316;

	UPDATE cecred.crawepr
	   SET vlemprst = 1294.62			
	 WHERE cdcooper = 1
	   AND nrdconta = 822116
	   AND nrctremp = 227316;

	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
END;