/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank151.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vanessa Klein
   Data    : Agosto/2015                        Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  :
      
   Alteracoes:
..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM pr_cdcooper  LIKE crapcop.cdcooper                   NO-UNDO.
DEF INPUT  PARAM pr_nrdconta  LIKE crapass.nrdconta                   NO-UNDO.
DEF INPUT  PARAM pr_idtipfol  AS INT                                  NO-UNDO.
DEF INPUT  PARAM pr_lisrowid AS CHAR                                  NO-UNDO.
DEF INPUT  PARAM pr_iddspscp AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                 NO-UNDO.
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
RUN STORED-PROCEDURE pc_impressao_comprovante aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT INT(pr_cdcooper),
                      INPUT INT(pr_nrdconta),
                      INPUT INT(pr_idtipfol),                      
                      INPUT STRING(pr_lisrowid),
                      INPUT pr_iddspscp,
                      OUTPUT ?,
                      OUTPUT 0,
                      OUTPUT "").
                      
                     
CLOSE STORED-PROC pc_impressao_comprovante aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_impressao_comprovante.pr_cdcritic
                      WHEN pc_impressao_comprovante.pr_cdcritic <> ?
           aux_dscritic = pc_impressao_comprovante.pr_dscritic
                      WHEN pc_impressao_comprovante.pr_dscritic <> ?
           xml_req      = pc_impressao_comprovante.pr_retxml.                                                                                                 

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    RETURN "NOK".
END.


CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = xml_req.

RETURN "OK".



