/* *****************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
+----------------------------------------+-------------------------------------+
| Rotina Progress                        | Rotina Oracle PLSQL                 |
+----------------------------------------+-------------------------------------+
| lista_estouros                         | EMPR0001.pc_lista_estouros          |
| lista_ocorren                          | CADA0004.pc_lista_ocorren           |
+----------------------------------------+-------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - Daniel Zimmermann    (CECRED)
   - Marcos Martini       (SUPERO)

****************************************************************************** */

/*..............................................................................

    Programa  : b1wgen0027.p
    Autor     : Guilherme
    Data      : Fevereiro/2008                Ultima Atualizacao: 19/06/2015
    
    Dados referentes ao programa:

    Objetivo  : BO ref. Rotina OCORRENCIAS da tela ATENDA.

    Alteracoes: 03/06/2008 - Incluir cdcooper nos FIND's da craphis (David).

                29/07/2008 - Correcao na procedure lista_emprestimos (David).
                
                10/11/2008 - Limpar variaveis de erro, dar return ok (Guilherme)

                04/03/2008 - Incluir rotina de extratos_emitidos_no_cash (Ze).

                28/04/2009 - Alimentar variavel aux_dsdrisco[10] = "H" (David).
                
                02/10/2009 - Aumento do campo nrterfin (Diego).
                
                23/11/2009 - Alteracao Codigo Historico (Kbase).
                
                04/12/2009 - Mudar o indrisco da crapass para crapnrc
                             (Gabriel).
                             
                18/08/2010 - Incluido os campos dtdrisco e qtdiaris na 
                             temp-table tt-ocorren referente a procedure
                             lista_ocorren (Elton).
                             
                06/10/2010 - Mostra risco e data do risco do cooperado na 
                             procedure lista_ocorren do mes atual  (Elton).
                             
                04/02/2011 - Incluir parametro par_flgcondc na procedure 
                             obtem-dados-emprestimos  (Gabriel - DB1).             
                             
                07/02/2011 - Nos extratos emitidos no TAA, mostrar a data do
                             dia que o extrato foi retirado e ajuste na busca
                             do PAC (Evandro)
                             
                04/03/2011 - Inclusao dos campos inrisctl e dtrisctl na 
                             temp-table tt-ocorren referente a procedure
                             lista_ocorren. (Fabricio)
                             
                19/04/2011 - Tratamento para o campo inrisctl na procedure
                             lista_ocorren, para não vir risco como 'AA'.
                             (Fabricio)
                             
                09/12/2011 - Sustação provisória (André R./Supero).
                
                04/07/2012 - Tratamento do cdoperad "operador" de INTE para CHAR.
                             (Lucas R.)    
                             
                30/07/2012 - Tratar prejuizo para o novo tipo de emprestimo
                             (Gabriel).    
                             
                29/11/2012 - Ajuste na procedure lista_ocorren para alimentar
                             o campo tt-ocorren.dsdrisgp - "Risco do Grupo" 
                             (Adriano). 
                                      
                06/02/2014 - Ajuste para carregar cash corretamente atraves da
                             Coop do TAA em proc extratos_emitidos_no_cash. 
                             (Jorge)
                             
                24/02/2014 - Adicionado param. de paginacao em procedure
                             obtem-dados-emprestimos em BO 0002.(Jorge)
                
                19/06/2015 - Ajuste para alimentar o campo tt-ocorren.innivris
                             na procedure lista_ocorren. (James) 
                
                25/04/2017 - Alterado rotina lista_ocorren para chamada da rotina oracle.
                             PRJ337 - Motor de Credito (Odirlei-Amcom)
..............................................................................*/

