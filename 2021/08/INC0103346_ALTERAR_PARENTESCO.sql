BEGIN
	UPDATE crawcrd
	   SET cdgraupr = 5
	 WHERE cdcooper = 1 
	   AND nrdconta = 8334145
		 AND nrctrcrd = 2131791;
	
	COMMIT;

END;  
