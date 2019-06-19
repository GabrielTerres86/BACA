    /* .............................................................................

   Programa: b1wgen0167.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : André Santos - SUPERO
   Data    : Agosto/2013.                       Ultima atualizacao: 06/02/2019

   Dados referentes ao programa:

   Objetivo  : BO mostra tela FINALI -- Manutencao das finalidades de emprestimo

   Alteracoes: 06/03/2014 - Incluso VALIDATE (Daniel).
    
               05/06/2014 - Alterado format do cdlcremp de 3 para 4 
                            Softdesk 137074 (Lucas R.)
                            
               04/08/2015 - Alterações e correções (Lunelli SD 102123)             
                            
               06/02/2019 - P510 - Remoção de proc convertida excluir-lcr-finali (Marcos-Envolti)
............................................................................. */

DEF VAR aux_dsretorn AS CHAR                                  NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0167tt.i }

/******************************************************************************/
PROCEDURE consulta-finali:

    DEF INPUT  PARAM par_cdcooper  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad  AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela  AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt  AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cddopcao  AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cdfinemp  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrregist  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nriniseq  AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_dsfinemp  AS CHAR                              NO-UNDO.    
    DEF OUTPUT PARAM par_dssitfin  AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_qtregist  AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craplch.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic           AS INTE                              NO-UNDO.
    DEF VAR aux_dscritic           AS CHAR                              NO-UNDO.
    DEF VAR aux_nrregist           AS INTE                              NO-UNDO.
    
    EMPTY TEMP-TABLE tt-craplch.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsretorn = "OK"
           aux_nrregist = par_nrregist.

    FIND crapfin WHERE crapfin.cdcooper = par_cdcooper
                   AND crapfin.cdfinemp = par_cdfinemp
                   NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapfin THEN 
        DO:
            IF  par_cddopcao <> "I" THEN 
                DO:
                    ASSIGN aux_cdcritic = 362.
                           aux_dscritic = "".
                END.
        END.
    ELSE 
        DO:
            ASSIGN par_dsfinemp = crapfin.dsfinemp
                   par_dssitfin = IF crapfin.flgstfin THEN "LIBERADA" ELSE "BLOQUEADA".

            /* Encontra e pagina linhas de crédito vinculadas */
            FOR EACH craplch WHERE craplch.cdcooper = crapfin.cdcooper
                               AND craplch.cdfinemp = crapfin.cdfinemp NO-LOCK,
               FIRST craplcr WHERE craplcr.cdcooper = craplch.cdcooper
                               AND craplcr.cdlcremp = craplch.cdlcrhab NO-LOCK:

                ASSIGN par_qtregist = par_qtregist + 1.

                /* controles da paginação */
                IF  (par_qtregist < par_nriniseq) OR
                    (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                    NEXT.

                IF  aux_nrregist > 0 THEN
                    DO:
                        CREATE tt-craplch.
                        ASSIGN tt-craplch.cdlcrhab = craplch.cdlcrhab
                               tt-craplch.dslcremp = craplcr.dslcremp.
                    END.

                ASSIGN aux_nrregist = aux_nrregist - 1.

            END.
        END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            ASSIGN aux_dsretorn = "NOK".
        END.

    RETURN aux_dsretorn.

END PROCEDURE.

/******************************************************************************/
PROCEDURE atualiza-finali:

    DEF INPUT  PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                               NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                               NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                               NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT  PARAM par_cddopcao AS CHAR                               NO-UNDO.
    DEF INPUT  PARAM par_cdfinemp AS INTE                               NO-UNDO.
    DEF INPUT  PARAM par_dsfinemp AS CHAR                               NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador          AS INTE                               NO-UNDO.
    DEF VAR aux_cdcritic          AS INTE                               NO-UNDO.
    DEF VAR aux_dscritic          AS CHAR                               NO-UNDO.
                                                                        
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsretorn = "OK".

    Grava: DO TRANSACTION
           ON ERROR  UNDO Grava, LEAVE Grava
           ON QUIT   UNDO Grava, LEAVE Grava
           ON STOP   UNDO Grava, LEAVE Grava
           ON ENDKEY UNDO Grava, LEAVE Grava:

        Contador: DO aux_contador = 1 TO 10:

            FIND crapfin WHERE crapfin.cdcooper = par_cdcooper
                           AND crapfin.cdfinemp = par_cdfinemp
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
            IF  NOT AVAILABLE crapfin THEN
                IF  LOCKED crapfin THEN 
                    DO:
                        IF  aux_contador = 10 THEN 
                            DO:
                                ASSIGN aux_cdcritic = 77.
                                       aux_dscritic = "".
        
                                LEAVE Contador.
                            END.
                        ELSE 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT Contador.
                            END.
                    END.
                ELSE 
                    DO:
                        ASSIGN aux_cdcritic = 362.
                               aux_dscritic = "".

                        LEAVE Contador.
                    END.
            ELSE 
                DO: 
                    ASSIGN crapfin.dsfinemp = CAPS(par_dsfinemp).
                    LEAVE Contador.
                END.

        END. /*  Fim do DO .. TO CONTADOR  */

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            DO:                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                ASSIGN aux_dsretorn = "NOK".

                UNDO Grava, LEAVE Grava.                
            END.
        
        LEAVE Grava.

    END. /* FIM DA TRANSAÇÃO */ 

    RELEASE crapfin.

    RETURN aux_dsretorn.

END PROCEDURE.

/******************************************************************************/
PROCEDURE bloqueia-libera-finali:

    DEF INPUT  PARAM par_cdcooper  AS INTE                             NO-UNDO.
    DEF INPUT  PARAM par_cdagenci  AS INTE                             NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa  AS INTE                             NO-UNDO.
    DEF INPUT  PARAM par_cdoperad  AS CHAR                             NO-UNDO.
    DEF INPUT  PARAM par_nmdatela  AS CHAR                             NO-UNDO.
    DEF INPUT  PARAM par_idorigem  AS INTE                             NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt  AS DATE                             NO-UNDO.
    DEF INPUT  PARAM par_cddopcao  AS CHAR                             NO-UNDO.
    DEF INPUT  PARAM par_cdfinemp  AS INTE                             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic           AS INTE                             NO-UNDO.
    DEF VAR aux_dscritic           AS CHAR                             NO-UNDO.
    DEF VAR aux_contador           AS INTE                             NO-UNDO.
                                                                       
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsretorn = "OK".

    Grava: DO TRANSACTION
           ON ERROR  UNDO Grava, LEAVE Grava
           ON QUIT   UNDO Grava, LEAVE Grava
           ON STOP   UNDO Grava, LEAVE Grava
           ON ENDKEY UNDO Grava, LEAVE Grava:

        Contador: DO aux_contador = 1 TO 10:
            
            FIND crapfin WHERE crapfin.cdcooper = par_cdcooper
                           AND crapfin.cdfinemp = par_cdfinemp
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
            IF  NOT AVAILABLE crapfin THEN
                IF  LOCKED crapfin THEN 
                    DO:
                        IF  aux_contador = 10 THEN 
                            DO:
                                ASSIGN aux_cdcritic = 77.
                                       aux_dscritic = "".
        
                                LEAVE Contador.
                            END.
                        ELSE 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT Contador.
                            END.
                    END.
                ELSE 
                    DO:
                        ASSIGN aux_cdcritic = 362.
                               aux_dscritic = "".

                        LEAVE Contador.
                    END.
            ELSE 
                DO: 
                    IF  par_cddopcao = "B" THEN
                        ASSIGN crapfin.flgstfin = FALSE.
                    ELSE
                        ASSIGN crapfin.flgstfin = TRUE.

                    LEAVE Contador.
                END.

        END. /*  Fim do DO .. TO CONTADOR  */

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            DO:                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                ASSIGN aux_dsretorn = "NOK".

                UNDO Grava, LEAVE Grava.                
            END.
        
        LEAVE Grava.

    END. /* FIM DA TRANSAÇÃO */ 

    RELEASE crapfin.

    RETURN aux_dsretorn.

END PROCEDURE.

/******************************************************************************/
PROCEDURE incluir-finali:

    DEF INPUT  PARAM par_cdcooper  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad  AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela  AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt  AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cddopcao  AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cdfinemp  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dsfinemp  AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM TABLE FOR tt-craplch.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic           AS INTE                              NO-UNDO.
    DEF VAR aux_dscritic           AS CHAR                              NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.                                           

    ASSIGN aux_dsretorn = "OK".

    IF  par_cdfinemp = 0 THEN 
        DO:
            ASSIGN aux_cdcritic = 362
                   aux_dscritic = "".
        END.
    ELSE
        DO:
            Grava: DO TRANSACTION ON ERROR  UNDO Grava, LEAVE Grava
                                  ON ENDKEY UNDO Grava, LEAVE Grava:

                DO WHILE TRUE:

                    FIND crapfin WHERE crapfin.cdcooper = par_cdcooper
                                   AND crapfin.cdfinemp = par_cdfinemp
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                    IF  NOT AVAILABLE crapfin THEN
                        IF  LOCKED crapfin THEN 
                            DO:
                                ASSIGN aux_cdcritic = 77
                                       aux_dscritic = "".
                                LEAVE.
                            END.
                        ELSE
                            DO: 
                                CREATE crapfin.
                                ASSIGN crapfin.cdfinemp = par_cdfinemp
                                       crapfin.flgstfin = TRUE
                                       crapfin.cdcooper = par_cdcooper
                                       crapfin.dsfinemp = CAPS(par_dsfinemp).
        
                                VALIDATE crapfin.
                            END.
                    
                    /* Atualiza registros de linhas de credito vinculadas à finalidade */
                    FOR EACH tt-craplch NO-LOCK:

                        FIND craplch WHERE craplch.cdcooper = crapfin.cdcooper
                                       AND craplch.cdfinemp = crapfin.cdfinemp
                                       AND craplch.cdlcrhab = tt-craplch.cdlcrhab
                                       NO-LOCK NO-ERROR NO-WAIT.
                    
                        IF  NOT AVAIL craplch THEN 
                            DO:
                                FIND LAST craplch WHERE craplch.cdcooper = crapfin.cdcooper
                                                    AND craplch.cdfinemp = crapfin.cdfinemp
                                                    NO-LOCK NO-ERROR NO-WAIT.
                                CREATE craplch.
                                ASSIGN craplch.cdcooper = crapfin.cdcooper
                                       craplch.cdfinemp = crapfin.cdfinemp
                                       craplch.cdlcrhab = tt-craplch.cdlcrhab
                                       craplch.nrseqlch = IF AVAIL craplch THEN (craplch.nrseqlch + 1) ELSE 0.
        
                                VALIDATE craplch.
                            END.

                    END.  /*  FOR EACH  */

                    RELEASE crapfin.

                    LEAVE.

                END. /* DO WHILE TRUE */

                IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                    DO:                
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1, /*sequencia*/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        ASSIGN aux_dsretorn = "NOK".

                        UNDO Grava, LEAVE Grava.                                
                    END.
                
                LEAVE Grava.

            END. /* FIM DO TO GRAVACAO */ 
        END.

    RELEASE crapfin.
    
    RETURN aux_dsretorn.
    
END PROCEDURE.

/******************************************************************************/
PROCEDURE excluir-finali:

    DEF INPUT  PARAM par_cdcooper  AS INTE                             NO-UNDO.
    DEF INPUT  PARAM par_cdagenci  AS INTE                             NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa  AS INTE                             NO-UNDO.
    DEF INPUT  PARAM par_cdoperad  AS CHAR                             NO-UNDO.
    DEF INPUT  PARAM par_nmdatela  AS CHAR                             NO-UNDO.
    DEF INPUT  PARAM par_idorigem  AS INTE                             NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt  AS DATE                             NO-UNDO.
    DEF INPUT  PARAM par_cddopcao  AS CHAR                             NO-UNDO.
    DEF INPUT  PARAM par_cdfinemp  AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                       NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                       NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsretorn = "OK".

    Grava: DO  TRANSACTION ON ERROR  UNDO Grava, LEAVE Grava
                           ON QUIT   UNDO Grava, LEAVE Grava
                           ON STOP   UNDO Grava, LEAVE Grava
                           ON ENDKEY UNDO Grava, LEAVE Grava:

        Contador: DO aux_contador = 1 TO 10:

            FIND crapfin WHERE crapfin.cdcooper = par_cdcooper
                           AND crapfin.cdfinemp = par_cdfinemp
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapfin THEN 
                DO:
                    IF  LOCKED crapfin THEN 
                        DO:
                            IF  aux_contador = 10 THEN 
                                DO:
                                    ASSIGN aux_cdcritic = 77.
                                           aux_dscritic = "".

                                    LEAVE Contador.
                                END.
                            ELSE 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT Contador.
                            END.
                        END.
                    ELSE 
                        DO:
                            ASSIGN aux_cdcritic = 362
                                   aux_dscritic = "".

                            LEAVE Contador.
                        END.
                END.
            ELSE
                DO: 
                    FIND FIRST crapepr WHERE crapepr.cdcooper = par_cdcooper
                                         AND crapepr.cdfinemp = par_cdfinemp
                                         USE-INDEX crapepr1 NO-LOCK NO-ERROR.
    
                    IF  AVAILABLE crapepr THEN 
                        DO:
                            ASSIGN aux_cdcritic = 376 
                                   aux_dscritic = "".

                            LEAVE Contador.
                        END.         
                    ELSE
                        DO:
                            FOR EACH craplch WHERE craplch.cdcooper = crapfin.cdcooper
                                               AND craplch.cdfinemp = crapfin.cdfinemp
                                               EXCLUSIVE-LOCK.
                                DELETE craplch.
                            END.    
                
                            DELETE crapfin.
                        END.

                    LEAVE Contador.
                END.
        END. /* END DO TO */

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            DO:                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                
                ASSIGN aux_dsretorn = "NOK".

                UNDO Grava, LEAVE Grava.                
            END.
        
        LEAVE Grava.

    END. /* FIM TRANSACTION GRAVA */

    RELEASE crapfin.

    RETURN aux_dsretorn.

END PROCEDURE.

/******************************************************************************/
PROCEDURE lista-linha-credito:

    DEF INPUT  PARAM par_cdcooper  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad  AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela  AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrregist  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nriniseq  AS INTE                              NO-UNDO.                                                                        
    DEF INPUT  PARAM par_cdlcremp  AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dslcremp  AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cddopcao  AS CHAR                              NO-UNDO.
                                                                        
    DEF OUTPUT PARAM par_qtregist  AS INTE                              NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-linhas-cred.

    DEF VAR aux_nrregist AS INT.

    EMPTY TEMP-TABLE tt-linhas-cred.

    ASSIGN aux_nrregist = par_nrregist.

    FOR EACH craplcr WHERE craplcr.cdcooper = par_cdcooper  AND
                          (IF par_cdlcremp <> 0 THEN
                           craplcr.cdlcremp = par_cdlcremp ELSE
                           craplcr.cdlcremp > 0)            AND
                          (IF par_dslcremp <> "" THEN
                           craplcr.dslcremp MATCHES "*" + par_dslcremp + "*" ELSE TRUE)                           
                           NO-LOCK.

         ASSIGN par_qtregist = par_qtregist + 1.

         IF (par_qtregist < par_nriniseq) OR
            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
             NEXT.

         IF  aux_nrregist > 0 THEN
             DO:
                CREATE tt-linhas-cred.
                ASSIGN tt-linhas-cred.cdlcremp = craplcr.cdlcremp
                       tt-linhas-cred.dslcremp = craplcr.dslcremp.
             END.

        ASSIGN aux_nrregist = aux_nrregist - 1.

    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
