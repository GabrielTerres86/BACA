/* ............................................................................

   Programa: sistema/generico/procedures/b1wgen0197.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : Maio/2017.                       Ultima atualizacao: 21/11/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : BO referente a Desligamento de Cooperados

   Alteracoes: 14/11/2017 - Auste para consulta dos produtos impeditivos (Jonata - RKAM P364).

               22/11/2017 - Corrigido consulta de seguros para encontrar somente os ativos (Jonata - RKAM p364).
   
............................................................................ */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0003tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0009tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/b1wgen0033tt.i }
{ sistema/generico/includes/b1wgen0082tt.i }
{ sistema/generico/includes/b1wgen0197tt.i }

DEFINE TEMP-TABLE tt-autori                                             NO-UNDO
    FIELD cdhistor LIKE crapatr.cdhistor
    FIELD dshistor LIKE craphis.dshistor
    FIELD cddddtel LIKE crapatr.cddddtel
    FIELD cdrefere AS DECI FORMAT "zzzzzzzzzzzzzzzzzzzzzzzz9"
    FIELD dtautori LIKE crapatr.dtiniatr
    FIELD dtcancel LIKE crapatr.dtfimatr
    FIELD dtultdeb LIKE crapatr.dtultdeb
    FIELD dtvencto LIKE crapatr.ddvencto
    FIELD nmfatura LIKE crapatr.nmfatura
    FIELD nmempres LIKE crapatr.nmempres
    FIELD nmempcon LIKE gnconve.nmempres
    FIELD vlrmaxdb LIKE crapatr.vlrmaxdb
    FIELD desmaxdb AS CHAR
    FIELD cdempcon LIKE crapatr.cdempcon
    FIELD cdsegmto LIKE crapatr.cdsegmto
    FIELD dbcancel AS LOGI.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0006 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0009 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0019 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0021 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0030 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0033 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0078 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0082 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0092 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0003 AS HANDLE                                         NO-UNDO.
 
DEF VAR aux_dsdidade AS CHAR                                           NO-UNDO.
DEF VAR aux_vlbloque AS DECIMAL                                        NO-UNDO.
DEF VAR aux_vlresblq AS DECIMAL                                        NO-UNDO.
DEF VAR aux_vlresapl AS DECIMAL INIT 0                                 NO-UNDO.
DEF VAR aux_vlsrdrpp AS DECIMAL INIT 0                                 NO-UNDO.
DEF VAR aux_dsdmesag AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_cdhistor AS INTE                                           NO-UNDO.
DEF VAR aux_cdrefere AS INTE                                           NO-UNDO.
DEF VAR aux_flgsicre AS CHAR                                           NO-UNDO.
DEF VAR aux_qtregist AS INTEGER                                        NO-UNDO.

/******************************************************************************/

