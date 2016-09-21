/*.....................................................................................................
   
   Programa: sistema/internet/fontes/InternetBank143.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lombardi
   Data    : Agosto/2015                        Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  :
      
   Alteracoes: 04/11/2015 - Tratamento para leitura do xml da pc_lista_empregados_ib (Vanessa).
......................................................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

/* Variaveis para o XML */
DEF VAR xDoc          AS HANDLE                                     NO-UNDO.
DEF VAR xRoot         AS HANDLE                                     NO-UNDO.
DEF VAR xRoot2        AS HANDLE                                     NO-UNDO.
DEF VAR xField        AS HANDLE                                     NO-UNDO.
DEF VAR xText         AS HANDLE                                     NO-UNDO.
DEF VAR aux_cont_raiz AS INTEGER                                    NO-UNDO.
DEF VAR aux_cont AS INTEGER                                    NO-UNDO.
DEF VAR ponteiro_xml  AS MEMPTR                                     NO-UNDO.
DEF VAR xml_req       AS LONGCHAR                                   NO-UNDO.


DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.


{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_lista_empregados_ib aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      OUTPUT "",
                      OUTPUT 0,
                      OUTPUT "").

CLOSE STORED-PROC pc_lista_empregados_ib aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_lista_empregados_ib.pr_cdcritic
                      WHEN pc_lista_empregados_ib.pr_cdcritic <> ?
       aux_dscritic = pc_lista_empregados_ib.pr_dscritic
                      WHEN pc_lista_empregados_ib.pr_dscritic <> ?
       xml_req      = pc_lista_empregados_ib.pr_data_xml.
 
{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

/* Efetuar a leitura do XML*/ 
   SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
   PUT-STRING(ponteiro_xml,1) = xml_req. 
   
   /* Inicializando objetos para leitura do XML */ 
   CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
   CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
   CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
   CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
   CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
  
  IF ponteiro_xml <> ? THEN
      DO:
         xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
         xDoc:GET-DOCUMENT-ELEMENT(xRoot).
         
          DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:
         
          xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
      
            IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
               NEXT. 
            
            IF xRoot2:NUM-CHILDREN > 0 THEN
              CREATE xml_operacao143.
             
             DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                xRoot2:GET-CHILD(xField,aux_cont).
                     
                IF xField:SUBTYPE <> "ELEMENT" THEN 
                    NEXT. 
                
                xField:GET-CHILD(xText,1).                
               
                ASSIGN  xml_operacao143.nrdconta = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta"
                        xml_operacao143.nrcpfemp = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrcpfemp"
                        xml_operacao143.nmprimtl = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nmprimtl"
                        xml_operacao143.dsdcargo = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dsdcargo"
                        xml_operacao143.dtadmiss = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dtadmiss"
                        xml_operacao143.dstelefo = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dstelefo"
                        xml_operacao143.dsdemail = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dsdemail"
                        xml_operacao143.nrregger = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrregger"
                        xml_operacao143.nrodopis = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrodopis"
                        xml_operacao143.nrdactps = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrdactps"
                        xml_operacao143.cdempres = STRING(xText:NODE-VALUE) WHEN xField:NAME = "cdempres"
                        xml_operacao143.idtpcont = STRING(xText:NODE-VALUE) WHEN xField:NAME = "idtpcont"
                        xml_operacao143.vlultsal = STRING(xText:NODE-VALUE) WHEN xField:NAME = "vlultsal".
             END.
          END.
          
          SET-SIZE(ponteiro_xml) = 0. 
      END.
   /*Elimina os objetos criados*/
   DELETE OBJECT xDoc. 
   DELETE OBJECT xRoot. 
   DELETE OBJECT xRoot2. 
   DELETE OBJECT xField. 
   DELETE OBJECT xText.
   
   CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<raiz>".
   
   FOR EACH xml_operacao143 WHERE NO-LOCK:   
      
      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<funcionarios><nrdconta>" + xml_operacao143.nrdconta + "</nrdconta>" +
                                     "<nrcpfemp>" + xml_operacao143.nrcpfemp + "</nrcpfemp>" +
                                     "<nmprimtl>" + xml_operacao143.nmprimtl + "</nmprimtl>" +
                                     "<dsdcargo>" + xml_operacao143.dsdcargo + "</dsdcargo>" +
                                     "<dtadmiss>" + xml_operacao143.dtadmiss + "</dtadmiss>" +
                                     "<dstelefo>" + xml_operacao143.dstelefo + "</dstelefo>" +
                                     "<dsdemail>" + xml_operacao143.dsdemail + "</dsdemail>" +
                                     "<nrregger>" + xml_operacao143.nrregger + "</nrregger>" +
                                     "<nrdactps>" + xml_operacao143.nrdactps + "</nrdactps>" +
                                     "<nrodopis>" + xml_operacao143.nrodopis + "</nrodopis>" +
                                     "<cdempres>" + xml_operacao143.cdempres + "</cdempres>" +
                                     "<idtpcont>" + xml_operacao143.idtpcont + "</idtpcont>" +
                                     "<vlultsal>" + xml_operacao143.vlultsal + "</vlultsal></funcionarios>".                                       
       
    END.
    
    CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "</raiz>".
RETURN "OK".

