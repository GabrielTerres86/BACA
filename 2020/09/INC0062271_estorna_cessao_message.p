  
/*..............................................................................

    Programa  : P298_desfazer_efetivacao.p
    Autor     : Rafael Faria (Supero)
    Data      : maio/2019                Ultima Atualizacao:
    
    Dados referentes ao programa:

    Objetivo  : BO ref. Rotina para desfazer efetivacao pos

    Alteracoes: 

..............................................................................*/

/*................................ DEFINICOES ............................... */
{ sistema/generico/includes/b1wgen0188tt.i  }
{ sistema/generico/includes/b1wgen0002tt.i  }
{ sistema/generico/includes/b1wgen0024tt.i  }
{ sistema/generico/includes/b1wgen0038tt.i  }
{ sistema/generico/includes/b1wgen0043tt.i  }
{ sistema/generico/includes/b1wgen0056tt.i  }
{ sistema/generico/includes/b1wgen0069tt.i  }
{ sistema/generico/includes/b1wgen0084tt.i  }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/b1wgen9999tt.i  }
{ sistema/generico/includes/b1wgen0114tt.i  }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

/* programas */
DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0165 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0043 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0084 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0195  AS HANDLE                                        NO-UNDO.

/* variaveis */
DEF STREAM str_arquivo.
DEF STREAM str_2.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsnivris AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dsmensag AS CHAR                                           NO-UNDO.

/* tabelas */
DEF TEMP-TABLE tt-registro-arquivo NO-UNDO               
    FIELD cdcooper  LIKE crawepr.cdcooper
    FIELD nrdconta  LIKE crawepr.nrdconta
    FIELD nmprimtl  LIKE crapass.nmprimtl
    FIELD nrctremp  LIKE crawepr.nrctremp
    FIELD cdfinemp  LIKE crawepr.cdfinemp
    FIELD cdlcremp  LIKE crawepr.cdlcremp
    FIELD flgctrmg  AS LOGICAL INIT FALSE
    FIELD dscritic  LIKE crapcri.dscritic
    FIELD dtdpagto  LIKE crapepr.dtdpagto
    FIELD qtparatu  LIKE crawepr.qtpreemp.
    
DEF TEMP-TABLE tt-tipo-rendi                                           NO-UNDO
    FIELD tpdrendi  AS INTE
    FIELD dsdrendi  AS CHAR.

DEF TEMP-TABLE tt-aval-crapbem                                         NO-UNDO
    LIKE tt-crapbem
    USE-INDEX crapbem2 USE-INDEX tt-crapbem AS PRIMARY.

PROCEDURE desfaz_efetivacao_emprestimo.

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

    DEF VAR aux_flgtrans          AS LOGI                           NO-UNDO.
    DEF VAR aux_idcarga           AS INTE                           NO-UNDO.
    DEF VAR aux_tpfinali          AS INTE                           NO-UNDO.

    DEF VAR h-b1wgen0134          AS HANDLE                         NO-UNDO.
    DEF VAR h-b1craplot           AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0188          AS HANDLE                         NO-UNDO.

    DEF BUFFER b-crawepr FOR crawepr.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Desfaz efetivacao empresimo.".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

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

        FIND crapfin WHERE crapfin.cdcooper = crapepr.cdcooper
                       AND crapfin.cdfinemp = crapepr.cdfinemp NO-LOCK NO-ERROR NO-WAIT.
           
        IF AVAILABLE crapfin THEN
          ASSIGN aux_tpfinali = crapfin.tpfinali. 
        
       IF   aux_floperac   THEN             /* Financiamento*/
          DO:
            IF aux_tpfinali = 3 THEN /* CDC */
              ASSIGN aux_cdhistor = 2014.
            ELSE
              ASSIGN aux_cdhistor = 1059.
              
            ASSIGN  aux_nrdolote = 600030.
          END.
       ELSE                                 /* Emprestimo */
         DO:
          IF aux_tpfinali = 3 THEN /* CDC */
            ASSIGN aux_cdhistor = 2013.
          ELSE
            ASSIGN aux_cdhistor = 1036.
          
          ASSIGN aux_nrdolote = 600005.
         END.

        RUN sistema/generico/procedures/b1craplot.p PERSISTENT SET h-b1craplot.

        /* Lancamento de Liberar valor de Emprestimo  */
        RUN inclui-altera-lote IN h-b1craplot
                               (INPUT par_cdcooper,
                                INPUT par_dtmvtolt,
                                INPUT par_cdagenci,
                                INPUT 100,          /* cdbccxlt */
                                INPUT aux_nrdolote,
                                INPUT 4,            /* tplotmov */
                                INPUT par_cdoperad,
                                INPUT aux_cdhistor,
                                INPUT par_dtmvtolt,
                                INPUT aux_vltotemp, /* Valor total emprestado */
                                INPUT FALSE,
                                INPUT TRUE,
                               OUTPUT aux_nrseqdig,
                               OUTPUT aux_cdcritic).

        DELETE PROCEDURE h-b1craplot.

        RUN sistema/generico/procedures/b1wgen0134.p
            PERSISTENT SET h-b1wgen0134.

        RUN desfaz_lancamentos_lem IN h-b1wgen0134
                                        (INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT par_nrctremp,
                                        OUTPUT aux_cdcritic).
        DELETE PROCEDURE h-b1wgen0134.

        IF   RETURN-VALUE <> "OK"   THEN
             UNDO Desfaz , LEAVE Desfaz.

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

    IF   par_flgerlog THEN
         DO:
             RUN proc_gerar_log ( INPUT  par_cdcooper,
                                  INPUT  par_cdoperad,
                                  INPUT  aux_dscritic,
                                  INPUT  aux_dsorigem,
                                  INPUT  aux_dstransa,
                                  INPUT  FALSE,
                                  INPUT  par_idseqttl,
                                  INPUT  par_nmdatela,
                                  INPUT  par_nrdconta,
                                  OUTPUT aux_nrdrowid).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctremp",
                                     INPUT par_nrctremp,
                                     INPUT par_nrctremp).

         END.

    RETURN "OK".