PROCEDURE busca_inf_produtos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-inf-produto.

    FOR FIRST crapope FIELDS(flgacres)
                       WHERE crapope.cdcooper = par_cdcooper
                         AND crapope.cdoperad = par_cdoperad
                         NO-LOCK:                     
    END.
  
    IF AVAILABLE crapope THEN
       DO:
          FOR FIRST crapass FIELDS(flgrestr vllimcre)
                             WHERE crapass.cdcooper = par_cdcooper
                               AND crapass.nrdconta = par_nrdconta
                               NO-LOCK:
          END.
          
          IF NOT AVAILABLE crapass THEN
             DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT 9,
                               INPUT-OUTPUT aux_dscritic).
                               
                ASSIGN par_dscritic = aux_dscritic.
                               
                RETURN "NOK".
             END.
          ELSE
             DO:
                IF crapass.flgrestr = TRUE AND crapope.flgacres = FALSE THEN
                  DO:
                     ASSIGN par_dscritic = "Operacao nao permitida.".
                     
                     RETURN "NOK".
                  END.
             END.
       END.
    ELSE
       DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT 67,
                         INPUT-OUTPUT aux_dscritic).
                         
          ASSIGN par_dscritic = aux_dscritic.
                         
          RETURN "NOK".          
       END.
       
    /* Buscar data do proximo dia util*/
    FOR FIRST crapdat FIELDS(dtmvtopr inproces)
                      WHERE crapdat.cdcooper = par_cdcooper
                      NO-LOCK:
    END.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT "Consulta Impedimentos Desligamento",
                        INPUT TRUE,
                        INPUT par_idseqttl, /** idseqttl **/
                        INPUT par_nmdatela,
                        INPUT par_nrdconta, /* nrdconta */
                       OUTPUT aux_nrdrowid).

    CREATE tt-inf-produto.
    ASSIGN tt-inf-produto.vlemprst = 0
           tt-inf-produto.vllimpro = 0
           tt-inf-produto.vllimdsc = 0
           tt-inf-produto.vlcompcr = 0
           tt-inf-produto.vllimcar = 0
           tt-inf-produto.vlresapl = 0
           tt-inf-produto.vlsrdrpp = 0
           tt-inf-produto.flcobran = 0
           tt-inf-produto.flseguro = 0
           tt-inf-produto.flconsor = 0
           tt-inf-produto.flgctitg = 0
           tt-inf-produto.flgccbcb = 0
           tt-inf-produto.flgccbdb = 0
           tt-inf-produto.qtfdcuso = 0
           tt-inf-produto.qtchqdev = 0
           tt-inf-produto.qtreqtal = 0
           tt-inf-produto.qtchqcan = 0
           tt-inf-produto.inarqcbr = 0
           tt-inf-produto.flgbinss = 0
           tt-inf-produto.flpdbrde = 0
           tt-inf-produto.flgconve = 0.

    /************************ Emprestimo *********************************/
    FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                           crapepr.nrdconta = par_nrdconta AND
                           crapepr.inliquid = 0   
						   NO-LOCK:
    
        ASSIGN tt-inf-produto.vlemprst = tt-inf-produto.vlemprst + crapepr.vlsdeved.

    END. 
    
    FOR LAST craplim WHERE craplim.cdcooper = par_cdcooper AND
                           craplim.nrdconta = par_nrdconta AND
                           craplim.tpctrlim = 1            AND
                           craplim.insitlim = 2
                           NO-LOCK USE-INDEX craplim2:
      ASSIGN tt-inf-produto.vllimpro = craplim.vllimite.
    END.
    
    RUN sistema/generico/procedures/b1wgen0009.p PERSISTENT SET h-b1wgen0009.    
    
    RUN busca_dados_dscchq IN h-b1wgen0009 (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_dtmvtolt,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_idorigem,
                                            INPUT par_nmdatela,
                                            INPUT FALSE, /* LOG*/
                                           OUTPUT TABLE tt-erro, 
                                           OUTPUT TABLE tt-desconto_cheques).
    
    DELETE PROCEDURE h-b1wgen0009.
            
    FOR FIRST tt-desconto_cheques NO-LOCK:
      ASSIGN tt-inf-produto.vllimdsc = tt-desconto_cheques.vllimite.
    END.
    
    RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
    
    RUN busca_dados_dsctit IN h-b1wgen0030 (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT FALSE, /* LOG */
                                           OUTPUT TABLE tt-erro, 
                                           OUTPUT TABLE tt-desconto_titulos).

    DELETE PROCEDURE h-b1wgen0030.
        
    FOR FIRST tt-desconto_titulos NO-LOCK:
      ASSIGN tt-inf-produto.vllimdsc = tt-inf-produto.vllimdsc + tt-desconto_titulos.vllimite.
    END.
        
    RUN sistema/generico/procedures/b1wgen0009.p PERSISTENT SET h-b1wgen0009.    
    
    RUN busca_borderos IN h-b1wgen0009 (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_dtmvtolt,
                                        INPUT FALSE,
                                       OUTPUT TABLE tt-bordero_chq).
                              
    DELETE PROCEDURE h-b1wgen0009.
    
    FOR EACH tt-bordero_chq NO-LOCK:
      ASSIGN tt-inf-produto.vlcompcr = tt-inf-produto.vlcompcr + tt-bordero_chq.vlcompcr.
    END.
            
    FOR EACH crawcrd FIELDS(vllimcrd)
                     WHERE crawcrd.cdcooper = par_cdcooper
                       AND crawcrd.nrdconta = par_nrdconta
                       AND (crawcrd.insitcrd = 4 
					    OR  crawcrd.insitcrd = 3
                        OR  crawcrd.insitcrd = 7)
                        NO-LOCK:
      ASSIGN tt-inf-produto.vllimcar = tt-inf-produto.vllimcar + crawcrd.vllimcrd
	         tt-inf-produto.flgcarta = 1.
    END.
    
    RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

    RUN obtem-dados-aplicacoes IN h-b1wgen0081 (INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_idorigem,
                                                INPUT par_nrdconta,
                                                INPUT par_idseqttl,
                                                INPUT 0,
                                                INPUT par_nmdatela,                                                 
                                                INPUT 0,
                                                INPUT ?,
                                                INPUT ?,
                                               OUTPUT aux_vlresapl,
                                               OUTPUT TABLE tt-saldo-rdca,
                                               OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0081.

    ASSIGN tt-inf-produto.vlresapl = aux_vlresapl.
    
	RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT SET h-b1wgen0006.      
    
    RUN consulta-poupanca IN h-b1wgen0006 (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT 0,
                                           INPUT par_dtmvtolt,
                                           INPUT crapdat.dtmvtopr,
                                           INPUT crapdat.inproces,
                                           INPUT par_nmdatela,
                                           INPUT FALSE,
                                          OUTPUT aux_vlsrdrpp,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-dados-rpp).
                                          
    DELETE PROCEDURE h-b1wgen0006.

    ASSIGN tt-inf-produto.vlsrdrpp = aux_vlsrdrpp.

    RUN sistema/generico/procedures/b1wgen0082.p PERSISTENT SET h-b1wgen0082.
    
    RUN carrega-convenios-ceb IN h-b1wgen0082 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_idorigem,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT par_dtmvtolt,
                                               INPUT FALSE,
                                              OUTPUT aux_dsdmesag,
                                              OUTPUT TABLE tt-cadastro-bloqueto,
                                              OUTPUT TABLE tt-crapcco,
                                              OUTPUT TABLE tt-titulares,
                                              OUTPUT TABLE tt-emails-titular).

    DELETE PROCEDURE h-b1wgen0082.
	
	/* Projeto 364 - Andrey - INICIO */
    FOR FIRST tt-cadastro-bloqueto WHERE tt-cadastro-bloqueto.insitceb = 1 NO-LOCK:
        ASSIGN tt-inf-produto.flcobran = 1.
    END.
	/* Projeto 364 - Andrey - FIM */
    
    /* Verificar se conta possui seguro */
    FOR EACH crapseg WHERE crapseg.cdcooper = par_cdcooper
                       AND crapseg.nrdconta = par_nrdconta
                       AND (crapseg.cdsitseg = 1 
					    OR  crapseg.cdsitseg = 3) NO-LOCK:

        ASSIGN tt-inf-produto.flseguro = 1.

		IF crapseg.tpseguro = 2 THEN
		  ASSIGN tt-inf-produto.flsegauto = 1.

    END.     

	/*Seguro de vida previsul */
	FOR EACH craphis FIELDS(cdhistor)
	                 WHERE craphis.cdcooper = par_cdcooper
	                   AND craphis.dsexthst matches '*PREVISUL*'
					       NO-LOCK,
						    		
		FIRST craplcm WHERE craplcm.cdcooper = par_cdcooper
						AND craplcm.nrdconta = par_nrdconta
						AND craplcm.cdhistor = craphis.cdhistor NO-LOCK:

			ASSIGN tt-inf-produto.flsegvida = 1.

			LEAVE.
    END.	                       
        
    /* Verificar se conta possui consorcio ativo */
    FOR FIRST crapcns WHERE crapcns.cdcooper = par_cdcooper 
                        AND crapcns.nrdconta = par_nrdconta
                        AND crapcns.flgativo = TRUE NO-LOCK:
        ASSIGN tt-inf-produto.flconsor = 1.
    END.        
    /* Verificar se conta possui conta ITG ativa */
    FOR FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                        AND crapass.nrdconta = par_nrdconta
                        AND crapass.flgctitg = 2 NO-LOCK:
        ASSIGN tt-inf-produto.flgctitg = 1.
    END.

    /* Verificar cartao bancoob */
    FOR FIRST craplcm WHERE craplcm.cdcooper = par_cdcooper
                        AND craplcm.nrdconta = par_nrdconta
                        AND CAN-DO("1956,1957,1958,1959,1960,1961", STRING(craplcm.cdhistor)) NO-LOCK:
        ASSIGN tt-inf-produto.flgccbcb = 1.
    END.
    
    /* Verificar cartao BB */
    FOR FIRST craplcm WHERE craplcm.cdcooper = par_cdcooper
                        AND craplcm.nrdconta = par_nrdconta
                        AND CAN-DO("444,584", STRING(craplcm.cdhistor)) NO-LOCK:
        ASSIGN tt-inf-produto.flgccbdb = 1.
    END.
	
	FOR FIRST craptab WHERE  craptab.nmsistem = "CRED" 				 AND
							 craptab.tptabela = "GENERI" 			 AND
							 craptab.cdempres = 0 					 AND
							 craptab.cdacesso = "VERIFICADOCARTAOBB" AND
							 craptab.tpregist = par_nrdconta         AND
							 craptab.cdcooper = par_cdcooper 		 NO-LOCK:
		ASSIGN tt-inf-produto.flgccbcb = 0.
		ASSIGN tt-inf-produto.flgccbdb = 0.
	END.
	
    /* Buscar quantidade de folhas de cheque em uso */
    FOR EACH crapfdc FIELDS(cdcooper nrdconta cdbanchq cdagechq nrctachq nrcheque) 
					  WHERE crapfdc.cdcooper = par_cdcooper 
						AND crapfdc.nrdconta = par_nrdconta
						AND crapfdc.incheque = 0 
						AND crapfdc.dtliqchq = ? 
						AND crapfdc.dtemschq <> ? 
						AND crapfdc.dtretchq <> ?
						NO-LOCK:
				
		FIND FIRST crapneg WHERE crapneg.cdcooper = crapfdc.cdcooper AND
		                         crapneg.nrdconta = crapfdc.nrdconta AND
							     crapneg.cdbanchq = crapfdc.cdbanchq AND
								 crapneg.cdagechq = crapfdc.cdagechq AND
								 crapneg.nrctachq = crapfdc.nrctachq AND
								 crapneg.cdhisest = 1 				AND
								 INT(SUBSTR(STRING(crapneg.nrdocmto,"9999999"),1,6))  = crapfdc.nrcheque
								 NO-LOCK NO-ERROR.
							
		IF NOT AVAIL crapneg THEN
		   ASSIGN tt-inf-produto.qtfdcuso = tt-inf-produto.qtfdcuso + 1.
			
	END.
    
	/* Buscar quantidade de folhas de cheque em estoque */
    FOR EACH crapfdc FIELDS(cdcooper nrdconta cdbanchq cdagechq nrctachq nrcheque) 
					  WHERE crapfdc.cdcooper = par_cdcooper 
						AND crapfdc.nrdconta = par_nrdconta
						AND crapfdc.dtemschq <> ?
						AND crapfdc.dtretchq = ? 
							NO-LOCK:
							
		FIND FIRST crapneg WHERE crapneg.cdcooper = crapfdc.cdcooper AND
		                         crapneg.nrdconta = crapfdc.nrdconta AND
							     crapneg.cdbanchq = crapfdc.cdbanchq AND
								 crapneg.cdagechq = crapfdc.cdagechq AND
								 crapneg.nrctachq = crapfdc.nrctachq AND
								 crapneg.cdhisest = 1 				AND
								 INT(SUBSTR(STRING(crapneg.nrdocmto,"9999999"),1,6))  = crapfdc.nrcheque 
								 NO-LOCK NO-ERROR.
							
		IF NOT AVAIL crapneg THEN
		   ASSIGN tt-inf-produto.qtfdcest = tt-inf-produto.qtfdcest + 1.
			
	END.

	
    /* Buscar quantidade de cheques devolvidos */
    FOR EACH crapneg FIELDS(cdcooper)
                      WHERE crapneg.cdcooper = par_cdcooper 
                        AND crapneg.nrdconta = par_nrdconta 
                        AND crapneg.cdhisest = 1
                        AND CAN-DO("11,12,13", STRING(crapneg.cdobserv)) NO-LOCK:
        ASSIGN tt-inf-produto.qtchqdev = tt-inf-produto.qtchqdev + 1.
    END.
    
    /* Buscar quantidade de Talonarios em estoque */
    FOR FIRST crapreq FIELDS(qtreqtal)
                       WHERE crapreq.cdcooper = par_cdcooper
                         AND crapreq.nrdconta = par_nrdconta
                         AND crapreq.insitreq = 1
                         AND crapreq.tprequis = 1
                         NO-LOCK:
        ASSIGN tt-inf-produto.qtreqtal = crapreq.qtreqtal.
    END.
    
    /* Verificar se cooperado recebe beneficio do INSS */
    FOR EACH craplcm FIELDS(cdcooper)
                      WHERE craplcm.cdcooper = par_cdcooper
                        AND craplcm.nrdconta = par_nrdconta
                        AND craplcm.cdhistor = 1399 /* Beneficio INSS */
                         NO-LOCK:
        ASSIGN tt-inf-produto.flgbinss = 1.
    END.
    
    /* Cooperado utiliza pagamento por arquivo */
    FOR FIRST crapass FIELDS(inarqcbr)
                       WHERE crapass.cdcooper = par_cdcooper
                         AND crapass.nrdconta = par_nrdconta
                         AND crapass.flgctitg = 2 /* Ativo */
                         AND crapass.inarqcbr = 1 /* Gera arquivo */
                         NO-LOCK:
        ASSIGN tt-inf-produto.inarqcbr = crapass.inarqcbr.
    END.
    
    /* Produto BRDE */
    FOR FIRST craplcm FIELDS(cdcooper)
                       WHERE craplcm.cdcooper = par_cdcooper
                         AND craplcm.nrdconta = par_nrdconta
                         AND craplcm.cdhistor = 583 /* Financiamento BRDE */
                         NO-LOCK:
        ASSIGN tt-inf-produto.flpdbrde = 1.
    END.
	
	/*********************** Lancamento Futuro ***************************/
	RUN sistema/generico/procedures/b1wgen0003.p 
		PERSISTENT SET h-b1wgen0003.
		
	RUN consulta-lancamento IN 
		h-b1wgen0003 (INPUT par_cdcooper,
					  INPUT par_cdagenci,
					  INPUT par_nrdcaixa,
					  INPUT par_cdoperad,
					  INPUT par_nrdconta,
					  INPUT par_idorigem,
					  INPUT par_idseqttl,
					  INPUT par_nmdatela,
					  INPUT FALSE,
					 OUTPUT TABLE tt-totais-futuros,
					 OUTPUT TABLE tt-erro,
					 OUTPUT TABLE tt-lancamento_futuro).

	DELETE PROCEDURE h-b1wgen0003.
	
	IF  CAN-FIND(FIRST tt-lancamento_futuro NO-LOCK)  
	THEN DO:
		ASSIGN tt-inf-produto.flgagend = 1.	   
	END.
    
	/******************** Cartao Magnetico *******************************/
	IF CAN-FIND(FIRST crapcrm WHERE crapcrm.cdcooper  = par_cdcooper AND
									crapcrm.nrdconta  = par_nrdconta AND
									crapcrm.cdsitcar  = 2            AND
									crapcrm.dtvalcar >= par_dtmvtolt 
									NO-LOCK)
	THEN DO:
		ASSIGN tt-inf-produto.flgcrmag = 1.		
	END.
		
  /* PRJ 402 */
  FOR FIRST crapcdr WHERE crapcdr.cdcooper = par_cdcooper
                      AND crapcdr.nrdconta = par_nrdconta NO-LOCK NO-ERROR NO-WAIT. END.
                      
  IF AVAILABLE crapcdr THEN
    ASSIGN tt-inf-produto.flgconve = crapcdr.flgconve.
  /* PRJ 402 */
    
  RETURN "OK".
    
