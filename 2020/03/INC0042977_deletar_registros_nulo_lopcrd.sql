BEGIN
	DELETE 
	  FROM tbcrd_limoper o
	 WHERE o.vllimconsumd IS NULL
		OR o.vllimdisp IS NULL; 
		
	COMMIT;
END;