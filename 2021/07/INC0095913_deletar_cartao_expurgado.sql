BEGIN
  DELETE FROM crapcrd d WHERE d.cdcooper = 14 AND d.nrdconta = 12700 AND d.nrctrcrd = 6708;
  DELETE FROM crawcrd w WHERE w.cdcooper = 14 AND w.nrdconta = 12700 AND w.nrctrcrd = 6708;
	
	COMMIT;
END;
