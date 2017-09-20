/*..............................................................................

    Programa: b1wgen0048.p
    Autor   : David
    Data    : Novembro/2009                   Ultima atualizacao: 13/12/2013

    Objetivo  : Tranformacao BO tela CONTAS - Rotina INF.ADICIONAL
                Baseado em fontes/contas_financeiro_infadicional.p

    Alteracoes: 04/12/2009 - Incluido novos campos nas procedures (Elton).
    
                12/04/2010 - Adaptacao para gravar log na crapalt (David).
                
                28/07/2010 - Incluir campo de observacoes nas informacoes
                             adicionais tambem para a pessoa fisica
                             (Gabriel).
                             
                16/11/2011 - Tratamento para cdcooper = 3 na procedure
                             validar-informacoes-adicionais. (Fabricio)
                
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                06/09/2017 - Filtrado caracteres especiais qdo carregar ou gravar
                             dados do campo dsinfadi (Tiago #722921)
..............................................................................*/


/*................................. DEFINICOES ...............................*/

                                                                                
{ sistema/generico/includes/b1wgen0048tt.i}
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_log.i}
{ sistema/generico/includes/gera_erro.i}
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
                                                                       
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
                                                                      
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR h-b1wgen0060 AS HANDLE                                         NO-UNDO.


/*............................ PROCEDURES EXTERNAS ...........................*/


