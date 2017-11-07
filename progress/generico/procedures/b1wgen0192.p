/*..............................................................................
   
   Programa: sistema/generico/procedures/b1wgen0192.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Agosto/2014                       Ultima atualizacao: 01/11/2017
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Procedures referente ao Pagamento de Titulos por Arq (WEB)
      
   Alteracoes: 29/01/2015 - Correção de leitura de XML, estava ocorrendo
                            erro no carregamento da tela ATENDA (Jean Michel).
               
               01/11/2017 - Alteracoes referentes a melhoria 271.3 (Tiago)
..............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgen0192tt.i }
{ sistema/generico/includes/var_oracle.i }

/******************************************************************************/
 
PROCEDURE verif-aceite-conven:

    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                  NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                  NO-UNDO.
    DEF INPUT  PARAM par_nrconven AS INTE                                NO-UNDO.

    DEF OUTPUT PARAM par_flconven AS INTE                                NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                                NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                                NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-arquivos.

    /* Variaveis para o XML */
    DEF VAR xDoc          AS HANDLE                                     NO-UNDO.
    DEF VAR xRoot         AS HANDLE                                     NO-UNDO.
    DEF VAR xRoot2        AS HANDLE                                     NO-UNDO.
    DEF VAR xField        AS HANDLE                                     NO-UNDO.
    DEF VAR xText         AS HANDLE                                     NO-UNDO.
    DEF VAR aux_cont_raiz AS INTEGER                                    NO-UNDO.
    DEF VAR aux_cont_perf AS INTEGER                                    NO-UNDO.
    DEF VAR ponteiro_xml  AS MEMPTR                                     NO-UNDO.
    DEF VAR xml_req       AS LONGCHAR                                   NO-UNDO.

    DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
    DEF VAR aux_dsretorn AS CHAR                                        NO-UNDO.
    DEF VAR aux_nrdocmto AS DECI                                        NO-UNDO.

    /* Inicializando objetos para leitura do XML de PERFIL */
    CREATE X-DOCUMENT xDoc.
    CREATE X-NODEREF  xRoot.
    CREATE X-NODEREF  xRoot2.
    CREATE X-NODEREF  xField.
    CREATE X-NODEREF  xText.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_verif_aceite_conven aux_handproc = PROC-HANDLE
                         NO-ERROR (INPUT par_cdcooper,
                                   INPUT par_nrdconta,
                                   INPUT 1, /* par_nrconven - FIXO */
                                   OUTPUT "",
                                   OUTPUT "",
                                   OUTPUT 0,
                                   OUTPUT "").

    CLOSE STORED-PROC pc_verif_aceite_conven aux_statproc = PROC-STATUS
                      WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_verif_aceite_conven.pr_cdcritic
                          WHEN pc_verif_aceite_conven.pr_cdcritic <> ?
           aux_dscritic = pc_verif_aceite_conven.pr_dscritic
                          WHEN pc_verif_aceite_conven.pr_dscritic <> ?
           aux_dsretorn = pc_verif_aceite_conven.pr_vretorno
                          WHEN pc_verif_aceite_conven.pr_vretorno <> ?.

    IF  aux_dscritic <> "" THEN
        par_flconven = 0. /* FALSE */
    ELSE
        par_flconven = 1. /* TRUE  */

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dsretorn <> "OK" THEN DO:

        IF  aux_cdcritic <> 0   OR
            aux_dscritic <> ""  THEN DO:
                          
            ASSIGN par_cdcritic = aux_cdcritic
                   par_dscritic = aux_dscritic.
    
            IF  aux_dscritic = "" THEN DO:
                FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                     NO-LOCK NO-ERROR.
    
                IF  AVAIL crapcri THEN
                    ASSIGN par_dscritic = crapcri.dscritic.
                ELSE
                    ASSIGN par_dscritic =  "Nao foi possivel verificar " +
                                           "aceite do Pagto Lote.".
    
            END.
    
            RETURN "NOK".
    
        END.
    END.
   
    ASSIGN par_dscritic = aux_dscritic
           xml_req      = pc_verif_aceite_conven.pr_tab_cpt.
    
    /* Efetuar a leitura do XML*/
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1.
    PUT-STRING(ponteiro_xml,1) = xml_req.

    IF ponteiro_xml <> ? THEN
        DO:    
            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).
            
            DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:

                xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
        
                IF  xRoot2:SUBTYPE <> "ELEMENT" THEN
                    NEXT.
            
                IF xRoot2:NUM-CHILDREN > 0 THEN
                  CREATE tt-arquivos.

                DO  aux_cont_perf = 1 TO xRoot2:NUM-CHILDREN:
                    xRoot2:GET-CHILD(xField,aux_cont_perf).
        
                    IF  xField:SUBTYPE <> "ELEMENT" THEN
                        NEXT.
        
                    xField:GET-CHILD(xText,1).
        
                    ASSIGN tt-arquivos.nrconven = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nrconven".
                    ASSIGN tt-arquivos.dtdadesa = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtdadesa".
                    ASSIGN tt-arquivos.cdoperad = xText:NODE-VALUE       WHEN xField:NAME = "cdoperad".
                    ASSIGN tt-arquivos.flgativo = xText:NODE-VALUE       WHEN xField:NAME = "flgativo".
                    ASSIGN tt-arquivos.dsorigem = xText:NODE-VALUE       WHEN xField:NAME = "dsorigem".
                    ASSIGN tt-arquivos.flghomol = xText:NODE-VALUE       WHEN xField:NAME = "flghomol".
                    ASSIGN tt-arquivos.dtdhomol = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtdhomol".
                    ASSIGN tt-arquivos.idretorn = xText:NODE-VALUE       WHEN xField:NAME = "idretorn".
                    ASSIGN tt-arquivos.cdopehom = xText:NODE-VALUE       WHEN xField:NAME = "cdopehom".
                    ASSIGN tt-arquivos.dtaltera = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtaltera".
                    ASSIGN tt-arquivos.nrremret = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nrremret".
                    ASSIGN tt-arquivos.dsflgativo = xText:NODE-VALUE       WHEN xField:NAME = "dsflgativo".
                    ASSIGN tt-arquivos.dsflghomol = xText:NODE-VALUE       WHEN xField:NAME = "dsflghomol".
                    ASSIGN tt-arquivos.dsidretorn = xText:NODE-VALUE       WHEN xField:NAME = "dsidretorn".


                END.
            END.
        
            SET-SIZE(ponteiro_xml) = 0.
        
            DELETE OBJECT xDoc.
            DELETE OBJECT xRoot.
            DELETE OBJECT xRoot2.
            DELETE OBJECT xField.
            DELETE OBJECT xText.

        END.

    RETURN "OK".
    
