/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +----------------------------------------+--------------------------------------------------+
  | Rotina Progress                        | Rotina Oracle PLSQL                              |
  +----------------------------------------+--------------------------------------------------+
  | Busca_Dados                            | AVAL0001.pc_busca_dados_contratos                |
  | Busca_Avalista                         | AVAL0001.pc_busca_dados_avalista                 |
  +----------------------------------------+--------------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/


/* .............................................................................

   Programa: Fontes/avalis.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereio/94                      Ultima atualizacao: 21/01/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela AVALIS.

   Alteracoes: 19/11/96 - Alterado para ajustar mascara do campo nrctremp(Odair)

               05/03/98 - Tratar datas milenio (Odair)
               
               26/04/2000 - Colocar total da divida (Odair)

               27/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               23/03/2003 - Incluir tratamento da Concredi (Margarete).
               
               07/06/2004 - Mostrar prejuz (Evandro).

               16/06/2004 - Pesquisa avalistas(Terceiros) atraves CPF(Evandro).

               30/07/2004 - Passado parametro quantidade prestacoes
                            calculadas(Mirtes)

               11/03/2005 - Message quando CPF de determinada Conta , existir
                            tambem em outra conta(Mirtes).
                            
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
                            
               15/05/2007 - Avalista nao cooperado que torna-se cooperado  
                            nao esta sendo apresentado(Mirtes)
               13/10/2008 - Nome do cooperado. (Buscar da conta caso tornar-se
                            cooperado)(Mirtes)
                            
               04/08/2009 - Contemplar avalistas de descto titulos(Guilherme).

               01/09/2009 - Adicionar consulta de avalista por nome <F7> no
                            campo CPF - tel_nrcpfcgc (Fernando).
                            
               29/09/2009 - Adicionar no <F7> do tel_nrcpfcgc os avalistas
                            cooperados (Fernando).   
                            
               01/06/2010 - Ajustado FIND na crabass (Fernando).                      
               
               20/03/2012 - Ajuste na consulta da CRAPCDC para procurar 'tpctrlim'
                            igual a craplim.tpctrlim (Lucas). 
               
               04/06/2012 - Projeto Oracle -  Adaptação de Fontes - Substituição 
                            da função CONTAINS pela MATCHES (Lucas R.).
                            
               20/12/2012 - Adaptado para uso de BO - Gabriel Capóia (DB1).
               
               21/11/2013 - Removido o F7 devido ao uso do CONTAINS (Guilherme). 
               
               27/11/2013 - Alterado coluna da tt-avalistas.nrcpfcgc de "CPF/CGC"
                            para "CPF/CNPJ". (Reinert)
               
               21/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714) 
                            
               01/07/2015 - Migracao PROGRESS/ORACLE - Adaptado para executar
                            a nova procedure no Oracle (Busca_Dados e Busca_Avalista)
                            (Jéssica DB1)   
............................................................................. */

{ includes/var_online.i }                                 
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0145tt.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/gera_erro.i}

DEF VAR tel_nrdconta AS INTE FORMAT "zzzz,zzz,9"                     NO-UNDO.
DEF VAR tel_nmprimtl AS CHAR FORMAT "x(40)"                          NO-UNDO.
DEF VAR tel_nrcpfcgc AS DECI FORMAT "zzzzzzzzzzzzz9"                 NO-UNDO.
DEF VAR h-b1wgen0145 AS HANDLE                                       NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                         NO-UNDO.
DEF VAR aux_nmdavali AS CHAR                                         NO-UNDO.

DEF VAR aux_contador AS INTE FORMAT "99"                             NO-UNDO.
DEF VAR aux_nrdconta AS INTE FORMAT "zzzz,zzz,9"                     NO-UNDO.

DEF VAR aux_flgretor AS LOGI                                         NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                         NO-UNDO.

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

