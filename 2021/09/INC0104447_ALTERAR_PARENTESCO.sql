BEGIN
	UPDATE crawcrd
	   SET cdgraupr = 5
	 WHERE cdcooper = 1 
	   AND nrdconta = 7173660
		 AND nrctrcrd = 2132063;
	
	COMMIT;

END;  
