BEGIN
	UPDATE crawcrd w 
	   SET w.cdorigem = 10
	 WHERE w.cdcooper = 11
	   AND w.idlimite IN (1691, 1780, 2837, 2835);
  
	
	COMMIT;
END;  