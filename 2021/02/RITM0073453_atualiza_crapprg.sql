DECLARE

  CURSOR cr_crapprg IS
	  SELECT prg.nmsistem
		      ,prg.cdprogra
					,prg.cdcooper
		      ,prg.nrsolici
		      ,prg.nrordprg
					,prg.inctrprg
		  FROM crapprg prg
		 WHERE prg.cdcooper = 1
		   AND prg.cdprogra IN('CRPS616','CRPS575','CRPS312')
			 AND prg.nmsistem = 'CRED';

  rw_crapprg cr_crapprg%ROWTYPE;
	
BEGIN
	
  OPEN cr_crapprg;
	
	LOOP
		
		FETCH cr_crapprg INTO rw_crapprg;
		EXIT WHEN cr_crapprg%NOTFOUND;
		
		UPDATE crapprg prg
		   SET prg.nrsolici = rw_crapprg.nrsolici
			    ,prg.nrordprg = rw_crapprg.nrordprg
					,prg.inctrprg = rw_crapprg.inctrprg
		 WHERE prg.cdcooper = 3
		   AND prg.cdprogra = rw_crapprg.cdprogra
			 AND prg.nmsistem = rw_crapprg.nmsistem;
		
	END LOOP;
	
	CLOSE cr_crapprg;
	
	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		CLOSE cr_crapprg;
END;  
