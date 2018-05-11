/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank149.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jaison
   Data    : Agosto/2015                        Ultima atualizacao: 27/01/2016
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Efetuar geracao do relatorio dos pagamentos de folha (Marcos-Supero)
      
   Alteracoes: 27/01/2016 - Repassar o cpf do operador conectado na chamada
                            (Marcos-Supero)
                            
..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF INPUT  PARAM par_dtiniper AS   DATE                                NO-UNDO.
DEF INPUT  PARAM par_dtfimper AS   DATE                                NO-UNDO.
DEF INPUT  PARAM par_insituac AS   INTE                                NO-UNDO.
DEF INPUT  PARAM par_tpemissa AS   CHAR                                NO-UNDO.
DEF INPUT  PARAM par_nrctalfp LIKE craplfp.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_iddspscp AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM xml_nmarquiv AS CHAR                                  NO-UNDO.


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

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_dssrvarq AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdirarq AS CHAR                                           NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_gera_relatorio_ib aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT INTE(par_cdcooper),
                      INPUT DATE(par_dtmvtolt),
                      INPUT INTE(par_nrdconta), /* Conta logada */
                      INPUT par_nrcpfope,
                      INPUT INTE(par_nrctalfp), /* Conta filtro */
                      INPUT DATE(par_dtiniper),
                      INPUT DATE(par_dtfimper),
                      INPUT INTE(par_insituac),
                      INPUT par_tpemissa,
                      INPUT par_iddspscp,
                      OUTPUT "",
                      OUTPUT "",               
                      OUTPUT "",
                      OUTPUT "").

CLOSE STORED-PROC pc_gera_relatorio_ib aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_dscritic = ""
           aux_nmarquiv = ""
           aux_dssrvarq = ""
           aux_dsdirarq = "" 
           aux_dscritic = pc_gera_relatorio_ib.pr_dscritic WHEN pc_gera_relatorio_ib.pr_dscritic <> ?
           aux_nmarquiv = pc_gera_relatorio_ib.pr_nmarquiv WHEN pc_gera_relatorio_ib.pr_nmarquiv <> ?
           aux_dssrvarq = pc_gera_relatorio_ib.pr_dssrvarq WHEN pc_gera_relatorio_ib.pr_dssrvarq <> ? 
           aux_dsdirarq = pc_gera_relatorio_ib.pr_dsdirarq WHEN pc_gera_relatorio_ib.pr_dsdirarq <> ?.                          

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_dscritic <> "" THEN DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    RETURN "NOK".
END.

ASSIGN xml_nmarquiv =  "<nmarquiv>" + aux_nmarquiv + "</nmarquiv>" +
                       "<dssrvarq>" + aux_dssrvarq + "</dssrvarq>" +
                       "<dsdirarq>" + aux_dsdirarq + "</dsdirarq>".

RETURN "OK".