{ sistema/generico/includes/b1wgen0027tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

PROCEDURE lista_ocorren:

    DEF  INPUT  PARAM  par_cdcooper  AS  INTE                          NO-UNDO.
    DEF  INPUT  PARAM  par_cdagenci  AS  INTE /** 0-TODOS **/          NO-UNDO.
    DEF  INPUT  PARAM  par_nrdcaixa  AS  INTE                          NO-UNDO.
    DEF  INPUT  PARAM  par_cdoperad  AS  CHAR                          NO-UNDO.
    DEF  INPUT  PARAM  par_nrdconta  AS  INTE                          NO-UNDO.
    DEF  INPUT  PARAM  par_dtmvtolt  AS  DATE                          NO-UNDO.
    DEF  INPUT  PARAM  par_dtmvtopr  AS  DATE                          NO-UNDO.
    DEF  INPUT  PARAM  par_inproces  AS  INTE                          NO-UNDO.
    DEF  INPUT  PARAM  par_idorigem  AS  INTE                          NO-UNDO.
    DEF  INPUT  PARAM  par_idseqttl  AS  INTE                          NO-UNDO.
    DEF  INPUT  PARAM  par_nmdatela  AS  CHAR                          NO-UNDO.
    DEF  INPUT  PARAM  par_flgerlog  AS  LOGI                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-ocorren. 
    
    
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
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-ocorren.

   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_lista_ocorren_prog
     aux_handproc = PROC-HANDLE NO-ERROR 
                  (  INPUT par_cdcooper /* pr_cdcooper   --> Codigo da cooperativa */
                    ,INPUT par_cdagenci /* pr_cdagenci   --> Codigo de agencia */
                    ,INPUT par_nrdcaixa /* pr_nrdcaixa   --> Numero do caixa */
                    ,INPUT par_cdoperad /* pr_cdoperad   --> Codigo do operador */
                    ,INPUT par_nrdconta /* pr_nrdconta   --> Numero da conta       */                                    
                    ,INPUT par_idorigem /* pr_idorigem   --> Identificado de oriem */
                    ,INPUT par_idseqttl /* pr_idseqttl   --> sequencial do titular */
                    ,INPUT par_nmdatela /* pr_nmdatela   --> Nome da tela          */
                    ,INPUT (IF par_flgerlog THEN  "S" ELSE "N") /* pr_flgerlog   --> identificador se deve gerar log S-Sim e N-Nao  */                                    
                                                                                                        
                      /* ------ OUT ------                         */              
                    ,OUTPUT ""           /* pr_xml_ocorren --> retorna lista de ocorrencias */  
                    ,OUTPUT ""           /* pr_dscritic --> Descriçao da critica */
                    ,OUTPUT 0 ).         /* pr_cdcritic --> Codigo da critica */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_lista_ocorren_prog
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


    ASSIGN aux_cdcritic = pc_lista_ocorren_prog.pr_cdcritic
                             WHEN pc_lista_ocorren_prog.pr_cdcritic <> ?
           aux_dscritic = pc_lista_ocorren_prog.pr_dscritic
                             WHEN pc_lista_ocorren_prog.pr_dscritic <> ?.

    IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
      DO:
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1, /*sequencia*/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic). 
          RETURN "NOK".
      END. 
      
    
    /*Leitura do XML de retorno da proc e criacao dos registros na tt-ocorren */

    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_lista_ocorren_prog.pr_xml_ocorren. 

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
                    CREATE tt-ocorren.

                DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

                    xRoot2:GET-CHILD(xField,aux_cont).

                    IF xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 

                    xField:GET-CHILD(xText,1) NO-ERROR. 

                    /* Se nao vier conteudo na TAG */ 
                    IF ERROR-STATUS:ERROR             OR  
                       ERROR-STATUS:NUM-MESSAGES > 0  THEN
                                     NEXT.
                    
                    ASSIGN tt-ocorren.qtctrord = INT(xText:NODE-VALUE) WHEN xField:NAME = "qtctrord". 
                    ASSIGN tt-ocorren.qtdevolu = INT(xText:NODE-VALUE) WHEN xField:NAME = "qtdevolu". 
                    ASSIGN tt-ocorren.dtcnsspc = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtcnsspc" AND xText:NODE-VALUE <> ?. 
                    ASSIGN tt-ocorren.dtdsdsps = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtdsdsps" AND xText:NODE-VALUE <> ?. 
                    ASSIGN tt-ocorren.qtddsdev = INT(xText:NODE-VALUE) WHEN xField:NAME = "qtddsdev". 
                    ASSIGN tt-ocorren.dtdsdclq = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtdsdclq" AND xText:NODE-VALUE <> ?. 
                    ASSIGN tt-ocorren.qtddtdev = INT(xText:NODE-VALUE) WHEN xField:NAME = "qtddtdev". 
                    
                    IF xField:NAME = "flginadi" AND INT(xText:NODE-VALUE) = 1 THEN
                      ASSIGN tt-ocorren.flginadi = TRUE. 
                    ELSE
                      ASSIGN tt-ocorren.flginadi = FALSE.
                                          
                    IF xField:NAME = "flglbace" AND INT(xText:NODE-VALUE) = 1 THEN
                      ASSIGN tt-ocorren.flglbace = TRUE. 
                    ELSE
                      ASSIGN tt-ocorren.flglbace = FALSE.
                    
                    IF xField:NAME = "flgeprat" AND INT(xText:NODE-VALUE) = 1 THEN
                      ASSIGN tt-ocorren.flgeprat = TRUE. 
                    ELSE
                      ASSIGN tt-ocorren.flgeprat = FALSE.
                      
                    ASSIGN tt-ocorren.indrisco = xText:NODE-VALUE WHEN xField:NAME = "indrisco". 
                    ASSIGN tt-ocorren.nivrisco = xText:NODE-VALUE WHEN xField:NAME = "nivrisco". 
                    
                    IF xField:NAME = "flgpreju" AND INT(xText:NODE-VALUE) = 1 THEN
                      ASSIGN tt-ocorren.flgpreju = TRUE. 
                    ELSE
                      ASSIGN tt-ocorren.flgpreju = FALSE.
                    
                    IF xField:NAME = "flgjucta" AND INT(xText:NODE-VALUE) = 1 THEN
                      ASSIGN tt-ocorren.flgjucta = TRUE. 
                    ELSE
                      ASSIGN tt-ocorren.flgjucta = FALSE.
                    
                    IF xField:NAME = "flgocorr" AND INT(xText:NODE-VALUE) = 1 THEN
                      ASSIGN tt-ocorren.flgocorr = TRUE. 
                    ELSE
                      ASSIGN tt-ocorren.flgocorr = FALSE.  
                      
                    ASSIGN tt-ocorren.dtdrisco = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtdrisco" AND xText:NODE-VALUE <> ?. 
                    ASSIGN tt-ocorren.qtdiaris = INT(xText:NODE-VALUE) WHEN xField:NAME = "qtdiaris". 
                    ASSIGN tt-ocorren.inrisctl = xText:NODE-VALUE WHEN xField:NAME = "inrisctl". 
                    ASSIGN tt-ocorren.dtrisctl = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtrisctl" AND xText:NODE-VALUE <> ?. 
                    ASSIGN tt-ocorren.dsdrisgp = xText:NODE-VALUE WHEN xField:NAME = "dsdrisgp". 
                    ASSIGN tt-ocorren.innivris = INT(xText:NODE-VALUE) WHEN xField:NAME = "innivris". 

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