END.
/******************************************************************************/

PROCEDURE efetua-aceite-cancel:

    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                  NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                  NO-UNDO.
    DEF INPUT  PARAM par_nrconven AS INTE                                NO-UNDO.
    DEF INPUT  PARAM par_tpdtermo AS INTE                                NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                                NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                                NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                                NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                                NO-UNDO.
    
    DEF VAR aux_cdcritic AS INTE                                         NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                         NO-UNDO.
    DEF VAR aux_dsretorn AS CHAR                                         NO-UNDO.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_efetua_aceite_cancel aux_handproc = PROC-HANDLE
                         NO-ERROR (INPUT par_cdcooper,
                                   INPUT par_nrdconta,
                                   INPUT par_nrconven,
                                   INPUT par_tpdtermo,
                                   INPUT par_dtmvtolt,
                                   INPUT par_cdoperad,
                                   OUTPUT 0,
                                   OUTPUT "").

    CLOSE STORED-PROC pc_efetua_aceite_cancel aux_statproc = PROC-STATUS
                      WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_efetua_aceite_cancel.pr_cdcritic
                          WHEN pc_efetua_aceite_cancel.pr_cdcritic <> ?
           aux_dscritic = pc_efetua_aceite_cancel.pr_dscritic
                          WHEN pc_efetua_aceite_cancel.pr_dscritic <> ?.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN DO:
    
        ASSIGN par_cdcritic = aux_cdcritic
               par_dscritic = aux_dscritic.
        
        IF  aux_dscritic = "" THEN DO:
            FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                            NO-LOCK NO-ERROR.
    
            IF  AVAIL crapcri THEN
                ASSIGN par_dscritic = crapcri.dscritic.
            ELSE
                ASSIGN par_dscritic =  "Nao foi possivel verificar " +
                                       "aceite do Pagto Lote.".
        END.
    
        RETURN "NOK".
    
    END.

    RETURN "OK".

END.
/******************************************************************************/

PROCEDURE busca-termo-servico:

    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
    DEF INPUT  PARAM par_nrconven LIKE crapass.nrdconta                    NO-UNDO.
    DEF INPUT  PARAM par_tpdtermo AS INT                                   NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                                  NO-UNDO.
    
    DEF OUTPUT PARAM xml_dsmsgerr  AS CHAR                                 NO-UNDO.
    DEF OUTPUT PARAM xml_operacao  AS CHAR                                 NO-UNDO.
    
    DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
    DEF VAR aux_dsretorn AS CHAR                                           NO-UNDO.
    DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
    DEF VAR aux_nrdocmto AS DEC                                            NO-UNDO.
    DEF VAR ret_flconven AS INTE                                           NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

     RUN STORED-PROCEDURE pc_busca_termo_servico aux_handproc = PROC-HANDLE NO-ERROR
                          (INPUT par_cdcooper,
                           INPUT par_nrdconta,
                           INPUT par_nrconven,
                           INPUT par_tpdtermo,
                           INPUT 5, /** idorigem */
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").

     CLOSE STORED-PROC pc_busca_termo_servico aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

     ASSIGN aux_dslinxml = ""
            aux_cdcritic = 0
            aux_dscritic = ""
            aux_cdcritic = pc_busca_termo_servico.pr_cdcritic
                           WHEN pc_busca_termo_servico.pr_cdcritic <> ?
            aux_dscritic = pc_busca_termo_servico.pr_dscritic
                           WHEN pc_busca_termo_servico.pr_dscritic <> ?
            xml_operacao = pc_busca_termo_servico.pr_dsdtermo
                           WHEN pc_busca_termo_servico.pr_dsdtermo <> ?.


    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN DO: 
    
        IF  aux_dscritic = "" THEN DO:
            FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                       NO-LOCK NO-ERROR.
    
            IF  AVAIL crapcri THEN
                ASSIGN aux_dscritic = crapcri.dscritic.
            ELSE
                ASSIGN aux_dscritic =  "Nao foi possivel verificar " +
                                       "aceite do Pagto Lote.".
        END.
    
        ASSIGN xml_dsmsgerr = aux_dscritic.  
    
        RETURN "NOK".

    END.

    RETURN "OK".

END PROCEDURE.
