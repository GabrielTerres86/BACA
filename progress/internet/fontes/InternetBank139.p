
/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank139.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Renato Darosci/SUPERO
   Data    : Junho/2015                        Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Retorna os boletos que podem ser reimpressos em formato de carne
      
   Alteracoes:
..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_tpdaacao AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM par_flgpgtib AS INTE                                  NO-UNDO.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

/* Variaveis para o XML */
DEF VAR xDoc          AS HANDLE                                        NO-UNDO.
DEF VAR xRoot         AS HANDLE                                        NO-UNDO.
DEF VAR xRoot2        AS HANDLE                                        NO-UNDO.
DEF VAR xField        AS HANDLE                                        NO-UNDO.
DEF VAR xText         AS HANDLE                                        NO-UNDO.
DEF VAR aux_cont_raiz AS INTEGER                                       NO-UNDO.
DEF VAR aux_cont_perf AS INTEGER                                       NO-UNDO.
DEF VAR ponteiro_xml  AS MEMPTR                                        NO-UNDO.
DEF VAR aux_flgpgtib  AS INTE                                          NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

/* Se a ação a ser executada for igual a 1 */
IF (par_tpdaacao = 1) THEN
DO:
    RUN STORED-PROCEDURE pc_busca_flgpgtib aux_handproc = PROC-HANDLE NO-ERROR
                          (INPUT par_cdcooper,
                           INPUT par_nrdconta,
                           OUTPUT 0,
                           OUTPUT 0,   /* cdcritic */
                           OUTPUT ""). /* dscritic */

    CLOSE STORED-PROC pc_busca_flgpgtib aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_busca_flgpgtib.pr_cdcritic   WHEN pc_busca_flgpgtib.pr_cdcritic <> ?
           aux_dscritic = pc_busca_flgpgtib.pr_dscritic   WHEN pc_busca_flgpgtib.pr_dscritic <> ?
           aux_flgpgtib = pc_busca_flgpgtib.pr_flgpgtib   WHEN pc_busca_flgpgtib.pr_flgpgtib <> ?. 
    
    ASSIGN par_flgpgtib = aux_flgpgtib.
END.
ELSE
DO:
    RUN STORED-PROCEDURE pc_envia_email_interesse aux_handproc = PROC-HANDLE NO-ERROR
                          (INPUT par_cdcooper,
                           INPUT par_nrdconta,
                           OUTPUT 0,   /* cdcritic */
                           OUTPUT ""). /* dscritic */

    CLOSE STORED-PROC pc_envia_email_interesse aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_envia_email_interesse.pr_cdcritic   WHEN pc_envia_email_interesse.pr_cdcritic <> ?
           aux_dscritic = pc_envia_email_interesse.pr_dscritic   WHEN pc_envia_email_interesse.pr_dscritic <> ?. 
END.


{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_cdcritic <> 0   OR
    aux_dscritic <> ""  THEN DO: 

    IF  aux_dscritic = "" THEN DO:
        FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                     NO-LOCK NO-ERROR.

        IF  AVAIL crapcri THEN
            ASSIGN aux_dscritic = crapcri.dscritic.
        ELSE
            ASSIGN aux_dscritic =  "Nao foi possivel realizar a operação".
    END.

    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

    RETURN "NOK".
END.

RETURN "OK".

