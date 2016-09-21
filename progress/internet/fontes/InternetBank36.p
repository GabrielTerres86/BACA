/* ............................................................................
   Programa: siscaixa/web/InternetBank36.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao: 22/10/2015
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Carregar dados para gerar arquivo de retorno de cobranca.
   
   Alteracoes: 03/11/2008 - Inclusao widget-pool (martin)
   
               ??/05/2011 - Tratamento Cobranca Registrada (Guilherme/Supero)
               
               21/06/2011 - Dar o DELETE PROCEDURE h-b1wgen0090 dentro do 
                            VALID-HANDLE (Guilherme).
                            
               05/06/2013 - Projeto Melhorias da Cobranca - permitir cooperado
                            gerar arq. de retorno CNAB400. (Rafael)
                            
               11/03/2014 - Correcao fechamento instancia b1wgen0090 (Daniel)  
               
               04/04/2014 - Ajuste processo busca flgregis (Daniel).
               
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
               
               22/10/2015 - Ajuste para alterar a chamada das rotinas progress
                            para suas respectivas conversoes PLSQL
                            (Adriano - SD 335749).
               
 ............................................................................ */
 
create widget-pool.
 
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0010tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0010 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0090 AS HANDLE                                         NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_flgregis AS LOG                                            NO-UNDO.
DEF VAR aux_dtmvtolt AS DATE                                           NO-UNDO.

/* Variaveis para o XML */                                            
DEF VAR xDoc          AS HANDLE                                        NO-UNDO.
DEF VAR xRoot         AS HANDLE                                        NO-UNDO.
DEF VAR xRoot2        AS HANDLE                                        NO-UNDO.
DEF VAR xField        AS HANDLE                                        NO-UNDO.
DEF VAR xText         AS HANDLE                                        NO-UNDO.
DEF VAR aux_cont_raiz AS INTEGER                                       NO-UNDO.
DEF VAR aux_cont      AS INTEGER                                       NO-UNDO.
DEF VAR ponteiro_xml  AS MEMPTR                                        NO-UNDO.
DEF VAR xml_req       AS LONGCHAR                                      NO-UNDO.

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT  PARAM par_dtiniper AS DATE                                  NO-UNDO.
DEF INPUT  PARAM par_dtfimper AS DATE                                  NO-UNDO.
DEF INPUT  PARAM par_nrcnvcob AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao36.


ASSIGN aux_dstransa = "Carregar dados para gerar arquivo de retorno de " +
                      "cobranca".


FIND FIRST crapcco WHERE crapcco.cdcooper = par_cdcooper AND
                         crapcco.nrconven = par_nrcnvcob
                         NO-LOCK NO-ERROR.

IF AVAIL crapcco THEN
   ASSIGN aux_flgregis = crapcco.flgregis.
ELSE
   DO:
      ASSIGN aux_dscritic = "Convenio de cobranca nao disponivel."
             xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    
      RUN proc_geracao_log (INPUT FALSE).
    
      RETURN "NOK".
   END.

FIND crapceb WHERE crapceb.cdcooper = par_cdcooper AND
                   crapceb.nrdconta = par_nrdconta AND
                   crapceb.nrconven = par_nrcnvcob
                   NO-LOCK NO-ERROR.

IF NOT AVAIL crapceb THEN
   DO:
      ASSIGN aux_dscritic = "Convenio de cobranca nao disponivel."
             xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
   
      RUN proc_geracao_log (INPUT FALSE).
   
      RETURN "NOK".
   END.
ELSE
   IF crapceb.inarqcbr = 0 THEN
      DO:
         ASSIGN aux_dscritic = "Convenio sem parametro de recebimento de " + 
                               "arquivo de retorno. " + 
                               "Entre em contato com seu PA."
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
      
         RUN proc_geracao_log (INPUT FALSE).
      
         RETURN "NOK".
      END.

