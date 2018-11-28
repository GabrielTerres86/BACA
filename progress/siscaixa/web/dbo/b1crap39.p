/*-----------------------------------------------------------------------------

    b1crap39.p - OPERAÇÕES PARA RECEBIMENTO DE TARIFAS
    
    Alteracoes: 
                
------------------------------------------------------------------------------ **/
{dbo/bo-erro1.i}

{ sistema/generico/includes/var_internet.i }

DEF VAR i-cod-erro      AS INTEGER.
DEF VAR c-desc-erro     AS CHAR.

PROCEDURE retorna-valor-historico:

    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-cod-histor    AS INTE.
    DEF OUTPUT PARAM p-nrctacrd      AS INTE.
    DEF OUTPUT PARAM p-nrctadeb      AS INTE.
    DEF OUTPUT PARAM p-cdhstctb      AS INTE.
    DEF OUTPUT PARAM p-indcompl      AS INTE.
    DEF OUTPUT PARAM p-ds-histor     AS CHAR.
        
    FIND crapcop WHERE crapcop.nmrescop = p-cooper          NO-LOCK NO-ERROR.

    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper  AND
                       crapage.cdagenci = p-cod-agencia     NO-LOCK NO-ERROR.

    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper  AND
                       craphis.cdhistor = p-cod-histor      NO-LOCK NO-ERROR.
        
    IF craphis.tpctbcxa = 2 THEN
        ASSIGN  p-nrctadeb = crapage.cdcxaage
                p-nrctacrd = craphis.nrctacrd.
    ELSE
        IF craphis.tpctbcxa = 3 THEN
            ASSIGN  p-nrctacrd = crapage.cdcxaage
                    p-nrctadeb = craphis.nrctadeb.
        ELSE
            ASSIGN  p-nrctacrd = craphis.nrctacrd
                    p-nrctadeb = craphis.nrctadeb.

    ASSIGN  p-cdhstctb  = craphis.cdhstctb
            p-indcompl  = craphis.indcompl
            p-ds-histor = craphis.dshistor.

    RETURN "OK".

END PROCEDURE.

PROCEDURE retorna-tarifa:

    DEF INPUT  PARAM pr_cdcooper    AS INTE     NO-UNDO.
    DEF INPUT  PARAM pr_cdbattar    AS CHAR     NO-UNDO.
    DEF INPUT  PARAM pr_cdprogra    AS CHAR     NO-UNDO.
    
    DEF OUTPUT PARAM out_cdhistor   AS  INTE    NO-UNDO.
    DEF OUTPUT PARAM out_cdhisest   AS  DECI    NO-UNDO.
    DEF OUTPUT PARAM out_vltarifa   AS  DECI    NO-UNDO.
    DEF OUTPUT PARAM out_cdcritic   AS  CHAR    NO-UNDO.
    DEF OUTPUT PARAM out_dscritic   AS  CHAR    NO-UNDO.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
    RUN STORED-PROCEDURE pc_carrega_dados_tar_vigen_prg 
      aux_handproc = PROC-HANDLE NO-ERROR (  INPUT pr_cdcooper /* INTEGER */
                                            ,INPUT pr_cdbattar /* VARCHAR2 */
                                            ,INPUT pr_cdprogra /* VARCHAR2 */
                                            ,OUTPUT 0   /* pr_cdhistor  OUT INTEGER */
                                            ,OUTPUT 0   /* pr_cdhisest  OUT NUMBER */
                                            ,OUTPUT 0   /* pr_vltarifa  OUT NUMBER */
                                            ,OUTPUT 0   /* pr_cdcritic  OUT INTEGER */
                                            ,OUTPUT "").  /* pr_dscritic  OUT VARCHAR2 */

    CLOSE STORED-PROC pc_carrega_dados_tar_vigen_prg
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN  out_cdhistor = pc_carrega_dados_tar_vigen_prg.pr_cdhistor
            out_cdhisest = pc_carrega_dados_tar_vigen_prg.pr_cdhisest
            out_vltarifa = pc_carrega_dados_tar_vigen_prg.pr_vltarifa
            out_cdcritic = pc_carrega_dados_tar_vigen_prg.pr_cdcritic
            out_dscritic = pc_carrega_dados_tar_vigen_prg.pr_dscritic.


    IF pr_dscritic <> ""  THEN
    DO:
        RETURN "NOK".
    END.

    RETURN "OK".
END PROCEDURE.


// PROCEDURE valida-campos-debaut:

//     DEF INPUT  PARAM par_nmrescop   AS CHAR               NO-UNDO.
//     DEF INPUT  PARAM par_cdagenci   AS INTE               NO-UNDO.
//     DEF INPUT  PARAM par_nrdcaixa   AS INTE               NO-UNDO.
//     DEF INPUT  PARAM par_nrdconta   AS DECI               NO-UNDO.
//     DEF INPUT  PARAM par_cdempcon   AS CHAR               NO-UNDO.
//     DEF INPUT  PARAM par_cdrefere   AS DECI               NO-UNDO.
//     DEF INPUT  PARAM par_inlimite   AS INTE               NO-UNDO.
//     DEF INPUT  PARAM par_vlrmaxdb   AS DECI               NO-UNDO.
//     DEF INPUT  PARAM par_dshisext   AS CHAR               NO-UNDO.    
//     DEF OUTPUT PARAM par_foco       AS CHAR               NO-UNDO.

