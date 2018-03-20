/*-----------------------------------------------------------------------------

     b1crap52.p - Movimentacoes  - Depositos sem Captura
     Historicos - 403(Praca)/404(Fora Praca) - Unificados no historico 700     
     Autenticacao  - RC
                                                                 
     Ultima Atualizacao:  17/04/2017
     
     Alteracoes:
                23/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                10/09/2007 - Conversao de rotina ver_capital para BO 
                             (Sidnei/Precise)
                             
                29/01/2008 - Incluido o PA do cooperado na impressao da
                             autenticacao (Elton).

                25/05/2009 - Alteracao CDOPERAD (Kbase).
                
                05/05/2011 - Ajuste nas datas liberacao de cheque (Gabriel)
                
                05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).

				17/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							 (Adriano - P339).

                16/03/2018 - Substituida verificacao "cdtipcta = 6,7" pela
                             modalidade do tipo de conta igual a 3. PRJ366 (Lombardi).

----------------------------------------------------------------------------*/

{dbo/bo-erro1.i}
{ sistema/generico/includes/var_internet.i }

DEF VAR i-cod-erro      AS INT                                  NO-UNDO.
DEF VAR c-desc-erro     AS CHAR                                 NO-UNDO.

DEF VAR i-nro-lote      AS INTE                                 NO-UNDO.
DEF VAR aux_nrdconta    AS INTE                                 NO-UNDO.
DEF VAR i_conta         AS DEC                                  NO-UNDO.
DEF VAR aux_nrtrfcta    LIKE  craptrf.nrsconta                  NO-UNDO.

DEF VAR h_b2crap00      AS HANDLE                               NO-UNDO.
DEF VAR h_b1crap00      AS HANDLE                               NO-UNDO.

DEF VAR p-literal       AS CHAR                                 NO-UNDO.
DEF VAR p-ult-sequencia AS INTE                                 NO-UNDO.
DEF VAR p-registro      AS RECID                                NO-UNDO.

DEF VAR aux_contador    AS INTE                                 NO-UNDO.
DEF VAR dt-menor-fpraca AS DATE                                 NO-UNDO.
DEF VAR dt-maior-praca  AS DATE                                 NO-UNDO.
DEF VAR dt-menor-praca  AS DATE                                 NO-UNDO.
DEF VAR dt-maior-fpraca AS DATE                                 NO-UNDO.
DEF VAR c-docto         AS CHAR                                 NO-UNDO.
DEF VAR c-docto-salvo   AS CHAR                                 NO-UNDO.

DEF VAR de-valor        AS DEC  FORMAT "zzz,zzz,zzz,zz9.99"     NO-UNDO.
DEF VAR i-nro-docto     AS INTE                                 NO-UNDO. 
DEF VAR in99            AS INTE                                 NO-UNDO.

DEF VAR c-literal       AS CHAR FORMAT "x(48)" EXTENT 33.
DEF VAR c-nome-titular1 AS CHAR FORMAT "x(40)"                  NO-UNDO.
DEF VAR c-nome-titular2 AS CHAR FORMAT "x(40)"                  NO-UNDO.

DEF VAR aux_dsidenti    AS CHAR                                 NO-UNDO.
DEF VAR in01            AS INTE                                 NO-UNDO.

