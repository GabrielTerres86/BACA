/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank178.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lombardi
   Data    : Setembro/2016                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Resumo de cheques em custodia
   
   Alteracoes: 
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_oracle.i }
 
DEF VAR aux_dscritic AS CHAR                         NO-UNDO.
DEF VAR xml_req      AS LONGCHAR                     NO-UNDO.

DEF  INPUT PARAM par_operacao AS INT                 NO-UNDO.
DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper  NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta  NO-UNDO.
DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope  NO-UNDO.
DEF  INPUT PARAM par_dtiniper AS DATE                NO-UNDO.
DEF  INPUT PARAM par_dtfimper AS DATE                NO-UNDO.
DEF  INPUT PARAM par_insitbdc AS INT                 NO-UNDO.
DEF  INPUT PARAM par_nriniseq AS INT                 NO-UNDO.
DEF  INPUT PARAM par_nrregist AS INT                 NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INT                 NO-UNDO.
DEF  INPUT PARAM par_nrctrlim AS INT                 NO-UNDO.
DEF  INPUT PARAM par_nrborder AS INT                 NO-UNDO.
DEF  INPUT PARAM par_dtlibera AS CHAR                NO-UNDO.
DEF  INPUT PARAM par_dtdcaptu AS CHAR                NO-UNDO.
DEF  INPUT PARAM par_vlcheque AS CHAR                NO-UNDO.
DEF  INPUT PARAM par_dtcustod AS CHAR                NO-UNDO.
DEF  INPUT PARAM par_intipchq AS CHAR                NO-UNDO.
DEF  INPUT PARAM par_dsdocmc7 AS CHAR                NO-UNDO.
DEF  INPUT PARAM par_nrremret AS CHAR                NO-UNDO.
DEF  INPUT PARAM par_iddspscp AS INTE                NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

IF par_operacao = 1 THEN
  DO:

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     
    RUN STORED-PROCEDURE pc_lista_borderos_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_dtiniper
                         ,INPUT par_dtfimper
                         ,INPUT par_insitbdc
                         ,OUTPUT ""
                         ,OUTPUT "").   

    CLOSE STORED-PROC pc_lista_borderos_ib aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_lista_borderos_ib.pr_dscritic 
                          WHEN pc_lista_borderos_ib.pr_dscritic <> ?
           xml_req      = pc_lista_borderos_ib.pr_retxml.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.
  END.
  
ELSE IF par_operacao = 2 THEN
  DO:

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     
    RUN STORED-PROCEDURE pc_lista_detalhe_bord_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_nrborder
                         ,INPUT par_nriniseq
                         ,INPUT par_nrregist
                         ,OUTPUT ""
                         ,OUTPUT "").
 
    CLOSE STORED-PROC pc_lista_detalhe_bord_ib aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_lista_detalhe_bord_ib.pr_dscritic 
                          WHEN pc_lista_detalhe_bord_ib.pr_dscritic <> ?
           xml_req      = pc_lista_detalhe_bord_ib.pr_retxml.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
    IF  aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
 
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.

  END.

ELSE IF par_operacao = 3 THEN
  DO:

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     
    RUN STORED-PROCEDURE pc_lista_cheques_cust_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_nriniseq
                         ,INPUT par_nrregist
                         ,OUTPUT ""
                         ,OUTPUT "").   

    CLOSE STORED-PROC pc_lista_cheques_cust_ib aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_lista_cheques_cust_ib.pr_dscritic 
                          WHEN pc_lista_cheques_cust_ib.pr_dscritic <> ?
           xml_req      = pc_lista_cheques_cust_ib.pr_retxml.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.
  END.
  
ELSE IF par_operacao = 4 THEN
  DO:

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_imprime_bordero_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_idseqttl
                         ,INPUT par_nrctrlim
                         ,INPUT par_nrborder
                         ,INPUT par_iddspscp
                         ,OUTPUT ""
                         ,OUTPUT "").   

    CLOSE STORED-PROC pc_imprime_bordero_ib aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_imprime_bordero_ib.pr_dscritic 
                          WHEN pc_imprime_bordero_ib.pr_dscritic <> ?
           xml_req      = pc_imprime_bordero_ib.pr_retxml.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.
  END.

ELSE IF par_operacao = 5 THEN
  DO:
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     
    RUN STORED-PROCEDURE pc_verifica_ass_multi_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_idseqttl
                         ,INPUT par_nrcpfope
                         ,INPUT par_dtlibera
                         ,INPUT par_dtdcaptu
                         ,INPUT par_vlcheque
                         ,INPUT par_dtcustod
                         ,INPUT par_intipchq
                         ,INPUT par_dsdocmc7
                         ,INPUT par_nrremret
                         ,0 
                         ,OUTPUT ""
                         ,OUTPUT "").
 
    CLOSE STORED-PROC pc_verifica_ass_multi_ib aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_verifica_ass_multi_ib.pr_dscritic 
                          WHEN pc_verifica_ass_multi_ib.pr_dscritic <> ?
           xml_req      = pc_verifica_ass_multi_ib.pr_retxml.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
    IF  aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.
  END.
  
ELSE IF par_operacao = 6 THEN
  DO:
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     
    RUN STORED-PROCEDURE pc_verifica_emitentes_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_dsdocmc7
                         ,OUTPUT ""
                         ,OUTPUT "").
 
    CLOSE STORED-PROC pc_verifica_emitentes_ib aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_verifica_emitentes_ib.pr_dscritic 
                          WHEN pc_verifica_emitentes_ib.pr_dscritic <> ?
           xml_req      = pc_verifica_emitentes_ib.pr_retxml.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
    IF  aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.
  END.

ELSE IF par_operacao = 7 THEN
  DO:
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     
    RUN STORED-PROCEDURE pc_excluir_bordero_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_nrborder
                         ,OUTPUT ""
                         ,OUTPUT "").
 
    CLOSE STORED-PROC pc_excluir_bordero_ib aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_excluir_bordero_ib.pr_dscritic 
                          WHEN pc_excluir_bordero_ib.pr_dscritic <> ?
           xml_req      = pc_excluir_bordero_ib.pr_retxml.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
    IF  aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.
  END.

/*............................................................................*/
