BEGIN   

	INSERT INTO crapstf
	  (DTMVTOLT
	  ,NRTERFIN
	  ,VLDSDINI
	  ,VLDSDFIN
	  ,CDCOOPER)
	VALUES
	  (to_date('27-02-2024', 'dd-mm-yyyy')
	  ,120
	  ,1000.00
	  ,1000.00
	  ,9);

	COMMIT; 
END;