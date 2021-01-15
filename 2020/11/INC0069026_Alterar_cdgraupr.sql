BEGIN
  UPDATE crawcrd 
     SET cdgraupr = 5
	 WHERE cdcooper = 2
	   AND nrdconta = 868841
		 AND nrctrcrd = 133281;
	COMMIT;
END;