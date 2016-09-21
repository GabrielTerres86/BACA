/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +----------------------------------------+--------------------------------------------------+
  | Rotina Progress                        | Rotina Oracle PLSQL                              |
  +----------------------------------------+--------------------------------------------------+
  | cadreg/consulta/cddopcao = 'C'         | RREG0001.pc_busca_crapreg                        |
  | cadreg/alteração/cddopcao = 'A'        | RREG0001.pc_grava_regional                       |  
  | cadreg/inclusão/cddopcao = 'I'         | RREG0001.pc_grava_regional                       |   
  +----------------------------------------+--------------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/* ............................................................................

   Programa: Fontes/cadreg.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Fevereiro/2011                  Ultima Atualizacao: 26/10/2015
   
   Dados referentes ao programa:
   
   Frequencia: On-line.
   Objetivo  : Cadastro de Regionais para PACs.

   Alteracoes: 08/04/2014 - Ajuste WHOLE-INDEX; adicionado filtro com
                            cdcooper na leitura da temp-table. (Fabricio)
                            
               26/10/2015 - Conversao Progress >> Oracle (PLSQL) - Jéssica (DB1) 
   
               25/11/2015 - Ajuste de homologacao referente a conversao
                            realizada pela DB1
                            (Adriano).
............................................................................ */

{ includes/var_online.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0086tt.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/gera_erro.i}

DEF VAR aux_cddopcao AS CHAR                                          NO-UNDO.
DEF VAR aux_confirma AS CHAR                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                         NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                         NO-UNDO.

/* Variaveis para o XML */ 
DEF VAR xDoc          AS HANDLE                                      NO-UNDO.   
DEF VAR xRoot         AS HANDLE                                      NO-UNDO.  
DEF VAR xRoot2        AS HANDLE                                      NO-UNDO.  
DEF VAR xField        AS HANDLE                                      NO-UNDO. 
DEF VAR xText         AS HANDLE                                      NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER                                     NO-UNDO. 
DEF VAR aux_cont      AS INTEGER                                     NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR                                      NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR                                    NO-UNDO.

DEF VAR h-b1wgen0086 AS HANDLE                                        NO-UNDO.

DEF QUERY q-crapreg FOR tt-crapreg.

DEF BROWSE b-crapreg QUERY q-crapreg
    DISPLAY tt-crapreg.cddsregi COLUMN-LABEL "Regional"    FORMAT "x(20)"
            tt-crapreg.dsoperad COLUMN-LABEL "Responsavel" FORMAT "x(25)"
            tt-crapreg.dsdemail
            WITH  7 DOWN NO-BOX WIDTH 76.

FORM WITH ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela 
     WITH FRAME f_moldura.

FORM glb_cddopcao AT 03 LABEL "Opcao"                         AUTO-RETURN
     HELP "Informe a opcao desejada (C,A,I)."
     VALIDATE(CAN-DO("C,A,I",glb_cddopcao),"014 - Opcao errada.")
     
     WITH ROW 6 COLUMN 3 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM b-crapreg
       WITH ROW 8 CENTERED OVERLAY WIDTH 78 FRAME f_crapreg.
     
FORM tt-crapreg.cddregio LABEL "Codigo da Regional"    AT 04    
     SKIP(1)
     tt-crapreg.dsdregio LABEL "Descricao da Regional" AT 01
        VALIDATE (tt-crapreg.dsdregio <> "",
                  "375 - O campo deve ser preenchido.")
     SKIP(1)
     tt-crapreg.cdopereg LABEL "Responsavel"           AT 11
        VALIDATE(tt-crapreg.cdopereg <> "",
                 "Operador nao informado.")
     tt-crapreg.nmoperad NO-LABEL
     SKIP(1)
     tt-crapreg.dsdemail LABEL "Email"                 AT 17
     WITH CENTERED NO-BOX ROW 9 SIDE-LABELS OVERLAY FRAME f_dados.
     
