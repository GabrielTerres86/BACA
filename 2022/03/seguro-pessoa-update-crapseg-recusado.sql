BEGIN
    update crapseg p
	   set p.cdsitseg = 5
	 where p.cdcooper = 14 
	   and p.nrdconta = 284262 
	   and p.tpseguro = 4
	   and p.nrctrseg = 41096;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
END; 