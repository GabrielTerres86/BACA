/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank150.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vanessa Klein
   Data    : Agosto/2015                        Ultima atualizacao: 27/01/2016
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Efetuar a gravacao dos comprovantes salariais carregados no IB
      
   Alteracoes: 27/01/2016 - Repassar o cpf do operador conectado na chamada
                            (Marcos-Supero)
   
..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM pr_cdcooper  LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM pr_cdempres  LIKE crapem.cdempres                     NO-UNDO.
DEF INPUT  PARAM pr_nrcpfope  LIKE crapopi.nrcpfope                    NO-UNDO.
DEF INPUT  PARAM pr_nrseqpag AS INT                                    NO-UNDO.
DEF INPUT  PARAM pr_dsarquiv AS CHAR                                   NO-UNDO.
DEF INPUT  PARAM pr_dtrefere AS CHAR                                   NO-UNDO.

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
message "teste antes > " + STRING(pr_dtrefere).
RUN STORED-PROCEDURE pc_insere_compr_folha aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT INT(pr_cdcooper),
                      INPUT INT(pr_cdempres),
                      INPUT pr_nrcpfope,
                      INPUT INT(pr_nrseqpag),
                      INPUT DATE(pr_dtrefere),
                      INPUT STRING(pr_dsarquiv),
                      OUTPUT 0,
                      OUTPUT "").                      
                     
CLOSE STORED-PROC pc_insere_compr_folha aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_insere_compr_folha.pr_cdcritic WHEN pc_insere_compr_folha.pr_cdcritic <> ?
           aux_dscritic = pc_insere_compr_folha.pr_dscritic WHEN pc_insere_compr_folha.pr_dscritic <> ?.
                                                                                                             
{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    RETURN "NOK".
END.
message "teste depois".

RETURN "OK".