IF aux_flgregis                 AND 
   par_dtiniper <> par_dtfimper THEN
   DO:
       ASSIGN aux_dscritic = "Geracao de arquivo permitido apenas " + 
                             "para um unico dia."
              xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

       RUN proc_geracao_log (INPUT FALSE).

       RETURN "NOK".
   END.

IF aux_flgregis THEN 
   DO:
      DO aux_dtmvtolt = par_dtiniper TO par_dtfimper:
      
         /* Verifica se data dia util */
         IF CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt)))             OR
            CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                   crapfer.dtferiad = aux_dtmvtolt) THEN 
            NEXT. /* Sabado, Domingo e Feriado */
     
         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                    
         /* Efetuar a chamada da rotina Oracle */ 
         RUN STORED-PROCEDURE pc_gera_arq_cooperado_car
             aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper, 
                                                 INPUT par_nrcnvcob, 
                                                 INPUT par_nrdconta, 
                                                 INPUT aux_dtmvtolt, 
                                                 INPUT 3, /*Internet*/ 
                                                 INPUT 0, /*Logar*/ 
                                                 INPUT "InternetBank36",
                                                 OUTPUT "", /*nmdcampo*/
                                                 OUTPUT "", /*OK/NOK*/
                                                 OUTPUT ?, /*Tabela arquivo cobranca*/
                                                 OUTPUT 0, /*Codigo da critica*/
                                                 OUTPUT ""). /*Descricao da critica*/
         
         /* Fechar o procedimento para buscarmos o resultado */ 
         CLOSE STORED-PROC pc_gera_arq_cooperado_car
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
         
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
         
         /* Busca possíveis erros */ 
         ASSIGN aux_cdcritic = 0
                aux_dscritic = ""
                aux_cdcritic = pc_gera_arq_cooperado_car.pr_cdcritic 
                               WHEN pc_gera_arq_cooperado_car.pr_cdcritic <> ?
                aux_dscritic = pc_gera_arq_cooperado_car.pr_dscritic 
                               WHEN pc_gera_arq_cooperado_car.pr_dscritic <> ?.
         
         IF aux_cdcritic <> 0  OR
            aux_dscritic <> "" THEN
            DO:
               IF aux_dscritic = "" THEN
                  ASSIGN aux_dscritic = "Nao foi possivel gerar arquivo.".
             
               ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
             
               RUN proc_geracao_log (INPUT FALSE).
             
               RETURN "NOK".
          
            END.
      
         EMPTY TEMP-TABLE tt-arq-cobranca.
      
         /*Leitura do XML de retorno da proc e criacao dos registros na tt-beneficiario
          para visualizacao dos registros na tela */
          
         /* Buscar o XML na tabela de retorno da procedure Progress */ 
         ASSIGN xml_req = pc_gera_arq_cooperado_car.pr_clob_ret. 
             
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
                    CREATE tt-arq-cobranca.
            
                  DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                      
                     xRoot2:GET-CHILD(xField,aux_cont).
                         
                     IF xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 
                     
                     xField:GET-CHILD(xText,1).
                     
                     ASSIGN tt-arq-cobranca.cdseqlin = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdseqlin".
                     ASSIGN tt-arq-cobranca.dslinha =  xText:NODE-VALUE WHEN xField:NAME = "dsdlinha".
                                                        
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
      
         FOR EACH tt-arq-cobranca NO-LOCK BY tt-arq-cobranca.cdseqlin:
      
             CREATE xml_operacao36.
                 
             ASSIGN xml_operacao36.dscabini = "<DADOS>"
                    xml_operacao36.cdseqlin =   "<cdseqlin>" +
                                        TRIM(STRING(tt-arq-cobranca.cdseqlin)) +
                                                "</cdseqlin>"
                    xml_operacao36.dsdlinha =   "<dsdlinha>" +
                                                 tt-arq-cobranca.dslinha + 
                                                "</dsdlinha>"
                    xml_operacao36.dscabfim = "</DADOS>".
                                      
         END.                  
      
         RUN proc_geracao_log (INPUT TRUE).
      
         RETURN "OK".
      
      END. /* FIM do DO de Datas */
          
   END. /* FIM do IF avail CRAPCOB */
