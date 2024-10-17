BEGIN   
    update crapstf set VLDSDINI = 1000.00, VLDSDFIN = 1000.00
	   where NRTERFIN in (206, 207) and
	   CDCOOPER = 9 and
	   DTMVTOLT = to_date('17-10-2024', 'dd-mm-yyyy');

    COMMIT; 
  END;