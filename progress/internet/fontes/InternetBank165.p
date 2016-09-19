/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank165.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : Novembro/2015.                       Ultima atualizacao: 
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Buscar os pacotes de tarifa do cooperador
   
   Alteracoes: 

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }
                                                                         
DEF INPUT PARAM par_cdcooper AS INTE                                    NO-UNDO.
DEF INPUT PARAM par_nrdconta AS INTE                                    NO-UNDO.
DEF INPUT PARAM par_inpessoa AS INTE                                    NO-UNDO.
DEF INPUT PARAM par_inconsul AS INTE                                    NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                   NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dsxmlout  AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic  AS INT                                            NO-UNDO.
DEF VAR aux_dscritic  AS CHAR                                           NO-UNDO.

/* Variaveis para o XML */
DEF VAR xDoc          AS HANDLE                                         NO-UNDO.
DEF VAR xRoot         AS HANDLE                                         NO-UNDO.
DEF VAR xRoot2        AS HANDLE                                         NO-UNDO.
DEF VAR xField        AS HANDLE                                         NO-UNDO.
DEF VAR xText         AS HANDLE                                         NO-UNDO.
DEF VAR aux_cont_raiz AS INTEGER                                        NO-UNDO.
DEF VAR aux_cont_perf AS INTEGER                                        NO-UNDO.
DEF VAR ponteiro_xml  AS MEMPTR                                         NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_busca_pacote_tarifas 
    aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_inpessoa,
                      INPUT par_inconsul,
                      OUTPUT "",
                      OUTPUT 0,
                      OUTPUT "").

CLOSE STORED-PROC pc_busca_pacote_tarifas 
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

ASSIGN aux_dsxmlout = ""
       aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_busca_pacote_tarifas.pr_cdcritic
                      WHEN pc_busca_pacote_tarifas.pr_cdcritic <> ?
       aux_dscritic = pc_busca_pacote_tarifas.pr_dscritic
                      WHEN pc_busca_pacote_tarifas.pr_dscritic <> ?
       aux_dsxmlout = pc_busca_pacote_tarifas.pr_clobxmlc
                      WHEN pc_busca_pacote_tarifas.pr_clobxmlc <> ?.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_cdcritic <> 0   OR
    aux_dscritic <> ""  THEN DO: 

    IF  aux_dscritic = "" THEN DO:
        FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                   NO-LOCK NO-ERROR.

        IF  AVAIL crapcri THEN
            ASSIGN aux_dscritic = crapcri.dscritic.
        ELSE
            ASSIGN aux_dscritic =  "Nao foi possivel apresentar o demonstrativo".
    END.

    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                       "</dsmsgerr>".  
    
    RETURN "NOK".
    
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = aux_dsxmlout.