END PROCEDURE. /* desfaz efetivacao emprestimo */

PROCEDURE excluir-proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdmodali AS CHAR               NO-UNDO.
    DEF VAR aux_des_erro AS CHAR               NO-UNDO.
    DEF VAR aux_contador AS INTE               NO-UNDO.
    DEF VAR aux_nrdconta LIKE crapass.nrdconta NO-UNDO.
    DEF VAR aux_flgrespo AS INTE               NO-UNDO.
    DEF VAR h-b1wgen0114 AS HANDLE             NO-UNDO.

    DEF  BUFFER crabavt           FOR crapavt.
    DEF  BUFFER crabbpr           FOR crapbpr.
    DEF  BUFFER crabrpr           FOR craprpr.
    DEF  BUFFER crabadi           FOR crapadi.
    DEF  BUFFER crabadt           FOR crapadt.
    DEF  BUFFER crabgrv           FOR crapgrv.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Excluir a proposta de emprestimo".

    
    DO TRANSACTION WHILE TRUE:

        DO aux_contador = 1 TO 10:

            FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                               crawepr.nrdconta = par_nrdconta   AND
                               crawepr.nrctremp = par_nrctremp
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL crawepr   THEN
                 IF   LOCKED crawepr   THEN
                      DO:
                          aux_cdcritic = 371.
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          aux_cdcritic = 356.
                          LEAVE.
                      END.

            aux_cdcritic = 0.
            LEAVE.

        END. /* Tratamento Lock crawepr */

        RUN sistema/generico/procedures/b1wgen0084.p
            PERSISTENT SET h-b1wgen0084.

        RUN exclui_parcelas_proposta IN h-b1wgen0084 (
            INPUT par_cdcooper,
            INPUT par_cdagenci,
            INPUT par_nrdcaixa,
            INPUT par_cdoperad,
            INPUT par_nmdatela,
            INPUT par_idorigem,
            INPUT par_nrdconta,
            INPUT par_idseqttl,
            INPUT par_dtmvtolt,
            INPUT par_flgerlog,
            INPUT par_nrctremp,
            OUTPUT TABLE tt-erro).

        DELETE OBJECT h-b1wgen0084.

        IF RETURN-VALUE <> "OK" THEN
            DO:
                FIND FIRST tt-erro NO-ERROR.
                IF AVAIL tt-erro THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE

                    aux_dscritic = "Ocorreram erros durante a exclusao"
                                   + " das parcelas da proposta.".
            END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        /*  Primeiro avalista  */
        DO aux_contador = 1 TO 10:

           FIND crapavl WHERE crapavl.cdcooper = par_cdcooper       AND 
                              crapavl.nrdconta = crawepr.nrctaav1   AND
                              crapavl.nrctravd = crawepr.nrctremp   AND
                              crapavl.tpctrato = 1 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
           
           IF   NOT AVAILABLE crapavl   THEN
                IF   LOCKED crapavl   THEN
                     DO:
                         ASSIGN aux_cdcritic = 77.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     LEAVE.
           ELSE
                DELETE crapavl.
           
          LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.

        /*  Segundo avalista  */
       DO aux_contador = 1 TO 10:

           FIND crapavl WHERE crapavl.cdcooper = par_cdcooper       AND 
                              crapavl.nrdconta = crawepr.nrctaav2   AND
                              crapavl.nrctravd = crawepr.nrctremp   AND
                              crapavl.tpctrato = 1
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
           IF   NOT AVAILABLE crapavl   THEN
                IF   LOCKED crapavl   THEN
                     DO:
                         ASSIGN aux_cdcritic = 77.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     LEAVE.
           ELSE
                DELETE crapavl.
        
           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.

        /* Avalistas terceiros, intervenientes anuentes */
       FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper        AND
                               crapavt.nrdconta = par_nrdconta        AND
                               CAN-DO("1,9",STRING(crapavt.tpctrato)) AND
                               crapavt.nrctremp = par_nrctremp        NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabavt WHERE crabavt.cdcooper = crapavt.cdcooper   AND
                                   crabavt.nrdconta = crapavt.nrdconta   AND
                                   crabavt.tpctrato = crapavt.tpctrato   AND
                                   crabavt.nrctremp = crapavt.nrctremp   AND
                                   crabavt.nrcpfcgc = crapavt.nrcpfcgc
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF    NOT AVAIL crabavt   THEN
                      IF   LOCKED crabavt   THEN
                           DO:
                               aux_cdcritic = 77.
                               PAUSE 1 NO-MESSAGE.
                               NEXT.
                           END.
                      ELSE
                           DO:
                               aux_cdcritic = 869.
                               LEAVE.
                           END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0   THEN
                 LEAVE.

            /* Excluir avalista terceiro */
            DELETE crabavt.

        END.

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.


        /* Bens das propostas */
        FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper    AND
                               crapbpr.nrdconta = par_nrdconta    AND
                               crapbpr.tpctrpro = 90              AND
                               crapbpr.nrctrpro = par_nrctremp    NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabbpr WHERE crabbpr.cdcooper = crapbpr.cdcooper   AND
                                   crabbpr.nrdconta = crapbpr.nrdconta   AND
                                   crabbpr.tpctrpro = crapbpr.tpctrpro   AND
                                   crabbpr.nrctrpro = crapbpr.nrctrpro   AND
                                   crabbpr.idseqbem = crapbpr.idseqbem
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAIL crabbpr   THEN
                     IF   LOCKED crabbpr   THEN
                          DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              ASSIGN aux_dscritic = "Descricao dos bens da proposta " +
                                                    "de emprestimo nao encontrada.".
                              LEAVE.
                          END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0  OR
                 aux_dscritic <> "" THEN
                 LEAVE.

            DELETE crabbpr.

        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.


        /* GRAVAMES dos BENS */
        FOR EACH crapgrv
           WHERE crapgrv.cdcooper = par_cdcooper
             AND crapgrv.nrdconta = par_nrdconta
             AND crapgrv.tpctrpro = 90
             AND crapgrv.nrctrpro = par_nrctremp
              NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND FIRST crabgrv
                     WHERE ROWID(crabgrv) = ROWID(crapgrv)
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crabgrv THEN
                    IF  LOCKED crabgrv THEN DO:
                        aux_cdcritic = 77.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                    ELSE DO:
                        ASSIGN aux_dscritic = "Registro do Gravames nao" +
                                              " encontrado.".
                        LEAVE.
                    END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF  aux_cdcritic <> 0  OR
                aux_dscritic <> "" THEN
                LEAVE.

            DELETE crabgrv.

        END.

        IF  aux_cdcritic <> 0  OR
            aux_dscritic <> "" THEN
            UNDO, LEAVE.



        /* Proposta */
        DO aux_contador = 1 TO 10:

            FIND crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                               crapprp.nrdconta = par_nrdconta   AND
                               crapprp.tpctrato = 90             AND
                               crapprp.nrctrato = par_nrctremp
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF    NOT AVAIL crapprp   THEN
                  IF   LOCKED crapprp   THEN
                       DO:
                           aux_cdcritic = 371.
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.
                  ELSE
                       DO:
                           aux_cdcritic = 510.
                           LEAVE.
                       END.

            aux_cdcritic = 0.
            LEAVE.

        END.

        IF   aux_cdcritic <> 0   THEN
             UNDO, LEAVE.

        DELETE crapprp.

        /* Rendimentos da proposta */
        FOR EACH craprpr WHERE craprpr.cdcooper = par_cdcooper   AND
                               craprpr.nrdconta = par_nrdconta   AND
                               craprpr.tpctrato = 90             AND
                               craprpr.nrctrato = par_nrctremp   NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabrpr WHERE crabrpr.cdcooper = craprpr.cdcooper   AND
                                   crabrpr.nrdconta = craprpr.nrdconta   AND
                                   crabrpr.tpctrato = craprpr.tpctrato   AND
                                   crabrpr.nrctrato = craprpr.nrctrato   AND
                                   crabrpr.tpdrendi = craprpr.tpdrendi
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAIL crabrpr   THEN
                     IF   LOCKED crabrpr   THEN
                          DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              ASSIGN aux_dscritic = "Registro de rendimento " +
                                                    "do cooperado nao encontrado.".
                              LEAVE.
                          END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0  OR
                 aux_dscritic <> "" THEN
                 LEAVE.

            DELETE crabrpr.

        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.
        
        FOR EACH crapadt WHERE crapadt.cdcooper = par_cdcooper   AND
                               crapadt.nrdconta = par_nrdconta   AND
                               crapadt.nrctremp = par_nrctremp   AND
                               crapadt.tpctrato = 90             NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabadt WHERE crabadt.cdcooper = crapadt.cdcooper   AND
                                   crabadt.nrdconta = crapadt.nrdconta   AND
                                   crabadt.nrctremp = crapadt.nrctremp   AND
                                   crabadt.nraditiv = crapadt.nraditiv   AND 
                                   crabadt.tpctrato = crapadt.tpctrato
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAIL crabadt   THEN
                     IF   LOCKED crabadt   THEN
                          DO:
                              aux_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              ASSIGN aux_dscritic = "Registro de aditivo" +
                                                    "contratual nao encontrado.".
                              LEAVE.
                          END.

                aux_cdcritic = 0.
                LEAVE.

            END.

            IF   aux_cdcritic <> 0  OR
                 aux_dscritic <> "" THEN
                 LEAVE.
    
            IF  crapadt.cdaditiv = 2 THEN /* Aplicações da própria conta da proposta */
                aux_nrdconta = crapadt.nrdconta.
            ELSE IF crapadt.cdaditiv = 3 THEN /* Aplicações de interveniente garantidor */
                aux_nrdconta = crapadt.nrctagar.
            
            FOR EACH crapadi WHERE crapadi.cdcooper = crapadt.cdcooper AND
                                   crapadi.nrdconta = crapadt.nrdconta AND
                                   crapadi.nrctremp = crapadt.nrctremp AND
                                   crapadi.nraditiv = crapadt.nraditiv AND
                                   crapadi.tpctrato = crapadt.tpctrato NO-LOCK:


                IF  crapadi.tpproapl = 1 THEN /* Produto Novo */
                    DO:
                        FOR FIRST craprac FIELDS(cdcooper) WHERE 
                                  craprac.cdcooper = crapadi.cdcooper
                              AND craprac.nrdconta = aux_nrdconta
                              AND craprac.nraplica = crapadi.nraplica
                              AND craprac.idblqrgt = 2 EXCLUSIVE-LOCK. /* Blq.ADITIV */

                            ASSIGN craprac.idblqrgt = 0.
                            VALIDATE craprac.

                        END.
                    END.
                ELSE IF crapadi.tpproapl = 2 THEN /* Produto Antigo */
                    DO:
                        /* DESBLOQUEIA todas as aplicacoes dessa conta e contrato
                           que foram bloqueadas pela tela ADITIV */
                        FIND craptab WHERE craptab.cdcooper = crapadi.cdcooper AND
                                           craptab.nmsistem = "CRED"           AND
                                           craptab.tptabela = "BLQRGT"         AND
                                           craptab.cdempres = 00               AND
                                           craptab.cdacesso = STRING(aux_nrdconta,"9999999999") AND
                                           SUBSTR(craptab.dstextab,1,7) = STRING(crapadi.nraplica,"9999999") AND
                                           SUBSTR(craptab.dstextab,10,1) = "A"
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                        IF  AVAIL craptab THEN
                            DELETE craptab.
                    END.
    
                DO aux_contador = 1 TO 10:
    
                    FIND crabadi WHERE crabadi.cdcooper = crapadi.cdcooper   AND
                                       crabadi.nrdconta = crapadi.nrdconta   AND
                                       crabadi.nrctremp = crapadi.nrctremp   AND
                                       crabadi.nraditiv = crapadi.nraditiv   AND
                                       crabadi.nrsequen = crapadi.nrsequen   AND
                                       crabadi.tpctrato = crapadt.tpctrato
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                    IF   NOT AVAIL crabadi   THEN
                         IF   LOCKED crabadi   THEN
                              DO:
                                  aux_cdcritic = 77.
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                         ELSE
                              DO:
                                  ASSIGN aux_dscritic = "Registro de item do aditivo" +
                                                        "contratual nao encontrado.".
                                  LEAVE.
                              END.
    
                    aux_cdcritic = 0.
                    LEAVE.
    
                END.
    
                IF   aux_cdcritic <> 0  OR
                     aux_dscritic <> "" THEN
                     LEAVE.
                
                DELETE crabadi.
    
            END.
            
            IF   aux_cdcritic <> 0  OR
                 aux_dscritic <> "" THEN
                 LEAVE.

            DELETE crabadt.

        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        
        /* verificar se existe cessao de credito */
        FIND FIRST tbcrd_cessao_credito
            WHERE tbcrd_cessao_credito.cdcooper = par_cdcooper
              AND tbcrd_cessao_credito.nrdconta = par_nrdconta
              AND tbcrd_cessao_credito.nrctremp = par_nrctremp
              EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE tbcrd_cessao_credito THEN      
          DO:
             DELETE tbcrd_cessao_credito.
          END.

        /* Cancelar proposta na Esteira de credito*/
        /* Somente Cancelar a Proposta na Esteira se a mesma 
           foi enviada para analise manual na Esteira  */
        IF crawepr.dtenvest <> ? AND 
           crawepr.insitest >= 2 AND 
           crawepr.cdopeapr <> "MOTOR" AND
           crawepr.cdoperad <> "AUTOCDC" THEN /*Proposta de origem CDC sao cancelada primeiro na IBRATAN/ESTEIRA*/
        DO: 
        
           FIND FIRST crapope  
                WHERE crapope.cdcooper = par_cdcooper             
                  AND crapope.cdoperad = par_cdoperad
                   NO-LOCK NO-ERROR.
                     
           RUN sistema/generico/procedures/b1wgen0195.p
               PERSISTENT SET h-b1wgen0195.
       
           /* Enviar Cancelamento da proposta para esteira*/
           RUN Enviar_proposta_esteira IN h-b1wgen0195        
                             ( INPUT par_cdcooper,
                               INPUT crapope.cdpactra,
                               INPUT par_nrdcaixa,
                               INPUT par_nmdatela,
                               INPUT par_cdoperad,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_dtmvtolt,
                               INPUT par_dtmvtolt,
                               INPUT par_nrctremp, /* nrctremp */
                               INPUT par_nrctremp, /* nrctremp_novo */
                               INPUT "",           /* dsiduser */
                               INPUT 0,            /* flreiflx */
                               INPUT "C",          /* tpenvest */
                              OUTPUT aux_dsmensag, 
                              OUTPUT aux_cdcritic, 
                              OUTPUT aux_dscritic).
           
           DELETE OBJECT h-b1wgen0195.
           
           IF  RETURN-VALUE = "NOK"  THEN
              DO:
                  IF aux_cdcritic = 0 AND 
                     aux_dscritic = "" THEN
                  DO:
                    ASSIGN aux_dscritic = "Nao foi possivel enviar exclusao do " + 
                                          "numero da proposta para Analise de Credito.".
                  END.
                  UNDO, LEAVE.
              END. 
        END.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT crawepr.idcobope
                                              ,INPUT 0
                                              ,INPUT 0
                                              ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_vincula_cobertura_operacao.pr_dscritic 
               WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.
                        
        IF aux_dscritic <> "" THEN
           UNDO, LEAVE.
        
        /* Excluir proposta */
        DELETE crawepr.

        LEAVE.

    END. /* Fim TRANSACTION , criticas */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             IF  par_flgerlog  THEN
                 DO:
                     RUN proc_gerar_log (INPUT par_cdcooper,
                                         INPUT par_cdoperad,
                                         INPUT aux_dscritic,
                                         INPUT aux_dsorigem,
                                         INPUT aux_dstransa,
                                         INPUT FALSE,
                                         INPUT par_idseqttl,
                                         INPUT par_nmdatela,
                                         INPUT par_nrdconta,
                                        OUTPUT aux_nrdrowid).

                     RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                              INPUT "nrctremp",
                                              INPUT par_nrctremp,
                                              INPUT par_nrctremp).
                 END.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".

         END.

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctremp",
                                     INPUT par_nrctremp,
                                     INPUT par_nrctremp).
        END.

    RETURN "OK".

