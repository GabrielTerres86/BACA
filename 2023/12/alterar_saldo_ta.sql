BEGIN   
    	INSERT INTO crapstf
	  (DTMVTOLT,NRTERFIN,VLDSDINI,VLDSDFIN,CDCOOPER)
	    VALUES
	  (to_date('27-08-2024', 'dd-mm-yyyy'),193,1000.00,1000.00,9);

    	INSERT INTO crapstf
	  (DTMVTOLT,NRTERFIN,VLDSDINI,VLDSDFIN,CDCOOPER)
	    VALUES
	  (to_date('27-08-2024', 'dd-mm-yyyy'),170,1000.00,1000.00,9);

    COMMIT; 
    
  END;