/* Variaveis para o XML msgconta*/ 
DEF VAR xDoc_msg          AS HANDLE                                      NO-UNDO.   
DEF VAR xRoot_msg         AS HANDLE                                      NO-UNDO.  
DEF VAR xRoot2_msg        AS HANDLE                                      NO-UNDO.  
DEF VAR xField_msg        AS HANDLE                                      NO-UNDO. 
DEF VAR xText_msg         AS HANDLE                                      NO-UNDO. 
DEF VAR aux_cont_raiz_msg AS INTEGER                                     NO-UNDO. 
DEF VAR aux_cont_msg      AS INTEGER                                     NO-UNDO. 
DEF VAR ponteiro_xml_msg  AS MEMPTR                                      NO-UNDO. 
DEF VAR xml_req_msg       AS LONGCHAR                                    NO-UNDO.

DEF QUERY q_avalistas FOR tt-avalistas.

DEF BROWSE b_avalistas QUERY q_avalistas
    DISP tt-avalistas.nrdconta                   COLUMN-LABEL "Conta/dv"  
         tt-avalistas.nmdavali    FORMAT "x(35)" COLUMN-LABEL "Nome pesquisado"
         tt-avalistas.nrcpfcgc                   COLUMN-LABEL "CPF/CNPJ"
    WITH 5 DOWN TITLE " Avalistas ".

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta AT  2 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta do associado"
     tel_nrcpfcgc AT  2 LABEL "CPF "      AUTO-RETURN
     tel_nmprimtl AT 26 LABEL "Titular"
     SKIP (1)
     "Contrato Pesquisa" AT 3
     "Conta/dv Nome"     AT 40
     "Divida"            AT 73
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_avalis.

FORM tt-contras.nrctremp FORMAT "zz,zzz,zz9"   AT  1
     tt-contras.cdpesqui FORMAT "x(26)"        AT 12
     tt-contras.nrdconta FORMAT "zzzz,zz9,9"   AT 38
     tt-contras.nmprimtl FORMAT "x(13)"        AT 49
     tt-contras.tpdcontr FORMAT "x(2)"         AT 64
     tt-contras.vldivida FORMAT "x(12)"        AT 67    
     WITH ROW 10 COLUMN 2 OVERLAY 11 DOWN NO-LABEL NO-BOX FRAME f_contras.

FORM b_avalistas
     HELP "Pressione <ENTER> para selecionar ou <F4> p/ sair."
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_browse.

ON RETURN OF b_avalistas IN FRAME f_browse DO:

    IF  AVAILABLE tt-avalistas  THEN
        ASSIGN tel_nrcpfcgc = tt-avalistas.nrcpfcgc.

    APPLY "GO".
END.
                                            
ASSIGN glb_cddopcao = "C".

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE (0).

DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO , LEAVE:

        UPDATE tel_nrdconta tel_nrcpfcgc WITH FRAME f_avalis
        EDITING:

            DO WHILE TRUE:

                READKEY PAUSE 1.

                /* Caso o campo da conta for igual a 0, mostrar HELP <F7> */
                IF  LASTKEY = KEYCODE("ENTER") THEN
                    /* Removido o F7 devido ao uso de CONTAINS
                    IF  INT(tel_nrdconta:SCREEN-VALUE IN FRAME f_avalis) = 0  THEN
                        tel_nrcpfcgc:HELP IN FRAME f_avalis =
                        "Informe o CPF do avalista ou pressione <F7>.".
                    ELSE
                    */
                        tel_nrcpfcgc:HELP IN FRAME f_avalis = 
                        "Informe o CPF do avalista.".


                /* Listar os avalistas 
                Removido o F7 devido ao uso de CONTAINS
                IF  LASTKEY = KEYCODE("F7")       AND 
                    FRAME-FIELD  = "tel_nrcpfcgc" AND
                    INT(tel_nrdconta:SCREEN-VALUE IN FRAME f_avalis) = 0 THEN
                    DO:
                        ASSIGN tel_nrcpfcgc = 0.
            
                        RUN zoom_avalistas.

                        HIDE FRAME f_browse NO-PAUSE.
                        HIDE FRAME f_zoom   NO-PAUSE.

                        IF  tel_nrcpfcgc > 0   THEN
                            DO:
                                DISPLAY tel_nrcpfcgc WITH FRAME f_avalis.  
                                PAUSE 0.
                                APPLY "RETURN".
                            END.
                        ELSE
                            DO:
                                NEXT-PROMPT tel_nrcpfcgc.
                                NEXT.
                            END.
                    END.
                ELSE */
                    APPLY LASTKEY.
                
                LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            HIDE MESSAGE NO-PAUSE.
          
            IF  GO-PENDING THEN
                DO: 
                    RUN Busca_Dados.
                    
                    IF  RETURN-VALUE <> "OK" THEN
                        DO:     
                            {sistema/generico/includes/foco_campo.i
                                &VAR-GERAL=SIM
                                &NOME-FRAME="f_avalis"
                                &NOME-CAMPO=aux_nmdcampo }
                        END.
                END.

            
        END.  /*  Fim do EDITING  */

        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  glb_nmdatela <> "AVALIS" THEN
                DO:
                    HIDE FRAME f_avalis.
                    HIDE FRAME f_contras.
                    HIDE FRAME f_moldura.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.


