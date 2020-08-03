BEGIN
  BEGIN
     -- Cria nova proposta
	INSERT INTO crawcrd
	   (nrdconta,
		nrcrcard,
		nrcctitg,
		nrcpftit,
		vllimcrd,
		flgctitg,
		dtmvtolt,
		nmextttl,
		flgprcrd,
		tpdpagto,
		flgdebcc,
		tpenvcrd,
		vlsalari,
		dddebito,
		cdlimcrd,
		tpcartao,
		dtnasccr,
		nrdoccrd,
		nmtitcrd,
		nrctrcrd,
		cdadmcrd,
		cdcooper,
		nrseqcrd,
		dtentr2v,
		dtpropos,
		flgdebit,
		nmempcrd,
		cdgraupr,
		insitcrd)
	VALUES
	   (66150,
		6393500145053493, 
		7564457020315, 
		35247118987,
		0,
		3,
		to_date('18/01/2019', 'DD/MM/RRRR',
		'',
		1,
		1,
		1,
		1,
		0,
		32,
		0,
		2,
		to_date('03/10/1959', 'DD/MM/RRRR'),
		916534,
		'EVALDO TURKO',
		fn_sequence('CRAPMAT','NRCTRCRD', 13), 
		17,
		13,
		CCRD0003.fn_sequence_nrseqcrd(pr_cdcooper => 13),
		trunc(sysdate),
		trunc(sysdate),
		1,
		'FIVE STAR T E TURISMO',
		5,
		3);	 
     
     BEGIN
           -- Insere o cartao
        INSERT INTO crapcrd (
			cdcooper,
			nrdconta,
			nrcrcard,
			nrcpftit,
			nmtitcrd,
			dddebito,
			cdlimcrd,
			dtvalida,
			nrctrcrd,
			cdmotivo,
			nrprotoc,
			cdadmcrd,
			tpcartao,
			dtcancel,
			flgdebit
		) SELECT w.cdcooper
			    ,w.nrdconta
			    ,w.nrcrcard
			    ,w.nrcpftit
			    ,w.nmtitcrd
			    ,w.dddebito
			    ,w.cdlimcrd
			    ,w.dtvalida
			    ,w.nrctrcrd
			    ,w.cdmotivo
			    ,w.nrprotoc
			    ,w.cdadmcrd
			    ,w.tpcartao
			    ,w.dtcancel
			    ,w.flgdebit
		   FROM crawcrd w
		  WHERE w.cdcooper = 13
		    AND w.nrdconta = 66150
		    AND w.nrcrcard = 6393500145053493;
               
     EXCEPTION
       WHEN OTHERS THEN
         ROLLBACK;
         Raise_Application_Error (-20343, 'Erro ao criar registro na crapcrd.' || SQLERRM);         
     END;  
     
     COMMIT;      
   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK;
       Raise_Application_Error (-20343, 'Erro ao atualizar registro crawcrd.' || SQLERRM);
   END;
   
END;
