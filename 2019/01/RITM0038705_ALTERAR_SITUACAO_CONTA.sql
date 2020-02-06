-- Created on 15/01/2020 by T0032613 
DECLARE 

    ------> Cursor de cooperativas
    CURSOR cr_crapcop IS
		SELECT cdcooper
			   ,flgativo
	      FROM crapcop
	     WHERE cdcooper <> 3
	     ORDER BY cdcooper DESC;

BEGIN
  
	FOR coop IN cr_crapcop LOOP

		UPDATE crapass a 
		   SET a.cdsitdct = 1 
		 WHERE a.cdcooper = coop.cdcooper 
		   AND a.cdsitdct = 0;
  
	END LOOP;	 
	COMMIT;

END;