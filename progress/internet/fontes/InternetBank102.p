/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank102.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/SUPERO
   Data    : Agosto/2014                       Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Retorna lista de Titulos Agendados
      
   Alteracoes:
..............................................................................*/

 { sistema/internet/includes/var_ibank.i    }
 { sistema/generico/includes/var_internet.i }
 { sistema/generico/includes/var_oracle.i   }

 DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
 DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
 DEF INPUT  PARAM par_nrconven LIKE crapass.nrdconta                    NO-UNDO.
 DEF INPUT  PARAM par_dtiniper AS DATE                                  NO-UNDO.
 DEF INPUT  PARAM par_dtfimper AS DATE                                  NO-UNDO.

 DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
 DEF OUTPUT PARAM xml_operacao AS CHAR                                  NO-UNDO.

 DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
 DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

 DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
 DEF VAR aux_nrdocmto AS DEC                                            NO-UNDO.
 DEF VAR ret_flconven AS INTE                                           NO-UNDO.

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


{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

 RUN STORED-PROCEDURE pc_retorna_titulo_agendado aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT par_cdcooper,
                       INPUT par_nrdconta,
                       INPUT par_nrconven,
                       INPUT par_dtiniper,
                       INPUT par_dtfimper,
                       OUTPUT "",
                       OUTPUT 0,
                       OUTPUT "").

 CLOSE STORED-PROC pc_retorna_titulo_agendado aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

 ASSIGN aux_dslinxml = ""
        aux_cdcritic = 0
        aux_dscritic = ""
        aux_cdcritic = pc_retorna_titulo_agendado.pr_cdcritic
                       WHEN pc_retorna_titulo_agendado.pr_cdcritic <> ?
        aux_dscritic = pc_retorna_titulo_agendado.pr_dscritic
                       WHEN pc_retorna_titulo_agendado.pr_dscritic <> ?
        xml_req      = pc_retorna_titulo_agendado.pr_tab_titulo
                       WHEN pc_retorna_titulo_agendado.pr_tab_titulo <> ?.

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


 ASSIGN xml_operacao = xml_req.


 RETURN "OK".

 /* ............................... PROCEDURES ............................... */