PROCEDURE lista_contra-ordem:

    DEF  INPUT PARAM par_cdcooper AS INTE NO-UNDO.                   
    DEF  INPUT PARAM par_cdagenci AS INTE NO-UNDO. /** 0-TODOS **/
    DEF  INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.                     
    DEF  INPUT PARAM par_cdoperad AS CHAR NO-UNDO.                
    DEF  INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-contra_ordem.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-contra_ordem.
    
    DEF VAR aux_dshistor AS CHAR NO-UNDO.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar ocorrencias de contra-ordens.".    
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR.
    
    IF   NOT AVAIL crapdat   THEN
         DO:
             ASSIGN aux_cdcritic = 1
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                 
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_cdcritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).              
                           
             RETURN "NOK".
         END.

    
    FOR EACH crapcor WHERE crapcor.cdcooper = par_cdcooper      AND
                           crapcor.nrdconta = par_nrdconta      AND 
                           crapcor.flgativo = TRUE              NO-LOCK:

        FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                           craphis.cdhistor = crapcor.cdhistor NO-LOCK NO-ERROR.
        
        IF   NOT AVAILABLE craphis   THEN
             aux_dshistor = STRING(crapcor.cdhistor).
        ELSE
             aux_dshistor = STRING(craphis.cdhistor,"9999") + 
                            "-" + craphis.dshistor.

        CREATE tt-contra_ordem.
        ASSIGN tt-contra_ordem.cdbanchq = crapcor.cdbanchq
               tt-contra_ordem.cdagechq = crapcor.cdagechq
               tt-contra_ordem.nrctachq = crapcor.nrctachq
               tt-contra_ordem.cdoperad = crapcor.cdoperad
               tt-contra_ordem.nrcheque = crapcor.nrcheque
               tt-contra_ordem.dtemscor = crapcor.dtemscor
               tt-contra_ordem.dtmvtolt = crapcor.dtmvtolt
               tt-contra_ordem.dshistor = aux_dshistor.
               
    END.  /*  Fim do FOR EACH  --  crapcor  */
    
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE lista_emprestimos:

    DEF  INPUT PARAM par_cdcooper AS INTE NO-UNDO.                   
    DEF  INPUT PARAM par_cdagenci AS INTE NO-UNDO. /** 0-TODOS **/
    DEF  INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.                     
    DEF  INPUT PARAM par_cdoperad AS CHAR NO-UNDO.                
    DEF  INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE NO-UNDO.    
    DEF  INPUT PARAM par_idorigem AS INTE NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR NO-UNDO.
       
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-emprestimos.
        
    DEF VAR aux_qtregist AS INTE NO-UNDO.

    DEF VAR h-b1wgen0002 AS HANDLE NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-emprestimos.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar ocorrencias de emprestimos.".

    RUN sistema/generico/procedures/b1wgen0002.p 
        PERSISTENT SET h-b1wgen0002.
        
    IF   NOT VALID-HANDLE(h-b1wgen0002)   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Handle invalido para h-b1wgen0002.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                              
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).
                                              
             RETURN "NOK".    
         END.
         
    RUN obtem-dados-emprestimos IN h-b1wgen0002 (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtmvtopr,
                                                 INPUT ?,
                                                 INPUT 0,
                                                 INPUT "b1wgen0027",
                                                 INPUT par_inproces,
                                                 INPUT FALSE,
                                                 INPUT FALSE, /*par_flgcondc*/
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-epr).
     
    DELETE PROCEDURE h-b1wgen0002.
    
    IF   RETURN-VALUE = "NOK" THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Conta: " + STRING(par_nrdconta) +
                                   " nao possui emprestimo.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                                       
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).               

             RETURN "NOK".    
    END.    

    FOR EACH tt-dados-epr WHERE tt-dados-epr.vlpreapg > 0 AND
                                tt-dados-epr.inprejuz = 0 NO-LOCK:

        CREATE tt-emprestimos. 
        ASSIGN tt-emprestimos.cdpesqui = SUBSTR(tt-dados-epr.cdpesqui,1,10)
               tt-emprestimos.nrctremp = tt-dados-epr.nrctremp
               tt-emprestimos.vlemprst = tt-dados-epr.vlemprst
               tt-emprestimos.vlsdeved = tt-dados-epr.vlsdeved
               tt-emprestimos.vlpreapg = tt-dados-epr.vlpreapg
              tt-emprestimos.dtultpag = tt-dados-epr.dtultpag.
    END.
                                   
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.

