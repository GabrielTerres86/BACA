BEGIN

    UPDATE crawcrd
       SET nrcctitg = 7563239740599,
           nrcrcard = 5474080188821654,
           insitcrd = 3
     WHERE cdcooper = 1 
       AND nrdconta = 11250399 
       AND nrctrcrd = 1967666;

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
      SELECT cdcooper,
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
		      0						 
	 FROM crawcrd 
	   WHERE cdcooper = 1 
         AND nrdconta = 11250399 
         AND nrctrcrd = 1967666;
	
 COMMIT;
END;  