PROCEDURE valida-valores:
    
    DEF INPUT  PARAM p-cooper                AS CHAR.
    DEF INPUT  PARAM p-cod-agencia           AS INTEGER. 
    DEF INPUT  PARAM p-nro-caixa             AS INTEGER.    
    DEF INPUT  PARAM p-valor-menor-praca     aS DEC.
    DEF INPUT  PARAM p-valor-maior-praca     AS DEC.
    DEF INPUT  PARAM p-valor-menor-fpraca    AS DEC.
    DEF INPUT  PARAM p-valor-maior-fpraca    AS DEC.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).           

    IF  p-valor-menor-praca  = 0    AND
        p-valor-maior-praca  = 0    AND
        p-valor-menor-fpraca = 0    AND
        p-valor-maior-fpraca = 0    THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Valor deve ser Informado".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
        
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE valida-cheque-sem-captura:
    
    DEF INPUT  PARAM p-cooper                AS CHAR.
    DEF INPUT  PARAM p-cod-agencia           AS INTEGER. 
    DEF INPUT  PARAM p-nro-caixa             AS INTEGER.      
    DEF INPUT  PARAM p-nro-conta             AS INTEGER.    
    DEF OUTPUT PARAM p-nome-titular          AS CHAR.
    DEF OUTPUT PARAM p-data-menor-praca      AS DATE.
    DEF OUTPUT PARAM p-data-maior-praca      AS DATE.
    DEF OUTPUT PARAM p-data-menor-fpraca     AS DATE.
    DEF OUTPUT PARAM p-data-maior-fpraca     AS DATE.
    DEF OUTPUT PARAM p-conta-poupanca        AS LOG.
    DEF OUTPUT PARAM p-transferencia-conta   AS CHAR.

    DEF VAR aux_cdmodali AS INTE                                      NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                                      NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.
    
    DEF VAR h-b1wgen0001 AS HANDLE                                    NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
    ASSIGN p-nro-conta = dec(REPLACE(string(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).            

    ASSIGN p-conta-poupanca      = NO
           p-transferencia-conta = " ".
           
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    IF  p-nro-conta = 0  THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Conta deve ser Informada".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    aux_nrdconta = p-nro-conta.

    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    ASSIGN i_conta = p-nro-conta.
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT i_conta).
    DELETE PROCEDURE h_b2crap00.

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    ASSIGN aux_nrtrfcta = 0.
    DO  WHILE TRUE:
        FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                           crapass.nrdconta = aux_nrdconta      NO-ERROR.
                           
        IF  NOT AVAIL crapass  THEN  
            DO:
                ASSIGN i-cod-erro  = 9   
                       c-desc-erro = " ".           
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
            END.
            
        IF  crapass.dtelimin <> ? THEN 
            DO:
                ASSIGN i-cod-erro  = 410
                       c-desc-erro = " ".           
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                 RETURN "NOK".
            END.

        IF  CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl)) THEN 
            DO:
            
                FIND FIRST craptrf WHERE 
                           craptrf.cdcooper = crapcop.cdcooper  AND
                           craptrf.nrdconta = crapass.nrdconta  AND
                           craptrf.tptransa = 1                 AND
                           craptrf.insittrs = 2   
                           USE-INDEX craptrf1  NO-LOCK NO-ERROR.

                IF  NOT AVAIL craptrf THEN  
                    DO:
                        ASSIGN i-cod-erro  = 95 /* Titular da Conta Bloqueado */
                               c-desc-erro = " ".           
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.
                    
                ASSIGN aux_nrtrfcta = craptrf.nrsconta
                       aux_nrdconta = craptrf.nrsconta.
                NEXT.
            END.
        

        RUN sistema/generico/procedures/b1wgen0001.p
            PERSISTENT SET h-b1wgen0001.
        
        IF   VALID-HANDLE(h-b1wgen0001)   THEN
        DO:
             RUN ver_capital IN h-b1wgen0001(INPUT  crapcop.cdcooper,
                                             INPUT  aux_nrdconta,
                                             INPUT  p-cod-agencia,
                                             INPUT  p-nro-caixa,
                                             0,
                                             INPUT  crapdat.dtmvtolt,
                                             INPUT  "b1crap52",
                                             INPUT  2, /*CAIXA*/
                                             OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h-b1wgen0001.
        END.
         
        /* Verifica se houve erro */
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF   AVAILABLE tt-erro   THEN
        DO:
             ASSIGN i-cod-erro  = tt-erro.cdcritic
                    c-desc-erro = tt-erro.dscritic.
                      
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
        END.

        LEAVE.

    END. /* do while */
   
    IF  aux_nrtrfcta > 0  THEN 
        DO:   /* Transferencia de Conta */
        
            ASSIGN p-transferencia-conta = "Conta transferida do Numero  " +
                                           STRING(p-nro-conta,"zzzz,zzz,9") + 
                                           " para o numero " + 
                                           STRING(aux_nrtrfcta,"zzzz,zzz,9").
                   aux_nrdconta          = aux_nrtrfcta.
        END.

    ASSIGN p-nome-titular = crapass.nmprimtl.
    
    /*  Monta a Data de Liberacao  para Depositos da Praca e Fora da Praca */
    ASSIGN dt-menor-praca  = crapdat.dtmvtolt + 1
           dt-maior-praca  = crapdat.dtmvtolt + 1.
          
    /* Verificar se 'Data menor' eh Sabado,Domingo ou Feriado */
    DO WHILE TRUE:
    
       IF   WEEKDAY(dt-menor-praca) = 1  OR /* Domingo */
            WEEKDAY(dt-menor-praca) = 7  OR /* Sabado  */
            CAN-FIND (crapfer WHERE         /* Feriado */
                      crapfer.cdcooper = crapcop.cdcooper  AND
                      crapfer.dtferiad = dt-menor-praca)   THEN
            DO:
                ASSIGN dt-menor-praca = dt-menor-praca + 1
                       dt-maior-praca = dt-maior-praca + 1.
                NEXT.
            END.

       ASSIGN dt-menor-praca  = dt-menor-praca + 1.

       DO WHILE TRUE:
     
          IF   WEEKDAY(dt-menor-praca) = 1  OR /* Domingo */
               WEEKDAY(dt-menor-praca) = 7  OR /* Sabado  */
               CAN-FIND (crapfer WHERE         /* Feriado */
                         crapfer.cdcooper = crapcop.cdcooper  AND
                         crapfer.dtferiad = dt-menor-praca)   THEN
               DO:
                   ASSIGN dt-menor-praca = dt-menor-praca + 1.
                   NEXT.
               END.
                 
          LEAVE.
     
       END.
              
       LEAVE.
    
    END.    

    /* Fora da praca tem mesma data */
    ASSIGN dt-menor-fpraca = dt-menor-praca 
           dt-maior-fpraca = dt-maior-praca.
    
    /*---------------------------------------------------------------*/
    
    ASSIGN p-data-menor-praca  = dt-menor-praca
           p-data-maior-praca  = dt-maior-praca
           p-data-menor-fpraca = dt-menor-fpraca
           p-data-maior-fpraca = dt-maior-fpraca.
             
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_busca_modalidade_tipo
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                         INPUT crapass.cdtipcta, /* Tipo de conta */
                                        OUTPUT 0,                /* Modalidade */
                                        OUTPUT "",               /* Flag Erro */
                                        OUTPUT "").              /* Descriçao da crítica */

    CLOSE STORED-PROC pc_busca_modalidade_tipo
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdmodali = 0
           aux_des_erro = ""
           aux_dscritic = ""
           aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                          WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
           aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                          WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
           aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                          WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.
    
    IF aux_des_erro = "NOK"  THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = aux_dscritic.
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
        
    IF  aux_cdmodali = 3   THEN  
        DO: /* Conta tipo Poupanca */
            ASSIGN p-conta-poupanca = YES.
        END.  

    RETURN "OK".

