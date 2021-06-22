BEGIN

    UPDATE crawcrd
       SET nrcctitg = 7563239740599,
           nrcrcard = 6393500103924073,
           insitcrd = 3
     WHERE cdcooper = 1 
       AND nrdconta = 11714565 
       AND nrctrcrd = 2155456;

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
         AND nrdconta = 11714565 
         AND nrctrcrd = 2155456;
	
 COMMIT;
END;  
