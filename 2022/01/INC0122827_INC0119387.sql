BEGIN
    UPDATE crapseg p 
	   SET p.cdsitseg = 2
	 WHERE p.cdcooper = 14
	   AND p.nrdconta = 44318
	   AND p.nrctrseg = 2432;
	   
	UPDATE crapseg p 
	   SET p.cdsitseg = 2
	 WHERE p.cdcooper = 7
	   AND p.nrdconta = 103896
	   AND p.nrctrseg = 12973;   
	
    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;