//     RUN elimina-erro (INPUT par_nmrescop,
//                       INPUT par_cdagenci,
//                       INPUT par_nrdcaixa).

//     FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

//     IF  par_cdempcon = "" THEN
//         DO:
//             ASSIGN i-cod-erro  = 0
//                    c-desc-erro = "Selecione uma empresa.".
//                    par_foco    = "13". 

//             RUN cria-erro (INPUT par_nmrescop,
//                            INPUT par_cdagenci,
//                            INPUT par_nrdcaixa,
//                            INPUT i-cod-erro,
//                            INPUT c-desc-erro,
//                            INPUT YES).
  
//             RETURN "NOK".
//         END.

//     IF  par_cdrefere = 0 THEN
//         DO:
//             ASSIGN i-cod-erro  = 0
//                    c-desc-erro = "Preencha a Identificação do Consumidor.".
//                    par_foco    = "15".

//             RUN cria-erro (INPUT par_nmrescop,
//                            INPUT par_cdagenci,
//                            INPUT par_nrdcaixa,
//                            INPUT i-cod-erro,
//                            INPUT c-desc-erro,
//                            INPUT YES).
  
//             RETURN "NOK".
//         END.

//     IF  par_inlimite = 1 AND 
//         par_vlrmaxdb = 0 THEN
//         DO:
//             ASSIGN i-cod-erro  = 0
//                    c-desc-erro = "Insira o valor máximo de débito.".
//                    par_foco    = "18". 

//             RUN cria-erro (INPUT par_nmrescop,
//                            INPUT par_cdagenci,
//                            INPUT par_nrdcaixa,
//                            INPUT i-cod-erro,
//                            INPUT c-desc-erro,
//                            INPUT YES).
  
//             RETURN "NOK".
//         END.

//     RETURN "OK".

// END PROCEDURE.


// PROCEDURE inclui-debito-automatico:

//     DEF INPUT  PARAM par_nmrescop   AS CHAR               NO-UNDO.
//     DEF INPUT  PARAM par_cdagenci   AS INTE               NO-UNDO.
//     DEF INPUT  PARAM par_nrdcaixa   AS INTE               NO-UNDO.
//     DEF INPUT  PARAM par_cdoperad   AS CHAR               NO-UNDO.
//     DEF INPUT  PARAM par_nrdconta   AS DECI               NO-UNDO.
//     DEF INPUT  PARAM par_cdsegmto   AS INTE               NO-UNDO.
//     DEF INPUT  PARAM par_cdempcon   AS INTE               NO-UNDO.
//     DEF INPUT  PARAM par_cdrefere   AS DECI               NO-UNDO.
//     DEF INPUT  PARAM par_vlrmaxdb   AS DECI               NO-UNDO.
//     DEF INPUT  PARAM par_dshisext   AS CHAR               NO-UNDO.    
//     DEF OUTPUT PARAM par_foco       AS CHAR               NO-UNDO.
                                                          
//     DEF VAR aux_nmdcampo            AS CHAR               NO-UNDO.
//     DEF VAR aux_nmprimtl            AS CHAR               NO-UNDO.
//     DEF VAR aux_nmfatret            AS CHAR               NO-UNDO.
                                                          
//     RUN elimina-erro (INPUT par_nmrescop,
//                       INPUT par_cdagenci,
//                       INPUT par_nrdcaixa).

//     FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.
//     FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

//     RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

//     RUN busca_convenios_codbarras IN h-b1wgen0092 (INPUT crapcop.cdcooper,
//                                                    INPUT par_cdempcon, 
//                                                    INPUT par_cdsegmto,
//                                                    OUTPUT TABLE tt-convenios-codbarras).

//     DELETE PROCEDURE h-b1wgen0092.

//     FIND FIRST tt-convenios-codbarras WHERE tt-convenios-codbarras.cdempcon = par_cdempcon
//                                         AND tt-convenios-codbarras.cdsegmto = par_cdsegmto
//                                             NO-LOCK NO-ERROR.
    
//     IF  RETURN-VALUE = "NOK" OR NOT AVAIL tt-convenios-codbarras  THEN
//         DO:
//             ASSIGN i-cod-erro  = 0
//                    c-desc-erro = "Convenio nao encontrado."
//                    par_foco    = "14". 

//             RUN cria-erro (INPUT par_nmrescop,
//                            INPUT par_cdagenci,
//                            INPUT par_nrdcaixa,
//                            INPUT i-cod-erro,
//                            INPUT c-desc-erro,
//                            INPUT YES).  
//             RETURN "NOK".
//         END.
    
//     RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

