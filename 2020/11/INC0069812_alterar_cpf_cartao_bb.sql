BEGIN
	UPDATE crawcrd 
	   SET nrcpftit = 08200190978
	 WHERE cdcooper = 1
	   AND nrdconta = 827703
		 AND nrctrcrd = 176872;
		 
  COMMIT;
END;  
