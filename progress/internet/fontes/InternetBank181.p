/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank181.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lombardi
   Data    : Fevereiro/2016                        Ultima atualizacao: 28/03/2018

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Mantem recarga de celular
   
   Alteracoes: 28/03/2018 - Ajuste para que o caixa eletronico possa utilizar o mesmo
                            servico da conta online (PRJ 363 - Douglas Quisinski)
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_oracle.i }
 
DEF VAR aux_dscritic AS CHAR                         NO-UNDO.
DEF VAR xml_req      AS LONGCHAR                     NO-UNDO.
DEF VAR xml_dslancto AS CHAR                         NO-UNDO.
DEF VAR aux_dsxmlout AS CHAR                         NO-UNDO.
DEF VAR aux_msgretor AS CHAR                         NO-UNDO.

DEF  INPUT PARAM par_operacao AS INT                   NO-UNDO.
DEF  INPUT PARAM par_cdcooper    LIKE crapass.cdcooper NO-UNDO.
DEF  INPUT PARAM par_nrdconta    LIKE crapass.nrdconta NO-UNDO.
DEF  INPUT PARAM par_cdoperadora AS INT                NO-UNDO.
DEF  INPUT PARAM par_cdproduto   AS INT                NO-UNDO.
DEF  INPUT PARAM par_nrddd       AS INT                NO-UNDO.
DEF  INPUT PARAM par_nrcelular   AS INT                NO-UNDO.
DEF  INPUT PARAM par_nmcontato   AS CHAR               NO-UNDO.
DEF  INPUT PARAM par_flgfavori   AS INT                NO-UNDO.
DEF  INPUT PARAM par_idseqttl    AS INT                NO-UNDO.
DEF  INPUT PARAM par_nrcpfope    LIKE crapopi.nrcpfope NO-UNDO.
DEF  INPUT PARAM par_vlrecarga   AS DECIMAL            NO-UNDO.
DEF  INPUT PARAM aux_cdopcaodt   AS INT                NO-UNDO.
DEF  INPUT PARAM par_dtrecarga   AS DATE               NO-UNDO.
DEF  INPUT PARAM par_qtmesagd    AS INT                NO-UNDO.
DEF  INPUT PARAM par_flmobile    AS LOGI               NO-UNDO.

/*  Projeto 363 - Novo ATM  */ 
DEF  INPUT PARAM par_cdorigem    AS INT                NO-UNDO.
DEF  INPUT PARAM par_cdagenci    AS INT                NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa    AS INT                NO-UNDO.
DEF  INPUT PARAM par_nmprogra    AS CHAR               NO-UNDO.
DEF  INPUT PARAM par_cdcoptfn    AS INT                NO-UNDO.
DEF  INPUT PARAM par_cdagetfn    AS INT                NO-UNDO.
DEF  INPUT PARAM par_nrterfin    AS INT                NO-UNDO.
DEF  INPUT PARAM par_nrcartao    AS DECI               NO-UNDO.


DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

IF par_operacao = 1 THEN
  DO:

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     
    RUN STORED-PROCEDURE pc_obtem_favoritos_recarga aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,OUTPUT ?
                         ,OUTPUT 0
                         ,OUTPUT "").

    CLOSE STORED-PROC pc_obtem_favoritos_recarga aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dsxmlout = ""
           aux_dscritic = ""
           aux_dscritic = pc_obtem_favoritos_recarga.pr_dscritic 
                          WHEN pc_obtem_favoritos_recarga.pr_dscritic <> ?
           aux_dsxmlout = pc_obtem_favoritos_recarga.pr_telfavor
                        WHEN pc_obtem_favoritos_recarga.pr_telfavor <> ?.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    xml_req = aux_dsxmlout.

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
    
    RUN STORED-PROCEDURE pc_obtem_operadoras_recarga aux_handproc = PROC-HANDLE NO-ERROR
                         (OUTPUT ?
                         ,OUTPUT 0
                         ,OUTPUT "").

    CLOSE STORED-PROC pc_obtem_operadoras_recarga aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dsxmlout = ""
           aux_dscritic = ""
           aux_dscritic = pc_obtem_operadoras_recarga.pr_dscritic 
                          WHEN pc_obtem_operadoras_recarga.pr_dscritic <> ?
           aux_dsxmlout = pc_obtem_operadoras_recarga.pr_clobxml
                        WHEN pc_obtem_operadoras_recarga.pr_clobxml <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    xml_req = aux_dsxmlout.

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
    
    RUN STORED-PROCEDURE pc_obtem_valores_recarga aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdoperadora
                         ,INPUT par_cdproduto  
                         ,OUTPUT ?
                         ,OUTPUT 0
                         ,OUTPUT "").

    CLOSE STORED-PROC pc_obtem_valores_recarga aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dsxmlout = ""
           aux_dscritic = ""
           aux_dscritic = pc_obtem_valores_recarga.pr_dscritic 
                          WHEN pc_obtem_valores_recarga.pr_dscritic <> ?
           aux_dsxmlout = pc_obtem_valores_recarga.pr_clobxml
                        WHEN pc_obtem_valores_recarga.pr_clobxml <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    xml_req = aux_dsxmlout.

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
    
    RUN STORED-PROCEDURE pc_excluir_favorito aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_nrddd
                         ,INPUT par_nrcelular
                         ,OUTPUT 0
                         ,OUTPUT "").

    CLOSE STORED-PROC pc_excluir_favorito aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dsxmlout = ""
           aux_dscritic = ""
           aux_dscritic = pc_excluir_favorito.pr_dscritic 
                          WHEN pc_excluir_favorito.pr_dscritic <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

  END.


