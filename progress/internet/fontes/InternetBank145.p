/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank145.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lombardi
   Data    : Agosto/2015                        Ultima atualizacao: 06/08/2019
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  :
      
   Alteracoes:  06/08/2019 - Permitir inclusao de folha CTASAL apenas antes do horario
                             parametrisado na PAGFOL "Portabilidade (Pgto no dia):"
                             RITM0032122 - Lucas Ranghetti
..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdctemp AS   CHAR                                NO-UNDO.
DEF INPUT  PARAM par_nrcpfemp AS   CHAR                                NO-UNDO.
                                                                               
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM xml_nmprimtl AS CHAR                                  NO-UNDO.

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

DEF VAR aux_dsalerta AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
                      
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_valida_lancto_folha aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT INT(par_cdcooper),
                      INPUT INT(par_nrdctemp),
                      INPUT DECIMAL(REPLACE(par_nrcpfemp,"-","")),
                      INPUT ?,
                      INPUT ?,
                      OUTPUT "",
                      OUTPUT "",
                      OUTPUT "").

CLOSE STORED-PROC pc_valida_lancto_folha aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_dscritic = ""
           aux_dsalerta = ""
           aux_dsalerta = pc_valida_lancto_folha.pr_dsalerta WHEN pc_valida_lancto_folha.pr_dsalerta <> ?
           aux_dscritic = pc_valida_lancto_folha.pr_dscritic WHEN pc_valida_lancto_folha.pr_dscritic <> ?
           aux_nmprimtl = pc_valida_lancto_folha.pr_nmprimtl WHEN pc_valida_lancto_folha.pr_nmprimtl <> ?.
                                                                                                                
{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_dscritic <> "" THEN 
    DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>". 
        RETURN "NOK".
    END.
ELSE IF aux_dsalerta <> "" THEN
    DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dsalerta + "</dsmsgerr>". 
        RETURN "NOK".
    END.
    
    DO:
    ASSIGN xml_nmprimtl =  "<nmprimtl>" + aux_nmprimtl + "</nmprimtl>".
END.

RETURN "OK".



