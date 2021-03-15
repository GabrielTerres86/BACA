BEGIN
  UPDATE crawcrd w
	   SET w.dtsol2vi = NULL
   WHERE w.cdcooper = 16
     AND w.nrdconta = 616265
     AND w.nrctrcrd = 17483;
  COMMIT;
END;


		 
		 
