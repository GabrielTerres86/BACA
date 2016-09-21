
/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank147.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lombardi
   Data    : Agosto/2015                        Ultima atualizacao: 27/01/2016
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Efetuar exclusao dos empregados de folha no IB 
      
   Alteracoes:  27/01/2016 - Repassar o cpf do operador conectado na chamada
                            (Marcos-Supero)
..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM par_nrdctemp AS   CHAR                                NO-UNDO.
DEF INPUT  PARAM par_nrcpfemp AS   CHAR                                NO-UNDO.
DEF INPUT  PARAM par_cdempres AS   CHAR                                NO-UNDO.
DEF INPUT  PARAM par_idtpcont AS   CHAR                                NO-UNDO.
                                                                               
DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

/* Variaveis para o XML */
DEF VAR xDoc          AS HANDLE                                        NO-UNDO.
DEF VAR xRoot         AS HANDLE                                        NO-UNDO.
DEF VAR xRoot2        AS HANDLE                                        NO-UNDO.
DEF VAR xField        AS HANDLE                                        NO-UNDO.
DEF VAR xText         AS HANDLE                                        NO-UNDO.
DEF VAR aux_cont_raiz AS INTEGER                                       NO-UNDO.
DEF VAR aux_cont_perf AS INTEGER                                       NO-UNDO.
DEF VAR ponteiro_xml  AS MEMPTR                                        NO-UNDO.
DEF VAR xml_req       AS LONGCHAR                                      NO-UNDO.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
                      
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_exclui_empregado_ib aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT INT(par_cdcooper),
                      INPUT INT(par_nrdconta),
                      INPUT par_nrcpfope,
                      INPUT INT(par_nrdctemp),
                      INPUT DECIMAL(REPLACE(par_nrcpfemp,"-","")),
                      INPUT INT(par_cdempres),
                      INPUT par_idtpcont,
                      OUTPUT 0,
                      OUTPUT "").

CLOSE STORED-PROC pc_exclui_empregado_ib aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_exclui_empregado_ib.pr_cdcritic WHEN pc_exclui_empregado_ib.pr_cdcritic <> ?
           aux_dscritic = pc_exclui_empregado_ib.pr_dscritic WHEN pc_exclui_empregado_ib.pr_dscritic <> ?.
                                                                                                                
{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    RETURN "NOK".
END.

RETURN "OK".


