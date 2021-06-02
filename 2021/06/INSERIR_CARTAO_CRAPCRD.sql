
BEGIN
  INSERT INTO crapcrd (
      cdcooper,
      nrdconta,
      nrcrcard,
      nrcpftit,
      nmtitcrd,
      dddebito,
      cdlimcrd,
      nrctrcrd,
      cdmotivo,
      nrprotoc,
      cdadmcrd,
      tpcartao,
      dtcancel,
      flgdebit,
      flgprovi
  )
    SELECT w.cdcooper,
		       w.nrdconta,
		       w.nrcrcard,
					 w.nrcpftit,
					 w.nmtitcrd,
					 w.dddebito,
					 w.cdlimcrd,
					 w.nrctrcrd,
					 w.cdmotivo,
					 w.nrprotoc,
					 w.cdadmcrd,
					 w.tpcartao,
					 w.dtcancel,
					 w.flgdebit,
           0					 
		  FROM crawcrd w WHERE w.cdcooper = 6 AND w.nrdconta = 75175 AND w.nrcrcard = 5127070345206452;
			
	COMMIT;
END;