ELSE
   DO:
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
      
      /* Efetuar a chamada da rotina Oracle */ 
      RUN STORED-PROCEDURE pc_gera_ret_arq_cobranca_car
          aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper, 
                                              INPUT par_nrdconta, 
                                              INPUT par_dtiniper, 
                                              INPUT par_dtfimper, 
                                              INPUT par_nrcnvcob,
                                              INPUT 90, /*Agencia*/
                                              INPUT 900, /*Caixa*/
                                              INPUT 3, /*Internet*/ 
                                              INPUT "InternetBank36",
                                              OUTPUT "", /*nmdcampo*/
                                              OUTPUT "", /*OK/NOK*/
                                              OUTPUT ?, /*Tabela arquivo cobranca*/
                                              OUTPUT 0, /*Codigo da critica*/
                                              OUTPUT ""). /*Descricao da critica*/
      
      /* Fechar o procedimento para buscarmos o resultado */ 
      CLOSE STORED-PROC pc_gera_ret_arq_cobranca_car
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
      
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
      
      /* Busca possíveis erros */ 
      ASSIGN aux_cdcritic = 0
             aux_dscritic = ""
             aux_cdcritic = pc_gera_ret_arq_cobranca_car.pr_cdcritic 
                            WHEN pc_gera_ret_arq_cobranca_car.pr_cdcritic <> ?
             aux_dscritic = pc_gera_ret_arq_cobranca_car.pr_dscritic 
                            WHEN pc_gera_ret_arq_cobranca_car.pr_dscritic <> ?.
      
      IF aux_cdcritic <> 0  OR
         aux_dscritic <> "" THEN
         DO:
            IF aux_dscritic = "" THEN
               ASSIGN aux_dscritic = "Nao foi possivel gerar arquivo.".
          
            ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
          
            RUN proc_geracao_log (INPUT FALSE).
          
            RETURN "NOK".
       
         END.
      
      EMPTY TEMP-TABLE tt-arq-cobranca.
      
      /*Leitura do XML de retorno da proc e criacao dos registros na tt-beneficiario
       para visualizacao dos registros na tela */
       
      /* Buscar o XML na tabela de retorno da procedure Progress */ 
      ASSIGN xml_req = pc_gera_ret_arq_cobranca_car.pr_clob_ret. 
          
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
                 CREATE tt-arq-cobranca.
         
               DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                   
                  xRoot2:GET-CHILD(xField,aux_cont).
                      
                  IF xField:SUBTYPE <> "ELEMENT" THEN 
                     NEXT. 
                  
                  xField:GET-CHILD(xText,1).
                  
                  ASSIGN tt-arq-cobranca.cdseqlin = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdseqlin".
                  ASSIGN tt-arq-cobranca.dslinha =  xText:NODE-VALUE WHEN xField:NAME = "dsdlinha".
                                                     
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
      
      FOR EACH tt-arq-cobranca NO-LOCK BY tt-arq-cobranca.cdseqlin:
      
          CREATE xml_operacao36.
              
          ASSIGN xml_operacao36.dscabini = "<DADOS>"
                 xml_operacao36.cdseqlin =   "<cdseqlin>" +
                                     TRIM(STRING(tt-arq-cobranca.cdseqlin)) +
                                             "</cdseqlin>"
                 xml_operacao36.dsdlinha =   "<dsdlinha>" +
                                              tt-arq-cobranca.dslinha + 
                                             "</dsdlinha>"
                 xml_operacao36.dscabfim = "</DADOS>".
                                   
      END.                  
      
      RUN proc_geracao_log (INPUT TRUE).
      
      RETURN "OK".

   END. /* FIM do ELSE DO */


/* ............................... PROCEDURES ............................... */
PROCEDURE proc_geracao_log:
    DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT "INTERNET",
                                          INPUT aux_dstransa,
                                          INPUT TODAY,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).
                                                            
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE. 


