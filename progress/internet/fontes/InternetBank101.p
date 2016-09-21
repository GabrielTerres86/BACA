/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank101.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/SUPERO
   Data    : Agosto/2014                       Ultima atualizacao:

   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)

   Objetivo  : Verificar Aceite no Pagto Titulo em Lote

   Alteracoes:
..............................................................................*/


{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                     NO-UNDO.
DEF INPUT  PARAM par_nrconven LIKE crapass.nrdconta                     NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                   NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_cdcritic  AS INT                                            NO-UNDO.
DEF VAR aux_dscritic  AS CHAR                                           NO-UNDO.
DEF VAR aux_dsretorn  AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinxml  AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdocmto  AS DEC                                            NO-UNDO.
DEF VAR ret_flconven  AS INTE                                           NO-UNDO.
DEF VAR aux_hrfimpag  AS CHAR                                           NO-UNDO.
DEF VAR aux_nrremret  AS CHAR                                           NO-UNDO.

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

RUN STORED-PROCEDURE pc_verif_aceite_conven aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_nrconven,
                      OUTPUT "",
                      OUTPUT "", 
                      OUTPUT 0,
                      OUTPUT "").

CLOSE STORED-PROC pc_verif_aceite_conven aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

ASSIGN aux_dslinxml = ""
       aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_verif_aceite_conven.pr_cdcritic
                      WHEN pc_verif_aceite_conven.pr_cdcritic <> ?
       aux_dscritic = pc_verif_aceite_conven.pr_dscritic
                      WHEN pc_verif_aceite_conven.pr_dscritic <> ?
       aux_dsretorn = pc_verif_aceite_conven.pr_vretorno
                      WHEN pc_verif_aceite_conven.pr_vretorno <> ?

       aux_dslinxml = pc_verif_aceite_conven.pr_tab_cpt
                      WHEN pc_verif_aceite_conven.pr_tab_cpt <> ?
    .

IF  aux_dscritic <> "" THEN
    ret_flconven = 0. /* FALSE */
ELSE
    ret_flconven = 1. /* TRUE  */


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
                                   "aceite do Pagto Lote.".
    END.

    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                       "</dsmsgerr>".  
    
    RETURN "NOK".
    
END.

/***** ROTINA APENAS PARA PEGAR O HORARIO MAXIMO PARA AGENDAMENTO DE TITULOS *****/
/** Baseado na TAB com "HRTRTITULO" **/

/* Inicializando objetos para leitura do XML de PERFIL */
CREATE X-DOCUMENT xDoc.
CREATE X-NODEREF xRoot.
CREATE X-NODEREF xRoot2.
CREATE X-NODEREF xField.
CREATE X-NODEREF xText.

/* Efetuar a leitura do XML*/
SET-SIZE(ponteiro_xml) = LENGTH(aux_dslinxml) + 1.
PUT-STRING(ponteiro_xml,1) = aux_dslinxml.

xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).
xDoc:GET-DOCUMENT-ELEMENT(xRoot).


DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:
    xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

    IF  xRoot2:SUBTYPE <> "ELEMENT" THEN
        NEXT.

    DO  aux_cont_perf = 1 TO xRoot2:NUM-CHILDREN:
        xRoot2:GET-CHILD(xField,aux_cont_perf).

        IF  xField:SUBTYPE <> "ELEMENT" THEN
            NEXT.

        xField:GET-CHILD(xText,1).

        CASE xField:NAME:
            WHEN "nrconven" THEN NEXT.
            
            WHEN "dtdadesa" THEN NEXT.
            
            WHEN "cdoperad" THEN NEXT.
            
            WHEN "flgativo" THEN NEXT.
            
            WHEN "dsorigem" THEN NEXT.

            WHEN "hrfimpag" THEN aux_hrfimpag = xText:NODE-VALUE.

            WHEN "nrremret" THEN aux_nrremret = xText:NODE-VALUE.

        END CASE.
    END.
END.

SET-SIZE(ponteiro_xml) = 0.

DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xRoot2.
DELETE OBJECT xField.
DELETE OBJECT xText.

/***** FIM - ROTINA APENAS PARA PEGAR O HORARIO MAXIMO PARA AGENDAMENTO DE TITULOS *****/

CREATE xml_operacao.
    
ASSIGN xml_operacao.dslinxml = "<MSGCONFIRMA>" + 
                                 "<flconven>" + STRING(ret_flconven) + "</flconven>" +
                                 "<hrfimpag>" + aux_hrfimpag + "</hrfimpag>" +
                                 "<nrremret>" + aux_nrremret + "</nrremret>" +
                               "</MSGCONFIRMA>".

RETURN "OK".



/* ............................... PROCEDURES ............................... */