END PROCEDURE. /*excluir-proposta*/

PROCEDURE executa_programa:

  FIND FIRST crapdat NO-LOCK NO-ERROR.
  EMPTY TEMP-TABLE tt-erro.
  DEF BUFFER b-crapepr_cessao FOR crapepr.
  DEF VAR aux_contador AS INT                                          NO-UNDO.
   
  ASSIGN aux_contador = 0.

  FOR EACH crapepr WHERE crapepr.dtmvtolt = 09/23/2020 AND
                         crapepr.inliquid = 0  AND 
                         crapepr.cdfinemp = 69 AND
                         crapepr.cdlcremp = 6901 AND                          
                         LOOKUP(STRING(crapepr.nrdconta), "307025,449997,830364") = 0 AND
                         LOOKUP(STRING(crapepr.nrdconta), "2349299, 6138047,7393555,8681660,9350934,9492305,9719288,11281995,175560,409898,503029,11264233,172278") = 0 AND
                         (crapepr.nrdconta <> 307025 AND crapepr.nrdconta <> 449997 AND crapepr.nrdconta <> 830364 AND crapepr.nrdconta <> 2349299 AND crapepr.nrdconta <>  6138047 AND crapepr.nrdconta <> 7393555 AND crapepr.nrdconta <> 8681660 AND crapepr.nrdconta <> 9350934 AND crapepr.nrdconta <> 9492305 AND crapepr.nrdconta <> 9719288 AND crapepr.nrdconta <> 11281995 AND crapepr.nrdconta <> 175560 AND crapepr.nrdconta <> 409898 AND crapepr.nrdconta <> 503029 AND crapepr.nrdconta <> 11264233 AND crapepr.nrdconta <> 172278)
                         NO-LOCK,
	
      FIRST tbcrd_cessao_credito WHERE tbcrd_cessao_credito.cdcooper = crapepr.cdcooper     AND
                                       tbcrd_cessao_credito.nrdconta = crapepr.nrdconta     AND
                                       tbcrd_cessao_credito.nrctremp = crapepr.nrctremp     
                                       NO-LOCK.
  
      FIND FIRST b-crapepr_cessao WHERE b-crapepr_cessao.cdcooper = crapepr.cdcooper AND
                                        b-crapepr_cessao.nrdconta = crapepr.nrdconta AND
                                        b-crapepr_cessao.dtmvtolt = 09/23/2020       AND
                                        b-crapepr_cessao.vlemprst = crapepr.vlemprst AND
                                        b-crapepr_cessao.qtpreemp = crapepr.qtpreemp
                                        NO-LOCK NO-ERROR.
                                       
      IF NOT AVAIL b-crapepr_cessao THEN
         NEXT.         
         
      FIND FIRST crawepr WHERE crawepr.cdcooper = crapepr.cdcooper AND
                                     crawepr.nrdconta = crapepr.nrdconta AND
                                     crawepr.nrctremp = crapepr.nrctremp AND
                                     crawepr.flgreneg = 0
                                     NO-LOCK NO-ERROR.		

      IF  NOT AVAIL crawepr THEN
        NEXT.           
  
      ASSIGN aux_contador = aux_contador + 1.
      
  END. /*fecha o for*/
  
  MESSAGE aux_contador.

END PROCEDURE.

/*executar programa*/
RUN executa_programa.
