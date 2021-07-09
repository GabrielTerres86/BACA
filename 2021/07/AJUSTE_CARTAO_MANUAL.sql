BEGIN
    DELETE FROM crapcrd WHERE cdcooper = 11 AND nrdconta = 772437 AND nrctrcrd = 148570;
		DELETE FROM crawcrd WHERE cdcooper = 11 AND nrdconta = 772437 AND nrctrcrd = 148570;
		
		
    UPDATE crawcrd
       SET nrcctitg = 7564438062018,
           nrcrcard = 5127070349721183,
           insitcrd = 3,
					 insitdec = 3
     WHERE cdcooper = 11
       AND nrdconta = 772437 
       AND nrctrcrd = 147296;

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
	WHERE cdcooper = 11
		AND nrdconta = 772437 
		AND nrctrcrd = 147296;
  
 COMMIT;
END;  