END PROCEDURE.

PROCEDURE atualiza-cheque-sem-captura:
    
    DEF INPUT  PARAM p-cooper                  AS CHAR. 
    DEF INPUT  PARAM p-cod-agencia             AS INTEGER. 
    DEF INPUT  PARAM p-nro-caixa               AS INTEGER.      
    DEF INPUT  PARAM p-cod-operador            AS CHAR.
    DEF INPUT  PARAM p-nro-conta               AS INTEGER.    
    DEF INPUT  PARAM p-valor-menor-praca       AS DEC.
    DEF INPUT  PARAM p-valor-maior-praca       AS DEC.
    DEF INPUT  PARAM p-valor-menor-fpraca      AS DEC.
    DEF INPUT  PARAM p-valor-maior-fpraca      AS DEC.
    DEF INPUT  PARAM p-data-menor-praca        aS DATE.
    DEF INPUT  PARAM p-data-maior-praca        AS DATE.
    DEF INPUT  PARAM p-data-menor-fpraca       AS DATE.
    DEF INPUT  PARAM p-data-maior-fpraca       AS DATE.
    DEF INPUT  PARAM p-nome-titular            AS CHAR.
    DEF INPUT  PARAM p-dsidenti                AS CHAR.
    DEF OUTPUT PARAM p-literal-autentica       AS CHAR.
    DEF OUTPUT PARAM p-ult-sequencia-autentica AS INTE.
    DEF OUTPUT PARAM p-nro-docto               AS INTE.
           
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
    ASSIGN p-nro-conta = dec(REPLACE(string(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.
  
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    ASSIGN aux_nrdconta = p-nro-conta.
   
    /*--- Verifica se Houve Transferencia de Conta --*/
    ASSIGN aux_nrtrfcta = 0.
    DO  WHILE TRUE:
        FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                           crapass.nrdconta = aux_nrdconta    
                           NO-LOCK NO-ERROR.
             
        IF  CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl)) THEN 
            DO:
          
                FIND FIRST craptrf WHERE 
                           craptrf.cdcooper = crapcop.cdcooper   AND
                           craptrf.nrdconta = crapass.nrdconta   AND
                           craptrf.tptransa = 1                  AND
                           craptrf.insittrs = 2   
                           USE-INDEX craptrf1 NO-LOCK NO-ERROR.
                        
                ASSIGN aux_nrtrfcta = craptrf.nrsconta
                       aux_nrdconta = craptrf.nrsconta.
                NEXT.
            END.
        LEAVE.
    END. /* do while */
    IF  aux_nrtrfcta > 0  THEN    /* Transferencia de Conta */
        ASSIGN aux_nrdconta = aux_nrtrfcta.
    /*-------------------------------------------------*/
    
    ASSIGN p-nro-conta = aux_nrdconta.
    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtolt  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND /* Fixo */
                       craplot.nrdolote = i-nro-lote 
                       NO-ERROR.
         
    IF  NOT AVAIL craplot THEN 
        DO:
            CREATE craplot.
            ASSIGN 
               craplot.cdcooper = crapcop.cdcooper
               craplot.dtmvtolt = crapdat.dtmvtolt
               craplot.cdagenci = p-cod-agencia   
               craplot.cdbccxlt = 11              
               craplot.nrdolote = i-nro-lote
               craplot.tplotmov = 1
               craplot.cdoperad = p-cod-operador
               craplot.cdhistor = 0 /* 700 */  /* Deposito */
               craplot.nrdcaixa = p-nro-caixa
               craplot.cdopecxa = p-cod-operador.
        END.
 
    ASSIGN c-docto-salvo = STRING(time).

    /*------*/
    ASSIGN i-nro-docto = inte(c-docto-salvo)
           p-nro-docto = INTE(c-docto-salvo)
           de-valor    = p-valor-menor-praca  + 
                         p-valor-maior-praca  +
                         p-valor-menor-fpraca +
                         p-valor-maior-fpraca.
   
    /*--- Grava Autenticacao Arquivo/Spool --*/
    RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
    RUN grava-autenticacao  IN h_b1crap00 (INPUT  p-cooper,
                                           INPUT  p-cod-agencia,
                                           INPUT  p-nro-caixa,
                                           INPUT  p-cod-operador,
                                           INPUT  de-valor,
                                           INPUT  dec(i-nro-docto),
                                           INPUT  no,
                                           INPUT  "1",  
                                           INPUT  NO,  
                                           INPUT  700,
                                           INPUT  ?, 
                                           INPUT  0, 
                                           INPUT  0, 
                                           INPUT  0,
                                           OUTPUT p-literal,
                                           OUTPUT p-ult-sequencia,
                                           OUTPUT p-registro).
    DELETE PROCEDURE h_b1crap00.
    
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
    /*------*/

    IF  p-valor-menor-praca > 0  THEN 
        DO:
            ASSIGN c-docto = c-docto-salvo + "1".

            /*--- Verifica se Lancamento ja Existe ---*/
            FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper      AND
                               craplcm.dtmvtolt = crapdat.dtmvtolt      AND
                               craplcm.cdagenci = p-cod-agencia         AND
                               craplcm.cdbccxlt = 11                    AND
                               craplcm.nrdolote = i-nro-lote            AND
                               craplcm.nrseqdig = craplot.nrseqdig + 1 
                               USE-INDEX craplcm3 NO-ERROR.

            IF  AVAIL craplcm THEN 
                DO: 
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Lancamento  ja existente".           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.

            FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                               craplcm.dtmvtolt = crapdat.dtmvtolt  AND
                               craplcm.cdagenci = p-cod-agencia     AND
                               craplcm.cdbccxlt = 11                AND
                               craplcm.nrdolote = i-nro-lote        AND
                               craplcm.nrdctabb = p-nro-conta       AND
                               craplcm.nrdocmto = inte(c-docto) 
                               USE-INDEX craplcm1 NO-ERROR.
                            
            IF  AVAIL craplcm THEN  
                DO: 
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Lancamento(Primario) ja existente".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            /*----------------------------------------------------*/
       
            CREATE craplcm.
            ASSIGN craplcm.cdcooper = crapcop.cdcooper
                   craplcm.dtmvtolt = crapdat.dtmvtolt
                   craplcm.cdagenci = p-cod-agencia
                   craplcm.cdbccxlt = 11
                   craplcm.nrdolote = i-nro-lote
                   craplcm.dsidenti = p-dsidenti
                   craplcm.nrdconta = p-nro-conta
                   craplcm.nrdocmto = inte(c-docto)
                   craplcm.vllanmto = p-valor-menor-praca
                   craplcm.cdhistor = 403
                   craplcm.nrseqdig = craplot.nrseqdig + 1 
                   craplcm.nrdctabb = p-nro-conta
                   craplcm.nrdctitg = STRING(p-nro-conta,"99999999")
                   craplcm.nrautdoc = p-ult-sequencia
                   craplcm.cdpesqbb = "CRAP52".

            CREATE crapdpb.
            ASSIGN crapdpb.cdcooper = crapcop.cdcooper
                   crapdpb.nrdconta = p-nro-conta
                   crapdpb.dtliblan = p-data-menor-praca
                   crapdpb.cdhistor = 403
                   crapdpb.nrdocmto = INTE(c-docto)
                   crapdpb.dtmvtolt = crapdat.dtmvtolt
                   crapdpb.cdagenci = p-cod-agencia
                   crapdpb.cdbccxlt = 11
                   crapdpb.nrdolote = i-nro-lote
                   crapdpb.vllanmto = p-valor-menor-praca
                   crapdpb.inlibera = 1.

            ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1 
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.qtinfoln = craplot.qtinfoln + 1
                   craplot.vlcompcr = craplot.vlcompcr + p-valor-menor-praca
                   craplot.vlinfocr = craplot.vlinfocr + p-valor-menor-praca.
        END.
        
    IF  p-valor-maior-praca > 0  THEN 
        DO:
            ASSIGN c-docto = c-docto-salvo + "2".
        
            /*--- Verifica se Lancamento ja Existe ---*/
            FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper      AND
                               craplcm.dtmvtolt = crapdat.dtmvtolt      AND
                               craplcm.cdagenci = p-cod-agencia         AND
                               craplcm.cdbccxlt = 11                    AND
                               craplcm.nrdolote = i-nro-lote            AND
                               craplcm.nrseqdig = craplot.nrseqdig + 1 
                               USE-INDEX craplcm3 NO-ERROR.
                                                                        
            IF  AVAIL craplcm THEN 
                DO: 
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Lancamento ja existente".           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.

            FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                               craplcm.dtmvtolt = crapdat.dtmvtolt  AND
                               craplcm.cdagenci = p-cod-agencia     AND
                               craplcm.cdbccxlt = 11                AND
                               craplcm.nrdolote = i-nro-lote        AND
                               craplcm.nrdctabb = p-nro-conta       AND
                               craplcm.nrdocmto = inte(c-docto) 
                               USE-INDEX craplcm1 NO-ERROR.
             
            IF  AVAIL craplcm THEN 
                DO: 
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Lancamento(Primario) ja existente".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            /*----------------------------------------------------*/

            CREATE craplcm.
            ASSIGN craplcm.cdcooper = crapcop.cdcooper
                   craplcm.dtmvtolt = crapdat.dtmvtolt
                   craplcm.cdagenci = p-cod-agencia
                   craplcm.cdbccxlt = 11
                   craplcm.nrdolote = i-nro-lote
                   craplcm.nrdconta = p-nro-conta
                   craplcm.nrdocmto = inte(c-docto)
                   craplcm.dsidenti = p-dsidenti
                   craplcm.vllanmto = p-valor-maior-praca
                   craplcm.cdhistor = 403
                   craplcm.nrseqdig = craplot.nrseqdig + 1 
                   craplcm.nrdctabb = p-nro-conta
                   craplcm.nrdctitg = STRING(p-nro-conta,"99999999")
                   craplcm.nrautdoc = p-ult-sequencia
                   craplcm.cdpesqbb = "CRAP52".

            CREATE crapdpb.
            ASSIGN crapdpb.cdcooper = crapcop.cdcooper
                   crapdpb.nrdconta = p-nro-conta
                   crapdpb.dtliblan = p-data-maior-praca
                   crapdpb.cdhistor = 403
                   crapdpb.nrdocmto = INTE(c-docto)
                   crapdpb.dtmvtolt = crapdat.dtmvtolt
                   crapdpb.cdagenci = p-cod-agencia
                   crapdpb.cdbccxlt = 11
                   crapdpb.nrdolote = i-nro-lote
                   crapdpb.vllanmto = p-valor-maior-praca
                   crapdpb.inlibera = 1.
   
            ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1 
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.qtinfoln = craplot.qtinfoln + 1
                   craplot.vlcompcr = craplot.vlcompcr + p-valor-maior-praca
                   craplot.vlinfocr = craplot.vlinfocr + p-valor-maior-praca.
        END.

    IF  p-valor-menor-fpraca > 0  THEN 
        DO:
            ASSIGN c-docto = c-docto-salvo + "3".
            
            /*--- Verifica se Lancamento ja Existe ---*/
            FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper      AND
                               craplcm.dtmvtolt = crapdat.dtmvtolt      AND
                               craplcm.cdagenci = p-cod-agencia         AND
                               craplcm.cdbccxlt = 11                    AND
                               craplcm.nrdolote = i-nro-lote            AND
                               craplcm.nrseqdig = craplot.nrseqdig + 1 
                               USE-INDEX craplcm3 NO-ERROR.
                               
            IF  AVAIL craplcm THEN 
                DO: 
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Lancamento  ja existente".           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.

            FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                               craplcm.dtmvtolt = crapdat.dtmvtolt  AND
                               craplcm.cdagenci = p-cod-agencia     AND
                               craplcm.cdbccxlt = 11                AND
                               craplcm.nrdolote = i-nro-lote        AND
                               craplcm.nrdctabb = p-nro-conta       AND
                               craplcm.nrdocmto = inte(c-docto)     
                               USE-INDEX craplcm1 NO-ERROR.
             
            IF  AVAIL craplcm THEN 
                DO: 
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Lancamento(Primario) ja existente". 
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            /*----------------------------------------------------*/

            CREATE craplcm.
            ASSIGN craplcm.cdcooper = crapcop.cdcooper
                   craplcm.dtmvtolt = crapdat.dtmvtolt
                   craplcm.cdagenci = p-cod-agencia
                   craplcm.cdbccxlt = 11
                   craplcm.nrdolote = i-nro-lote
                   craplcm.dsidenti = p-dsidenti
                   craplcm.nrdconta = p-nro-conta
                   craplcm.nrdocmto = inte(c-docto)
                   craplcm.vllanmto = p-valor-menor-fpraca
                   craplcm.cdhistor = 404
                   craplcm.nrseqdig = craplot.nrseqdig + 1 
                   craplcm.nrdctabb = p-nro-conta
                   craplcm.nrdctitg = STRING(p-nro-conta,"99999999")
                   craplcm.nrautdoc = p-ult-sequencia
                   craplcm.cdpesqbb = "CRAP52".
   
            CREATE crapdpb.
            ASSIGN crapdpb.cdcooper = crapcop.cdcooper
                   crapdpb.nrdconta = p-nro-conta
                   crapdpb.dtliblan = p-data-menor-fpraca
                   crapdpb.cdhistor = 404
                   crapdpb.nrdocmto = INTE(c-docto)
                   crapdpb.dtmvtolt = crapdat.dtmvtolt
                   crapdpb.cdagenci = p-cod-agencia
                   crapdpb.cdbccxlt = 11
                   crapdpb.nrdolote = i-nro-lote
                   crapdpb.vllanmto = p-valor-menor-fpraca
                   crapdpb.inlibera = 1.
   
            ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1 
                   craplot.qtcompln  = craplot.qtcompln + 1
                   craplot.qtinfoln  = craplot.qtinfoln + 1
                   craplot.vlcompcr  = craplot.vlcompcr + p-valor-menor-fpraca
                   craplot.vlinfocr  = craplot.vlinfocr + p-valor-menor-fpraca.
        END.
        
    IF  p-valor-maior-fpraca > 0  THEN 
        DO:
            ASSIGN c-docto = c-docto-salvo + "4".

            /*--- Verifica se Lancamento ja Existe ---*/
            FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper      AND
                               craplcm.dtmvtolt = crapdat.dtmvtolt      AND
                               craplcm.cdagenci = p-cod-agencia         AND
                               craplcm.cdbccxlt = 11                    AND
                               craplcm.nrdolote = i-nro-lote            AND
                               craplcm.nrseqdig = craplot.nrseqdig + 1 
                               USE-INDEX craplcm3 NO-ERROR.
                               
            IF  AVAIL craplcm THEN 
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Lancamento  ja existente".           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.

            FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                               craplcm.dtmvtolt = crapdat.dtmvtolt  AND
                               craplcm.cdagenci = p-cod-agencia     AND
                               craplcm.cdbccxlt = 11                AND
                               craplcm.nrdolote = i-nro-lote        AND
                               craplcm.nrdctabb = p-nro-conta       AND
                               craplcm.nrdocmto = inte(c-docto)     
                               USE-INDEX craplcm1 NO-ERROR.
                               
            IF  AVAIL craplcm THEN 
                DO: 
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Lancamento(Primario) ja existente".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            /*----------------------------------------------------*/
        
            CREATE craplcm.
            ASSIGN craplcm.cdcooper = crapcop.cdcooper
                   craplcm.dtmvtolt = crapdat.dtmvtolt
                   craplcm.cdagenci = p-cod-agencia
                   craplcm.cdbccxlt = 11
                   craplcm.nrdolote = i-nro-lote
                   craplcm.dsidenti = p-dsidenti
                   craplcm.nrdconta = p-nro-conta
                   craplcm.nrdocmto = inte(c-docto)
                   craplcm.vllanmto = p-valor-maior-fpraca 
                   craplcm.cdhistor = 404
                   craplcm.nrseqdig = craplot.nrseqdig + 1 
                   craplcm.nrdctabb = p-nro-conta
                   craplcm.nrdctitg = STRING(p-nro-conta,"99999999")
                   craplcm.nrautdoc = p-ult-sequencia
                   craplcm.cdpesqbb = "CRAP52".

            CREATE crapdpb.
            ASSIGN crapdpb.cdcooper = crapcop.cdcooper
                   crapdpb.nrdconta = p-nro-conta
                   crapdpb.dtliblan = p-data-maior-fpraca
                   crapdpb.cdhistor = 404
                   crapdpb.nrdocmto = INTE(c-docto)
                   crapdpb.dtmvtolt = crapdat.dtmvtolt
                   crapdpb.cdagenci = p-cod-agencia
                   crapdpb.cdbccxlt = 11
                   crapdpb.nrdolote = i-nro-lote
                   crapdpb.vllanmto = p-valor-maior-fpraca
                   crapdpb.inlibera = 1.
   
            ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1 
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.qtinfoln = craplot.qtinfoln + 1
                   craplot.vlcompcr = craplot.vlcompcr + p-valor-maior-fpraca
                   craplot.vlinfocr = craplot.vlinfocr + p-valor-maior-fpraca.
        END.

   /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/
   
    ASSIGN c-nome-titular1 = " "
           c-nome-titular2 = " ".
           
    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                       crapass.nrdconta = craplcm.nrdconta  NO-ERROR.
    
    IF  AVAIL crapass THEN
	   DO:
           ASSIGN c-nome-titular1 = crapass.nmprimtl.

		   IF crapass.inpessoa = 1 THEN
			  DO:
				  FOR FIRST crapttl FIELDS(crapttl.nmextttl)
				                     WHERE crapttl.cdcooper = crapass.cdcooper AND
									       crapttl.nrdconta = crapass.nrdconta AND
									       crapttl.idseqttl = 2 
									       NO-LOCK:

					 ASSIGN c-nome-titular2 = crapttl.nmextttl.

                  END.

			  END.
	   END.

	
                   
    ASSIGN c-literal = " ".
    ASSIGN c-literal[1]  = 
           TRIM(crapcop.nmrescop) +  " - " + TRIM(crapcop.nmextcop) 
           c-literal[2]  = " "
           c-literal[3]  =
           STRING(crapdat.dtmvtolt,"99/99/99") + " " +
           STRING(TIME,"HH:MM:SS")     +  " PA  " + 
           STRING(p-cod-agencia,"999") + 
           "  CAIXA: " +
           STRING(p-nro-caixa,"Z99") + "/" +
           SUBSTR(p-cod-operador,1,10)  
           c-literal[4]  = " " 
           c-literal[5]  =
           "      ** COMPROVANTE DE DEPOSITO " + 
           STRING(i-nro-docto,"ZZZ,ZZ9")  + " **" 
           c-literal[6]  = " " 
           c-literal[7]  = "CONTA: "    +
           TRIM(STRING(craplcm.nrdconta,"zzzz,zzz,9")) +
           "   PA:  " + TRIM(STRING(crapass.cdagenci,"zz9")) 
           c-literal[8 ] = "       "    + 
           TRIM(c-nome-titular1)
           c-literal[9]  = "       "    + 
           TRIM(c-nome-titular2)
           c-literal[10] = " ".     

    IF  p-dsidenti <> "  " THEN
        ASSIGN c-literal[11] = "DEPOSITADO POR"  
               c-literal[12] = TRIM(p-dsidenti)  
               c-literal[13] = " ".  
           
    ASSIGN c-literal[14] = "   TIPO DE DEPOSITO     VALOR EM R$ LIBERACAO EM"    
           c-literal[15] = "------------------------------------------------".

   
    IF  p-valor-menor-praca > 0  THEN   
        ASSIGN  c-literal[16] = "CHEQ.PRACA MENOR...: " +  
                                STRING(p-valor-menor-praca,"ZZZ,ZZZ,ZZ9.99") + 
                                "   " + 
                                STRING(p-data-menor-praca,"99/99/9999").
    
    IF  p-valor-maior-praca > 0  THEN  
        ASSIGN  c-literal[17] = "CHEQ.PRACA MAIOR...: " +  
                                STRING(p-valor-maior-praca,"ZZZ,ZZZ,ZZ9.99") + 
                                "   " + 
                                STRING(p-data-maior-praca,"99/99/9999").
   
    IF  p-valor-menor-fpraca > 0  THEN  
        ASSIGN  c-literal[18] = "CHEQ.F.PRACA MENOR.: " +  
                                STRING(p-valor-menor-fpraca,"ZZZ,ZZZ,ZZ9.99") +
                                "   " + 
                                STRING(p-data-menor-fpraca,"99/99/9999").
    
    IF  p-valor-maior-fpraca > 0  THEN   
        ASSIGN  c-literal[19] = "CHEQ.F.PRACA MAIOR.: " +  
                                STRING(p-valor-maior-fpraca,"ZZZ,ZZZ,ZZ9.99") +
                                "   " + 
                                STRING(p-data-maior-fpraca,"99/99/9999").
   
    ASSIGN c-literal[20] = " " 
           c-literal[21] = "TOTAL DEPOSITADO...: " + 
                           STRING(de-valor,"ZZZ,ZZZ,ZZ9.99") 
           c-literal[22] = " "
           c-literal[23] = p-literal
           c-literal[24] = " "
           c-literal[25] = " "
           c-literal[26] = " "
           c-literal[27] = " "
           c-literal[28] = " "
           c-literal[29] = " "
           c-literal[30] = " "
           c-literal[31] = " "
           c-literal[32] = " "
           c-literal[33] = " ".
          
    ASSIGN p-literal-autentica = STRING(c-literal[1],"x(48)")   + 
                                 STRING(c-literal[2],"x(48)")   + 
                                 STRING(c-literal[3],"x(48)")   + 
                                 STRING(c-literal[4],"x(48)")   + 
                                 STRING(c-literal[5],"x(48)")   + 
                                 STRING(c-literal[6],"x(48)")   + 
                                 STRING(c-literal[7],"x(48)")   + 
                                 STRING(c-literal[8],"x(48)")   + 
                                 STRING(c-literal[9],"x(48)")   + 
                                 STRING(c-literal[10],"x(48)").   
                                  
    IF  c-literal[12] <> " " THEN
        ASSIGN p-literal-autentica =
               p-literal-autentica + STRING(c-literal[11],"x(48)")
               p-literal-autentica =
               p-literal-autentica + STRING(c-literal[12],"x(48)")
               p-literal-autentica =
               p-literal-autentica + STRING(c-literal[13],"x(48)").

    ASSIGN p-literal-autentica =
           p-literal-autentica + STRING(c-literal[14],"x(48)")
           p-literal-autentica =
           p-literal-autentica + STRING(c-literal[15],"x(48)").

    IF  c-literal[16] <> " " THEN
        ASSIGN p-literal-autentica =
               p-literal-autentica + STRING(c-literal[16]).
    IF  c-literal[17] <> " " THEN
        ASSIGN p-literal-autentica =
               p-literal-autentica + STRING(c-literal[17]).
    IF  c-literal[18] <> " " THEN
        ASSIGN p-literal-autentica =
               p-literal-autentica + STRING(c-literal[18]).
    IF  c-literal[19] <> " " THEN
        ASSIGN p-literal-autentica = 
               p-literal-autentica + STRING(c-literal[19]).

    ASSIGN p-literal-autentica = p-literal-autentica             +
                                 STRING(c-literal[20],"x(48)")   + 
                                 STRING(c-literal[21],"x(48)")   + 
                                 STRING(c-literal[22],"x(48)")   + 
                                 STRING(c-literal[23],"x(48)")   + 
                                 STRING(c-literal[24],"x(48)")   +
                                 STRING(c-literal[25],"x(48)")   + 
                                 STRING(c-literal[26],"x(48)")   + 
                                 STRING(c-literal[27],"x(48)")   + 
                                 STRING(c-literal[28],"x(48)")   + 
                                 STRING(c-literal[29],"x(48)")   + 
                                 STRING(c-literal[30],"x(48)")   + 
                                 STRING(c-literal[31],"x(48)")   + 
                                 STRING(c-literal[32],"x(48)")   + 
                                 STRING(c-literal[33],"x(48)").

    ASSIGN p-ult-sequencia-autentica = p-ult-sequencia.
    /*-----*/

    ASSIGN in99 = 0. 
    DO  WHILE TRUE:
        
        ASSIGN in99 = in99 + 1.
        FIND crapaut WHERE RECID(crapaut) = p-registro 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapaut   THEN  
            DO:
                IF  LOCKED crapaut   THEN 
                    DO:
                        IF  in99 <  100  THEN 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Tabela CRAPAUT em uso ".           
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                RETURN "NOK".
                            END.
                    END.
            END.
        ELSE 
            DO:
                ASSIGN  crapaut.dslitera = p-literal-autentica.
                RELEASE crapaut.
                LEAVE.
            END.
    END. /* DO  WHILE TRUE */ 
    RELEASE craplot.
    
    RETURN "OK".
END PROCEDURE.

PROCEDURE  valida_identificacao_dep:
              
    DEF INPUT  PARAM p-cooper         AS CHAR.
    DEF INPUT  PARAM p-cod-agencia    AS INTEGER.  /* Cod. Agencia       */
    DEF INPUT  PARAM p-nro-caixa      AS INTEGER.  /* Numero Caixa       */
    DEF INPUT  PARAM p-nro-conta      AS INTEGER.  /* Nro Conta          */
    DEF INPUT  PARAM p-dsidenti       AS CHAR.
           
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN aux_nrdconta = p-nro-conta.
   
    IF  LENGTH(STRING(aux_nrdconta)) <= 8 THEN 
        DO: /* Nao Conta Invest. */

            /*--- Verifica se Houve Transferencia de Conta --*/
            ASSIGN aux_nrtrfcta = 0.
            DO  WHILE TRUE:
                FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                                   crapass.nrdconta = aux_nrdconta 
                                   NO-ERROR.
                                   
                IF  CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
                    DO:
          
                        FIND FIRST craptrf WHERE 
                                   craptrf.cdcooper = crapcop.cdcooper  AND
                                   craptrf.nrdconta = crapass.nrdconta  AND
                                   craptrf.tptransa = 1                 AND
                                   craptrf.insittrs = 2   
                                   USE-INDEX craptrf1 NO-LOCK NO-ERROR.
                            
                        ASSIGN aux_nrtrfcta = craptrf.nrsconta
                               aux_nrdconta = craptrf.nrsconta.
                        NEXT.
                    END.
                LEAVE.
            END. /* do while */
            IF  aux_nrtrfcta > 0  THEN    /* Transferencia de Conta */
                ASSIGN aux_nrdconta = aux_nrtrfcta.
            /*-------------------------------------------------*/
        END.  

    ASSIGN p-nro-conta = aux_nrdconta.

    ASSIGN aux_dsidenti = p-dsidenti.
                 
    ASSIGN in01        = 1
           i-cod-erro  = 0
           c-desc-erro = " ".

    DO  WHILE in01 LE 50:
        IF  SUBSTR(aux_dsidenti,in01,1) = " " OR
            SUBSTR(aux_dsidenti,in01,1) = "A" OR  
            SUBSTR(aux_dsidenti,in01,1) = "B" OR   
            SUBSTR(aux_dsidenti,in01,1) = "C" OR                       
            SUBSTR(aux_dsidenti,in01,1) = "D" OR
            SUBSTR(aux_dsidenti,in01,1) = "E" OR   
            SUBSTR(aux_dsidenti,in01,1) = "F" OR  
            SUBSTR(aux_dsidenti,in01,1) = "G" OR   
            SUBSTR(aux_dsidenti,in01,1) = "H" OR   
            SUBSTR(aux_dsidenti,in01,1) = "I" OR                              
            SUBSTR(aux_dsidenti,in01,1) = "J" OR                             
            SUBSTR(aux_dsidenti,in01,1) = "K" OR                          
            SUBSTR(aux_dsidenti,in01,1) = "L" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "M" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "N" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "O" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "P" OR 
            SUBSTR(aux_dsidenti,in01,1) = "Q" OR                     
            SUBSTR(aux_dsidenti,in01,1) = "R" OR   
            SUBSTR(aux_dsidenti,in01,1) = "S" OR                       
            SUBSTR(aux_dsidenti,in01,1) = "T" OR
            SUBSTR(aux_dsidenti,in01,1) = "U" OR   
            SUBSTR(aux_dsidenti,in01,1) = "V" OR 
            SUBSTR(aux_dsidenti,in01,1) = "X" OR   
            SUBSTR(aux_dsidenti,in01,1) = "W" OR   
            SUBSTR(aux_dsidenti,in01,1) = "Y" OR                              
            SUBSTR(aux_dsidenti,in01,1) = "Z" OR                             
            SUBSTR(aux_dsidenti,in01,1) = "a" OR                          
            SUBSTR(aux_dsidenti,in01,1) = "b" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "c" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "d" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "d" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "e" OR 
            SUBSTR(aux_dsidenti,in01,1) = "f" OR                     
            SUBSTR(aux_dsidenti,in01,1) = "g" OR   
            SUBSTR(aux_dsidenti,in01,1) = "h" OR                       
            SUBSTR(aux_dsidenti,in01,1) = "i" OR
            SUBSTR(aux_dsidenti,in01,1) = "j" OR   
            SUBSTR(aux_dsidenti,in01,1) = "k" OR 
            SUBSTR(aux_dsidenti,in01,1) = "l" OR   
            SUBSTR(aux_dsidenti,in01,1) = "m" OR   
            SUBSTR(aux_dsidenti,in01,1) = "n" OR                              
            SUBSTR(aux_dsidenti,in01,1) = "o" OR                             
            SUBSTR(aux_dsidenti,in01,1) = "p" OR                          
            SUBSTR(aux_dsidenti,in01,1) = "q" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "r" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "s" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "t" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "u" OR 
            SUBSTR(aux_dsidenti,in01,1) = "v" OR                     
            SUBSTR(aux_dsidenti,in01,1) = "x" OR   
            SUBSTR(aux_dsidenti,in01,1) = "w" OR                       
            SUBSTR(aux_dsidenti,in01,1) = "y" OR
            SUBSTR(aux_dsidenti,in01,1) = "z" OR   
            SUBSTR(aux_dsidenti,in01,1) = "0" OR   
            SUBSTR(aux_dsidenti,in01,1) = "1" OR   
            SUBSTR(aux_dsidenti,in01,1) = "2" OR                              
            SUBSTR(aux_dsidenti,in01,1) = "3" OR                             
            SUBSTR(aux_dsidenti,in01,1) = "4" OR                          
            SUBSTR(aux_dsidenti,in01,1) = "5" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "6" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "7" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "8" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "9" THEN 
            DO:
                .
            END.
            ELSE 
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = 
                          "Ident.Deposito preenchido com caracteres invalidos".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    LEAVE.
                END.
            ASSIGN in01 = in01 + 1.
    END.
    IF  c-desc-erro <> " " THEN
        RETURN "NOK".
            
    IF  crapass.flgiddep = YES  AND
        p-dsidenti       = " "  THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Ident.Deposito obrigatorio para esta conta".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
           RETURN "NOK".
        END.

    RETURN "OK".
END PROCEDURE.

/* b1crap52.p */

/* .......................................................................... */

 
