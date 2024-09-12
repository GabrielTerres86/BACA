BEGIN   
    	update crapstf set VLDSDINI = 1000.00, VLDSDFIN = 1000.00
	   where NRTERFIN = 201 and
	   CDCOOPER = 9 and
	   DTMVTOLT = to_date('12-09-2024', 'dd-mm-yyyy')

    COMMIT; 
    
  END;