END.  /*  Fim do DO WHILE TRUE  */
                                                
PROCEDURE zoom_avalistas:

   FORM 
       SKIP(1)
       aux_nmdavali   LABEL "Nome a pesquisar" FORMAT "x(30)"
                      HELP "Pesquisar por nome de avalista." 
       SKIP(1)
       WITH ROW 8 CENTERED SIDE-LABELS OVERLAY WIDTH 50 
       TITLE "Pesquisa de avalistas" FRAME f_zoom.
   
   ASSIGN aux_nmdavali = "".
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE aux_nmdavali WITH FRAME f_zoom.
      LEAVE.
   END.
     
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            HIDE FRAME f_zoom NO-PAUSE.
            RETURN.
        END.
   
   RUN Busca_Avalista.
   
   IF  RETURN-VALUE <> "OK" THEN
       RETURN.
   
   OPEN QUERY q_avalistas FOR EACH tt-avalistas NO-LOCK 
                                   BY tt-avalistas.nmdavali 
                                      BY tt-avalistas.nrdconta.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE b_avalistas WITH FRAME f_browse.
      LEAVE.
   END.                                            
   
   HIDE FRAME f_browse NO-PAUSE.
   HIDE FRAME f_zoom   NO-PAUSE.
   
   RETURN.

END PROCEDURE.

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msgconta.
    EMPTY TEMP-TABLE tt-contras.
    
    DO WITH FRAME f_avalis:
    
        ASSIGN tel_nrdconta
               tel_nrcpfcgc.
    END.

    CLEAR FRAME f_contras ALL NO-PAUSE.
    
    ASSIGN aux_flgretor = FALSE
           aux_contador = 0.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    MESSAGE "Aguarde...buscando dados...".
    
    /* Efetuar a chamada da rotina Oracle */ 
    RUN STORED-PROCEDURE pc_busca_dados_contratos_car
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper,  /*codigo da cooperativa*/                      
                                            INPUT 0, /*codigo da agencia*/                                  
                                            INPUT 0, /*Numero do caixa*/                                  
                                            INPUT 1, /*idorigem*/                                  
                                            INPUT glb_dtmvtolt, /*data do movimento*/                       
                                            INPUT glb_nmdatela, /*nome da tela*/                       
                                            INPUT glb_cdoperad, /*codigo do operador*/                       
                                            INPUT tel_nrdconta, /*Numero da conta*/                       
                                            INPUT tel_nrcpfcgc, /*Numero do CPF*/                       
                                            INPUT glb_inproces, /*tabela de juros*/                       
                                           OUTPUT tel_nmprimtl, /*Nome do associado*/                                              
                                           OUTPUT tel_nrdconta, /*Numero da conta apresentado quando o parametro entrada é somente o numero do CPF*/                                              
                                           OUTPUT tel_nrcpfcgc, /*Numero do CPF apresentado quando o parametro entrada é somente o numero da conta*/                       
                                           OUTPUT aux_nmdcampo, /*Nome do Campo*/     
                                           OUTPUT "", /*Saida OK/NOK*/                 
                                           OUTPUT ?, /*Tabela Contratos*/              
                                           OUTPUT ?, /*Tabela msgconta*/               
                                           OUTPUT 0, /*Codigo da critica*/             
                                           OUTPUT ""). /*Descricao da critica*/     
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_busca_dados_contratos_car
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    HIDE MESSAGE NO-PAUSE.
    
    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           tel_nmprimtl = ""
           tel_nrdconta = 0 
           tel_nrcpfcgc = 0 
           tel_nmprimtl = pc_busca_dados_contratos_car.pr_nmprimtl 
                          WHEN pc_busca_dados_contratos_car.pr_nmprimtl <> ?
           tel_nrdconta = pc_busca_dados_contratos_car.pr_axnrcont 
                          WHEN pc_busca_dados_contratos_car.pr_axnrcont <> ?
           tel_nrcpfcgc = pc_busca_dados_contratos_car.pr_axnrcpfc 
                          WHEN pc_busca_dados_contratos_car.pr_axnrcpfc <> ? 

           aux_cdcritic = pc_busca_dados_contratos_car.pr_cdcritic 
                          WHEN pc_busca_dados_contratos_car.pr_cdcritic <> ?
           aux_dscritic = pc_busca_dados_contratos_car.pr_dscritic 
                          WHEN pc_busca_dados_contratos_car.pr_dscritic <> ?.
       
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
       
    
    EMPTY TEMP-TABLE tt-contras.
    
    /*Leitura do XML de retorno da proc e criacao dos registros na tt-contras
    para visualizacao dos registros na tela */
    
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_busca_dados_contratos_car.pr_clob_ret.
    
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
             
                    CREATE tt-contras.

                END.
     
             DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
               
                xRoot2:GET-CHILD(xField,aux_cont).
                  
                IF xField:SUBTYPE <> "ELEMENT" THEN 
                   NEXT. 
              
                xField:GET-CHILD(xText,1).
  
                ASSIGN tt-contras.nrctremp = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrctremp".
                ASSIGN tt-contras.cdpesqui = xText:NODE-VALUE WHEN xField:NAME = "cdpesqui".
                ASSIGN tt-contras.nrdconta = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta".
                ASSIGN tt-contras.nmprimtl = xText:NODE-VALUE WHEN xField:NAME = "nmprimtl".
                ASSIGN tt-contras.vldivida = xText:NODE-VALUE WHEN xField:NAME = "vldivida".
                ASSIGN tt-contras.tpdcontr = xText:NODE-VALUE WHEN xField:NAME = "tpdcontr".
                
             END. 
            
          END.
     
          SET-SIZE(ponteiro_xml) = 0. 
  
       END.
     
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText. 

    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc_msg.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot_msg.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot2_msg.  /* Vai conter a tag aplicacao em diante */ 
    CREATE X-NODEREF  xField_msg.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText_msg.   /* Vai conter o texto que existe dentro da tag xField */
   
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req_msg = pc_busca_dados_contratos_car.pr_clob_msg.

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml_msg) = LENGTH(xml_req_msg) + 1. 
    PUT-STRING(ponteiro_xml_msg,1) = xml_req_msg. 
    
    IF ponteiro_xml_msg <> ? THEN
       DO:
          xDoc_msg:LOAD("MEMPTR",ponteiro_xml_msg,FALSE). 
          xDoc_msg:GET-DOCUMENT-ELEMENT(xRoot_msg).
          
          DO aux_cont_raiz_msg = 1 TO xRoot_msg:NUM-CHILDREN: 
        
             xRoot_msg:GET-CHILD(xRoot2_msg,aux_cont_raiz_msg).
     
             IF xRoot2_msg:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 
           
             IF xRoot2_msg:NUM-CHILDREN > 0 THEN
                CREATE tt-msgconta.
     
             DO aux_cont_msg = 1 TO xRoot2_msg:NUM-CHILDREN:
               
                xRoot2_msg:GET-CHILD(xField_msg,aux_cont_msg).
                  
                IF xField_msg:SUBTYPE <> "ELEMENT" THEN 
                   NEXT. 
              
                xField_msg:GET-CHILD(xText_msg,1).
                
                ASSIGN tt-msgconta.msgconta = xText_msg:NODE-VALUE WHEN xField_msg:NAME = "msgconta".
                                                                      
             END. 
            
          END.
     
          SET-SIZE(ponteiro_xml_msg) = 0. 
  
       END.
     
    DELETE OBJECT xDoc_msg. 
    DELETE OBJECT xRoot_msg. 
    DELETE OBJECT xRoot2_msg. 
    DELETE OBJECT xField_msg. 
    DELETE OBJECT xText_msg. 
    
    HIDE MESSAGE NO-PAUSE.
    
    FOR EACH tt-msgconta:
        MESSAGE tt-msgconta.msgconta.
        PAUSE.
    END.
    
    DISPLAY tel_nmprimtl tel_nrdconta
            tel_nrcpfcgc WITH FRAME f_avalis.
    
    FOR EACH tt-contras:

        ASSIGN aux_contador = aux_contador + 1.

        IF  aux_contador = 1 THEN
            IF  aux_flgretor  THEN
                DO:
                    PAUSE MESSAGE
                    "Tecle <Entra> para continuar ou <Fim> para encerrar".
                    CLEAR FRAME f_contras ALL NO-PAUSE.
                END.
            ELSE
                ASSIGN aux_flgretor = TRUE.

        DISPLAY tt-contras.nrctremp
                tt-contras.cdpesqui
                tt-contras.nrdconta
                tt-contras.nmprimtl
                tt-contras.tpdcontr
                tt-contras.vldivida
                WITH FRAME f_contras.

        IF  aux_contador = 11 THEN
            ASSIGN aux_contador = 0.
        ELSE
            DOWN WITH FRAME f_contras.

    END. /* FOR EACH tt-contras */
    
    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Busca_Avalista:

    EMPTY TEMP-TABLE tt-avalistas.
    EMPTY TEMP-TABLE tt-erro.

    MESSAGE "Aguarde...buscando dados...".

    CLEAR FRAME f_avalis  NO-PAUSE.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    /* Efetuar a chamada da rotina Oracle */ 
    RUN STORED-PROCEDURE pc_busca_dados_avalista_car
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*codigo da cooperativa*/           
                                            INPUT 0, /*codigo da agencia*/                        
                                            INPUT 0, /*Numero do caixa*/                        
                                            INPUT glb_cdoperad, /*codigo do operador*/                          
                                            INPUT glb_nmdatela, /*nome da tela*/                 
                                            INPUT 1, /*idorigem*/                               
                                            INPUT aux_nmdavali, /*Nome do Avalista*/             
                                           OUTPUT aux_nmdcampo, /*Nome do Campo*/                
                                           OUTPUT "", /*Saida OK/NOK*/                          
                                           OUTPUT ?, /*Tabela Avalistas*/                       
                                           OUTPUT 0, /*Codigo da critica*/                      
                                           OUTPUT ""). /*Descricao da critica*/                 
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_busca_dados_avalista_car
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    HIDE MESSAGE NO-PAUSE.
    
    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_busca_dados_avalista_car.pr_cdcritic 
                          WHEN pc_busca_dados_avalista_car.pr_cdcritic <> ?
           aux_dscritic = pc_busca_dados_avalista_car.pr_dscritic 
                          WHEN pc_busca_dados_avalista_car.pr_dscritic <> ?.

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
    
    EMPTY TEMP-TABLE tt-avalistas.
    
    /*Leitura do XML de retorno da proc e criacao dos registros na tt-contras
    para visualizacao dos registros na tela */
    
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_busca_dados_avalista_car.pr_clob_ret.
    
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
             
                    CREATE tt-avalistas.

                END.
     
             DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
               
                xRoot2:GET-CHILD(xField,aux_cont).
                  
                IF xField:SUBTYPE <> "ELEMENT" THEN 
                   NEXT. 
              
                xField:GET-CHILD(xText,1).

                ASSIGN tt-avalistas.nrdconta = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta".
                ASSIGN tt-avalistas.nmdavali = xText:NODE-VALUE WHEN xField:NAME = "nmdavali".
                ASSIGN tt-avalistas.nrcpfcgc = DEC(xText:NODE-VALUE) WHEN xField:NAME = "nrcpfcgc".
                
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

END PROCEDURE. /* Busca_Avalista */













