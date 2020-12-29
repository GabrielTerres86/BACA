BEGIN
	UPDATE crawcrd w
	 SET w.nrcrcard = 5474080186818793
		,w.nrcctitg = 7563239663731
		,w.insitcrd = 3
		,w.dtentreg = NULL
		,w.inanuida = 0
		,w.qtanuida = 0
		,w.dtlibera = trunc(SYSDATE)
		,w.dtrejeit = NULL      
	WHERE w.cdcooper = 1 
	 AND w.nrdconta = 11923288
	 AND w.nrctrcrd = 1947341;

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
			11923288,
			5474080186818793,
			4937612921,
			'GUSTAVO KIELWAGEN',
			19,
			0,
			1947341,
			0,
			0,
			15,
			2,
			NULL,
			0,
			0
	);
				
 COMMIT;
END;  
