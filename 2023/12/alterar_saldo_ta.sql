BEGIN   
    	INSERT INTO crapstf
	  (DTMVTOLT,NRTERFIN,VLDSDINI,VLDSDFIN,CDCOOPER)
	    VALUES
	  (to_date('12-09-2024', 'dd-mm-yyyy'),198,1000.00,1000.00,9);

    COMMIT; 
    
  END;