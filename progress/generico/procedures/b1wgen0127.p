/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0127.p
    Autor   : Gabriel Capoia (DB1)
    Data    : Novembro/2011                     Ultima atualizacao: 06/10/2015

    Objetivo  : Transformacao BO tela VALPRO

    Alteracoes: 11/08/2014 - Ajuste para validar protocolo provenientes de
                             migracao entre cooperativas (David).
                             
                06/10/2015 - Incluindo validacao de protocolo MD5 - Sicredi
                            (Andre Santos - SUPERO)

                29/05/2017 - Ajuste para utilizar a procedure Oracle para 
                             validar o protocolo (Douglas - Chamado 663312)
............................................................................*/

/*............................. DEFINICOES .................................*/

{ sistema/generico/includes/b1wgen0127tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                    Valida os Dados do Protocolo Informado                */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Protocolo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_horproto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_minproto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_segproto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprotoc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsprotoc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqaut AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_msgretur AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_msgerror AS CHAR                           NO-UNDO.
                     
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_tempotot AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsprotoc AS CHAR                                    NO-UNDO.
    DEF VAR h-bo_algoritmo_seguranca AS HANDLE                      NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_msgretur = ""
           aux_msgerror = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar Protocolo de Transacoes".

    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* GENE0006 */
    RUN STORED-PROCEDURE pc_valida_protocolo aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_cddopcao,
                          INPUT par_nrdconta,
                          INPUT par_nrdocmto,
                          INPUT par_dtmvtolx,
                          INPUT par_horproto,
                          INPUT par_minproto,
                          INPUT par_segproto,
                          INPUT par_vlprotoc,
                          INPUT par_dsprotoc,
                          INPUT par_nrseqaut,
                          OUTPUT "",  /* nmdcampo */
                          OUTPUT "",  /* returnvl */
                          OUTPUT "",  /* msgretur */
                          OUTPUT "",  /* msgerror */
                          OUTPUT 0,   /* cdcritic */ 
                          OUTPUT ""). /* dscritic */
                          
    CLOSE STORED-PROC pc_valida_protocolo aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN par_nmdcampo = ""
           aux_msgretur = ""
           aux_msgerror = ""
           aux_returnvl = ""
           par_nmdcampo = pc_valida_protocolo.pr_nmdcampo
                          WHEN pc_valida_protocolo.pr_nmdcampo <> ?
           aux_msgretur = pc_valida_protocolo.pr_msgretur
                          WHEN pc_valida_protocolo.pr_msgretur <> ?
           aux_msgerror = pc_valida_protocolo.pr_msgerror
                          WHEN pc_valida_protocolo.pr_msgerror <> ?
           aux_returnvl = pc_valida_protocolo.pr_returnvl
                          WHEN pc_valida_protocolo.pr_returnvl <> ?
           aux_cdcritic = pc_valida_protocolo.pr_cdcritic
                          WHEN pc_valida_protocolo.pr_cdcritic <> ?
           aux_dscritic = pc_valida_protocolo.pr_dscritic
                          WHEN pc_valida_protocolo.pr_dscritic <> ?.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    
    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Protocolo */


/* ------------------------------------------------------------------------ */
/*         Valida os Dados do Protocolo MD5 Informado - SICREDI             */
/* ------------------------------------------------------------------------ */
PROCEDURE pc_valida_protocolo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_horproto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_minproto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_segproto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprotoc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsprotoc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqaut AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgretur AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgerror AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
    DEF VAR aux_msgretur AS CHAR                                    NO-UNDO.
    DEF VAR aux_msgerror AS CHAR                                    NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* GENE0006 */
    RUN STORED-PROCEDURE pc_valida_protocolo_md5 aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_cdprogra,
                          INPUT par_idorigem,
                          INPUT par_dtmvtolt,
                          INPUT par_dtmvtopr,
                          INPUT par_nmdatela,
                          INPUT par_cddopcao,
                          INPUT par_nrdconta,
                          INPUT par_nrdocmto,
                          INPUT par_dtmvtolx,
                          INPUT par_horproto,
                          INPUT par_minproto,
                          INPUT par_segproto,
                          INPUT par_vlprotoc,
                          INPUT par_dsprotoc,
                          INPUT par_nrseqaut,
                          INPUT INTE(STRING(par_flgerlog,"1/0")),
                          OUTPUT "",
                          OUTPUT "",
                          OUTPUT "").

    CLOSE STORED-PROC pc_valida_protocolo_md5 aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_nmdcampo = ""
           aux_msgretur = ""
           aux_msgerror = ""
           aux_nmdcampo = pc_valida_protocolo_md5.pr_nmdcampo
                          WHEN pc_valida_protocolo_md5.pr_nmdcampo <> ?
           aux_msgretur = pc_valida_protocolo_md5.pr_desmensg
                          WHEN pc_valida_protocolo_md5.pr_desmensg <> ?
           aux_msgerror = pc_valida_protocolo_md5.pr_dscritic
                          WHEN pc_valida_protocolo_md5.pr_dscritic <> ?.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_msgerror <> "" THEN
        DO:
            /* Verifica se eh uma conta migrada, e se for, valida novamente
               com a cooperativa e conta antiga, pois o comprovante tambem
               pode ter sido migrado */
            FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                               craptco.nrdconta = par_nrdconta AND
                               craptco.tpctatrf = 1
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL craptco  THEN
                DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = aux_msgerror
               par_msgerror = aux_msgerror
               par_nmdcampo = aux_nmdcampo
               par_msgretur = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.
        ELSE
            DO:                
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                /* GENE0006 */
                RUN STORED-PROCEDURE pc_valida_protocolo_md5 aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT craptco.cdcopant,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_cdprogra,
                                        INPUT par_idorigem,
                                        INPUT par_dtmvtolt,
                                        INPUT par_dtmvtopr,
                                        INPUT par_nmdatela,
                                        INPUT par_cddopcao,
                                        INPUT craptco.nrctaant,
                                        INPUT par_nrdocmto,
                                        INPUT par_dtmvtolx,
                                        INPUT par_horproto,
                                        INPUT par_minproto,
                                        INPUT par_segproto,
                                        INPUT par_vlprotoc,
                                        INPUT par_dsprotoc,
                                        INPUT par_nrseqaut,
                                        INPUT INTE(STRING(par_flgerlog,"1/0")),
                                        OUTPUT "",
                                        OUTPUT "",
                                        OUTPUT "").

                CLOSE STORED-PROC pc_valida_protocolo_md5 aux_statproc = PROC-STATUS
                        WHERE PROC-HANDLE = aux_handproc.

                ASSIGN aux_nmdcampo = ""
                        aux_msgretur = ""
                        aux_msgerror = ""
                        aux_nmdcampo = pc_valida_protocolo_md5.pr_nmdcampo
                                        WHEN pc_valida_protocolo_md5.pr_nmdcampo <> ?
                        aux_msgretur = pc_valida_protocolo_md5.pr_desmensg
                                        WHEN pc_valida_protocolo_md5.pr_desmensg <> ?
                        aux_msgerror = pc_valida_protocolo_md5.pr_dscritic
                                        WHEN pc_valida_protocolo_md5.pr_dscritic <> ?.
                 
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                    
    IF  aux_msgerror <> "" THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = aux_msgerror
               par_msgerror = aux_msgerror
               par_nmdcampo = aux_nmdcampo
               par_msgretur = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
                END.        
            END.        
    END.

    ASSIGN par_msgretur = aux_msgretur.

    RETURN "OK".

END PROCEDURE.


/*............................. PROCEDURES INTERNAS .........................*/

/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/
