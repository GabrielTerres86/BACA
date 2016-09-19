/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank140.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Junho/2015                        Ultima atualizacao: 16/11/2015
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  :
      
   Alteracoes: 16/11/2015 - Estado de crise (Gabriel-RKAM).
..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_dtiniper LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_dtfimper LIKE crapdat.dtmvtolt                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.


/* Variaveis para o XML */
DEF VAR xDoc          AS HANDLE                                     NO-UNDO.
DEF VAR xRoot         AS HANDLE                                     NO-UNDO.
DEF VAR xRoot2        AS HANDLE                                     NO-UNDO.
DEF VAR xField        AS HANDLE                                     NO-UNDO.
DEF VAR xText         AS HANDLE                                     NO-UNDO.
DEF VAR aux_cont_raiz AS INTEGER                                    NO-UNDO.
DEF VAR aux_cont_perf AS INTEGER                                    NO-UNDO.
DEF VAR ponteiro_xml  AS MEMPTR                                     NO-UNDO.
DEF VAR xml_req       AS LONGCHAR                                   NO-UNDO.


DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.


RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                      INPUT 90,
                                      INPUT 7, /* Folha de pagamento*/
                                      INPUT 2, /* inpessoa*/
                                     OUTPUT aux_dscritic,
                                     OUTPUT TABLE tt-limite).
DELETE PROCEDURE h-b1wgen0015.

IF   aux_dscritic <> ""   THEN
     DO:
         ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".          
         RETURN "NOK".
     END.   

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_busca_dados_pagto_ib aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_dtiniper,
                      INPUT par_dtfimper,
                      OUTPUT 0,
                      OUTPUT "",
                      OUTPUT "").
CLOSE STORED-PROC pc_busca_dados_pagto_ib aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_busca_dados_pagto_ib.pr_cdcritic
                      WHEN pc_busca_dados_pagto_ib.pr_cdcritic <> ?
       aux_dscritic = pc_busca_dados_pagto_ib.pr_dscritic
                      WHEN pc_busca_dados_pagto_ib.pr_dscritic <> ?
       xml_req      = pc_busca_dados_pagto_ib.pr_pagto_xml.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    RETURN "NOK".
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = xml_req.

RETURN "OK".
