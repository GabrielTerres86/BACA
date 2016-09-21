/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank167.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : Março/2016.                       Ultima atualizacao: 
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Inserir novo pacote de tarifa do cooperado
   
   Alteracoes: 

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }
                                                                         
DEF INPUT PARAM par_cdcooper AS INTE                                    NO-UNDO.
DEF INPUT PARAM par_nrdconta AS INTE                                    NO-UNDO.
DEF INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope						NO-UNDO.
DEF INPUT PARAM par_idseqttl AS INTE									NO-UNDO.
DEF INPUT PARAM par_cdpacote AS INTE									NO-UNDO.
DEF INPUT PARAM par_dtinivig AS CHAR									NO-UNDO.
DEF INPUT PARAM par_diadebit AS INTE									NO-UNDO.
DEF INPUT PARAM par_vlpacote AS DECI                                    NO-UNDO.
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

RUN STORED-PROCEDURE pc_insere_pacote_conta
    aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT par_cdcooper,
                      INPUT par_nrdconta,
 					  INPUT par_nrcpfope,
					  INPUT par_idseqttl,
					  INPUT par_cdpacote,
					  INPUT date(par_dtinivig),
					  INPUT par_diadebit,
                      INPUT par_vlpacote,
					  INPUT 0,
					  INPUT 2,
					  INPUT 0,
                      OUTPUT "",
                      OUTPUT 0,
                      OUTPUT "").

CLOSE STORED-PROC pc_insere_pacote_conta 
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

ASSIGN aux_dsxmlout = ""
       aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_insere_pacote_conta.pr_cdcritic
                      WHEN pc_insere_pacote_conta.pr_cdcritic <> ?
       aux_dscritic = pc_insere_pacote_conta.pr_dscritic
                      WHEN pc_insere_pacote_conta.pr_dscritic <> ?
       aux_dsxmlout = pc_insere_pacote_conta.pr_clobxmlc
                      WHEN pc_insere_pacote_conta.pr_clobxmlc <> ?.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_cdcritic <> 0   OR
    aux_dscritic <> ""  THEN DO: 

    IF  aux_dscritic = "" THEN DO:
        FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                   NO-LOCK NO-ERROR.

        IF  AVAIL crapcri THEN
            ASSIGN aux_dscritic = crapcri.dscritic.
        ELSE
            ASSIGN aux_dscritic =  "Nao foi possivel incluir o pacote".
    END.

    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                       "</dsmsgerr>".  
    
    RETURN "NOK".
    
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = aux_dsxmlout.
