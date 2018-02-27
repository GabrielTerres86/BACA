
/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank146.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vanessa Klein
   Data    : Agosto/2015                        Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  :
      
   Alteracoes:
..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }


DEF INPUT  PARAM pr_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT  PARAM pr_nrdconta LIKE crapass.nrdconta                     NO-UNDO.
DEF INPUT  PARAM pr_dsarquiv AS CHAR                                   NO-UNDO.
DEF INPUT  PARAM pr_dsdireto AS CHAR                                   NO-UNDO.
DEF INPUT  PARAM pr_nrseqpag AS INT                                    NO-UNDO.
DEF INPUT  PARAM pr_iddspscp AS INTE                                   NO-UNDO.
                     
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

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_qtcmperr AS CHAR                                           NO-UNDO.
DEF VAR aux_qtcmptot AS CHAR                                           NO-UNDO.
DEF VAR aux_qtdcmpok AS CHAR                                           NO-UNDO.
DEF VAR aux_qtdlinok AS CHAR                                           NO-UNDO.
DEF VAR aux_qtlinerr AS CHAR                                           NO-UNDO.
DEF VAR aux_qtlintot AS CHAR                                           NO-UNDO.
DEF VAR aux_dtrefere AS CHAR                                           NO-UNDO.
DEF VAR aux_nrseqpag AS INT                                           NO-UNDO.
DEF VAR aux_dsdconta AS CHAR                                           NO-UNDO.  

