

/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank157.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jonathan C. da Silva/RKAM
   Data    : Setembro/2015                       Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Buscar o Limite de Inscricao por Cooperativa e Cadastrar o Cooperado no EAD
      
   Alteracoes:
..............................................................................*/

 { sistema/internet/includes/var_ibank.i    }
 { sistema/generico/includes/var_internet.i }
 { sistema/generico/includes/var_oracle.i   }

 DEF INPUT  PARAM pr_cddopcao AS CHAR                                   NO-UNDO.
 DEF INPUT  PARAM pr_cdcadead AS INT                                    NO-UNDO.
 DEF INPUT  PARAM pr_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
 DEF INPUT  PARAM pr_nrdconta LIKE crapass.nrdconta                     NO-UNDO.
 DEF INPUT  PARAM pr_inpessoa AS INT                                    NO-UNDO.
 DEF INPUT  PARAM pr_invclopj AS INT                                    NO-UNDO.
 DEF INPUT  PARAM pr_idseqttl AS INT                                    NO-UNDO.
 DEF INPUT  PARAM pr_nmextptp AS CHAR                                   NO-UNDO.
 DEF INPUT  PARAM pr_nrcpfptp AS DECI                                   NO-UNDO.
 DEF INPUT  PARAM pr_dsemlptp AS CHAR                                   NO-UNDO.
 DEF INPUT  PARAM pr_nrfonptp AS CHAR                                   NO-UNDO.
 DEF INPUT  PARAM pr_nmlogptp AS CHAR                                   NO-UNDO.

 DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
 DEF OUTPUT PARAM TABLE FOR xml_operacao.

 /* Variáveis utilizadas para receber clob da rotina no oracle */
 DEF VAR xDoc          AS HANDLE   NO-UNDO.   
 DEF VAR xRoot         AS HANDLE   NO-UNDO.  
 DEF VAR xRoot2        AS HANDLE   NO-UNDO.
 DEF VAR xRoot3        AS HANDLE   NO-UNDO.   
 DEF VAR xField        AS HANDLE   NO-UNDO.
 DEF VAR xField2       AS HANDLE   NO-UNDO.  
 DEF VAR xText         AS HANDLE   NO-UNDO. 
 DEF VAR xText2        AS HANDLE   NO-UNDO. 
 DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO.
 DEF VAR aux_cont_crit AS INTEGER  NO-UNDO. 
 DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
 DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
 DEF VAR xml_req       AS LONGCHAR NO-UNDO.

 DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
 DEF VAR aux_dsretorn AS CHAR                                           NO-UNDO.
 DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
 DEF VAR aux_nrdocmto AS DEC                                            NO-UNDO.
 DEF VAR ret_flconven AS INTE                                           NO-UNDO.

 /* Inicializando objetos para leitura do XML */ 
 CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
 CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
 CREATE X-NODEREF  xRoot2.  /* Vai conter a tag criticas em diante */ 
 CREATE X-NODEREF  xRoot3.  /* Vai conter a tag critica em diante */ 
 CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
 CREATE X-NODEREF  xField2.
 CREATE X-NODEREF  xText.
 CREATE X-NODEREF  xText2.  /* Vai conter o texto que existe dentro da tag xField */ 

 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
  
 RUN STORED-PROCEDURE pc_tbead_inscricao_cooperado aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT pr_cddopcao,
                       INPUT pr_cdcadead,
                       INPUT pr_cdcooper,
                       INPUT pr_nrdconta,
                       INPUT pr_inpessoa,
                       INPUT pr_invclopj,
                       INPUT pr_idseqttl,
                       INPUT pr_nmextptp,
                       INPUT pr_nrcpfptp,
                       INPUT pr_dsemlptp,
                       INPUT pr_nrfonptp,
                       INPUT pr_nmlogptp,
                       OUTPUT "",
                       OUTPUT "").

 CLOSE STORED-PROC pc_tbead_inscricao_cooperado aux_statproc = PROC-STATUS 
      WHERE PROC-HANDLE = aux_handproc.
 
 ASSIGN aux_dscritic = ""
        aux_dscritic = pc_tbead_inscricao_cooperado.pr_dscritic 
                       WHEN pc_tbead_inscricao_cooperado.pr_dscritic <> ?
        xml_req      = pc_tbead_inscricao_cooperado.pr_retxml.

 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

 IF  aux_dscritic <> "" THEN DO:
     ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
     RETURN "NOK".
 END.

 CREATE xml_operacao.
 ASSIGN xml_operacao.dslinxml = xml_req.
 
 /* ............................... PROCEDURES ............................... */


