BEGIN
  UPDATE crawcrd w
     SET w.nrcrcard = 5474080175663960
        ,w.nrcctitg = 7563239620593
        ,w.insitcrd = 3
        ,w.dtentreg = NULL
        ,w.inanuida = 0
        ,w.qtanuida = 0
        ,w.dtlibera = trunc(SYSDATE)
        ,w.dtrejeit = NULL      
   WHERE w.cdcooper = 1 
     AND w.nrdconta = 11615737
     AND w.nrctrcrd = 1826565;

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
			11615737,
			5474080175663960,
			2750752493,
			'QUEZIA RIBEIRO DA SILVA',
			22,
			0,
			1826565,
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