PROCEDURE lista_prejuizos:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.                   
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO. /** 0-TODOS **/
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.                     
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.                
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtmvtopr AS DATE NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE NO-UNDO.    
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR NO-UNDO.
        
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-prejuizos.
        
    DEF VAR h-b1wgen0002 AS HANDLE NO-UNDO.

    DEF VAR aux_qtregist AS INTE NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-prejuizos.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar ocorrencias de prejuizos.".
    
    RUN sistema/generico/procedures/b1wgen0002.p 
        PERSISTENT SET h-b1wgen0002.
        
    IF   NOT VALID-HANDLE(h-b1wgen0002)   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Handle invalido para h-b1wgen0002.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                              
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).
                                              
             RETURN "NOK".    
         END.
         
    RUN obtem-dados-emprestimos IN h-b1wgen0002 (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtmvtopr,
                                                 INPUT ?,
                                                 INPUT 0,
                                                 INPUT "b1wgen0027",
                                                 INPUT par_inproces,
                                                 INPUT FALSE,
                                                 INPUT FALSE, /*par_flgcondc*/
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-epr).
     
    DELETE PROCEDURE h-b1wgen0002.
    
    IF   RETURN-VALUE = "NOK" THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Conta: " + STRING(par_nrdconta) +
                                   " nao possui emprestimo.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                                       
             RUN proc_gerar_log (INPUT par_cdcooper,
                                 INPUT par_cdoperad,
                                 INPUT aux_dscritic,
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).               

             RETURN "NOK".    
    END.    

    FOR EACH tt-dados-epr WHERE tt-dados-epr.inprejuz > 0:

        CREATE tt-prejuizos. 
        ASSIGN tt-prejuizos.cdpesqui = SUBSTR(tt-dados-epr.cdpesqui,1,10)
               tt-prejuizos.nrctremp = tt-dados-epr.nrctremp
               tt-prejuizos.dtprejuz = tt-dados-epr.dtprejuz
               tt-prejuizos.vlprejuz = tt-dados-epr.vlprejuz
               tt-prejuizos.vlsdprej = tt-dados-epr.vlsdprej.
    END.
                                   
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.

