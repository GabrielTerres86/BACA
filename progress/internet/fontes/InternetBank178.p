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
DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper  NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta  NO-UNDO.
DEF  INPUT PARAM par_dtiniper AS DATE                NO-UNDO.
DEF  INPUT PARAM par_dtfimper AS DATE                NO-UNDO.
DEF  INPUT PARAM par_insithcc AS INT                 NO-UNDO.
DEF  INPUT PARAM par_nrconven AS INT                 NO-UNDO.
DEF  INPUT PARAM par_intipmvt AS INT                 NO-UNDO.
DEF  INPUT PARAM par_nrremret AS INT                 NO-UNDO.
DEF  INPUT PARAM par_nrseqarq AS INT                 NO-UNDO.
DEF  INPUT PARAM par_dscheque AS CHAR                NO-UNDO.
DEF  INPUT PARAM par_dsemiten AS CHAR                NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INT                 NO-UNDO.
DEF  INPUT PARAM par_dtlibera AS CHAR                NO-UNDO.
DEF  INPUT PARAM par_dtdcaptu AS CHAR                NO-UNDO.
DEF  INPUT PARAM par_vlcheque AS CHAR                NO-UNDO.
DEF  INPUT PARAM par_dsdocmc7 AS CHAR                NO-UNDO.
DEF  INPUT PARAM par_nriniseq AS INT                 NO-UNDO.
DEF  INPUT PARAM par_nrregist AS INT                 NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

IF par_operacao = 1 THEN
  DO:

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     
    RUN STORED-PROCEDURE pc_lista_remessa_custodia aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_dtiniper
                         ,INPUT par_dtfimper
                         ,INPUT par_insithcc
                         ,OUTPUT ""
                         ,OUTPUT "").   

    CLOSE STORED-PROC pc_lista_remessa_custodia aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_lista_remessa_custodia.pr_dscritic 
                          WHEN pc_lista_remessa_custodia.pr_dscritic <> ?
           xml_req      = pc_lista_remessa_custodia.pr_retxml.

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
     
    RUN STORED-PROCEDURE pc_lista_detalhe_custodia aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_nrconven
                         ,INPUT par_nrremret
                         ,INPUT par_nriniseq
                         ,INPUT par_nrregist
                         ,OUTPUT ""
                         ,OUTPUT "").
 
    CLOSE STORED-PROC pc_lista_detalhe_custodia aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_lista_detalhe_custodia.pr_dscritic 
                          WHEN pc_lista_detalhe_custodia.pr_dscritic <> ?
           xml_req      = pc_lista_detalhe_custodia.pr_retxml.
 
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
     
    RUN STORED-PROCEDURE pc_excluir_cheque_remessa aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_nrconven
                         ,INPUT par_intipmvt
                         ,INPUT par_nrremret
                         ,INPUT par_nrseqarq
                         ,OUTPUT ""
                         ,OUTPUT "").
 
    CLOSE STORED-PROC pc_excluir_cheque_remessa aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_excluir_cheque_remessa.pr_dscritic 
                          WHEN pc_excluir_cheque_remessa.pr_dscritic <> ?
           xml_req      = pc_excluir_cheque_remessa.pr_retxml.
 
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
     
    RUN STORED-PROCEDURE pc_valida_custodia aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_dtlibera
                         ,INPUT par_dtdcaptu
                         ,INPUT par_vlcheque
                         ,INPUT par_dsdocmc7
                         ,OUTPUT ""
                         ,OUTPUT "").
 
    CLOSE STORED-PROC pc_valida_custodia aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_valida_custodia.pr_dscritic 
                          WHEN pc_valida_custodia.pr_dscritic <> ?
           xml_req      = pc_valida_custodia.pr_retxml.
 
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
     
    RUN STORED-PROCEDURE pc_cadastra_emitentes aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_dscheque
                         ,OUTPUT ""
                         ,OUTPUT "").
 
    CLOSE STORED-PROC pc_cadastra_emitentes aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_cadastra_emitentes.pr_dscritic 
                          WHEN pc_cadastra_emitentes.pr_dscritic <> ?
           xml_req      = pc_cadastra_emitentes.pr_retxml.
 
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
     
    RUN STORED-PROCEDURE pc_custodia_cheque aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_idseqttl
                         ,INPUT par_dtlibera
                         ,INPUT par_dtdcaptu
                         ,INPUT par_vlcheque
                         ,INPUT par_dsdocmc7
                         ,OUTPUT ""
                         ,OUTPUT "").
 
    CLOSE STORED-PROC pc_custodia_cheque aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_custodia_cheque.pr_dscritic 
                          WHEN pc_custodia_cheque.pr_dscritic <> ?
           xml_req      = pc_custodia_cheque.pr_retxml.
 
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
     
    RUN STORED-PROCEDURE pc_excluir_remessa aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_nrconven
                         ,INPUT par_intipmvt
                         ,INPUT par_nrremret
                         ,OUTPUT ""
                         ,OUTPUT "").
 
    CLOSE STORED-PROC pc_excluir_remessa aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_excluir_remessa.pr_dscritic 
                          WHEN pc_excluir_remessa.pr_dscritic <> ?
           xml_req      = pc_excluir_remessa.pr_retxml.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
    IF  aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.
  END.
  
ELSE IF par_operacao = 8 THEN
  DO:
    
    FIND crapprm WHERE crapprm.nmsistem = "CRED"
                   AND crapprm.cdcooper = 0 /* Serve pra todas as Cooperativas */
                   AND crapprm.cdacesso = "QTD_CHQ_REM_IB" NO-LOCK NO-ERROR.
    
    IF NOT AVAIL crapprm THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>Nao foi possível encontrar a quantidade de cheques possíveis por remessa.</dsmsgerr>".
        RETURN "NOK".
    END.
    
    ASSIGN xml_req = "<root>" + crapprm.dsvlrprm + "</root>".
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.
  END.
  
/*............................................................................*/