EMPTY TEMP-TABLE xml_operacao146.
    
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

    RUN STORED-PROCEDURE pc_valida_arq_compr_ib aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT pr_cdcooper,
                      INPUT 3,
                      INPUT pr_nrdconta,
                      INPUT pr_nrseqpag,
                      INPUT pr_dsarquiv,
                      INPUT pr_dsdireto,
                      INPUT pr_iddspscp,
                      OUTPUT "",
                      OUTPUT ?).
                                            
  CLOSE STORED-PROC pc_valida_arq_compr_ib aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.


  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_nrseqpag = 0
         aux_dsdconta = ""
         aux_dscritic = pc_valida_arq_compr_ib.pr_dscritic
                        WHEN pc_valida_arq_compr_ib.pr_dscritic <> ?
         xml_req      = pc_valida_arq_compr_ib.pr_retxml.

  IF aux_dscritic <> "" THEN DO:
    ASSIGN xml_dsmsgerr = "<DSMSGERR>" + aux_dscritic + "</DSMSGERR>".
    RETURN "NOK".
  END.

     /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
       
    IF ponteiro_xml <> ? THEN
        DO:   
            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).
        
            DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:
       
                xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
                
                 
                IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                 NEXT.         
                 
                xRoot2:GET-CHILD(xText,1).
                 
                IF xRoot2:NAME = "criticas" THEN
                DO: 
                  ASSIGN aux_qtcmperr = STRING(xRoot2:GET-ATTRIBUTE("qtcmperr"))
                         aux_qtcmptot = STRING(xRoot2:GET-ATTRIBUTE("qtcmptot"))
                         aux_qtdcmpok = STRING(xRoot2:GET-ATTRIBUTE("qtdcmpok")) 
                         aux_qtdlinok = STRING(xRoot2:GET-ATTRIBUTE("qtdlinok")) 
                         aux_qtlinerr = STRING(xRoot2:GET-ATTRIBUTE("qtlinerr")) 
                         aux_qtlintot = STRING(xRoot2:GET-ATTRIBUTE("qtlintot"))
                         aux_dtrefere = STRING(xRoot2:GET-ATTRIBUTE("dtrefere")). 
                         
                END.
                       
                DO aux_cont_crit = 1 TO xRoot2:NUM-CHILDREN:
                   
                    xRoot2:GET-CHILD(xField,aux_cont_crit).                   
                
                    
                    IF xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 
                    
                    xField:GET-CHILD(xText,1).
                    
                    IF xField:NAME = "critica" THEN
                    DO:  
                       xRoot2:GET-CHILD(xRoot3,aux_cont_crit).
                        
                       IF xRoot3:SUBTYPE <> "ELEMENT"   THEN 
                          NEXT. 
                    
                       IF xRoot3:NUM-CHILDREN > 0 THEN
                          CREATE xml_operacao146.

                       DO aux_cont = 1 TO xRoot3:NUM-CHILDREN:
                        
                          xRoot3:GET-CHILD(xField2,aux_cont).
                        
                          IF xField2:SUBTYPE <> "ELEMENT" THEN 
                             NEXT. 
                            
                          xField2:GET-CHILD(xText2,1).                
                                             
                          ASSIGN xml_operacao146.nrseqvld = STRING(xText2:NODE-VALUE) WHEN xField2:NAME = "nrseqvld"
                                 xml_operacao146.dsdconta = STRING(xText2:NODE-VALUE) WHEN xField2:NAME = "dsdconta"
                                 xml_operacao146.dscpfcgc = STRING(xText2:NODE-VALUE) WHEN xField2:NAME = "dscpfcgc"
                                 xml_operacao146.dsorigem = STRING(xText2:NODE-VALUE) WHEN xField2:NAME = "dsorigem"
                                 xml_operacao146.dsdescri = STRING(xText2:NODE-VALUE) WHEN xField2:NAME = "dsdescri"
                                 xml_operacao146.iddstipo = STRING(xText2:NODE-VALUE) WHEN xField2:NAME = "iddstipo"
                                 xml_operacao146.vlrpagto = STRING(xText2:NODE-VALUE) WHEN xField2:NAME = "vlrpagto"
                                 xml_operacao146.dscritic = STRING(xText2:NODE-VALUE) WHEN xField2:NAME = "dscritic".
                          
                          IF TRIM(xml_operacao146.dscritic) <> "" AND TRIM(aux_dsdconta) <> TRIM(xml_operacao146.dsdconta) AND TRIM(xml_operacao146.dsdconta) <> ""  THEN
                          DO:  
                              ASSIGN aux_nrseqpag = aux_nrseqpag + 1
                                     aux_dsdconta = xml_operacao146.dsdconta.                                 
                              ASSIGN xml_operacao146.nrseqpag = STRING(aux_nrseqpag).                             
                             
                          END.
                          ELSE                                                    
                            ASSIGN xml_operacao146.nrseqpag = STRING(aux_nrseqpag).
                      END.
                   END.
                END. 
                
            END.
       
            SET-SIZE(ponteiro_xml) = 0. 
        END.

    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<qtcmperr>" + aux_qtcmperr + "</qtcmperr>" +
                                   "<qtcmptot>" + aux_qtcmptot + "</qtcmptot>" +
                                   "<qtdcmpok>" + aux_qtdcmpok + "</qtdcmpok>" +
                                   "<qtdlinok>" + aux_qtdlinok + "</qtdlinok>" +
                                   "<qtlinerr>" + aux_qtlinerr + "</qtlinerr>" +
                                   "<qtlintot>" + aux_qtlintot + "</qtlintot>" +
                                   "<dtrefere>" + aux_dtrefere + "</dtrefere>" .
  
    FOR EACH xml_operacao146 WHERE INT (xml_operacao146.nrseqpag) <= 15 NO-LOCK:   
      
      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<critica><nrseqvld>" + xml_operacao146.nrseqvld + "</nrseqvld>" +
                                     "<dsdconta>" + xml_operacao146.dsdconta + "</dsdconta>" +
                                     "<dscpfcgc>" + xml_operacao146.dscpfcgc + "</dscpfcgc>" +
                                     "<dsorigem>" + xml_operacao146.dsorigem + "</dsorigem>" +
                                     "<dsdescri>" + xml_operacao146.dsdescri + "</dsdescri>" +
                                     "<iddstipo>" + xml_operacao146.iddstipo + "</iddstipo>" +
                                     "<vlrpagto>" + xml_operacao146.vlrpagto + "</vlrpagto>" +
                                     "<dscritic>" + xml_operacao146.dscritic + "</dscritic></critica>".                                       
       
    END.
    
RETURN "OK".