ELSE IF par_operacao = 5 THEN
  DO:

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_cadastra_favorito aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_nrddd
                         ,INPUT par_nrcelular
						 ,INPUT par_nmcontato
                         ,OUTPUT 0
                         ,OUTPUT "").

    CLOSE STORED-PROC pc_cadastra_favorito aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dsxmlout = ""
           aux_dscritic = ""
           aux_dscritic = pc_cadastra_favorito.pr_dscritic 
                          WHEN pc_cadastra_favorito.pr_dscritic <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

  END.

ELSE IF par_operacao = 6 THEN
  DO:

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_confirma_recarga_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
                         ,INPUT par_nrdconta
                         ,INPUT par_idseqttl
                         ,INPUT par_nrcpfope
                         ,INPUT par_nrddd
                         ,INPUT par_nrcelular
                         ,INPUT par_nmcontato
                         ,INPUT par_flgfavori
                         ,INPUT par_vlrecarga
                         ,INPUT par_cdoperadora
                         ,INPUT par_cdproduto
                         ,INPUT aux_cdopcaodt
                         ,INPUT par_dtrecarga
                         ,INPUT par_qtmesagd
                         ,INPUT 0
                         ,INPUT 0
						 ,INPUT INT(par_flmobile)
                         /* Projeto 363 - Novo ATM  */
                         ,INPUT par_cdorigem 
                         ,INPUT par_cdagenci
                         ,INPUT par_nrdcaixa
                         ,INPUT par_nmprogra
                         ,INPUT par_cdcoptfn
                         ,INPUT par_cdagetfn
                         ,INPUT par_nrterfin
                         ,INPUT par_nrcartao
                         ,OUTPUT ""  /* Lista com todos os agendamentos */
                         /* Projeto 363 - Novo ATM */
                         ,OUTPUT ""
                         ,OUTPUT 0
                         ,OUTPUT "").
                         

    CLOSE STORED-PROC pc_confirma_recarga_ib aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN xml_dslancto = "" 
           aux_dscritic = ""
           aux_msgretor = ""
           xml_dslancto = pc_confirma_recarga_ib.pr_xml_idlancto
                          WHEN pc_confirma_recarga_ib.pr_xml_idlancto <> ?
           aux_dscritic = pc_confirma_recarga_ib.pr_dscritic 
                          WHEN pc_confirma_recarga_ib.pr_dscritic <> ?
           aux_msgretor = pc_confirma_recarga_ib.pr_msg_retor 
                          WHEN pc_confirma_recarga_ib.pr_msg_retor <> ?.
    
    xml_req = STRING(aux_msgretor).
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.
  
    /* Projeto 363 - Novo ATM */ 
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_dslancto.
  
  END.
ELSE IF par_operacao = 7 THEN
  DO:

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_valida_recarga aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper
						 ,INPUT par_nrdconta
						 ,INPUT par_idseqttl
						 ,INPUT par_nrcpfope
						 ,INPUT par_nrddd
						 ,INPUT par_nrcelular
						 ,INPUT par_vlrecarga
						 ,INPUT par_dtrecarga
						 ,INPUT par_qtmesagd 
						 ,INPUT aux_cdopcaodt 
                         /* Projeto 363 - Novo ATM */ 
                         ,INPUT par_cdorigem
                         ,INPUT par_cdagenci
                         ,INPUT par_nrdcaixa
                         ,INPUT par_nmprogra
                         /* Projeto 363 - Novo ATM */
						 ,OUTPUT ""
						 ,OUTPUT 0
						 ,OUTPUT "").
    
    CLOSE STORED-PROC pc_valida_recarga aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dsxmlout = ""
           aux_dscritic = ""
           aux_dscritic = pc_valida_recarga.pr_dscritic 
                          WHEN pc_valida_recarga.pr_dscritic <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
END.

/*............................................................................*/