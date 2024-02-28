BEGIN   

	INSERT INTO crapstf
	  (DTMVTOLT
	  ,NRTERFIN
	  ,VLDSDINI
	  ,VLDSDFIN
	  ,CDCOOPER)
	VALUES
	  (to_date('28-02-2024', 'dd-mm-yyyy')
	  ,125
	  ,0.00
	  ,0.00
	  ,9);

	COMMIT; 
END;