ON RETURN OF b-crapreg IN FRAME f_crapreg 
   DO:
      IF glb_cddopcao = "C"   THEN
         RETURN.
     
      IF NOT AVAIL tt-crapreg   THEN
         RETURN.
     
      APPLY "GO".
     
   END. 

VIEW FRAME f_moldura.
PAUSE 0.

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:
   
   CLEAR FRAME f_dados.
   HIDE FRAME f_dados.

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE glb_cddopcao WITH FRAME f_opcao.
      LEAVE.

   END.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
      DO:
          RUN fontes/novatela.p.
      
          IF CAPS(glb_nmdatela) <> "CADREG"   THEN
             DO:
                 HIDE FRAME f_opcao.
                 RETURN.
             END.
          ELSE
             NEXT.

      END.

   IF aux_cddopcao <> glb_cddopcao   THEN
      DO:
          { includes/acesso.i }
          aux_cddopcao = glb_cddopcao.
      END.

   IF CAN-DO("C,A",STRING(glb_cddopcao))   THEN
      DO:
         RUN Busca_Crapreg.

         IF RETURN-VALUE <> "OK" THEN
            NEXT.
     
         OPEN QUERY q-crapreg FOR EACH tt-crapreg 
              WHERE tt-crapreg.cdcooper = glb_cdcooper NO-LOCK.

         b-crapreg:HELP = IF   glb_cddopcao = "C"   THEN
                               "Pressione <F4> / <End> para voltar."
                          ELSE
            "Pressione <ENTER> para continuar. <F4> / <END> para voltar.".

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
            UPDATE b-crapreg WITH FRAME f_crapreg.
            LEAVE.

         END.

         HIDE FRAME f_crapreg.
         
         IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
            NEXT.

      END.

   /* Opcao 'A' e 'I' */
   IF glb_cddopcao = "I"   THEN
      DO:  
         CREATE tt-crapreg.

         EMPTY TEMP-TABLE tt-erro.
                  
         MESSAGE "Aguarde...Gerando sequencia.".
         
         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
         
         /* Efetuar a chamada da rotina Oracle */ 
         RUN STORED-PROCEDURE pc_busca_proxima_sequencia_car
             aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*codigo da cooperativa*/ 
                                                 INPUT 0, /*codigo da agencia*/    
                                                 INPUT 0, /*Numero do caixa*/ 
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_nmdatela, /*nome da tela*/
                                                 INPUT 1, /*idorigem*/
                                                OUTPUT 0, /*cddregio*/
                                                OUTPUT "", /*Nome do Campo*/ 
                                                OUTPUT "", /*Saida OK/NOK*/   
                                                OUTPUT ?, /*Tabela Regionais*/  
                                                OUTPUT 0, /*Codigo da critica*/
                                                OUTPUT ""). /*Descricao da critica*/
         
         /* Fechar o procedimento para buscarmos o resultado */ 
         CLOSE STORED-PROC pc_busca_proxima_sequencia_car
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
            
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
         
         HIDE MESSAGE NO-PAUSE.
         
         /* Busca possíveis erros */ 
         ASSIGN aux_cdcritic = 0
                aux_dscritic = ""
                aux_cdcritic = pc_busca_proxima_sequencia_car.pr_cdcritic 
                               WHEN pc_busca_proxima_sequencia_car.pr_cdcritic <> ?
                aux_dscritic = pc_busca_proxima_sequencia_car.pr_dscritic 
                               WHEN pc_busca_proxima_sequencia_car.pr_dscritic <> ?
                tt-crapreg.cddregio = pc_busca_proxima_sequencia_car.pr_cddregio 
                               WHEN pc_busca_proxima_sequencia_car.pr_cddregio <> ?.
               
         IF aux_cdcritic <> 0  OR
            aux_dscritic <> "" THEN
            DO: 
               RUN gera_erro (INPUT glb_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT 1,          /** Sequencia **/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
         
               MESSAGE aux_dscritic.          
               PAUSE 3 NO-MESSAGE.
               NEXT.
            
            END.
         
         DISPLAY tt-crapreg.cddregio 
                 WITH FRAME f_dados.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
           UPDATE tt-crapreg.dsdregio
                  WITH FRAME f_dados.

           LEAVE.

         END.
         
         IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            NEXT.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
           UPDATE tt-crapreg.cdopereg
                  WITH FRAME f_dados.
                  
           LEAVE.

         END.

         IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            NEXT.

         RUN busca_operador.

         IF RETURN-VALUE <> "OK" THEN
            NEXT.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
            UPDATE tt-crapreg.dsdemail 
                   WITH FRAME f_dados.
                  
            LEAVE.

         END.

         IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            NEXT.
           
         RUN fontes/confirma.p (INPUT "",
                                OUTPUT aux_confirma).

         IF aux_confirma <> "S"   THEN
            NEXT.
                           
         RUN Grava_Regional. 

         IF RETURN-VALUE <> "OK" THEN
            DO:     
                {sistema/generico/includes/foco_campo.i
                    &VAR-GERAL=SIM
                    &NOME-FRAME="f_dados"
                    &NOME-CAMPO=aux_nmdcampo }
            END.

      END.
   ELSE 
   IF glb_cddopcao = "A" THEN 
      DO:
         DISPLAY tt-crapreg.cddregio WITH FRAME f_dados.
        
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
            UPDATE tt-crapreg.dsdregio
                   WITH FRAME f_dados.
        
            LEAVE.

         END.
         
         IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
            NEXT.

         DISPLAY tt-crapreg.nmoperad WITH FRAME f_dados.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
           UPDATE tt-crapreg.cdopereg
                  WITH FRAME f_dados.
                  
           LEAVE.

         END.

         IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            NEXT.

         RUN busca_operador.

         IF RETURN-VALUE <> "OK" THEN
            NEXT.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
            UPDATE tt-crapreg.dsdemail 
                   WITH FRAME f_dados.
                  
            LEAVE.

         END.

         IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            NEXT.

         RUN fontes/confirma.p (INPUT "",
                                OUTPUT aux_confirma).
            
         IF aux_confirma <> "S" THEN
            NEXT.
                           
         RUN Grava_Regional. 
        
         IF RETURN-VALUE <> "OK" THEN
            NEXT.

      END.

END. /* Fim laço principal */  


PROCEDURE Busca_Crapreg:

    EMPTY TEMP-TABLE tt-crapreg.
    EMPTY TEMP-TABLE tt-erro.

    MESSAGE "Aguarde...Buscando informacoes.".

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    /* Efetuar a chamada da rotina Oracle */ 
    RUN STORED-PROCEDURE pc_busca_crapreg_car
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*codigo da cooperativa*/           
                                            INPUT 0, /*codigo da agencia*/                        
                                            INPUT 0, /*Numero do caixa*/                        
                                            INPUT 1, /*idorigem*/
                                            INPUT glb_cdoperad, /*codigo do operador*/                          
                                            INPUT glb_nmdatela, /*nome da tela*/                                                                                            
                                            INPUT glb_dtmvtolt, /*Nome do Avalista*/ 
                                            INPUT 0, /*flgerlog*/
                                            INPUT 1, /*nriniseq*/
                                            INPUT 9999, /*nrregist*/
                                           OUTPUT "", /*Nome do Campo*/                
                                           OUTPUT "", /*Saida OK/NOK*/                          
                                           OUTPUT ?, /*Tabela Regionais*/                       
                                           OUTPUT 0, /*Codigo da critica*/                      
                                           OUTPUT ""). /*Descricao da critica*/ 
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_busca_crapreg_car
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    
    HIDE MESSAGE NO-PAUSE.

    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_busca_crapreg_car.pr_cdcritic 
                          WHEN pc_busca_crapreg_car.pr_cdcritic <> ?
           aux_dscritic = pc_busca_crapreg_car.pr_dscritic 
                          WHEN pc_busca_crapreg_car.pr_dscritic <> ?.

    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" THEN
       DO: 
          RUN gera_erro (INPUT glb_cdcooper,
                         INPUT 0,
                         INPUT 0,
                         INPUT 1,          /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          MESSAGE aux_dscritic.          
          PAUSE 3 NO-MESSAGE.
          RETURN "NOK".
       
       END.
    
    /*Leitura do XML de retorno da proc e criacao dos registros na tt-contras
    para visualizacao dos registros na tela */
    
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_busca_crapreg_car.pr_clob_ret.

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
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
                DO:
             
                    CREATE tt-crapreg.

                END.
     
             DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
               
                xRoot2:GET-CHILD(xField,aux_cont).
                  
                IF xField:SUBTYPE <> "ELEMENT" THEN 
                   NEXT. 
              
                xField:GET-CHILD(xText,1).

                ASSIGN tt-crapreg.cdcooper = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdcooper".                
                ASSIGN tt-crapreg.cddregio = INT(xText:NODE-VALUE) WHEN xField:NAME = "cddregio".
                ASSIGN tt-crapreg.cddsregi = xText:NODE-VALUE WHEN xField:NAME = "cddsregi".
                ASSIGN tt-crapreg.dsoperad = xText:NODE-VALUE WHEN xField:NAME = "dsoperad".
                ASSIGN tt-crapreg.dsdregio = xText:NODE-VALUE WHEN xField:NAME = "dsdregio".
                ASSIGN tt-crapreg.cdopereg = xText:NODE-VALUE WHEN xField:NAME = "cdopereg".
                ASSIGN tt-crapreg.nmoperad = xText:NODE-VALUE WHEN xField:NAME = "nmoperad".
                ASSIGN tt-crapreg.dsdemail = xText:NODE-VALUE WHEN xField:NAME = "dsdemail".

             END. 
            
          END.
     
          SET-SIZE(ponteiro_xml) = 0. 
  
       END.
     
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
   
    HIDE MESSAGE NO-PAUSE.

    RETURN "OK".

END PROCEDURE. /* Busca_Crapreg */

PROCEDURE Grava_Regional:
    
    EMPTY TEMP-TABLE tt-erro.

    MESSAGE "Aguarde...Gravando informacoes.".

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
       
    /* Efetuar a chamada da rotina Oracle */ 
    RUN STORED-PROCEDURE pc_grava_regional_car
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*codigo da cooperativa*/  
                                            INPUT 0, /*codigo da agencia*/          
                                            INPUT 0, /*Numero do caixa*/   
                                            INPUT 1, /*idorigem*/       
                                            INPUT glb_cdoperad, /*codigo do operador*/     
                                            INPUT glb_nmdatela, /*nome da tela*/
                                            INPUT tt-crapreg.cddregio,
                                            INPUT tt-crapreg.dsdregio,
                                            INPUT tt-crapreg.cdopereg,  
                                            INPUT tt-crapreg.dsdemail,    
                                            INPUT glb_dtmvtolt, /*data*/     
                                            INPUT 0,     
                                            INPUT glb_cddopcao,    
                                            OUTPUT "", /*Nome do Campo*/   
                                           OUTPUT "", /*Saida OK/NOK*/   
                                           OUTPUT ?, /*Tabela Regionais*/ 
                                           OUTPUT 0, /*Codigo da critica*/ 
                                           OUTPUT ""). /*Descricao da critica*/ 

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_grava_regional_car
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    HIDE MESSAGE NO-PAUSE.
    
    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           tt-crapreg.cddregio = 0
           aux_cdcritic = pc_grava_regional_car.pr_cdcritic 
                          WHEN pc_grava_regional_car.pr_cdcritic <> ?
           aux_dscritic = pc_grava_regional_car.pr_dscritic 
                          WHEN pc_grava_regional_car.pr_dscritic <> ?
           tt-crapreg.cddregio = pc_grava_regional_car.pr_cddregio 
                          WHEN pc_grava_regional_car.pr_cddregio <> ?.
    
    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" THEN
       DO: 
          RUN gera_erro (INPUT glb_cdcooper,
                         INPUT 0,
                         INPUT 0,
                         INPUT 1,          /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          MESSAGE aux_dscritic.          
          PAUSE 3 NO-MESSAGE.
          RETURN "NOK".
       
       END.
    
    RETURN "OK".

END PROCEDURE. /* Grava_Regional */

PROCEDURE busca_operador:

    EMPTY TEMP-TABLE tt-crapope.
    EMPTY TEMP-TABLE tt-erro.
    
    IF tt-crapreg.cdopereg = "" THEN
       DO:
          MESSAGE "Associado nao informado.". 
          PAUSE 3 NO-MESSAGE.
          RETURN NO-APPLY.

       END.

    MESSAGE "Aguarde...Buscando operador.".
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
 
    /* Efetuar a chamada da rotina Oracle */ 
    RUN STORED-PROCEDURE pc_busca_operadores_car
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*codigo da cooperativa*/           
                                            INPUT 0, /*codigo da agencia*/                        
                                            INPUT 0, /*Numero do caixa*/                        
                                            INPUT 1, /*idorigem*/
                                            INPUT tt-crapreg.cdopereg, /*codigo do operador*/                          
                                            INPUT glb_nmdatela, /*nome da tela*/                                                                                            
                                            INPUT 1, /*nriniseq*/
                                            INPUT 9999, /*nrregist*/
                                           OUTPUT "", /*Nome do Campo*/                
                                           OUTPUT "", /*Saida OK/NOK*/                          
                                           OUTPUT ?, /*Tabela Regionais*/                       
                                           OUTPUT 0, /*Codigo da critica*/                      
                                           OUTPUT ""). /*Descricao da critica*/ 
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_busca_operadores_car
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
         
    /* Efetuar a chamada da rotina Oracle */ 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    
    HIDE MESSAGE NO-PAUSE.
    
    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_busca_operadores_car.pr_cdcritic 
                          WHEN pc_busca_operadores_car.pr_cdcritic <> ?
           aux_dscritic = pc_busca_operadores_car.pr_dscritic 
                          WHEN pc_busca_operadores_car.pr_dscritic <> ?.
                      
    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" THEN
       DO:              
          RUN gera_erro (INPUT glb_cdcooper,
                         INPUT 0,
                         INPUT 0,
                         INPUT 1,          /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
    
          MESSAGE aux_dscritic.          
          PAUSE 3 NO-MESSAGE.
          RETURN NO-APPLY.
                          
       END.                 
    
    /*Leitura do XML de retorno da proc e criacao dos registros na tt-contras
    para visualizacao dos registros na tela */
    
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_busca_operadores_car.pr_clob_ret.
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
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
                DO:
                
                    CREATE tt-crapope.
    
                END.
     
             DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
               
                xRoot2:GET-CHILD(xField,aux_cont).
                  
                IF xField:SUBTYPE <> "ELEMENT" THEN 
                   NEXT. 
              
                xField:GET-CHILD(xText,1).
                  
                ASSIGN tt-crapope.cdcooper = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdcooper"
                       tt-crapope.cdoperad = xText:NODE-VALUE WHEN xField:NAME = "cdoperad"
                       tt-crapope.cdagenci = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdagenci"
                       tt-crapope.nmoperad = xText:NODE-VALUE WHEN xField:NAME = "nmoperad".
                
             END. 
            
          END.
     
          SET-SIZE(ponteiro_xml) = 0. 
    
       END.
     
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
      
    HIDE MESSAGE NO-PAUSE.

    DISPLAY tt-crapope.nmoperad @ tt-crapreg.nmoperad WITH FRAME f_dados.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Crapreg */

/* ..........................................................................*/