PROCEDURE lista_spc:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.                   
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO. /** 0-TODOS **/
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.                     
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.                
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO. 
    DEF INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-spc.
    
    DEF VAR aux_flginadi AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_tpidenti AS CHAR    EXTENT 4 INIT ["Dev1-","Dev2-",
                                                   "Fia1-","Fia2-"] NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-spc.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar ocorrencias de SPC.".
    
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND 
                             crapass.nrdconta = par_nrdconta 
                             NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapass   THEN
         DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                           
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_cdcritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).                           
                           
            RETURN "NOK".
         END.                         
    
    ASSIGN aux_flginadi = IF   crapass.inadimpl = 0  THEN
                               FALSE   
                          ELSE TRUE.    
        
    IF   aux_flginadi   THEN
         FOR EACH crapspc WHERE crapspc.cdcooper = par_cdcooper   AND
                               (crapspc.nrdconta = par_nrdconta   OR
                                crapspc.nrcpfcgc = crapass.nrcpfcgc) 
                                NO-LOCK:
                      
             CREATE tt-spc.
             ASSIGN tt-spc.nrctremp = crapspc.nrctremp
                    tt-spc.dsidenti = aux_tpidenti[crapspc.tpidenti]  
                    tt-spc.dtvencto = crapspc.dtvencto
                    tt-spc.dtinclus = crapspc.dtinclus
                    tt-spc.vldivida = crapspc.vldivida
                    tt-spc.nrctrspc = crapspc.nrctrspc
                    tt-spc.dtdbaixa = crapspc.dtdbaixa.

             IF   crapspc.cdorigem = 1   THEN
                  ASSIGN tt-spc.dsorigem = "CONTA".
             ELSE
             IF   crapspc.cdorigem = 2   THEN
                  ASSIGN tt-spc.dsorigem = "DESCTO".
             ELSE
             IF   crapspc.cdorigem = 3   THEN
                  ASSIGN tt-spc.dsorigem = "EMPRES".

             FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                      crapass.nrcpfcgc = crapspc.nrcpfcgc
                                      NO-LOCK NO-ERROR.
             IF   AVAILABLE crapass   THEN                          
                  ASSIGN tt-spc.dsidenti = tt-spc.dsidenti + "Cta " +
                                STRING(crapass.nrdconta,"zzzz,zzz,9").
             ELSE
                  ASSIGN tt-spc.dsidenti = tt-spc.dsidenti + "Cpf " +
                                STRING(crapspc.nrcpfcgc).
         END.
    
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.

