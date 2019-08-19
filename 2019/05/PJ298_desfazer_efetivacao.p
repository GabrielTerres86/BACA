  
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
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

/* programas */
DEF VAR h-b1wgen0043 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0084 AS HANDLE                                         NO-UNDO.

/* variaveis */
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsnivris AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
    

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
        
        FOR crappre FIELDS(cdfinemp vlmulpli) WHERE crappre.cdcooper = par_cdcooper
                                                AND crappre.inpessoa = crapass.inpessoa
                                                AND (crappre.cdfinemp = crapepr.cdfinemp 
                                                 OR crawepr.flgpreap = 1) NO-LOCK: END.

        /* Verifica se o emprestimo eh pre-aprovado */
        IF AVAIL crappre THEN
           DO:
               IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                  RUN sistema/generico/procedures/b1wgen0188.p 
                      PERSISTENT SET h-b1wgen0188.
                     
               /* Busca a carga ativa */
               RUN busca_carga_ativa IN h-b1wgen0188(INPUT par_cdcooper,
                                                     INPUT par_nrdconta,
                                                     OUTPUT aux_idcarga).
            
               IF VALID-HANDLE(h-b1wgen0188) THEN
                  DELETE PROCEDURE(h-b1wgen0188).

               Contador: DO aux_contador = 1 TO 10:

                 FIND crapcpa WHERE crapcpa.cdcooper = par_cdcooper AND
                                    crapcpa.nrdconta = par_nrdconta AND
                                    crapcpa.iddcarga = aux_idcarga
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF NOT AVAILABLE crapcpa THEN
                    IF LOCKED crapcpa THEN
                       DO:
                        ASSIGN aux_cdcritic = 77.
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                       END.
                    ELSE
                       DO:
                           ASSIGN aux_dscritic = "Associado nao cadastrado " +
                                                 "no pre-aprovado".
                           UNDO Desfaz , LEAVE Desfaz.
                       END.

                 ASSIGN aux_cdcritic = 0.
                 LEAVE Contador.

               END. /* END Contador: DO aux_contador = 1 TO 10: */

               /* Somente vamos atualizar o saldo, caso o saldo disponivel
                  for diferente que o saldo calculado na carga.           */
               IF crapcpa.vllimdis <> crapcpa.vlcalpre THEN
                  DO:
                      /* Atualiza o valor contratado do credito pre-aprovado */
                      ASSIGN crapcpa.vlctrpre = crapcpa.vlctrpre - crapepr.vlemprst
                             crapcpa.vllimdis = TRUNC(((crapcpa.vllimdis +
                                                        crapepr.vlemprst) /
                                                      crappre.vlmulpli),0)
                             crapcpa.vllimdis = crapcpa.vllimdis * crappre.vlmulpli.
                  END.

           END. /* END IF AVAIL crappre THEN */

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

        /* Lançamento de Liberar valor de Emprestimo  */
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

        /* Busca dados da proposta */
        FOR FIRST crawepr FIELDS(crawepr.nrctrliq[1] crawepr.nrctrliq[2]
                                 crawepr.nrctrliq[3] crawepr.nrctrliq[4]
                                 crawepr.nrctrliq[5] crawepr.nrctrliq[6]
                                 crawepr.nrctrliq[7] crawepr.nrctrliq[8]
                                 crawepr.nrctrliq[9] crawepr.nrctrliq[10]
                                 idcobope)
                          WHERE crawepr.cdcooper = par_cdcooper   AND
                                crawepr.nrdconta = par_nrdconta   AND
                                crawepr.nrctremp = par_nrctremp   NO-LOCK:

           IF  crawepr.idcobope > 0  THEN
               DO:
            
                  /* Efetuar o desbloqueio de possiveis coberturas vinculadas ao mesmo */
                  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                  RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT "ATENDA"
                                                        ,INPUT crawepr.idcobope
                                                        ,INPUT "D"
                                                        ,INPUT par_cdoperad
                                                        ,INPUT ""
                                                        ,INPUT 0
                                                        ,INPUT "S"
                                                        ,"").

                  CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                  ASSIGN aux_dscritic  = ""
                         aux_dscritic  = pc_bloq_desbloq_cob_operacao.pr_dscritic 
                                         WHEN pc_bloq_desbloq_cob_operacao.pr_dscritic <> ?.

                  IF aux_dscritic <> "" THEN
                     UNDO Desfaz , LEAVE Desfaz.

                  DO i = 1 TO 10:

                     IF  crawepr.nrctrliq[i] > 0  THEN
                         DO:

                            FOR FIRST b-crawepr FIELDS(idcobope)
                                                WHERE b-crawepr.cdcooper = par_cdcooper   AND
                                                      b-crawepr.nrdconta = par_nrdconta   AND
                                                      b-crawepr.nrctremp = crawepr.nrctrliq[i] NO-LOCK:
                               IF  b-crawepr.idcobope > 0  THEN
                                   DO:
                                      /* Efetuar o bloqueio de possiveis coberturas vinculadas ao mesmo */
                                      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                      RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
                                        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "ATENDA"
                                                                            ,INPUT b-crawepr.idcobope
                                                                            ,INPUT "B"
                                                                            ,INPUT par_cdoperad
                                                                            ,INPUT ""
                                                                            ,INPUT 0
                                                                            ,INPUT "S"
                                                                            ,"").

                                      CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
                                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                                      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                                      ASSIGN aux_dscritic  = ""
                                             aux_dscritic  = pc_bloq_desbloq_cob_operacao.pr_dscritic 
                                                             WHEN pc_bloq_desbloq_cob_operacao.pr_dscritic <> ?.

                                      IF aux_dscritic <> "" THEN
                                         UNDO Desfaz , LEAVE Desfaz.
                                   END.
                            END. /* FOR FIRST b-crawepr */

                         END. /* crawepr.nrctrliq[i] > 0 */

                  END. /** Fim do DO ... TO **/

               END. /* crawepr.idcobope > 0 */

        END. /* FOR FIRST crawepr */

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

PROCEDURE executa_programa:

  FIND FIRST crapdat WHERE crapdat.cdcooper = 5 NO-LOCK NO-ERROR.
  EMPTY TEMP-TABLE tt-erro.
  
  /*producao*/
  RUN desfaz_efetivacao_emprestimo (INPUT 5, /*par_cdcooper*/
                                    INPUT 14,  /*par_cdagenci*/
                                    INPUT 1, /*par_nrdcaixa*/
                                    INPUT 1, /*par_cdoperad*/
                                    INPUT "ATENDA", /*par_nmdatela*/
                                    INPUT 5, /*par_idorigem*/
                                    INPUT 153877, /*par_nrdconta*/
                                    INPUT 1, /*par_idseqttl*/
                                    INPUT crapdat.dtmvtolt, /*par_dtmvtolt*/
                                    INPUT crapdat.dtmvtopr, /*par_dtmvtopr*/
                                    INPUT 1, /*par_flgerlogv*/
                                    INPUT 12373, /*par_nrctremp*/
                                    INPUT 1, /*par_inproces*/
                                    OUTPUT TABLE tt-erro).

  FIND FIRST tt-erro NO-LOCK NO-ERROR.
    IF AVAIL tt-erro THEN
      DO:
        MESSAGE "Erro: " tt-erro.dscritic.
      END.


END PROCEDURE.

/*executar programa*/
RUN executa_programa.
