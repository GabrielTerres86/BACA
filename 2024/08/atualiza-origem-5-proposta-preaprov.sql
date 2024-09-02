BEGIN

  UPDATE cecred.crawepr
     SET cdorigem = 5
	 ,dtlibera = to_date('19/08/2024','dd/mm/yyyy')
   WHERE cdcooper = 11
   AND nrdconta = 489352
   AND nrctremp = 470400;
   
   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