PROCEDURE lista_estouros:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.                   
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO. /** 0-TODOS **/
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.                     
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.                
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO. 
    DEF INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-estouros.
    
    DEF VAR aux_cdhisest AS CHAR NO-UNDO.
    DEF VAR aux_dsobserv AS CHAR NO-UNDO.
    DEF VAR aux_cdobserv AS CHAR NO-UNDO.
    DEF VAR aux_dscodant AS CHAR NO-UNDO.
    DEF VAR aux_dscodatu AS CHAR NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-estouros.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar estouros de conta.".
    
    FOR EACH crapneg WHERE crapneg.cdcooper = par_cdcooper  AND
                           crapneg.nrdconta = par_nrdconta
                           USE-INDEX crapneg1 NO-LOCK:

        ASSIGN aux_cdhisest = ""
               aux_cdobserv = ""
               aux_dsobserv = ""
               aux_dscodant = ""
               aux_dscodatu = "".

        IF   crapneg.cdhisest = 0   THEN
             aux_cdhisest = "Admissao socio".
        ELSE
        IF   crapneg.cdhisest = 1   THEN
             aux_cdhisest = "Devolucao Chq.".
        ELSE
        IF   crapneg.cdhisest = 2   THEN
             aux_cdhisest = "Alt. Tipo Conta".
        ELSE
        IF   crapneg.cdhisest = 3   THEN
             aux_cdhisest = "Alt. Sit. Conta".
        ELSE
        IF   crapneg.cdhisest = 4   THEN
             aux_cdhisest = "Credito Liquid.".
        ELSE
        IF   crapneg.cdhisest = 5   THEN
             aux_cdhisest = "Estouro".
        ELSE
        IF   crapneg.cdhisest = 6   THEN
             aux_cdhisest = "Notificacao".

        IF   (crapneg.cdhisest = 1 AND crapneg.dtfimest <> ?) THEN
             aux_dscodatu = "  ACERTADO".
                            
        IF   (crapneg.cdhisest = 1 OR (crapneg.cdhisest = 5 AND
             crapneg.cdobserv > 0))   THEN
             DO:
                 FIND crapali WHERE crapali.cdalinea = crapneg.cdobserv 
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crapali  THEN
                      IF    crapneg.cdhisest = 1 THEN
                            ASSIGN aux_dsobserv = 
                                       "Alinea "+ STRING(crapneg.cdobserv)
                                   aux_cdobserv = "".
                      ELSE
                            ASSIGN aux_cdobserv = ""
                                   aux_dsobserv = "" .
                 ELSE
                      DO:
                         ASSIGN aux_dsobserv = crapali.dsalinea
                                aux_cdobserv = STRING(crapali.cdalinea).
                      END.
             END.

        IF   crapneg.cdhisest = 2   THEN
             DO:
                 FIND craptip WHERE craptip.cdcooper = par_cdcooper AND
                                    craptip.cdtipcta = crapneg.cdtctant
                                    NO-LOCK NO-ERROR.
            
                 IF   NOT AVAILABLE craptip THEN
                      aux_dscodant = STRING(crapneg.cdtctant).
                 ELSE
                      aux_dscodant = craptip.dstipcta.
 
                 FIND craptip WHERE craptip.cdcooper = par_cdcooper AND
                                    craptip.cdtipcta = crapneg.cdtctatu
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE craptip THEN
                      aux_dscodatu = STRING(crapneg.cdtctatu).
                 ELSE
                      aux_dscodatu = craptip.dstipcta.
             END.
      
        IF   crapneg.cdhisest = 3 THEN
             DO:
                 IF   crapneg.cdtctant = 0  THEN
                      aux_dscodant = STRING(crapneg.cdtctant).
                 ELSE
                      IF   crapneg.cdtctant = 1 THEN
                           aux_dscodant = "NORMAL".
                      ELSE
                           aux_dscodant = "ENCERRADA".
  
                 IF   crapneg.cdtctatu = 0  THEN
                      aux_dscodatu = STRING(crapneg.cdtctatu).
                 ELSE
                      IF   crapneg.cdtctatu = 1 THEN
                           aux_dscodatu = "NORMAL".
                      ELSE
                           aux_dscodatu = "ENCERRADA".
             END.

        CREATE tt-estouros.
        ASSIGN tt-estouros.nrseqdig = crapneg.nrseqdig
               tt-estouros.dtiniest = crapneg.dtiniest
               tt-estouros.qtdiaest = crapneg.qtdiaest
               tt-estouros.cdhisest = aux_cdhisest
               tt-estouros.vlestour = crapneg.vlestour
               tt-estouros.nrdctabb = crapneg.nrdctabb
               tt-estouros.nrdocmto = crapneg.nrdocmto
               tt-estouros.cdobserv = aux_cdobserv
               tt-estouros.dsobserv = aux_dsobserv
               tt-estouros.vllimcre = crapneg.vllimcre
               tt-estouros.dscodant = aux_dscodant
               tt-estouros.dscodatu = aux_dscodatu.

   END.
   
   RUN proc_gerar_log (INPUT par_cdcooper,
                       INPUT par_cdoperad,
                       INPUT "",
                       INPUT aux_dsorigem,
                       INPUT aux_dstransa,
                       INPUT TRUE,
                       INPUT par_idseqttl,
                       INPUT par_nmdatela,
                       INPUT par_nrdconta,
                      OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.


PROCEDURE extratos_emitidos_no_cash:
  
    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.                   
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.                     
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dtrefere AS DATE NO-UNDO.                     
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-extcash.

    DEF VAR aux_inisenta AS LOGI                                       NO-UNDO.
    DEF VAR aux_dtmesano AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrnmterm AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdagenci AS INT                                        NO-UNDO.
    DEF VAR aux_vetormes AS CHAR          EXTENT 12
                         INIT ["JAN","FEV","MAR","ABR","MAIO","JUN",
                               "JUL","AGO","SET","OUT","NOV","DEZ"]    NO-UNDO.
             
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-extcash.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar extratos emitidos no CASH.".    
    
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                             crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
    IF   NOT AVAIL crapass   THEN
         DO:
             ASSIGN aux_cdcritic = 9
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        

             IF  par_flgerlog  THEN                            
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_cdcritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).             
             RETURN "NOK".
         END.
    
    FIND crapage WHERE crapage.cdcooper = par_cdcooper     AND
                       crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.
                      
    IF   NOT AVAILABLE crapage THEN
         DO:
             ASSIGN aux_cdcritic = 15
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
             
             IF  par_flgerlog  THEN                            
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_cdcritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).                      
                            
             RETURN "NOK".
         END.

    FOR EACH crapext WHERE crapext.cdcooper =  par_cdcooper            AND
                           crapext.dtreffim >= par_dtrefere            AND
                           crapext.nrdconta =  crapass.nrdconta        AND
                           crapext.tpextrat =  1 /* C/C */             AND
                          (crapext.insitext =  1    OR 
                           crapext.insitext =  5)                  NO-LOCK  
                           BY crapext.dtrefere:
                               
        FIND craptfn WHERE craptfn.cdcooper = crapext.cdcoptfn  AND
                           craptfn.nrterfin = crapext.nrterfin
                           NO-LOCK No-ERROR.
                             
        IF   AVAILABLE craptfn THEN
             ASSIGN aux_cdagenci = craptfn.cdagenci
                    aux_nrnmterm = STRING(craptfn.nrterfin,"9999") + " - " +
                                   craptfn.nmterfin.
        ELSE
             ASSIGN aux_cdagenci = crapass.cdagenci
                    aux_nrnmterm = "9999 - NAO ENCONTRADO".
        
        /* referencia, inicio do periodo do extrato */
        ASSIGN aux_dtmesano = aux_vetormes[MONTH(crapext.dtrefere)] +
                              "/" + STRING(YEAR(crapext.dtrefere)).
        
        IF   crapext.inisenta = 0   THEN
             aux_inisenta = TRUE.
        ELSE
        IF   crapext.inisenta = 1   THEN
             aux_inisenta = FALSE.
        
        CREATE tt-extcash.
        ASSIGN tt-extcash.dtrefere = crapext.dtreffim /* dia que foi retirado */
               tt-extcash.dtmesano = aux_dtmesano
               tt-extcash.cdagenci = aux_cdagenci
               tt-extcash.nrnmterm = aux_nrnmterm
               tt-extcash.inisenta = aux_inisenta.
    END.
                  
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).
    
    RETURN "OK".
       
END PROCEDURE.

/* ......................................................................... */