/******************************************************************************/
/**       Procedure para carregar informacoes adicionais do associado        **/
/******************************************************************************/
PROCEDURE obtem-informacoes-adicionais:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-inf-adicionais.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-inf-adicionais.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem informacoes adicionais do associado".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            IF  par_flgerlog  THEN
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

            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen0060.p PERSISTENT SET h-b1wgen0060.

    IF  NOT VALID-HANDLE(h-b1wgen0060)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0060.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            IF  par_flgerlog  THEN
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

            RETURN "NOK".
        END.

    IF  crapass.inpessoa = 1 THEN
        DO:
            FOR FIRST crapttl FIELDS(nrinfcad nrpatlvr dsinfadi)
                              WHERE crapttl.cdcooper = par_cdcooper AND
                                    crapttl.nrdconta = par_nrdconta AND
                                    crapttl.idseqttl = par_idseqttl NO-LOCK:

                CREATE tt-inf-adicionais.
                ASSIGN tt-inf-adicionais.nrinfcad    = crapttl.nrinfcad
                       tt-inf-adicionais.nrpatlvr    = crapttl.nrpatlvr
               tt-inf-adicionais.dsinfadi[1] = SUBSTR(crapttl.dsinfadi,1,74)
               tt-inf-adicionais.dsinfadi[2] = SUBSTR(crapttl.dsinfadi,75,74)
               tt-inf-adicionais.dsinfadi[3] = SUBSTR(crapttl.dsinfadi,149,74)
               tt-inf-adicionais.dsinfadi[4] = SUBSTR(crapttl.dsinfadi,223,74)
               tt-inf-adicionais.dsinfadi[5] = SUBSTR(crapttl.dsinfadi,297,74).               
                    
            END.

            DYNAMIC-FUNCTION("BuscaTopico" IN h-b1wgen0060,
                             INPUT par_cdcooper,
                             INPUT 1,
                             INPUT 4,
                             INPUT tt-inf-adicionais.nrinfcad,
                            OUTPUT tt-inf-adicionais.dsinfcad,
                            OUTPUT aux_dscritic).

            DYNAMIC-FUNCTION("BuscaTopico" IN h-b1wgen0060,
                             INPUT par_cdcooper,
                             INPUT 1,
                             INPUT 8,
                             INPUT tt-inf-adicionais.nrpatlvr,
                            OUTPUT tt-inf-adicionais.dspatlvr,
                            OUTPUT aux_dscritic).
        END.
    ELSE 
        DO:
            FIND FIRST crapjfn WHERE crapjfn.cdcooper = par_cdcooper AND 
                                     crapjfn.nrdconta = par_nrdconta 
                                     NO-LOCK NO-ERROR.
    
            IF  AVAILABLE crapjfn  THEN 
                DO:
                    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                                       crapope.cdoperad = crapjfn.cdopejfn[5] 
                                       NO-LOCK NO-ERROR.
    
                    CREATE tt-inf-adicionais.
                    ASSIGN tt-inf-adicionais.cdopejfn    = crapjfn.cdopejfn[5]
                           tt-inf-adicionais.nmopejfn    = IF AVAIL crapope  
                                                           THEN
                                                               crapope.nmoperad
                                                           ELSE
                                                               "NAO CADASTRADO"
                           tt-inf-adicionais.dtaltjfn    = crapjfn.dtaltjfn[5]
                           tt-inf-adicionais.dsinfadi[1] = crapjfn.dsinfadi[1]
                           tt-inf-adicionais.dsinfadi[2] = crapjfn.dsinfadi[2]
                           tt-inf-adicionais.dsinfadi[3] = crapjfn.dsinfadi[3]
                           tt-inf-adicionais.dsinfadi[4] = crapjfn.dsinfadi[4]
                           tt-inf-adicionais.dsinfadi[5] = crapjfn.dsinfadi[5].
    
                    FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                       crapjur.nrdconta = par_nrdconta
                                       NO-LOCK NO-ERROR.

                    IF  AVAILABLE crapjur  THEN
                        ASSIGN tt-inf-adicionais.nrinfcad = crapjur.nrinfcad
                               tt-inf-adicionais.nrperger = crapjur.nrperger
                               tt-inf-adicionais.nrpatlvr = crapjur.nrpatlvr.

                    DYNAMIC-FUNCTION("BuscaTopico" IN h-b1wgen0060,
                                     INPUT par_cdcooper,
                                     INPUT 3,
                                     INPUT 3,
                                     INPUT tt-inf-adicionais.nrinfcad,
                                    OUTPUT tt-inf-adicionais.dsinfcad,
                                    OUTPUT aux_dscritic).

                    DYNAMIC-FUNCTION("BuscaTopico" IN h-b1wgen0060,
                                     INPUT par_cdcooper,
                                     INPUT 3,
                                     INPUT 9,
                                     INPUT tt-inf-adicionais.nrpatlvr,
                                    OUTPUT tt-inf-adicionais.dspatlvr,
                                    OUTPUT aux_dscritic).

                    DYNAMIC-FUNCTION("BuscaTopico" IN h-b1wgen0060,
                                     INPUT par_cdcooper,
                                     INPUT 3,
                                     INPUT 11,
                                     INPUT tt-inf-adicionais.nrperger,
                                    OUTPUT tt-inf-adicionais.dsperger,
                                    OUTPUT aux_dscritic).
                END.   
        END.

    DELETE PROCEDURE h-b1wgen0060.


    /*INICIO - Tratamento para retirar caracteres especias do campo dsinfadi*/
    
    
    /*1*/
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    
    RUN STORED-PROCEDURE pc_caract_acento
         aux_handproc = PROC-HANDLE NO-ERROR
                          (INPUT tt-inf-adicionais.dsinfadi[1],  /* String para limpeza  */
                           INPUT 1,         /* Flag para substituir */ 
                          OUTPUT "").       /* Texto sem caracteres especiais */

    CLOSE STORED-PROC pc_caract_acento
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
    ASSIGN tt-inf-adicionais.dsinfadi[1] = ""                         
           tt-inf-adicionais.dsinfadi[1] = pc_caract_acento.pr_clstexto
                          WHEN pc_caract_acento.pr_clstexto <> ?.
        
    /*2*/
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    
    RUN STORED-PROCEDURE pc_caract_acento
         aux_handproc = PROC-HANDLE NO-ERROR
                          (INPUT tt-inf-adicionais.dsinfadi[2],  /* String para limpeza  */
                           INPUT 1,         /* Flag para substituir */ 
                          OUTPUT "").       /* Texto sem caracteres especiais */

    CLOSE STORED-PROC pc_caract_acento
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
    ASSIGN tt-inf-adicionais.dsinfadi[2] = ""                         
           tt-inf-adicionais.dsinfadi[2] = pc_caract_acento.pr_clstexto
                          WHEN pc_caract_acento.pr_clstexto <> ?.
    
    /*3*/
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    
    RUN STORED-PROCEDURE pc_caract_acento
         aux_handproc = PROC-HANDLE NO-ERROR
                          (INPUT tt-inf-adicionais.dsinfadi[3],  /* String para limpeza  */
                           INPUT 1,         /* Flag para substituir */ 
                          OUTPUT "").       /* Texto sem caracteres especiais */

    CLOSE STORED-PROC pc_caract_acento
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
    ASSIGN tt-inf-adicionais.dsinfadi[3] = ""                         
           tt-inf-adicionais.dsinfadi[3] = pc_caract_acento.pr_clstexto
                          WHEN pc_caract_acento.pr_clstexto <> ?.
    
    /*4*/
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    
    RUN STORED-PROCEDURE pc_caract_acento
         aux_handproc = PROC-HANDLE NO-ERROR
                          (INPUT tt-inf-adicionais.dsinfadi[4],  /* String para limpeza  */
                           INPUT 1,         /* Flag para substituir */ 
                          OUTPUT "").       /* Texto sem caracteres especiais */

    CLOSE STORED-PROC pc_caract_acento
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
    ASSIGN tt-inf-adicionais.dsinfadi[4] = ""                         
           tt-inf-adicionais.dsinfadi[4] = pc_caract_acento.pr_clstexto
                          WHEN pc_caract_acento.pr_clstexto <> ?.
    
    /*5*/
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    
    RUN STORED-PROCEDURE pc_caract_acento
         aux_handproc = PROC-HANDLE NO-ERROR
                          (INPUT tt-inf-adicionais.dsinfadi[5],  /* String para limpeza  */
                           INPUT 1,         /* Flag para substituir */ 
                          OUTPUT "").       /* Texto sem caracteres especiais */

    CLOSE STORED-PROC pc_caract_acento
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
    ASSIGN tt-inf-adicionais.dsinfadi[5] = ""                         
           tt-inf-adicionais.dsinfadi[5] = pc_caract_acento.pr_clstexto
                          WHEN pc_caract_acento.pr_clstexto <> ?.
    
        
    /*FIM - Tratamento para retirar caracteres especias do campo dsinfadi*/


    IF  par_flgerlog  THEN
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

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**        Procedure para validar informacoes adicionais do associado        **/
/******************************************************************************/
PROCEDURE validar-informacoes-adicionais:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinfcad AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrperger AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrpatlvr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dstopico AS CHAR                                    NO-UNDO.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro. 

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida Informacoes Adicionais do associado"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_flgerror = TRUE.
    
    DO WHILE TRUE:
    
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.

        RUN sistema/generico/procedures/b1wgen0060.p PERSISTENT 
            SET h-b1wgen0060.

        IF  NOT VALID-HANDLE(h-b1wgen0060)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0060.".
                LEAVE.
            END.

        IF  crapass.inpessoa = 1  THEN
            DO:
                /** Informacoes Cadastrais **/
                IF  NOT DYNAMIC-FUNCTION("BuscaTopico" IN h-b1wgen0060,
                                         INPUT par_cdcooper,
                                         INPUT 1,
                                         INPUT 4,
                                         INPUT par_nrinfcad,
                                        OUTPUT aux_dstopico,
                                        OUTPUT aux_dscritic) THEN
                    LEAVE.
    
                /** Patrimonio Livre **/         
                IF  NOT DYNAMIC-FUNCTION("BuscaTopico" IN h-b1wgen0060,
                                         INPUT par_cdcooper,
                                         INPUT 1,
                                         INPUT 8,
                                         INPUT par_nrpatlvr,
                                        OUTPUT aux_dstopico,
                                        OUTPUT aux_dscritic) THEN
                    LEAVE.
            END.
        ELSE 
            DO:
                /** Informacoes Cadastrais **/
                IF  NOT DYNAMIC-FUNCTION("BuscaTopico" IN h-b1wgen0060,
                                         INPUT par_cdcooper,
                                         INPUT 3,
                                         INPUT 3,
                                         INPUT par_nrinfcad,
                                        OUTPUT aux_dstopico,
                                        OUTPUT aux_dscritic) THEN
                    LEAVE.

                IF par_cdcooper = 3 THEN
                DO:
                    IF par_nrpatlvr <> 0 THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao pode ser informado nenhum" +
                                                " Patrimonio Pessoal Livre.".

                        LEAVE.
                    END.

                    IF par_nrperger <> 0 THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao pode ser informado nenhuma" 
                                               + " Percepcao Geral.".

                        LEAVE.
                    END.
                        
                END.
                ELSE
                DO:
                    /** Patrimonio Livre **/         
                    IF  NOT DYNAMIC-FUNCTION("BuscaTopico" IN h-b1wgen0060,
                                             INPUT par_cdcooper,
                                             INPUT 3,
                                             INPUT 9,
                                             INPUT par_nrpatlvr,
                                            OUTPUT aux_dstopico,
                                            OUTPUT aux_dscritic) THEN
                        LEAVE.

                    /** Percepcao geral **/         
                    IF  NOT DYNAMIC-FUNCTION("BuscaTopico" IN h-b1wgen0060,
                                             INPUT par_cdcooper,
                                             INPUT 3,
                                             INPUT 11,
                                             INPUT par_nrperger,
                                            OUTPUT aux_dstopico,
                                            OUTPUT aux_dscritic) THEN
                        LEAVE.
                END.
    
            END.

        ASSIGN aux_flgerror = FALSE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  VALID-HANDLE(h-b1wgen0060)  THEN
        DELETE PROCEDURE h-b1wgen0060.

    IF  aux_flgerror  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
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
     
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**       Procedure para atualizar informacoes adicionais do associado       **/
/******************************************************************************/
PROCEDURE atualizar-informacoes-adicionais:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsinfad1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsinfad2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsinfad3 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsinfad4 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsinfad5 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrinfcad AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrperger AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrpatlvr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR par_cddopcao AS CHAR INITIAL "A"                        NO-UNDO.

    DEF VAR aux_dsinfad1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfad2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfad3 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfad4 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfad5 AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdopejfn AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_dtaltjfn AS DATE                                    NO-UNDO.
    
    DEF VAR aux_nrinfcad AS INTE                                    NO-UNDO.
    DEF VAR aux_nrperger AS INTE                                    NO-UNDO.
    DEF VAR aux_nrpatlvr AS INTE                                    NO-UNDO.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Atualizar informacoes adicionais do associado"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    TRANSACAO:

    DO TRANSACTION ON ERROR  UNDO TRANSACAO, LEAVE TRANSACAO 
                   ON ENDKEY UNDO TRANSACAO, LEAVE TRANSACAO:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        /*INICIO - Tratamento para retirar caracteres especias do campo dsinfadi*/
        
        
        /*1*/
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                        
        RUN STORED-PROCEDURE pc_caract_acento
             aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT par_dsinfad1,  /* String para limpeza  */
                               INPUT 1,         /* Flag para substituir */ 
                              OUTPUT "").       /* Texto sem caracteres especiais */

        CLOSE STORED-PROC pc_caract_acento
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
          
        ASSIGN par_dsinfad1 = ""                         
               par_dsinfad1 = pc_caract_acento.pr_clstexto
                              WHEN pc_caract_acento.pr_clstexto <> ?.
            
        /*2*/
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                        
        RUN STORED-PROCEDURE pc_caract_acento
             aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT par_dsinfad2,  /* String para limpeza  */
                               INPUT 1,         /* Flag para substituir */ 
                              OUTPUT "").       /* Texto sem caracteres especiais */

        CLOSE STORED-PROC pc_caract_acento
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
          
        ASSIGN par_dsinfad2 = ""                         
               par_dsinfad2 = pc_caract_acento.pr_clstexto
                              WHEN pc_caract_acento.pr_clstexto <> ?.
        
        /*3*/
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                        
        RUN STORED-PROCEDURE pc_caract_acento
             aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT par_dsinfad3,  /* String para limpeza  */
                               INPUT 1,         /* Flag para substituir */ 
                              OUTPUT "").       /* Texto sem caracteres especiais */

        CLOSE STORED-PROC pc_caract_acento
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
          
        ASSIGN par_dsinfad3 = ""                         
               par_dsinfad3 = pc_caract_acento.pr_clstexto
                              WHEN pc_caract_acento.pr_clstexto <> ?.
        
        /*4*/
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                        
        RUN STORED-PROCEDURE pc_caract_acento
             aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT par_dsinfad4,  /* String para limpeza  */
                               INPUT 1,         /* Flag para substituir */ 
                              OUTPUT "").       /* Texto sem caracteres especiais */

        CLOSE STORED-PROC pc_caract_acento
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
          
        ASSIGN par_dsinfad4 = ""                         
               par_dsinfad4 = pc_caract_acento.pr_clstexto
                              WHEN pc_caract_acento.pr_clstexto <> ?.
        
        /*5*/
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                        
        RUN STORED-PROCEDURE pc_caract_acento
             aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT par_dsinfad5,  /* String para limpeza  */
                               INPUT 1,         /* Flag para substituir */ 
                              OUTPUT "").       /* Texto sem caracteres especiais */

        CLOSE STORED-PROC pc_caract_acento
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
          
        ASSIGN par_dsinfad5 = ""                         
               par_dsinfad5 = pc_caract_acento.pr_clstexto
                              WHEN pc_caract_acento.pr_clstexto <> ?.
        
            
        /*FIM - Tratamento para retirar caracteres especias do campo dsinfadi*/


        IF  crapass.inpessoa = 1 THEN
            DO:
                DO aux_contador = 1 TO 10:

                    FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                       crapttl.nrdconta = par_nrdconta AND
                                       crapttl.idseqttl = par_idseqttl
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapttl  THEN
                        DO:
                            IF  LOCKED crapttl  THEN
                                DO:
                                    IF  aux_contador = 10  THEN
                                        DO:
                                            FIND crapttl WHERE 
                                             crapttl.cdcooper = par_cdcooper AND
                                             crapttl.nrdconta = par_nrdconta AND
                                             crapttl.idseqttl = par_idseqttl
                                             NO-LOCK NO-ERROR.
                                            
                                            RUN critica-lock 
                                               (INPUT RECID(crapttl),
                                                INPUT "banco",
                                                INPUT "crapttl",
                                                INPUT par_idorigem).
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                END.
                            ELSE 
                                ASSIGN aux_dscritic = "Titular nao cadastrado.".
                        END.
                    
                    LEAVE.

                END. /** Fim do DO ... TO **/

                IF  aux_dscritic <> ""  THEN
                    UNDO TRANSACAO, LEAVE TRANSACAO.

                { sistema/generico/includes/b1wgenalog.i }

                ASSIGN aux_nrinfcad     = crapttl.nrinfcad
                       aux_nrpatlvr     = crapttl.nrpatlvr
                       crapttl.nrinfcad = par_nrinfcad
                       crapttl.nrpatlvr = par_nrpatlvr
                       crapttl.dsinfadi = par_dsinfad1 + 
                                          par_dsinfad2 +  
                                          par_dsinfad3 + 
                                          par_dsinfad4 + 
                                          par_dsinfad5.                                          
            END.
        ELSE
            DO:
                DO aux_contador = 1 TO 10:
        
                    FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper AND 
                                       crapjfn.nrdconta = par_nrdconta
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF  NOT AVAILABLE crapjfn  THEN 
                        DO:
                            IF  LOCKED crapjfn  THEN 
                                DO:
                                    IF  aux_contador = 10  THEN
                                        DO:
                                            FIND crapjfn WHERE 
                                             crapjfn.cdcooper = par_cdcooper AND 
                                             crapjfn.nrdconta = par_nrdconta
                                             NO-LOCK NO-ERROR.
                                            
                                            RUN critica-lock 
                                               (INPUT RECID(crapjfn),
                                                INPUT "banco",
                                                INPUT "crapjfn",
                                                INPUT par_idorigem).
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                END.
                            ELSE 
                                DO:
                                    CREATE crapjfn.
                                    ASSIGN crapjfn.cdcooper = par_cdcooper
                                           crapjfn.nrdconta = par_nrdconta.
                                    VALIDATE crapjfn.
                                END.
                        END.
                    
                    LEAVE.
        
                END. /** Fim do DO .. TO **/
        
                IF  aux_dscritic <> ""  THEN
                    UNDO TRANSACAO, LEAVE TRANSACAO.
        
                DO aux_contador = 1 TO 10:
        
                    FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                       crapjur.nrdconta = par_nrdconta 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF  NOT AVAILABLE crapjur  THEN 
                        DO:
                            IF  LOCKED crapjur  THEN 
                                DO:
                                    IF  aux_contador = 10  THEN
                                        DO:
                                            FIND crapjur WHERE 
                                             crapjur.cdcooper = par_cdcooper AND
                                             crapjur.nrdconta = par_nrdconta
                                             NO-LOCK NO-ERROR.
                                            
                                            RUN critica-lock 
                                               (INPUT RECID(crapjur),
                                                INPUT "banco",
                                                INPUT "crapjur",
                                                INPUT par_idorigem).
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                END.
                            ELSE 
                                ASSIGN aux_dscritic = "Registro de pessoa " +
                                                    "juridica nao encontrado.".
                        END.
                    
                    LEAVE.
        
                END. /** Fim do DO .. TO **/
        
                IF  aux_dscritic <> ""  THEN
                    UNDO TRANSACAO, LEAVE TRANSACAO.

                { sistema/generico/includes/b1wgenalog.i }

                ASSIGN aux_dsinfad1        = crapjfn.dsinfadi[1]
                       aux_dsinfad2        = crapjfn.dsinfadi[2]
                       aux_dsinfad3        = crapjfn.dsinfadi[3]
                       aux_dsinfad4        = crapjfn.dsinfadi[4]
                       aux_dsinfad5        = crapjfn.dsinfadi[5]
                       aux_cdopejfn        = crapjfn.cdopejfn[5]
                       aux_dtaltjfn        = crapjfn.dtaltjfn[5]
                       aux_nrinfcad        = crapjur.nrinfcad  
                       aux_nrperger        = crapjur.nrperger
                       aux_nrpatlvr        = crapjur.nrpatlvr
                       crapjfn.dsinfadi[1] = par_dsinfad1
                       crapjfn.dsinfadi[2] = par_dsinfad2
                       crapjfn.dsinfadi[3] = par_dsinfad3
                       crapjfn.dsinfadi[4] = par_dsinfad4
                       crapjfn.dsinfadi[5] = par_dsinfad5
                       crapjfn.cdopejfn[5] = par_cdoperad
                       crapjfn.dtaltjfn[5] = par_dtmvtolt
                       crapjur.nrinfcad    = par_nrinfcad
                       crapjur.nrperger    = par_nrperger
                       crapjur.nrpatlvr    = par_nrpatlvr.
            END.

        { sistema/generico/includes/b1wgenllog.i }

        IF  AVAILABLE crapttl  THEN
            FIND CURRENT crapttl NO-LOCK NO-ERROR.

        IF  AVAILABLE crapjfn  THEN
            FIND CURRENT crapjfn NO-LOCK NO-ERROR.

        IF  AVAILABLE crapjur  THEN
            FIND CURRENT crapjur NO-LOCK NO-ERROR.
        
        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nao foi possivel atualizar as " +
                                      "informacoes adicionais.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            IF  par_flgerlog  THEN                           
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

            IF  aux_nrinfcad <> par_nrinfcad  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "nrinfcad",
                                         INPUT STRING(aux_nrinfcad),
                                         INPUT STRING(par_nrinfcad)).

            IF  aux_nrpatlvr <> par_nrpatlvr  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "nrpatlvr",
                                         INPUT STRING(aux_nrpatlvr),
                                         INPUT STRING(par_nrpatlvr)).
                                                     
            IF  crapass.inpessoa > 1   THEN
                DO:
                    IF  aux_nrperger <> par_nrperger  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "nrperger",
                                                 INPUT STRING(aux_nrperger),
                                                 INPUT STRING(par_nrperger)).
        
                    IF  aux_cdopejfn <> par_cdoperad  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "cdopejfn",
                                                 INPUT aux_cdopejfn,
                                                 INPUT par_cdoperad).
        
                    IF  aux_dtaltjfn <> par_dtmvtolt  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "dtaltjfn",
                                                 INPUT STRING(aux_dtaltjfn,
                                                              "99/99/9999"),
                                                 INPUT STRING(par_dtmvtolt,
                                                              "99/99/9999")).
        
                    IF  aux_dsinfad1 <> par_dsinfad1  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "dsinfadi1",
                                                 INPUT aux_dsinfad1,
                                                 INPUT par_dsinfad1).

                    IF  aux_dsinfad2 <> par_dsinfad2  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "dsinfadi2",
                                                 INPUT aux_dsinfad2,
                                                 INPUT par_dsinfad2).
        
                    IF  aux_dsinfad3 <> par_dsinfad3  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "dsinfadi3",
                                                 INPUT aux_dsinfad3,
                                                 INPUT par_dsinfad3).
        
                    IF  aux_dsinfad4 <> par_dsinfad4  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "dsinfadi4",
                                                 INPUT aux_dsinfad4,
                                                 INPUT par_dsinfad4).
        
                    IF  aux_dsinfad5 <> par_dsinfad5  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "dsinfadi5",
                                                 INPUT aux_dsinfad5,
                                                 INPUT par_dsinfad5).
                END.
        END.
        
    RETURN "OK".

END PROCEDURE.

                                                                             
/*............................ PROCEDURES INTERNAS ...........................*/


PROCEDURE critica-lock:

    DEF  INPUT PARAM par_nrdrecid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdbanco AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmtabela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_loginusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmusuari AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdevice AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtconnec AS CHAR                                    NO-UNDO.
    DEF VAR aux_numipusr AS CHAR                                    NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "Registro sendo alterado em outro terminal (" + 
                          par_nmtabela + ").".

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RETURN.
        
    RUN acha-lock IN h-b1wgen9999 (INPUT par_nrdrecid,
                                   INPUT par_nmdbanco,
                                   INPUT par_nmtabela,
                                  OUTPUT aux_loginusr,
                                  OUTPUT aux_nmusuari,
                                  OUTPUT aux_dsdevice,
                                  OUTPUT aux_dtconnec, 
                                  OUTPUT aux_numipusr).

    DELETE PROCEDURE h-b1wgen9999.

    ASSIGN aux_dscritic = aux_dscritic + " Operador: " + 
                          aux_loginusr + " - " + aux_nmusuari.

    RETURN "OK".

END PROCEDURE.

                                                                             
/*............................................................................*/
