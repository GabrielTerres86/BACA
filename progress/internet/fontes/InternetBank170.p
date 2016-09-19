/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank170.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : Abril/2016.                       Ultima atualizacao: 
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Buscar dados do termo de adesao do pacote de tarifas
   
   Alteracoes: 

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }
                                                                         
DEF INPUT PARAM par_cdcooper AS INTE                                    NO-UNDO.
DEF INPUT PARAM par_nrdconta AS INTE                                    NO-UNDO.
DEF INPUT PARAM par_idseqttl AS INTE									NO-UNDO.
DEF INPUT PARAM par_cdagenci AS INTE									NO-UNDO.
DEF INPUT PARAM par_nrdcaixa AS INTE									NO-UNDO.
DEF INPUT PARAM par_cdoperad AS CHAR									NO-UNDO.
DEF INPUT PARAM par_nmdatela AS CHAR 									NO-UNDO.
DEF INPUT PARAM par_idorigem AS INTE                                    NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                   NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dsxmlout  AS CHAR                                           NO-UNDO.
DEF VAR aux_des_erro  AS CHAR                                           NO-UNDO.
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

RUN STORED-PROCEDURE pc_cabeca_termos_pct_tar
    aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT par_cdcooper,
                      INPUT ?,
                      INPUT par_nrdconta,
                      INPUT 1,
                      INPUT par_idseqttl,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT ?,
                      INPUT ?,
                      INPUT ?,
                      INPUT ?,
                      INPUT ?,
                      OUTPUT "",
                      OUTPUT "",
                      OUTPUT "").

CLOSE STORED-PROC pc_cabeca_termos_pct_tar 
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

ASSIGN aux_dsxmlout = ""
       aux_des_erro = ""
       aux_dscritic = ""
       aux_des_erro = pc_cabeca_termos_pct_tar.pr_des_erro
                      WHEN pc_cabeca_termos_pct_tar.pr_des_erro <> ?
       aux_dscritic = pc_cabeca_termos_pct_tar.pr_dscritic
                      WHEN pc_cabeca_termos_pct_tar.pr_dscritic <> ?
       aux_dsxmlout = pc_cabeca_termos_pct_tar.pr_clobxmlc
                      WHEN pc_cabeca_termos_pct_tar.pr_clobxmlc <> ?.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_des_erro <> "OK" OR
    aux_dscritic <> ""   THEN DO: 

    IF  aux_dscritic = "" THEN DO:   
        ASSIGN aux_dscritic =  "Nao foi possivel buscar dados do pacote".
    END.

    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                       "</dsmsgerr>".  
    
    RETURN "NOK".
    
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = aux_dsxmlout.
