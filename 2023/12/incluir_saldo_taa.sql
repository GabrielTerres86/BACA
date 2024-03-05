BEGIN   

	INSERT INTO crapstf
	  (DTMVTOLT
	  ,NRTERFIN
	  ,VLDSDINI
	  ,VLDSDFIN
	  ,CDCOOPER)
	VALUES
	  (to_date('05-03-2024', 'dd-mm-yyyy')
	  ,127
	  ,1000.00
	  ,1000.00
	  ,9);

	INSERT INTO crapstf
	  (DTMVTOLT
	  ,NRTERFIN
	  ,VLDSDINI
	  ,VLDSDFIN
	  ,CDCOOPER)
	VALUES
	  (to_date('05-03-2024', 'dd-mm-yyyy')
	  ,111
	  ,1000.00
	  ,1000.00
	  ,9);


	COMMIT; 
END;