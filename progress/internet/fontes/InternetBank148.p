/*.................................................................................................
   Programa: sistema/internet/fontes/InternetBank148.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jaison
   Data    : Marco/2016                        Ultima atualizacao: 
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)

   Objetivo  :

   Alteracoes: 
................................................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_tpoperac AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_idapurac AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.
 
DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR xml_req      AS LONGCHAR                                       NO-UNDO.

IF  par_tpoperac = 1 THEN DO: /* Buscar os periodos de apuracao */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_periodo_apuracao_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").
    CLOSE STORED-PROC pc_periodo_apuracao_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_periodo_apuracao_ib.pr_cdcritic
                          WHEN pc_periodo_apuracao_ib.pr_cdcritic <> ?
           aux_dscritic = pc_periodo_apuracao_ib.pr_dscritic
                          WHEN pc_periodo_apuracao_ib.pr_dscritic <> ?
           xml_req      = pc_periodo_apuracao_ib.pr_data_xml.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

END.
ELSE IF  par_tpoperac = 2 THEN DO: /* Buscar a apuracao */   

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_apuracao_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_idapurac,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_apuracao_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_apuracao_ib.pr_cdcritic
                          WHEN pc_apuracao_ib.pr_cdcritic <> ?
           aux_dscritic = pc_apuracao_ib.pr_dscritic
                          WHEN pc_apuracao_ib.pr_dscritic <> ?
           xml_req      = pc_apuracao_ib.pr_data_xml.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

END.
ELSE IF  par_tpoperac = 3 THEN DO: /* Buscar os indicadores */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_indicadores_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_idapurac,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_indicadores_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_indicadores_ib.pr_cdcritic
                          WHEN pc_indicadores_ib.pr_cdcritic <> ?
           aux_dscritic = pc_indicadores_ib.pr_dscritic
                          WHEN pc_indicadores_ib.pr_dscritic <> ?
           xml_req      = pc_indicadores_ib.pr_data_xml.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = xml_req.

RETURN "OK".
