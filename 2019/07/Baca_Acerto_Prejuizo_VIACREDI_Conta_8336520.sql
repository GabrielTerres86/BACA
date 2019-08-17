  BEGIN
    UPDATE tbcc_prejuizo a
       SET vlsdprej = 0
     WHERE cdcooper = 1
       AND nrdconta = 8336520;
	   commit;
  END;