BEGIN
  DELETE CREDITO.TBCRED_PRONAMPE_REMESSA 
   WHERE NRREMESSA = 462;   
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;