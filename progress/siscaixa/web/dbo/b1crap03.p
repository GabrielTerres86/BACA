/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap03.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 10/10/2012.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Consulta Extrato

   Alteracoes: 31/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)                            
                            
               22/02/2006 - Unificacao dos bancos - SQLWorks - Eder             

               24/07/2007 - Incluidos historicos de transferencia pela internet
                            (Evandro).

               09/09/2009 - Incluir historico de transferencia de credito de 
                            salario (David). 

               23/11/2009 - Alteracao Codigo Historico (Kbase).
               
               19/05/2010 - Acerto no SUBSTRING do campo craplcm.cdpesqbb
                            (Diego).
                            
               10/10/2012 - Tratamento para novo campo da 'craphis' de descrição
                            do histórico em extratos (Lucas) [Projeto Tarifas].

               11/05/2018 - Chamada da rotina pc_consulta_extrato_car para 
                            listar e ordenar os extratos por ordem cronológica 
                            (Elton-AMcom) [Projeto Debitador].                            
............................................................................ */

/*---------------------------------------------------------------*/
/*  b1crap03.p - Consulta Extrato                                */
/*---------------------------------------------------------------*/

{ sistema/generico/includes/var_oracle.i }

DEF TEMP-TABLE tt-extrato
    FIELD conta    AS INTE
    FIELD dtmvtolt AS DATE    FORMAT "99/99/9999"
    FIELD nrdocmto AS CHAR    FORMAT "x(11)"
    FIELD indebcre AS CHAR    FORMAT " x "
    fIELD vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD dsextrat LIKE craphis.dsextrat.

PROCEDURE consulta-extrato.
    DEF INPUT        PARAM p-cooper        AS CHAR. 
    DEF INPUT        PARAM p-nro-conta     AS INTE.
    DEF INPUT        PARAM p-data          AS date.
    DEF OUTPUT       PARAM TABLE FOR  tt-extrato.

    DEF VAR dt-inipesq   AS DATE NO-UNDO.
    DEF VAR aux_lshistor AS CHAR NO-UNDO.
    DEF VAR aux_dslibera AS CHAR NO-UNDO.
    DEF VAR aux_dsextrat AS CHAR NO-UNDO.
    DEF VAR aux_dsextra2 AS CHAR NO-UNDO.
    
    
   
     /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE                                 NO-UNDO.   
    DEF VAR xRoot         AS HANDLE                                 NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE                                 NO-UNDO.  
    DEF VAR xField        AS HANDLE                                 NO-UNDO. 
    DEF VAR xText         AS HANDLE                                 NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER                                NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER                                NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR                                 NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR                               NO-UNDO. 

    DEF VAR aux_cdcritic  AS INTE                                   NO-UNDO.
    DEF VAR aux_dscritic  AS CHAR                                   NO-UNDO.
    /* fim */
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF  p-data = ? THEN
        ASSIGN p-data = (crapdat.dtmvtolt - DAY(crapdat.dtmvtolt)) + 1.

    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "GENERI"          AND
                       craptab.cdempres = 0                 AND
                       craptab.cdacesso = "HSTCHEQUES"      AND
                       craptab.tpregist = 0                 NO-LOCK NO-ERROR.
                
    IF  AVAILABLE craptab   THEN
        aux_lshistor = craptab.dstextab.
    ELSE
        aux_lshistor = "999".
        
    FOR EACH tt-extrato:
        DELETE tt-extrato.
    END.

    /* ver se precisa isso */
   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }  

    /* Efetuar a chamada da rotina Oracle */ 
    RUN STORED-PROCEDURE pc_consulta_extrato_car
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT  crapcop.cdcooper,
                                            INPUT 1,            /*par_cdagenci, */
                                            INPUT 900,          /*par_nrdcaixa, */
                                            INPUT '1',          /*par_cdoperad, */
                                            INPUT p-nro-conta,  /*par_nrdconta,*/
                                            INPUT p-data,       /*par_dtiniper, */
                                            INPUT crapdat.dtmvtocd, /* par_dtfimper, */
                                            INPUT 2,            /*par_idorigem, */
                                            INPUT 1,            /*par_idseqttl, */
                                            INPUT 'CRAP003',    /*par_nmdatela,*/
                                            INPUT 0,            /*IF par_flgerlog THEN 1 ELSE 0, */
                                           OUTPUT "",           /* pr_des_erro */
                                           OUTPUT "",           /* pr_clob_ret */
                                           OUTPUT 0,            /* pr_cdcritic */
                                           OUTPUT "").          /* pr_dscritic */

  /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_consulta_extrato_car
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
  
  
      /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_consulta_extrato_car.pr_cdcritic 
                           WHEN pc_consulta_extrato_car.pr_cdcritic <> ?
           aux_dscritic = pc_consulta_extrato_car.pr_dscritic 
                           WHEN pc_consulta_extrato_car.pr_dscritic <> ?.
                           


    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" THEN
       DO:
          RUN gera_erro (INPUT  crapcop.cdcooper, /*par_cdcooper, */
                         INPUT 1 ,                /*par_cdagenci,*/
                         INPUT 900,               /*par_nrdcaixa, */
                         INPUT 1,                 /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".
       END.

     EMPTY TEMP-TABLE tt-extrato.
    
    /*Leitura do XML de retorno da proc e criacao dos registros na tt-extrato
     para visualizacao dos registros na tela */

    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_consulta_extrato_car.pr_clob_ret. 

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
                    CREATE tt-extrato.

                DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

                    xRoot2:GET-CHILD(xField,aux_cont).

                    IF xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 

                    xField:GET-CHILD(xText,1).

                    ASSIGN tt-extrato.conta    = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta".
                    ASSIGN tt-extrato.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt".
                    ASSIGN tt-extrato.nrdocmto = xText:NODE-VALUE WHEN xField:NAME = "nrdocmto".
                    ASSIGN tt-extrato.indebcre = xText:NODE-VALUE WHEN xField:NAME = "indebcre".
                    ASSIGN tt-extrato.vllanmto = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vllanmto".

                    ASSIGN aux_dsextrat        = (xText:NODE-VALUE) WHEN xField:NAME = "cdhistor".
                    ASSIGN aux_dsextra2        = xText:NODE-VALUE WHEN xField:NAME = "dshistor".
                    ASSIGN tt-extrato.dsextrat = aux_dsextrat + "-" + aux_dsextra2.

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


    RETURN "OK".
END PROCEDURE.

/* b1crap03.p */        

/* ......................................................................... */

