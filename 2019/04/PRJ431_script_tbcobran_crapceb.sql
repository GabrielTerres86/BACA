DECLARE
  --
	CURSOR cr_tbcobran IS
		SELECT cdcooper
					,nrdconta
					,nrconven
					,nrcnvceb
					,dtcadast
					,cdoperad
					,insitceb
					,inarqcbr
					,cddemail
					,flgcruni
					,flgcebhm
					,cdhomolo
					,flcooexp
					,flceeexp
					,flserasa
					,cdopeori
					,cdageori
					,dtinsori
					,cdopeexc
					,cdageexc
					,dtinsexc
					,flprotes
					,qtdecprz
					,qtdfloat
					,idrecipr
					,dhanalis
					,cdopeana
					,inenvcob
					,flgregon
					,flgpgdiv
					,qtlimaxp
					,qtlimmip
					,insrvprt
					,flgdigit
					,fltercan
					,ROWID
			FROM tbcobran_crapceb tc
		 WHERE tc.cdcooper <> 16
			/* AND NOT EXISTS(SELECT 1
												FROM crapceb ceb
											 WHERE ceb.cdcooper = tc.cdcooper
												 AND ceb.nrdconta = tc.nrdconta)*/;
  --
BEGIN
	--
	FOR rg_tbcobran IN cr_tbcobran LOOP
		--
		INSERT INTO crapceb(cdcooper
											 ,nrdconta
											 ,nrconven
											 ,nrcnvceb
											 ,dtcadast
											 ,cdoperad
											 ,insitceb
											 ,inarqcbr
											 ,cddemail
											 ,flgcruni
											 ,flgcebhm
											 ,cdhomolo
											 ,flcooexp
											 ,flceeexp
											 ,flserasa
											 ,cdopeori
											 ,cdageori
											 ,dtinsori
											 ,cdopeexc
											 ,cdageexc
											 ,dtinsexc
											 ,flprotes
											 ,qtdecprz
											 ,qtdfloat
											 ,idrecipr
											 ,dhanalis
											 ,cdopeana
											 ,inenvcob
											 ,flgregon
											 ,flgpgdiv
											 ,qtlimaxp
											 ,qtlimmip
											 ,insrvprt
											 ,flgdigit
											 ,fltercan
											 )
								 VALUES(rg_tbcobran.cdcooper
											 ,rg_tbcobran.nrdconta
											 ,rg_tbcobran.nrconven
											 ,rg_tbcobran.nrcnvceb
											 ,rg_tbcobran.dtcadast
											 ,rg_tbcobran.cdoperad
											 ,2--rg_tbcobran.insitceb
											 ,rg_tbcobran.inarqcbr
											 ,rg_tbcobran.cddemail
											 ,rg_tbcobran.flgcruni
											 ,rg_tbcobran.flgcebhm
											 ,rg_tbcobran.cdhomolo
											 ,rg_tbcobran.flcooexp
											 ,rg_tbcobran.flceeexp
											 ,rg_tbcobran.flserasa
											 ,rg_tbcobran.cdopeori
											 ,rg_tbcobran.cdageori
											 ,rg_tbcobran.dtinsori
											 ,rg_tbcobran.cdopeexc
											 ,rg_tbcobran.cdageexc
											 ,rg_tbcobran.dtinsexc
											 ,rg_tbcobran.flprotes
											 ,rg_tbcobran.qtdecprz
											 ,rg_tbcobran.qtdfloat
											 ,rg_tbcobran.idrecipr
											 ,rg_tbcobran.dhanalis
											 ,rg_tbcobran.cdopeana
											 ,rg_tbcobran.inenvcob
											 ,rg_tbcobran.flgregon
											 ,rg_tbcobran.flgpgdiv
											 ,rg_tbcobran.qtlimaxp
											 ,rg_tbcobran.qtlimmip
											 ,rg_tbcobran.insrvprt
											 ,rg_tbcobran.flgdigit
											 ,rg_tbcobran.fltercan
											 );
	  --
		DELETE FROM tbcobran_crapceb WHERE ROWID = rg_tbcobran.rowid;
		--
	END LOOP;
	--
	COMMIT;
	--
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		dbms_output.put_line('Erro: ' || SQLERRM);
END;
/
