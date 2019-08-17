{ /usr/coop/sistema/generico/includes/var_internet.i  }
{ /usr/coop/sistema/generico/includes/b1wgen0084tt.i  }
{ /usr/coop/sistema/generico/includes/b1wgen0084att.i }
{ /usr/coop/sistema/generico/includes/b1wgen0043tt.i  }
{ sistema/generico/includes/var_oracle.i }

PROCEDURE desfaz_efetivacao_emprestimo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador          AS INTE                           NO-UNDO.
    DEF VAR aux_floperac          AS LOGI                           NO-UNDO.
    DEF VAR aux_cdhistor          AS INTE                           NO-UNDO.
    DEF VAR aux_nrdolote          AS INTE                           NO-UNDO.
    DEF VAR aux_vltotemp          AS DECI                           NO-UNDO.
    DEF VAR aux_vltotctr          AS DECI                           NO-UNDO.
    DEF VAR aux_vltotjur          AS DECI                           NO-UNDO.
    DEF VAR aux_nrseqdig          AS INTE                           NO-UNDO.
    DEF VAR i                     AS INTE                           NO-UNDO.
    DEF VAR aux_cdcritic          AS INTEGER NO-UNDO.
    DEF VAR aux_dscritic           AS CHAR NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                      NO-UNDO.

    DEF VAR aux_flgtrans          AS LOGI                           NO-UNDO.
    DEF VAR aux_idcarga           AS INTE                           NO-UNDO.
    DEF VAR aux_tpfinali          AS INTE                           NO-UNDO.

    DEF VAR h-b1wgen0134          AS HANDLE                         NO-UNDO.
    DEF VAR h-b1craplot           AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0188          AS HANDLE                         NO-UNDO.

    DEF BUFFER b-crawepr FOR crawepr.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
           
    FIND crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                       crapepr.nrdconta = par_nrdconta AND
                       crapepr.nrctremp = par_nrctremp
                       NO-LOCK NO-ERROR.
                       
    IF NOT AVAIL crapepr THEN
       RETURN "OK".    

    Desfaz:
    DO TRANSACTION ON ERROR UNDO, RETURN "NOK":

        DO aux_contador = 1 TO 10:

           FIND crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                              crapepr.nrdconta = par_nrdconta AND
                              crapepr.nrctremp = par_nrctremp
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAIL crapepr   THEN
                IF   LOCKED crapepr   THEN
                     DO:
                         ASSIGN aux_cdcritic = 356.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         ASSIGN aux_cdcritic = 77.
                         LEAVE.
                     END.

           ASSIGN aux_cdcritic = 0.
           LEAVE.

        END.

        IF   aux_cdcritic <> 0   THEN
             UNDO Desfaz , LEAVE Desfaz.

        FIND crapope WHERE crapope.cdcooper = crapepr.cdcooper   AND
                           crapope.cdoperad = par_cdoperad
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapope   THEN
             DO:
                 ASSIGN aux_cdcritic = 67.
                 UNDO Desfaz , LEAVE Desfaz.
             END.

        FIND crapass WHERE crapass.nrdconta = par_nrdconta AND
                           crapass.cdcooper = par_cdcooper
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL crapass THEN
           DO:
               ASSIGN aux_cdcritic = 9.
               UNDO Desfaz , LEAVE Desfaz.
           END.

        FIND craplcr WHERE craplcr.cdcooper = crapepr.cdcooper   AND
                           craplcr.cdlcremp = crapepr.cdlcremp
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL craplcr   THEN
             DO:
                 ASSIGN aux_cdcritic = 363.
                 UNDO Desfaz , LEAVE Desfaz.
             END.

        ASSIGN aux_floperac = ( craplcr.dsoperac = "FINANCIAMENTO" )
               aux_vltotemp = crapepr.vlemprst
               aux_vltotctr = crapepr.qtpreemp * crapepr.vlpreemp
               aux_vltotjur = aux_vltotctr - crapepr.vlemprst.

        /* Caso o emprestimo for pre-aprovado, precisamos atualizar saldo disponivel */
        FIND FIRST crawepr WHERE crawepr.cdcooper = par_cdcooper
                             AND crawepr.nrdconta = par_nrdconta
                             AND crawepr.nrctremp = par_nrctremp NO-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAILABLE crawepr THEN
          DO:
            ASSIGN aux_dscritic = "Registro de proposta de emprestimo nao encontrado.".
            UNDO Desfaz , LEAVE Desfaz.
          END.
        
        
		{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
	      /* Efetuar a chamada a rotina Oracle */
	      RUN STORED-PROCEDURE pc_exclui_iof
	      aux_handproc = PROC-HANDLE NO-ERROR 
                          (INPUT par_cdcooper        /* Cooperativa              */ 
		 			  	  ,INPUT par_nrdconta        /* Numero da Conta Corrente */
		 			  	  ,INPUT par_nrctremp        /* Numero do Bordero        */
					  	  ,OUTPUT 0                  /* Codigo da Critica */
					  	  ,OUTPUT "").               /* Descriçao da crítica */
										   
	      /* Fechar o procedimento para buscarmos o resultado */ 
	      CLOSE STORED-PROC pc_exclui_iof
	 	           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
      
	      ASSIGN aux_cdcritic = 0
	  		       aux_dscritic = ""
	  		       aux_cdcritic = pc_exclui_iof.pr_cdcritic
		  					              WHEN pc_exclui_iof.pr_cdcritic <> ?
			       aux_dscritic = pc_exclui_iof.pr_dscritic
				  			              WHEN pc_exclui_iof.pr_dscritic <> ?.
	    
		    /* Se retornou erro */
	      IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
		    DO:
			    UNDO Desfaz , LEAVE Desfaz.
		    END.
        
		    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
	      /* Efetuar a chamada a rotina Oracle */
	      RUN STORED-PROCEDURE pc_exclui_calculo_CET
	      aux_handproc = PROC-HANDLE NO-ERROR 
                          (INPUT par_cdcooper        /* Cooperativa              */ 
                          ,INPUT par_nrdconta        /* Numero da Conta Corrente */
                          ,INPUT par_nrctremp        /* Numero do Bordero        */
                          ,OUTPUT 0                  /* Codigo da Critica */
                          ,OUTPUT "").               /* Descriçao da crítica */
										   
	      /* Fechar o procedimento para buscarmos o resultado */ 
	      CLOSE STORED-PROC pc_exclui_calculo_CET
	 	           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
      
	      ASSIGN aux_cdcritic = 0
	  		       aux_dscritic = ""
	  		       aux_cdcritic = pc_exclui_calculo_CET.pr_cdcritic
		  					              WHEN pc_exclui_calculo_CET.pr_cdcritic <> ?
			       aux_dscritic = pc_exclui_calculo_CET.pr_dscritic
				  			              WHEN pc_exclui_calculo_CET.pr_dscritic <> ?.
	    
		    /* Se retornou erro */
	      IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
		    DO:
			    UNDO Desfaz , LEAVE Desfaz.
		    END.        

        RUN sistema/generico/procedures/b1wgen0043.p PERSISTEN SET h-b1wgen0043.

        RUN volta-atras-rating IN h-b1wgen0043 ( INPUT  par_cdcooper,
                                                 INPUT  0,
                                                 INPUT  0,
                                                 INPUT  par_cdoperad,
                                                 INPUT  par_dtmvtolt,
                                                 INPUT  par_dtmvtopr,
                                                 INPUT  par_nrdconta,
                                                 INPUT  90, /* Emprestimo */
                                                 INPUT  par_nrctremp,
                                                 INPUT  1,
                                                 INPUT  1,
                                                 INPUT  par_nmdatela,
                                                 INPUT  par_inproces,
                                                 INPUT  FALSE,
                                                 OUTPUT TABLE tt-erro).
        DELETE PROCEDURE h-b1wgen0043.

        IF   RETURN-VALUE <> "OK" THEN
             UNDO, RETURN "NOK".

        DELETE crapepr.

        ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans   THEN
         DO:
             IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS   THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    
    RETURN "OK".

END PROCEDURE. /* desfaz efetivacao emprestimo */


DEF VAR aux_cdcooper AS INTE INIT 1                                   NO-UNDO.
DEF VAR aux_cdagenci AS INTE INIT 1                                   NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE INIT 1                                   NO-UNDO.
DEF VAR aux_cdoperad AS CHAR INIT "1"                                 NO-UNDO.
DEF VAR aux_nmdatela AS CHAR INIT "ATENDA"                            NO-UNDO.
DEF VAR aux_idorigem AS INTE INIT 5                                   NO-UNDO. 
DEF VAR aux_nrdconta AS INTE INIT 10545328                            NO-UNDO.
DEF VAR aux_idseqttl AS INTE INIT 1                                   NO-UNDO.
DEF VAR aux_flgerlog AS LOGI INIT FALSE                               NO-UNDO.
DEF VAR aux_nrctremp AS INTE INIT 1581842                             NO-UNDO.
DEF VAR aux_dtmvtolt AS DATE INIT 07/05/2019                          NO-UNDO.
DEF VAR h-b1wgen0002 AS HANDLE                                        NO-UNDO.

/* Remover os lançamentos do extrato de emprestimo */
FOR EACH craplem WHERE craplem.cdcooper = aux_cdcooper AND 
                       craplem.nrdconta = aux_nrdconta AND
                       craplem.nrctremp = aux_nrctremp
                       EXCLUSIVE-LOCK:
    DELETE craplem.
END.

/* Remover o lancamento de credito em conta corrente */
FIND craplcm WHERE craplcm.cdcooper = aux_cdcooper AND 
                   craplcm.nrdconta = aux_nrdconta AND
                   craplcm.dtmvtolt = 07/03/2019   AND
                   craplcm.cdhistor = 15
                   EXCLUSIVE-LOCK NO-ERROR.
IF AVAIL craplcm THEN
   DELETE craplcm.
                   
/* Remover o lancamento de Tarifa em conta corrente */
FIND craplcm WHERE craplcm.cdcooper = aux_cdcooper AND 
                   craplcm.nrdconta = aux_nrdconta AND
                   craplcm.dtmvtolt = 07/03/2019   AND
                   craplcm.cdhistor = 1513
                   EXCLUSIVE-LOCK NO-ERROR.
IF AVAIL craplcm THEN
   DELETE craplcm.

/* Atualizar o Saldo do Deposito a Vista  */
FIND crapsda WHERE crapsda.cdcooper = aux_cdcooper AND 
                   crapsda.nrdconta = aux_nrdconta AND
                   crapsda.dtmvtolt = 07/03/2019
                   EXCLUSIVE-LOCK NO-ERROR.
IF AVAIL crapsda THEN
   DO:
       ASSIGN crapsda.vlsddisp = -18.32
              crapsda.vlsdeved = 0
              crapsda.vllimutl = 18.32
              crapsda.vltotpar = 0
              crapsda.vlopcdia = 0
              crapsda.vlsdfina = 0.
   END.  

FIND crapepr WHERE crapepr.cdcooper = aux_cdcooper AND
                   crapepr.nrdconta = aux_nrdconta AND
                   crapepr.nrctremp = aux_nrctremp
                   NO-LOCK NO-ERROR.
IF AVAIL crapepr THEN
   DO:
       /* Atualizar o Saldo do Deposito a Vista  */
       FIND crapsld WHERE crapsld.cdcooper = aux_cdcooper AND 
                          crapsld.nrdconta = aux_nrdconta
                          EXCLUSIVE-LOCK NO-ERROR.
       IF AVAIL crapsld THEN
          DO:
              ASSIGN crapsld.vlsddisp = crapsld.vlsddisp + 100 - 20000.
          END.
   END.
   
/* Remover o Contrato */
RUN desfaz_efetivacao_emprestimo(INPUT  aux_cdcooper,
                                 INPUT  aux_cdagenci,
                                 INPUT  aux_nrdcaixa,
                                 INPUT  aux_cdoperad,
                                 INPUT  aux_nmdatela,
                                 INPUT  aux_idorigem,
                                 INPUT  aux_nrdconta,
                                 INPUT  aux_idseqttl,
                                 INPUT  aux_dtmvtolt,
                                 INPUT  07/06/2019,
                                 INPUT  aux_flgerlog,
                                 INPUT  aux_nrctremp,
                                 INPUT  1,
                                 OUTPUT TABLE tt-erro).
                  
FIND FIRST tt-erro NO-LOCK NO-ERROR.                  
IF AVAIL tt-erro THEN
   DO:  
       MESSAGE "1. " + tt-erro.dscritic.
       PAUSE.
   END.

/* Remover a proposta de emprestimo */
RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

RUN excluir-proposta IN h-b1wgen0002 (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_nrctremp,
                                      INPUT TRUE,
                                      OUTPUT TABLE tt-erro).
                                
DELETE PROCEDURE h-b1wgen0002.
                                
FIND FIRST tt-erro NO-LOCK NO-ERROR.                  
IF AVAIL tt-erro THEN
   DO:  
       MESSAGE "2. " + tt-erro.dscritic.
       PAUSE.
   END.
   
  
