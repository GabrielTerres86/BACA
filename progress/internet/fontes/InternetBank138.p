/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank138.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas Quisinski/CECRED
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
DEF INPUT  PARAM par_dsboleto AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
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

DEF VAR aux_contador AS INTE NO-UNDO.
DEF VAR aux_qtd_str  AS INTE NO-UNDO.
DEF VAR aux_tot_str  AS INTE NO-UNDO.
DEF VAR aux_str_min  AS INTE NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_carrega_parcelas_carne aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT par_cdcooper,
                       INPUT par_nrdconta,
                       INPUT par_dsboleto,
                       OUTPUT "",  /* XML com as parcelas */
                       OUTPUT 0,   /* cdcritic */
                       OUTPUT ""). /* dscritic */

CLOSE STORED-PROC pc_carrega_parcelas_carne aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

ASSIGN aux_dslinxml = ""
       aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_carrega_parcelas_carne.pr_cdcritic
                      WHEN pc_carrega_parcelas_carne.pr_cdcritic <> ?
       aux_dscritic = pc_carrega_parcelas_carne.pr_dscritic
                      WHEN pc_carrega_parcelas_carne.pr_dscritic <> ?
       xml_req      = pc_carrega_parcelas_carne.pr_tab_boleto
                      WHEN pc_carrega_parcelas_carne.pr_tab_boleto <> ?.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_cdcritic <> 0   OR
    aux_dscritic <> ""  THEN DO: 

    IF  aux_dscritic = "" THEN DO:
        FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                     NO-LOCK NO-ERROR.

        IF  AVAIL crapcri THEN
            ASSIGN aux_dscritic = crapcri.dscritic.
        ELSE
            ASSIGN aux_dscritic =  "Nao foi possivel verificar " +
                                   "as parcelas para reimprimir " +
                                   "o carne.".
    END.

    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

    RETURN "NOK".
END.

/* Dividir o xml de retorno a cada 30000 caracteres */
ASSIGN aux_qtd_str = 30000
       aux_tot_str = TRUNCATE(LENGTH(xml_req) / aux_qtd_str,0) + 1
       aux_str_min = 1.

REPEAT aux_contador = 1 TO aux_tot_str:
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = SUBSTR(xml_req,aux_str_min,aux_qtd_str).

    ASSIGN aux_str_min = aux_str_min + aux_qtd_str.
END.

RETURN "OK".

