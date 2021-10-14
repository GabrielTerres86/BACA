BEGIN
	UPDATE crapass a
	   SET a.cdsitdct = 8
	 WHERE a.cdcooper = 16
	   AND a.nrdconta = 510408;

	UPDATE crapass a
	   SET a.cdsitdct = 8
	 WHERE a.cdcooper = 14
	   AND a.nrdconta = 38385;

COMMIT;
END;  