//     RUN valida-dados IN h-b1wgen0092
//         ( INPUT crapcop.cdcooper, 
//           INPUT 0,            
//           INPUT 0, 
//           INPUT par_cdoperad, 
//           INPUT "CXONLINE", 
//           INPUT 2, /** Caixa ON_LINE **/
//           INPUT par_nrdconta, 
//           INPUT 1, 
//           INPUT YES,
//           INPUT "I",
//           INPUT tt-convenios-codbarras.cdhistor,
//           INPUT par_cdrefere,
//           INPUT crapdat.dtmvtocd,
//           INPUT ?,
//           INPUT ?, /*dtlimite*/
//           INPUT crapdat.dtmvtocd,
//           INPUT ?,
//          OUTPUT aux_nmdcampo,
//          OUTPUT aux_nmprimtl,
//          OUTPUT TABLE tt-erro).

//     DELETE PROCEDURE h-b1wgen0092.

//     IF  RETURN-VALUE = "NOK"  THEN
//         DO:
//             FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
//             IF  AVAILABLE tt-erro  THEN
//                 ASSIGN i-cod-erro  = 0
//                        c-desc-erro = tt-erro.dscritic
//                        par_foco    = "13".      
//             ELSE
//                 ASSIGN i-cod-erro  = 0
//                        c-desc-erro = "Problemas na BO 92"
//                        par_foco    = "13". 

//             RUN cria-erro (INPUT par_nmrescop,
//                            INPUT par_cdagenci,
//                            INPUT par_nrdcaixa,
//                            INPUT i-cod-erro,
//                            INPUT c-desc-erro,
//                            INPUT YES).

//             RETURN "NOK".
//         END.

//     RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    
//     RUN grava-dados IN h-b1wgen0092
//         ( INPUT crapcop.cdcooper,                 /*  par_cdcooper   */
//           INPUT 0,                                /*  par_cdagenci   */
//           INPUT 0,                                /*  par_nrdcaixa   */
//           INPUT par_cdoperad,                     /*  par_cdoperad   */
//           INPUT "CXONLINE",                       /*  par_nmdatela   */
//           INPUT 2,                                /*  par_idorigem   */
//           INPUT par_nrdconta,                     /*  par_nrdconta   */
//           INPUT 1,                                /*  par_idseqttl   */
//           INPUT YES,                              /*  par_flgerlog   */
//           INPUT crapdat.dtmvtocd,                 /*  par_dtmvtolt   */
//           INPUT "I",                              /*  par_cddopcao   */         
//           INPUT tt-convenios-codbarras.cdhistor,  /*  par_cdhistor   */
//           INPUT par_cdrefere,                     /*  par_cdrefere   */
//           INPUT 0,                                /*  par_cddddtel   */
//           INPUT crapdat.dtmvtocd,                 /*  par_dtiniatr   */
//           INPUT ?,                                /*  par_dtfimatr   */
//           INPUT ?,                                /*  par_dtultdeb   */
//           INPUT ?,                                /*  par_dtvencto   */
//           INPUT par_dshisext,                     /*  par_nmfatura   */
//           INPUT par_vlrmaxdb,                     /*  par_vlrmaxdb   */
//           INPUT STRING(tt-convenios-codbarras.flgcnvsi, "S/N"),
//           INPUT tt-convenios-codbarras.cdempcon,
//           INPUT tt-convenios-codbarras.cdsegmto,
//           INPUT "N",                              
//           INPUT "",                     
//           INPUT "",                     
//           INPUT "",                     
//           INPUT "",                     
//           INPUT "",                     
//          OUTPUT aux_nmfatret,                     
//          OUTPUT TABLE tt-erro).    
         
//     DELETE PROCEDURE h-b1wgen0092.

//     IF  RETURN-VALUE = "NOK"  THEN
//         DO:
//             FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
//             IF  AVAILABLE tt-erro  THEN
//                 ASSIGN i-cod-erro  = 0
//                        c-desc-erro = tt-erro.dscritic
//                        par_foco    = "13".
//             ELSE
//                 ASSIGN i-cod-erro  = 0
//                        c-desc-erro = "Problemas na BO 92"
//                        par_foco    = "13". 

//             RUN cria-erro (INPUT par_nmrescop,
//                            INPUT par_cdagenci,
//                            INPUT par_nrdcaixa,
//                            INPUT i-cod-erro,
//                            INPUT c-desc-erro,
//                            INPUT YES).

//             RETURN "NOK".
//         END.
//     ELSE
//         DO:
//             RUN elimina-erro (INPUT par_nmrescop,
//                               INPUT par_cdagenci,
//                               INPUT par_nrdcaixa).
        
//             ASSIGN i-cod-erro  = 0 
//                    c-desc-erro = "Autorização cadastrada com sucesso.".
        
//             RUN cria-erro (INPUT par_nmrescop,
//                            INPUT par_cdagenci,
//                            INPUT par_nrdcaixa,
//                            INPUT i-cod-erro,
//                            INPUT c-desc-erro,
//                            INPUT YES).
//         END.

//     RETURN "OK".

// END PROCEDURE.


/* .......................................................................... */
