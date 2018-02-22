/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank172.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : Maio/2016                        Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  :
      
   Alteracoes:
..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM pr_cdcooper  LIKE crapcop.cdcooper                   NO-UNDO.
DEF INPUT  PARAM pr_nrdconta  LIKE crapass.nrdconta                   NO-UNDO.
DEF INPUT  PARAM pr_idseqttl  AS INT                                  NO-UNDO.
DEF INPUT  PARAM pr_idorigem  AS INT                                  NO-UNDO.
DEF INPUT  PARAM pr_cdpacote  AS INT                                  NO-UNDO.
DEF INPUT  PARAM pr_dspacote  AS CHAR                                 NO-UNDO.
DEF INPUT  PARAM pr_dtinivig  AS CHAR                                 NO-UNDO.
DEF INPUT  PARAM pr_dtdiadeb  AS CHAR                                 NO-UNDO.
DEF INPUT  PARAM pr_vlpacote  AS CHAR                                 NO-UNDO.
DEF INPUT  PARAM pr_iddscscp  AS INTE                                 NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                 NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

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

DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_dssrvarq AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdirarq AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
              

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_termo_adesao_pacote_ib 
  aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT INT(pr_cdcooper),
                      INPUT INT(pr_nrdconta),
                      INPUT INT(pr_idseqttl),                      
                      INPUT INT(pr_idorigem),
                      INPUT pr_cdpacote,
                      INPUT pr_dspacote, 
                      INPUT pr_dtinivig, 
                      INPUT pr_dtdiadeb, 
                      INPUT pr_vlpacote, 
                      INPUT pr_iddscscp,
                      OUTPUT "",
                      OUTPUT "",
                      OUTPUT "",
                      OUTPUT "",
                      OUTPUT "").
                      
                     
CLOSE STORED-PROC pc_termo_adesao_pacote_ib aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_nmarquiv = ""
           aux_dssrvarq = ""
           aux_dsdirarq = ""
           aux_dscritic = ""
           aux_nmarquiv = pc_termo_adesao_pacote_ib.pr_nmarquiv
                      WHEN pc_termo_adesao_pacote_ib.pr_nmarquiv <> ?                      
           aux_dssrvarq = pc_termo_adesao_pacote_ib.pr_dssrvarq
                          WHEN pc_termo_adesao_pacote_ib.pr_dssrvarq <> ?
           aux_dsdirarq = pc_termo_adesao_pacote_ib.pr_dsdirarq
                          WHEN pc_termo_adesao_pacote_ib.pr_dsdirarq <> ?                       
           aux_dscritic = pc_termo_adesao_pacote_ib.pr_dscritic
                      WHEN pc_termo_adesao_pacote_ib.pr_dscritic <> ?.           

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_dscritic <> "" THEN DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    RETURN "NOK".
END.


CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<nmarquiv>" + aux_nmarquiv + "</nmarquiv>" +
                               "<dssrvarq>" + aux_dssrvarq + "</dssrvarq>" +
                               "<dsdirarq>" + aux_dsdirarq + "</dsdirarq>".

RETURN "OK".



