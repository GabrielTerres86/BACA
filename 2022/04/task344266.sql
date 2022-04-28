BEGIN
  UPDATE crapepr e
     SET e.qtprecal = 7
   WHERE e.cdcooper = 1
     AND e.nrdconta = 9193120
     AND e.nrctremp = 4390840
     AND e.qtprecal = 2;
  COMMIT;
  EXCEPTION
	WHEN OTHERS THEN
	  RAISE_application_error(-20500, SQLERRM);
	ROLLBACK;
END;
