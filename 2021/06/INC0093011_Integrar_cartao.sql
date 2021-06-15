BEGIN
  UPDATE crawcrd w
     SET w.nrcrcard = 6393500103924339
        ,w.nrcctitg = 7563239740602
        ,w.insitcrd = 3
        ,w.dtentreg = NULL
        ,w.inanuida = 0
        ,w.qtanuida = 0
        ,w.dtlibera = trunc(SYSDATE)
        ,w.dtrejeit = NULL      
   WHERE w.cdcooper = 1 
     AND w.nrdconta = 12526525
     AND w.nrctrcrd = 2150315;

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
	) VALUES (
			1,
			12526525,
			6393500103924339,
			11025327977,
			'JUSSARA DOS SANTOS',
			32,
			0,
			2150315,
			0,
			0,
			16,
			2,
			NULL,
			1,
			0
	);	 
 COMMIT;
END;  
