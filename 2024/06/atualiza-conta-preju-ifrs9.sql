BEGIN
  UPDATE crapass a
     SET a.cdsitdct = 4
   WHERE a.cdcooper = 8
     AND a.nrdconta = 81526733;
     
	 
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);    

END;