END PROCEDURE.

PROCEDURE canc_auto_produtos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flaceint AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flfolpag AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_fldebaut AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_fllimint AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flplacot AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flpouppr AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    FOR FIRST crapass FIELDS(dtdemiss)
                      WHERE crapass.cdcooper = par_cdcooper AND
                            crapass.nrdconta = par_nrdconta NO-LOCK:

      Grava: DO TRANSACTION
          ON ERROR  UNDO Grava, LEAVE Grava
          ON QUIT   UNDO Grava, LEAVE Grava
          ON STOP   UNDO Grava, LEAVE Grava
          ON ENDKEY UNDO Grava, LEAVE Grava:

        /* PLANO DE COTAS */
        IF par_flplacot = 1 THEN
          DO:
            RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT SET h-b1wgen0021.
            
            RUN cancelar-plano-atual IN h-b1wgen0021 (INPUT par_cdcooper,
                                                      INPUT par_cdagenci,
                                                      INPUT par_nrdcaixa,
                                                      INPUT par_cdoperad,
                                                      INPUT par_nmdatela,
                                                      INPUT par_idorigem,
                                                      INPUT par_nrdconta,
                                                      INPUT par_idseqttl,
                                                      OUTPUT TABLE tt-erro,
                                                      OUTPUT TABLE tt-cancelamento).
            DELETE PROCEDURE h-b1wgen0021.

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.

                  IF   AVAIL tt-erro  THEN
                       par_dscritic = "Plano de cotas - " + tt-erro.dscritic + "</br>".
                  ELSE
                       par_dscritic = "Plano de cotas - Nao foi possivel efetuar o cancelamento automatico.</br>".              
                END.
          END.
        
        /* POUP. PROG. */
        IF par_flpouppr = 1 THEN
          DO:
            FOR EACH craprpp FIELDS(nrctrrpp)
                             WHERE craprpp.cdcooper = par_cdcooper AND
                                   craprpp.nrdconta = par_nrdconta AND
                                   craprpp.cdsitrpp <> 3           AND
								   craprpp.cdsitrpp <> 5 
								   NO-LOCK:
            
              RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT SET h-b1wgen0006.      
              
              RUN cancelar-poupanca IN h-b1wgen0006 (INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT par_cdoperad,
                                                     INPUT par_nmdatela,
                                                     INPUT par_idorigem,
                                                     INPUT par_nrdconta,
                                                     INPUT par_idseqttl,
                                                     INPUT craprpp.nrctrrpp,
                                                     INPUT par_dtmvtolt,
                                                     INPUT TRUE,
                                                    OUTPUT TABLE tt-erro).          
              DELETE PROCEDURE h-b1wgen0006.

              IF  RETURN-VALUE = "NOK"  THEN
                  DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF   AVAIL tt-erro  THEN
                         par_dscritic = par_dscritic + "Poupanca Programada - " + tt-erro.dscritic + "</br>".
                    ELSE
                         par_dscritic = par_dscritic + "Poupanca Programada - Nao foi possivel efetuar o cancelamento automatico.</br>".
                  END.
              
            END.
          END.
        /* APLICACAO */
        IF par_flaplica = 1 THEN
          DO: 
            FOR EACH crapaar FIELDS(nrctraar)
                             WHERE crapaar.cdcooper = par_cdcooper AND
                                   crapaar.nrdconta = par_nrdconta AND
                                   crapaar.cdsitaar <> 3 NO-LOCK:

              RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

              RUN excluir-agendamento IN h-b1wgen0081 (INPUT par_cdcooper,
                                                       INPUT par_nrdconta,
                                                       INPUT par_idseqttl,
                                                       INPUT crapaar.nrctraar,
                                                       INPUT par_cdoperad,
                                                      OUTPUT TABLE tt-erro).
                                                      
              DELETE PROCEDURE h-b1wgen0081.

              IF  RETURN-VALUE = "NOK"  THEN
                  DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF   AVAIL tt-erro  THEN
                         par_dscritic = par_dscritic + "Aplicacao - " + tt-erro.dscritic + "</br>".
                    ELSE
                         par_dscritic = par_dscritic + "Aplicacao - Nao foi possivel efetuar o cancelamento automatico.</br>".
                  END.

            END.  
          END.
          
        /* DEB. AUT. */
        IF par_fldebaut = 1 THEN
          DO:
            RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.      
            
            RUN busca-autori IN h-b1wgen0092(INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT TRUE, /* LOG */
                                             INPUT par_dtmvtolt,
                                             INPUT "C",
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT "N",
                                            OUTPUT TABLE tt-erro, 
                                            OUTPUT TABLE tt-autori).

            DELETE PROCEDURE h-b1wgen0092.

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.

                  IF   AVAIL tt-erro  THEN
                       par_dscritic = par_dscritic + "Debito automatico - " + tt-erro.dscritic + "</br>".
                  ELSE
                       par_dscritic = par_dscritic + "Debito automatico - Nao foi possivel efetuar o cancelamento automatico.</br>".
                END.    
                
            FOR EACH tt-autori:
                  
              Contador: DO aux_contador = 1 TO 10:

                  FOR FIRST crapatr WHERE crapatr.cdcooper = par_cdcooper AND
                                          crapatr.nrdconta = par_nrdconta AND
                                          crapatr.cdhistor = tt-autori.cdhistor AND
                                          crapatr.cdrefere = tt-autori.cdrefere
                                          USE-INDEX crapatr1
                                          EXCLUSIVE-LOCK:
                  END.
                  
                  IF  NOT AVAIL crapatr THEN
                      IF  LOCKED crapatr  THEN
                          DO:
                              IF  aux_contador = 10 THEN
                                  DO:
                                      RUN gera_erro (INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT 1,
                                                     INPUT 341,
                                                     INPUT-OUTPUT aux_dscritic).
                                      par_dscritic = par_dscritic + "Debito automatico - " + aux_dscritic + "</br>".                                                 
                                  END.
                              ELSE 
                                  DO:
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT Contador.
                                  END.
                          END.
                      ELSE 
                          DO:
                              RUN gera_erro (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT 1,
                                             INPUT 453,
                                             INPUT-OUTPUT aux_dscritic).
                              par_dscritic = par_dscritic + "Debito automatico - " + aux_dscritic + "</br>".
                          END.
                  ELSE
                    DO:
                      ASSIGN crapatr.cdopeexc = par_cdoperad
                             crapatr.cdageexc = par_cdagenci
                             crapatr.dtinsexc = TODAY
                             crapatr.dtfimatr = par_dtmvtolt.
                      LEAVE Contador.
                    END.
              END.      
            
            END.
            
            RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.                
                
            RUN encerrar-sacado-dda IN h-b1wgen0078(INPUT par_cdcooper,  
                                                    INPUT par_cdagenci,  
                                                    INPUT par_nrdcaixa,  
                                                    INPUT par_cdoperad,  
                                                    INPUT par_nmdatela,  
                                                    INPUT par_idorigem,  
                                                    INPUT par_nrdconta,  
                                                    INPUT par_idseqttl,  
                                                    INPUT par_dtmvtolt,  
                                                    INPUT TRUE,          
                                                   OUTPUT TABLE tt-erro).
            DELETE PROCEDURE h-b1wgen0078.

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.

                  IF   AVAIL tt-erro  THEN
                       par_dscritic = par_dscritic + "DDA - " + tt-erro.dscritic + "</br>".                                                 
                  ELSE
                       par_dscritic = par_dscritic + "DDA - Nao foi possivel efetuar o cancelamento automatico.</br>".
                END.
            
          END.
        /* FOLHA PAG. */          
        IF par_flfolpag = 1 THEN
          DO:
            FOR EACH crapemp WHERE crapemp.cdcooper = par_cdcooper AND
                                   crapemp.nrdconta = par_nrdconta EXCLUSIVE-LOCK:
              ASSIGN crapemp.flgpgtib = FALSE.
            END.
          END.
        
        /* ACESSO INTERNET */
        IF par_flaceint = 1 THEN
          DO:
            RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.
            
            RUN cancelar-senha-internet IN h-b1wgen0015 (INPUT par_cdcooper,
                                                         INPUT par_cdagenci,
                                                         INPUT par_nrdcaixa,
                                                         INPUT par_cdoperad,
                                                         INPUT par_nmdatela,
                                                         INPUT par_idorigem,
                                                         INPUT par_nrdconta,
                                                         INPUT par_idseqttl,
                                                         INPUT par_dtmvtolt,
                                                         INPUT 0,
                                                         INPUT TRUE, /** LOG **/
                                                        OUTPUT TABLE tt-msg-confirma,
                                                        OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0015.

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.

                  IF   AVAIL tt-erro  THEN
                       par_dscritic = par_dscritic + "Internet e Limite - " + tt-erro.dscritic + "</br>".
                  ELSE
                       par_dscritic = "Internet e Limite - Nao foi possivel efetuar o cancelamento automatico.</br>".
                END.      
          END.

        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT "Cancelamento automatico de produtos",
                            INPUT TRUE,
                            INPUT par_idseqttl, /** idseqttl **/
                            INPUT par_nmdatela,
                            INPUT par_nrdconta, /* nrdconta */
                           OUTPUT aux_nrdrowid).

      END.      
    END.
    
    IF NOT AVAILABLE crapass THEN
      ASSIGN par_dscritic = "Nao foi possivel efetuar o cancelamento automatico. Conta nao encontrada.".
      
    IF par_dscritic <> ? AND par_dscritic <> "" THEN
      RETURN "NOK".
      
    RETURN "OK".
    
END PROCEDURE.
/******************************************************************************/

PROCEDURE seta_vendas_cartao:
	
	DEF  INPUT PARAM par_cdcooper  AS INTE                           NO-UNDO.
	DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.
	DEF OUTPUT PARAM aux_dscritic  AS CHAR                           NO-UNDO.
	
	
	CREATE craptab.
	ASSIGN craptab.nmsistem = "CRED"
		   craptab.tptabela = "GENERI"
		   craptab.cdempres = 0
		   craptab.cdacesso = "VERIFICADOCARTAOBB"
		   craptab.tpregist = par_nrdconta
		   craptab.dstextab = ""
		   craptab.cdcooper = par_cdcooper.
		   
	VALIDATE craptab.
	
	RETURN 'OK'.
END PROCEDURE.