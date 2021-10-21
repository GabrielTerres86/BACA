BEGIN
	UPDATE crawcrd w
	   SET w.cdgraupr = 5
	 WHERE w.cdcooper = 1
	   AND w.nrdconta = 12627895
		 AND w.nrctrcrd = 2131895;
 COMMIT;
END;  
