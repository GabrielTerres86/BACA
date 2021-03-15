BEGIN 
	
	UPDATE crawcrd w 
		 SET w.cdgraupr = 5
	 WHERE w.cdcooper = 1
		 AND w.nrdconta = 7969694
		 AND w.nrctrcrd = 1889391;
	COMMIT;

END;	 
