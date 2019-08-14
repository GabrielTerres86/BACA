/*.............................................................................
    
    Programa: b1wgen0095.p
    Autor   : André - DB1
    Data    : Junho/2011                         Ultima Atualizacao: 18/05/2019

    Dados referentes ao programa:

    Objetivo  : BO ref. a Contra-Ordens/Avisos.

    Alteracoes: 12/12/2011 - Sustação provisória (André R./Supero).

                16/12/2011 - Tratamento para CPF/CNPJ na impressao (Ze).

                16/04/2012 - Ajuste na impressao da Contra-Ordem (Ze).

                25/04/2012 - Inclusão de log da Contra-Ordem (Lucas R.)

                11/06/2012 - Substituição do FIND craptab para os registros 
                             CONTACONVE pela chamada do fontes ver_ctace.p
                             (Lucas R.)

                20/07/2012 - Ajuste na alteracao de 25/04/2012. Nao estava
                             funcionando corretamente no Ayllos WEB (David).

                17/10/2012 - Nova chamada da procedure valida_operador_migrado
                             da b1wgen9998 para controle de contas e operadores
                             migrados (David Kruger).

                14/03/2013 - Ajuste na cobranca de tarifa quando altera de
                             provisoria para permamente (Ze).

                14/06/2013 - Retirar verificação se o cheque esta em Custodia/
                             Desconto (Trf. 67034) - Ze.     

                23/07/2013 - Ajuste para melhorar o desempenho no crapcor (Ze)

                13/12/2013 - Alteracao referente a integracao Progress X 
                             Dataserver Oracle Inclusao do VALIDATE
                             ( Guilherme / SUPERO)
                             
                11/09/2014 - Incluido tratamento nas rotinas valida-ctachq e
                             trata-custodia-desconto devido a migracao da 
                             4-concredi e 15-credimilsul (Odirlei/AMcom). 
                
                25/11/2014 - Incluir clausula no craptco flgativo = TRUE
                             (Lucas R./Rodrigo)
                
                09/12/2014 - Incluida validação de contas centralizadoras
                             SD - 162810 (Kelvin)
                
                09/12/2014 - Alteração feita para que as cooperativas possam 
                             eliminar contra-ordens antigas (criadas antes de 01/04/2012) 
                             com as alineas 20 e 28. (Kelvin - SD 219790)
               
               05/01/2015 - Alterada a crítica 947 para "Contra-ordem provisória realizada em 
                            + crapcor.dtemscor." (Kelvin - SD 238436)
                            
               22/01/2015 - Ajustado leitura da craptco no procediemnto valida-ctachq
                            SD 246323 (Odirlei-AMcom)
               
               26/02/2015 - Ajustes nas validações de inclusão de novas contra ordens,
                            onde não se pode cadastrar mais do que uma contra ordem 
                            por cheque, provisória ou permanente. SD 251046 (Kelvin)
                            
               22/12/2015 - Ajustar as mensagem de critica das validacoes da 
                            crapcor na procedure busca-contra-ordens
                            (Douglas - Melhoria 100)
                            
               03/06/2016 - Incluir procedures valida-conta-migrada e valida-agencia
                            para validar se conta e migrada e agencia informada e 
                            valida (Lucas Ranghetti #449707)

               02/12/2016 - Incorporacao Transulcred (Guilherme/SUPERO)

               24/01/2017 - Ajustes para verificar o campo cdagebcb na crapcop
                            para liberar o campo agencia na tela mantal
                            (Tiago/Elton SD549323)
              
               09/10/2017 - Alterar a ordem da gravacao da variavel aux_flagprov dentro 
                            procedure inclui-contra (Lucas Ranghetti #744217)
							
                26/10/2018 - Correcao para permitir incluir uma contra ordem apenas para cheques
                             com data de compensacao maior ou igual ao ultima dia util em relacao
                       a data atual de movimento (d - 1)
                       (Jonata - Mouts SCTASK0014736).
                       
               18/05/2019 - Perca de aprovacao do pré-aprovado na conta (Christian - Envolti).
               
               09/08/2019 - Alterado procedure busca-contra-ordens para trazer a data de liquidaçao
                            do cheque. RITM0023830 (Lombardi)
.............................................................................*/

/*................................ DEFINICOES ...............................*/
{ sistema/generico/includes/b1wgen0095tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgenvlog.i 
              &TELA-CONTAS=NAO &TELA-MATRIC=SIM &VAR-GERAL=SIM &SESSAO-BO=SIM }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.

DEF VAR h-b1wgen9998 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.

DEF STREAM str_1.

/*Funcao para retornar o ultimo dia util anterior a data atual.*/
FUNCTION fn_dia_util_anterior RETURN DATE
 (INPUT  p-cdcooper AS INTE,
  INPUT  p-dtvencto AS DATE,
  INPUT  p-qtdddias AS INTE).
  
    DEF VAR   aux_qtdddias  AS INTE.
    DEF VAR   aux_dtvencto  AS DATE.

    ASSIGN aux_qtdddias = p-qtdddias
           aux_dtvencto = p-dtvencto.

    DO WHILE aux_qtdddias > 0:

      aux_dtvencto = aux_dtvencto - 1.

      IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtvencto)))            OR
          CAN-FIND(crapfer WHERE crapfer.cdcooper = p-cdcooper  AND
                                 crapfer.dtferiad = aux_dtvencto)  THEN
      DO:
          NEXT.
      END.

      aux_qtdddias = aux_qtdddias - 1.
	  
   END. /** Fim do DO WHILE TRUE **/

   RETURN aux_dtvencto.
   
END.


/*............................ PROCEDURES EXTERNAS ..........................*/

/* ************************************************************************* */
/**                                Busca Dados                              **/
/* ************************************************************************* */
PROCEDURE busca-dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_tptransa AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_msgretor AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dctror.

    DEF VAR aux_nrdconta AS INTE                                       NO-UNDO.
    DEF VAR aux_lsconta2 AS CHAR                                       NO-UNDO.
    DEF VAR aux_opmigrad AS LOG                                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca dados de contra-ordens/avisos".

    Busca: DO WHILE TRUE:
        
        EMPTY TEMP-TABLE tt-erro.

        RUN sistema/generico/procedures/b1wgen9998.p
            PERSISTENT SET h-b1wgen9998.
      
        /* Validacao de operado e conta migrada */
        RUN valida_operador_migrado IN h-b1wgen9998 (INPUT par_cdoperad,
                                                     INPUT par_nrdconta,
                                                     INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     OUTPUT aux_opmigrad,
                                                     OUTPUT TABLE tt-erro).
                     
        DELETE PROCEDURE h-b1wgen9998.
                   
        IF  RETURN-VALUE <> "OK"  THEN
            DO:
               FIND tt-erro NO-LOCK NO-ERROR.

               IF AVAIL tt-erro THEN
                  DO:
                     ASSIGN aux_cdcritic = tt-erro.cdcritic.

                     EMPTY TEMP-TABLE tt-erro.
                  END.
               ELSE
                 ASSIGN aux_cdcritic = 36.
                
                 LEAVE Busca.

            END.


        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
            RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.

        RUN dig_fun IN h-b1wgen9999
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT-OUTPUT par_nrdconta,
             OUTPUT TABLE tt-erro ).  

        IF  VALID-HANDLE(h-b1wgen9999)  THEN
            DELETE PROCEDURE h-b1wgen9999.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Busca.

        /* Tratamento para opcao E */
        IF  par_cddopcao = "E" THEN
            DO:
                RUN localiza-generi ( INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                     OUTPUT aux_lsconta2,
                                     OUTPUT TABLE tt-erro ).
                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".

            END.

        /* Tipo 1 e 3 não habilitado para opcao A */
        IF  par_cddopcao = "A" THEN
            DO:
                IF  par_tptransa = 1 OR par_tptransa = 3 THEN
                    DO:
                        ASSIGN aux_cdcritic = 128
                               par_msgretor = "Tipos 1 e 3 somente " +
                                              "opcao C, I ou E.".
                        LEAVE Busca.
                    END.
            END.

        /* Tratamento Busca Dados da Cooperativa em todas as opcoes */
        FIND crapcop WHERE
             crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcop THEN
            DO:
                ASSIGN aux_cdcritic = 651.
                LEAVE Busca.
            END.

        FIND crapass WHERE
             crapass.cdcooper = par_cdcooper  AND
             crapass.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapass THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE Busca.
            END.

        CREATE tt-dctror.
        ASSIGN tt-dctror.nmprimtl = crapass.nmprimtl
                       tt-dctror.cdsitdtl = crapass.cdsitdtl.

        FIND crapsit WHERE crapsit.cdcooper = par_cdcooper     AND
                           crapsit.cdsitdtl = crapass.cdsitdtl
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapsit  THEN
            ASSIGN tt-dctror.dssitdtl = 
                             (IF  par_cddopcao = "I" THEN FILL("?",15) 
                                  ELSE FILL("*",15)).
        ELSE
            ASSIGN tt-dctror.dssitdtl = crapsit.dssitdtl.
                
        IF (par_cddopcao = "I"                          AND
           ((CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl)) AND 
            par_tptransa = 1)                           OR
           (CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))  AND 
            par_tptransa = 3)))                         THEN
            DO:
                ASSIGN aux_cdcritic = 95.
                LEAVE Busca.
            END.
        ELSE 
        IF (par_cddopcao = "E"                               AND
           ((NOT(CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))) AND 
            par_tptransa = 1)                                OR
           (NOT(CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl)))  AND 
            par_tptransa = 3)))                              THEN
            DO:
                ASSIGN aux_cdcritic = 131.
                LEAVE Busca.
            END.

        IF  crapass.dtelimin <> ? THEN
            DO:
                ASSIGN aux_cdcritic = 410.
                LEAVE Busca.
            END.

        IF  (par_cddopcao = "E" OR par_cddopcao = "I") AND
             CAN-DO("1,3", STRING(par_tptransa))       THEN
            DO:
                /* Procura registro de recadastramento */
                FIND LAST crapalt WHERE
                          crapalt.cdcooper = par_cdcooper     AND
                          crapalt.nrdconta = crapass.nrdconta AND
                          crapalt.tpaltera = 1                NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapalt THEN
                    ASSIGN tt-dctror.dtaltera = ?.
                ELSE
                    ASSIGN tt-dctror.dtaltera = crapalt.dtaltera.

                FIND FIRST craptrf WHERE
                           craptrf.cdcooper = par_cdcooper      AND
                           craptrf.nrdconta = crapass.nrdconta  AND
                           craptrf.tptransa = 1
                           USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                IF  AVAILABLE craptrf THEN
                    IF  craptrf.tptransa = 1 THEN
                        DO:
                            ASSIGN aux_cdcritic = 155.
                            LEAVE Busca.
                        END.

                IF  par_tptransa = 1 THEN
                    DO:
                        FIND FIRST craplau WHERE
                                   craplau.cdcooper  = par_cdcooper     AND
                                   craplau.nrdconta  = crapass.nrdconta AND
                                   craplau.dtmvtopg >= par_dtmvtolt     AND
                                  (craplau.cdbccxlt  = 600 /* custodia */ OR
                                   craplau.cdbccxlt  = 700) /* desconto chq */
                                   NO-LOCK NO-ERROR.
                        IF  AVAILABLE craplau THEN
                            DO:
                                ASSIGN aux_dscritic = "Cooperado com cheques" +
                                                      " a liberar.".
                                LEAVE Busca.
                            END.
                    END.
            END.

        /* Tratamento para opção I */
        IF  par_cddopcao = "I" THEN
            ASSIGN tt-dctror.dtemscor = par_dtmvtolt.
        ELSE
            ASSIGN tt-dctror.dtemscor = ?.

        ASSIGN tt-dctror.cdhistor = 0
               tt-dctror.nrinichq = 0
               tt-dctror.nrfinchq = 0
               tt-dctror.nrctachq = 0
               tt-dctror.cdbanchq = 0
               tt-dctror.cdagechq = 0.

        LEAVE Busca.
    END.

    IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
        aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE
                RUN gera_erro ( INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic ).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

/* ************************************************************************* */
/**                          Valida  Conta Cheque                           **/
/* ************************************************************************* */
PROCEDURE valida-ctachq:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.

    DEF  INPUT PARAM par_dtemscor AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrinichq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrfinchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_dsdctitg AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_lsconta2 AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrinital AS INTE                                       NO-UNDO.
    DEF VAR aux_nrfintal AS INTE                                       NO-UNDO.
    DEF VAR aux_nrposchq AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           par_nmdcampo = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validacao de conta cheque".

    Valida: DO WHILE TRUE:

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcop THEN
            DO:
                ASSIGN aux_cdcritic = 651.
                LEAVE Valida.
            END.

        IF  par_nrctachq > 0 THEN
            DO: 
                FIND gnctace WHERE gnctace.cdcooper = par_cdcooper AND 
                                   gnctace.nrctacen = par_nrctachq NO-LOCK NO-ERROR.
    
                /* Se não for Conta Centralização, valida dígitos de conta ITG */
                IF  NOT AVAIL gnctace THEN
                    DO:         
                        IF  NOT VALID-HANDLE(h-b1wgen9998)  THEN
                            RUN sistema/generico/procedures/b1wgen9998.p
                                PERSISTENT SET h-b1wgen9998.
            
                        RUN dig_bbx IN h-b1wgen9998
                            ( INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_nrctachq,
                             OUTPUT par_dsdctitg,
                             OUTPUT TABLE tt-erro ).
            
                        IF  VALID-HANDLE(h-b1wgen9998)  THEN
                            DELETE PROCEDURE h-b1wgen9998.
            
                        IF  RETURN-VALUE <> "OK"  THEN
                            DO:
                                ASSIGN par_nmdcampo = "nrctachq".
                                LEAVE Valida.
                            END.
                    END.
                    

                IF  (par_cddopcao = "A"  OR
                     par_cddopcao = "E"  OR
                     par_cddopcao = "I") AND
                     par_cdbanchq <> 1   THEN
                    IF  par_nrdconta <> par_nrctachq  THEN
                    DO:
                        
                        /*verifica se é uma conta migrada*/
                        FIND FIRST craptco 
                        WHERE craptco.cdcooper = par_cdcooper 
                          AND craptco.nrctaant = par_nrctachq
                          AND (craptco.cdcopant = 4  OR 
                               craptco.cdcopant = 15 OR 
                               craptco.cdcopant = 17 )
                          AND craptco.flgativo = TRUE
                          NO-LOCK NO-ERROR.

                        /* Gerar critica apenas se não for
                           conta migrada*/
                        IF NOT AVAIL(craptco) THEN 
                        DO:                      
                          ASSIGN aux_cdcritic = 127
                                 par_nmdcampo = "nrctachq".
                          LEAVE Valida.
                        END.
                    END.
            END.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 8
                       par_nmdcampo = "nrctachq".
                LEAVE Valida.
            END.

        IF  par_nrinichq > 0 THEN
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.

                RUN dig_fun IN h-b1wgen9999
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT-OUTPUT par_nrinichq,
                     OUTPUT TABLE tt-erro  ).

                IF  VALID-HANDLE(h-b1wgen9999)  THEN
                    DELETE PROCEDURE h-b1wgen9999.

                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        ASSIGN par_nmdcampo = "nrinichq".
                        LEAVE Valida.
                    END.
                ELSE
                IF  par_cddopcao = "I" AND par_nrfinchq > 0 THEN 
                    DO:
                        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                            RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
    
                        RUN dig_fun IN h-b1wgen9999
                            ( INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT-OUTPUT par_nrfinchq,
                             OUTPUT TABLE tt-erro  ).
    
                        IF  VALID-HANDLE(h-b1wgen9999)  THEN
                            DELETE PROCEDURE h-b1wgen9999.
    
                        IF  RETURN-VALUE <> "OK"  THEN
                            DO:
                                ASSIGN par_nmdcampo = "nrfinchq".
                                LEAVE Valida.
                            END.

                        IF  par_nrinichq >= par_nrfinchq THEN
                            DO:
                                ASSIGN aux_cdcritic = 129.
                                       par_nmdcampo = "nrinichq".
                                LEAVE Valida.
                            END.

                    END.
                ELSE
                IF  par_cddopcao = "E" THEN
                    DO:
                         RUN localiza-generi ( INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                              OUTPUT aux_lsconta2,
                                              OUTPUT TABLE tt-erro ).

                        IF  RETURN-VALUE <> "OK" THEN
                            LEAVE Valida.

                        IF  CAN-DO(aux_lsconta2, STRING(par_nrctachq)) AND
                            par_cdbanchq = 1                           THEN
                            DO:

                                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                                   RUN sistema/generico/procedures/b1wgen9999.p
                                        PERSISTENT SET h-b1wgen9999.

                                RUN num-tal IN h-b1wgen9999
                                    ( INPUT par_nrinichq,
                                      INPUT 10,           /* nrfolhas */
                                     OUTPUT aux_nrinital, /* nrtalchq */
                                     OUTPUT aux_nrposchq ).

                                IF  VALID-HANDLE(h-b1wgen9999)  THEN
                                    DELETE PROCEDURE h-b1wgen9999.

                            END.
                    END.
            END.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 129
                       par_nmdcampo = "nrinichq".
                LEAVE Valida.
            END.

        IF  par_cddopcao = "E" THEN
            IF par_nrfinchq > 0 THEN
                DO:
                    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                        RUN sistema/generico/procedures/b1wgen9999.p
                            PERSISTENT SET h-b1wgen9999.

                    RUN dig_fun IN h-b1wgen9999
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT-OUTPUT par_nrfinchq,
                         OUTPUT TABLE tt-erro  ).

                    IF  VALID-HANDLE(h-b1wgen9999)  THEN
                        DELETE PROCEDURE h-b1wgen9999.

                    IF  RETURN-VALUE <> "OK"  THEN
                        DO:
                            ASSIGN par_nmdcampo = "nrfinchq".
                            LEAVE Valida.
                        END.

                    ELSE
                        DO:
                            RUN localiza-generi ( INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                 OUTPUT aux_lsconta2,
                                                 OUTPUT TABLE tt-erro ).

                            IF  RETURN-VALUE <> "OK" THEN
                                LEAVE Valida.

                            IF  CAN-DO(aux_lsconta2, STRING(par_nrctachq)) AND
                                par_cdbanchq = 1                           THEN
                                DO:

                                    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                                    RUN sistema/generico/procedures/b1wgen9999.p
                                            PERSISTENT SET h-b1wgen9999.

                                    RUN num-tal IN h-b1wgen9999
                                        ( INPUT par_nrinichq,
                                          INPUT 10,           /* nrfolhas */
                                         OUTPUT aux_nrfintal, /* nrtalchq */
                                         OUTPUT aux_nrposchq ).

                                    IF  VALID-HANDLE(h-b1wgen9999)  THEN
                                        DELETE PROCEDURE h-b1wgen9999.

                                    IF  aux_nrinital <> aux_nrfintal  THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 253.
                                                   par_nmdcampo = "nrfinchq".
                                            LEAVE Valida.
                                        END.
                                END.
                        END.
                END.

        LEAVE Valida.

    END.

    IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
        aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE
                RUN gera_erro ( INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic ).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).
            
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

/* ************************************************************************* */
/**                          Valida Opcao Banco                             **/
/* ************************************************************************* */
PROCEDURE valida-agechq:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.

    DEF  INPUT PARAM par_cdbanchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_cdagechq AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           par_nmdcampo = ""
               aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validacao do banco com retorno da agencia".
        
    Verifica: DO WHILE TRUE:

        IF  par_cddopcao = "A" OR par_cddopcao = "C" THEN
            DO:
                FIND crapban WHERE
                     crapban.cdbccxlt = par_cdbanchq NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapban THEN
                    DO:
                        ASSIGN aux_cdcritic = 57
                               par_nmdcampo = "cdbanchq".
                        LEAVE Verifica.
                    END.
       
            END.

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcop THEN
            DO:
                ASSIGN aux_cdcritic = 651
                       par_nmdcampo = "cdbanchq".
                LEAVE Verifica.
            END.
        
        IF  par_cdbanchq = 1  THEN
            ASSIGN par_cdagechq = crapcop.cdageitg.
        ELSE
        IF  par_cdbanchq = 756  THEN
            ASSIGN par_cdagechq = crapcop.cdagebcb.
        ELSE
        IF  par_cdbanchq = crapcop.cdbcoctl  THEN
            ASSIGN par_cdagechq = crapcop.cdagectl.
        ELSE
            ASSIGN par_cdagechq = 0.

        LEAVE Verifica.
    END.
    
    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.



/* ************************************************************************* */
/**                          Valida Conta Migrada                           **/
/* ************************************************************************* */
PROCEDURE valida-conta-migrada:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    
    DEF OUTPUT PARAM par_altagchq AS INTE                              NO-UNDO.    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           par_nmdcampo = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validacao de conta migrada com retorno da agencia"
           par_altagchq = 0.
        
    Verifica: DO WHILE TRUE:        

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcop THEN
            DO:
                ASSIGN aux_cdcritic = 651
                       par_nmdcampo = "cdbanchq".
                LEAVE Verifica.
            END.
        
        FIND FIRST craptco WHERE craptco.cdcooper = par_cdcooper
                             AND craptco.nrdconta = par_nrdconta
                             NO-LOCK NO-ERROR.
                             
        IF  AVAILABLE craptco THEN
            ASSIGN par_altagchq = 1.

        LEAVE Verifica.
    END.
    
    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/* ************************************************************************* */
/**                          Valida Agencia                                 **/
/* ************************************************************************* */
PROCEDURE valida-agencia:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_cdagectl AS INTE                              NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           par_nmdcampo = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validacao da agencia".           
        
    Verifica: DO WHILE TRUE:        

        FIND crapcop WHERE crapcop.cdagectl = par_cdagectl NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcop THEN
            DO:

			    FIND crapcop WHERE crapcop.cdagebcb = par_cdagectl NO-LOCK NO-ERROR.

				IF NOT AVAIL crapcop THEN
				   DO:
                ASSIGN aux_cdcritic = 134 
                       par_nmdcampo = "cdagechq".
                LEAVE Verifica.
            END.       
            END.       
        
        LEAVE Verifica.
    END.
    
    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/* ************************************************************************* */
/**                          Busca Conta Cheque                             **/
/* ************************************************************************* */
PROCEDURE busca-ctachq:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    
    DEF  INPUT PARAM par_nrinichq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdsitdtl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dsdctitg AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_posvalid AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_dtemscor AS DATE                              NO-UNDO.
    DEF OUTPUT PARAM par_cdhistor AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_nrfinchq AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_dtvalcor AS DATE                              NO-UNDO.
    DEF OUTPUT PARAM par_flprovis AS LOGI                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrchqsdv AS INTE                                       NO-UNDO.
    DEF VAR aux_nrchqcdv AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca de conta do cheque".

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    Busca: DO WHILE TRUE:
        IF  par_cddopcao = "C" OR
            (par_cddopcao = "A" AND par_posvalid = 2) THEN
            DO:

                ASSIGN aux_nrchqsdv = INT(SUBSTR(STRING(par_nrinichq,
                                                                 "9999999"),1,6))
                       aux_nrchqcdv = INT(par_nrinichq).

                FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper   AND
                                   crapfdc.cdbanchq = par_cdbanchq   AND
                                   crapfdc.cdagechq = par_cdagechq   AND
                                   crapfdc.nrctachq = par_nrctachq   AND
                                   crapfdc.nrcheque = aux_nrchqsdv
                                   USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapfdc   OR
                    crapfdc.dtemschq = ?    THEN
                    DO:
                        ASSIGN aux_cdcritic = 108.
                        LEAVE Busca.
                    END.
                ELSE
                IF  crapfdc.nrdconta <> par_nrdconta   THEN
                    DO:
                        ASSIGN aux_cdcritic = 108.
                        LEAVE Busca.
                    END.
                ELSE
                IF  crapfdc.dtretchq = ?   THEN
                    DO:
                        ASSIGN aux_cdcritic = 109.
                        LEAVE Busca.
                    END.

                /* Validações somente para opção A */
                IF  par_cddopcao = "A"  THEN
                    DO:
                        IF  CAN-DO("0,5",STRING(crapfdc.incheque)) THEN
                            DO:
                                ASSIGN aux_cdcritic = 111.
                                LEAVE Busca.
                            END.
                        ELSE
                        IF  crapfdc.incheque = 8  THEN
                            DO:
                                ASSIGN aux_cdcritic = 320.
                                LEAVE Busca.
                            END.

                        FIND crapass WHERE
                             crapass.cdcooper = par_cdcooper  AND
                             crapass.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.

                        IF  NOT AVAIL crapass THEN
                            DO:
                                ASSIGN aux_cdcritic = 410.
                                LEAVE Busca.
                            END.

                        /* Exclusivo BB */
                        IF  crapass.nrdctitg = par_dsdctitg AND
                            par_cdbanchq = 1                THEN
                            DO:
                                FIND FIRST crapcch WHERE
                                     crapcch.cdcooper = par_cdcooper     AND
                                     crapcch.nrdconta = par_nrdconta     AND
                                     crapcch.nrdctitg = crapfdc.nrdctitg AND
                                     crapcch.nrchqini = par_nrinichq     AND
                                     crapcch.nrchqfim = par_nrinichq     AND
                                     crapcch.cdhistor <> 0               AND
                                    (crapcch.flgctitg = 1                OR
                                     crapcch.flgctitg = 4)               AND
                                     crapcch.cdbanchq = 1
                                     NO-LOCK NO-ERROR.

                                IF  AVAILABLE crapcch  THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 219.
                                        LEAVE Busca.
                                    END.
                            END.
                        ELSE
                            DO: /* BANCOOB e CECRED */
                                FIND FIRST crapcch WHERE
                                     crapcch.cdcooper = par_cdcooper     AND
                                     crapcch.nrdconta = par_nrdconta     AND
                                     crapcch.nrdctitg = crapfdc.nrdctitg AND
                                     crapcch.nrchqini = aux_nrchqcdv     AND
                                     crapcch.nrchqfim = aux_nrchqcdv     AND
                                     crapcch.cdhistor <> 0               AND
                                    (crapcch.flgctitg = 1                OR
                                     crapcch.flgctitg = 4)               AND
                                     crapcch.cdbanchq = par_cdbanchq
                                     NO-LOCK NO-ERROR.

                                IF  AVAILABLE crapcch   THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 219.
                                        LEAVE Busca.
                                    END.
                            END.
                    END.

                FIND crapcor WHERE crapcor.cdcooper = par_cdcooper     AND
                                   crapcor.cdbanchq = crapfdc.cdbanchq AND
                                   crapcor.cdagechq = crapfdc.cdagechq AND
                                   crapcor.nrctachq = crapfdc.nrctachq AND
                                   crapcor.nrcheque = aux_nrchqcdv     AND
                                   crapcor.flgativo = TRUE
                                   USE-INDEX crapcor1 NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapcor THEN
                    DO:
                        ASSIGN aux_cdcritic = 111.
                        LEAVE Busca.
                    END.



                ASSIGN par_dtemscor = crapcor.dtemscor
                       par_cdhistor = crapcor.cdhistor
                       par_nrfinchq = 0
                       par_dtvalcor = crapcor.dtvalcor
                       par_flprovis = IF   crapcor.dtvalcor <> ? THEN
                                           TRUE
                                      ELSE FALSE.
            END.
        ELSE
        IF  (par_cddopcao = "A" AND par_posvalid = 1)    OR
            (par_cddopcao = "E") OR (par_cddopcao = "I") THEN
            DO:
                IF  CAN-DO("5,6,7,8",STRING(par_cdsitdtl))  THEN
                    DO:
                        ASSIGN aux_cdcritic = 695.
                        LEAVE Busca.
                    END.

                IF  CAN-DO("2,4,6,8",STRING(par_cdsitdtl))  THEN
                    DO:
                        ASSIGN aux_cdcritic = 95.
                        LEAVE Busca.
                    END.
            END.

        LEAVE Busca.
    END.


    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

/* ************************************************************************* */
/**                             Valida Historico                            **/
/* ************************************************************************* */
PROCEDURE valida-hist:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.

    DEF  INPUT PARAM par_cdhistor AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_tplotmov AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validacao de historico".

    Valida: DO WHILE TRUE:

        FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                           craphis.cdhistor = par_cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craphis   THEN
            DO:
                ASSIGN aux_cdcritic = 93
                       par_nmdcampo = "cdhistor".
                LEAVE Valida.
            END.

        IF  NOT CAN-DO("8,9",STRING(craphis.tplotmov))   THEN
            DO:
                ASSIGN aux_cdcritic = 94
                       par_nmdcampo = "cdhistor".
                LEAVE Valida.
            END.

        ASSIGN par_tplotmov = craphis.tplotmov.

        LEAVE Valida.
    END.

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/* ************************************************************************* */
/**                             Grava Log dos Itens                         **/
/* ************************************************************************* */
PROCEDURE log-contras:

    DEF INPUT PARAMETER par_nrsequen AS INTE  NO-UNDO.
    DEF INPUT PARAMETER par_nrdrowid AS ROWID NO-UNDO.
    DEF INPUT PARAMETER TABLE FOR tt-dctror-ant.
    DEF INPUT PARAMETER TABLE FOR tt-dctror-atl.

    FIND FIRST tt-dctror-ant NO-LOCK NO-ERROR.

    FIND FIRST tt-dctror-atl NO-LOCK NO-ERROR.

    IF NOT AVAIL tt-dctror-ant THEN
        CREATE tt-dctror-ant.

    IF NOT AVAIL tt-dctror-atl THEN
        CREATE tt-dctror-atl.

    IF  AVAIL tt-dctror-ant AND AVAIL tt-dctror-atl THEN
        DO:

            /* nrcheque */
            RUN proc_gerar_log_item 
                ( INPUT par_nrdrowid,
                  INPUT "nrcheque" + STRING(par_nrsequen),
                  INPUT tt-dctror-ant.nrcheque,
                  INPUT tt-dctror-atl.nrcheque ).

            /* cdbanchq */
            RUN proc_gerar_log_item 
                ( INPUT par_nrdrowid,
                  INPUT "cdbanchq" + STRING(par_nrsequen),
                  INPUT tt-dctror-ant.cdbanchq,
                  INPUT tt-dctror-atl.cdbanchq ).

            /* cdagechq */
            RUN proc_gerar_log_item 
                ( INPUT par_nrdrowid,
                  INPUT "cdagechq" + STRING(par_nrsequen),
                  INPUT tt-dctror-ant.cdagechq,
                  INPUT tt-dctror-atl.cdagechq ).

            /* nrctachq */
            RUN proc_gerar_log_item 
                ( INPUT par_nrdrowid,
                  INPUT "nrctachq" + STRING(par_nrsequen),
                  INPUT tt-dctror-ant.nrctachq,
                  INPUT tt-dctror-atl.nrctachq ).

            IF  tt-dctror-ant.cdhistor <> 0 OR tt-dctror-atl.cdhistor <> 0 THEN
                DO:
                    /* cdhistor */
                    RUN proc_gerar_log_item 
                        ( INPUT par_nrdrowid,
                          INPUT "cdhistor" + STRING(par_nrsequen),
                          INPUT tt-dctror-ant.cdhistor,
                          INPUT tt-dctror-atl.cdhistor ).
                END.

             IF  tt-dctror-ant.dscritic <> tt-dctror-atl.dscritic  THEN
                DO:
                    /* dscritic */
                    RUN proc_gerar_log_item 
                        ( INPUT par_nrdrowid,
                          INPUT "dscritic" + STRING(par_nrsequen),
                          INPUT tt-dctror-ant.dscritic,
                          INPUT tt-dctror-atl.dscritic ).
                END.
        END.

END PROCEDURE.

/* ************************************************************************* */
/*                            Gravacao de alteracao                          */
/* ************************************************************************* */
PROCEDURE altera-contra:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.

    DEF  INPUT PARAM par_tplotmov AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrinichq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_stlcmexc AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_stlcmcad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_dtemscch AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dsdctitg AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_flprovis AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtvalcor AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_tptransa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO. 

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-contra.

    DEF VAR aux_nrchqsdv AS INTE                                       NO-UNDO.
    DEF VAR aux_nrchqcdv AS INTE                                       NO-UNDO.
    DEF VAR aux_idreglog AS ROWID                                      NO-UNDO.
    DEF VAR aux_retornvl AS CHAR INIT "NOK"                            NO-UNDO.

    DEF VAR aux_flagprov AS LOGICAL                                    NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        FIND crapcop WHERE 
             crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        Critica: DO WHILE TRUE:

            IF  NOT AVAILABLE crapcop  THEN
                DO:
                    ASSIGN aux_cdcritic = 651.
                    LEAVE Critica.
                END.
    
            ASSIGN aux_nrchqsdv = INT(SUBSTR(STRING(par_nrinichq,
                                                    "9999999"),1,6))
                   aux_nrchqcdv = INT(par_nrinichq).
    
            Contador: DO aux_contador = 1 TO 10:
    
                FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper   AND
                                   crapfdc.cdbanchq = par_cdbanchq   AND
                                   crapfdc.cdagechq = par_cdagechq   AND
                                   crapfdc.nrctachq = par_nrctachq   AND
                                   crapfdc.nrcheque = aux_nrchqsdv
                                   USE-INDEX crapfdc1
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                IF  NOT AVAIL crapfdc THEN
                    IF  LOCKED crapfdc  THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    ASSIGN aux_cdcritic = 341.
                                    LEAVE Critica.
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT Contador.
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 108.
                            LEAVE Critica.
                        END.
                LEAVE Contador.
            END.
    
            Contador: DO aux_contador = 1 TO 10:
    
                FIND crapass WHERE
                     crapass.cdcooper = par_cdcooper  AND
                     crapass.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL crapass THEN
                    DO:
                        ASSIGN aux_cdcritic = 410.
                        LEAVE Critica.
                    END.
    
                FIND crapcor WHERE crapcor.cdcooper = par_cdcooper      AND
                                   crapcor.cdbanchq = crapfdc.cdbanchq  AND
                                   crapcor.cdagechq = crapfdc.cdagechq  AND
                                   crapcor.nrctachq = crapfdc.nrctachq  AND
                                   crapcor.nrcheque = aux_nrchqcdv      AND
                                   crapcor.flgativo = TRUE
                                   USE-INDEX crapcor1
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                IF  NOT AVAIL crapcor THEN
                    IF  LOCKED crapcor  THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    ASSIGN aux_cdcritic = 341.
                                    LEAVE Critica.
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT Contador.
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 111.
                            LEAVE Critica.
                        END.
                LEAVE Contador.
            END.
        
            IF  NOT par_flprovis THEN
                DO:
                /* Grava somente para contra-ordem permanente */
                
                    /* Exclusivo BB */
                IF  (crapass.nrdctitg = par_dsdctitg AND par_cdbanchq = 1) OR
                    (par_cdbanchq = 756)   OR               /* BANCOOB */
                    (par_cdbanchq = crapcop.cdbcoctl) THEN  /* CECRED  */
                  DO:
                    RUN grava-crapcch ( INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nmdatela,
                                        INPUT par_idorigem,
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT par_flgerlog,
                                        INPUT par_dtmvtolt,
                                        INPUT crapfdc.cdbanchq,
                                        INPUT crapfdc.nrdconta,
                                        INPUT crapfdc.nrdctabb,
                                        INPUT par_nrinichq,
                                        INPUT par_cdhistor,
                                        INPUT par_stlcmexc,
                                        INPUT par_stlcmcad,
                                        INPUT par_dtemscch,
                                        INPUT par_nrctachq,
                                        INPUT crapfdc.nrdctitg,
                                        INPUT crapfdc.nrseqems,
                                        INPUT crapfdc.cdagechq,
                                       OUTPUT TABLE tt-erro ).

                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            IF  AVAIL tt-erro THEN
                                ASSIGN aux_cdcritic = tt-erro.cdcritic.
                        END.
                END.
            END. /* FIM do IF NOT provis */

            LEAVE Critica.
        END. /* Fim Critica */

        /* Tabela para geracao de LOG */
        CREATE tt-dctror-ant.
        BUFFER-COPY crapfdc TO tt-dctror-ant
        ASSIGN tt-dctror-ant.cdhistor = crapcor.cdhistor WHEN AVAIL crapcor.

        
        /*Se era provisoria e alterou para permanente, altera dtvalcor */
        IF   crapcor.dtvalcor <> ?     AND /**incluido**/
             par_flprovis     =  FALSE THEN
             DO:
                 CREATE crabcor.
                 BUFFER-COPY crapcor TO crabcor
                 ASSIGN crabcor.flgativo = FALSE.
                           
                 VALIDATE crabcor.

                 ASSIGN crapcor.dtvalcor = ?
                        crapcor.flgativo = TRUE
                        crapcor.dtmvtolt = par_dtmvtolt
                        aux_flagprov     = TRUE.
                 
                 /* Tratamento para impressao  */
                 CREATE tt-contra.
                 ASSIGN tt-contra.cdhistor = crapcor.cdhistor
                        tt-contra.cdbanchq = crapcor.cdbanchq
                        tt-contra.cdagechq = crapcor.cdagechq
                        tt-contra.nrctachq = crapcor.nrctachq
                        tt-contra.nrinichq = crapcor.nrcheque
                        tt-contra.nrfinchq = crapcor.nrcheque
                        tt-contra.nrdconta = crapcor.nrdconta
                        tt-contra.flprovis = FALSE
                        tt-contra.flgativo = crapcor.flgativo.
             END.
        ELSE
             ASSIGN aux_flagprov = FALSE.
            
        IF  aux_cdcritic = 0 THEN
            DO:
                IF  par_tplotmov = 8  THEN
                    ASSIGN crapfdc.incheque = IF  crapfdc.incheque < 5 THEN 2
                                                                       ELSE 7.
                ELSE
                    IF  par_tplotmov = 9  THEN
                        ASSIGN crapfdc.incheque =
                                              IF  crapfdc.incheque < 5 THEN 1
                                                                       ELSE 6.
        
                ASSIGN crapcor.cdhistor = par_cdhistor.

                IF   par_tptransa = 2 THEN /*  Tipo 2 - Contra-Ordem  */
                     RUN log-contra-cheque 
                        (INPUT par_dtmvtolt,
                         INPUT par_cdoperad,
                         INPUT crapcor.cdhistor,
                         INPUT crapcor.nrdconta,
                         INPUT crapcor.nrcheque,  
                         INPUT crapcor.cdbanchq,
                         INPUT crapcor.cdagechq,
                         INPUT par_cddopcao,
                         INPUT aux_flagprov).
            END.

        /* Tabela para geracao de LOG */
        CREATE tt-dctror-atl.
        BUFFER-COPY crapfdc TO tt-dctror-atl
            ASSIGN tt-dctror-atl.cdhistor = crapcor.cdhistor.

        IF  par_flgerlog  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                ELSE
                    RUN gera_erro ( INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1,            /** Sequencia **/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic ).

                ASSIGN aux_dstransa = "Alteracao de contra-ordem: " + 
                      (IF aux_dscritic <> "" THEN "Critica" ELSE "Efetivacao").
        
                RUN proc_gerar_log 
                    ( INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT "",
                      INPUT aux_dsorigem,
                      INPUT aux_dstransa,
                      INPUT TRUE,
                      INPUT par_idseqttl,
                      INPUT par_nmdatela,
                      INPUT par_nrdconta,
                     OUTPUT aux_idreglog ).

            IF  aux_dscritic <> ""  THEN
                ASSIGN tt-dctror-atl.dscritic = aux_dscritic.

            RUN log-contras 
                ( INPUT 1,
                  INPUT aux_idreglog,
                  INPUT TABLE tt-dctror-ant,
                  INPUT TABLE tt-dctror-atl ).

            EMPTY TEMP-TABLE tt-dctror-ant.
            EMPTY TEMP-TABLE tt-dctror-atl.

            IF  aux_dscritic <> "" THEN
                LEAVE Grava.
        END.

        ASSIGN aux_retornvl = "OK".

    END. /* Fim Grava */

    RELEASE crapfdc.
    RELEASE crapcor.

    RETURN aux_retornvl.

END PROCEDURE.


/* ************************************************************************* */
/*                   Exclusao e Inclusao de Bloqueio e Prejuizo              */
/* ************************************************************************* */
PROCEDURE trata-bloqpreju:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_tptransa AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_cdsitdtl AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_dssitdtl AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM log_msgrecad AS CHAR                              NO-UNDO.

    DEF VAR aux_retornvl AS CHAR INIT "NOK"                            NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                       NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = (IF par_cddopcao = "E" THEN "Exclui" 
                           ELSE "Inclui") + 
                          (IF par_tptransa = 1 THEN " Bloqueio."
                           ELSE " Prejuizo.").

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        Contador: DO aux_contador = 1 TO 10:

            FIND crapass WHERE
                 crapass.cdcooper = par_cdcooper  AND
                 crapass.nrdconta = par_nrdconta 
                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL crapass THEN
                IF  LOCKED crapass  THEN
                    DO:
                        IF  aux_contador = 10 THEN
                            DO:
                                ASSIGN aux_cdcritic = 72.
                                UNDO Grava, LEAVE Grava.
                            END.
                        ELSE
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT Contador.
                            END.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 9.
                        UNDO Grava, LEAVE Grava.
                    END.
            LEAVE Contador.
        END.

        { sistema/generico/includes/b1wgenalog.i &TELA-CONTAS=NAO 
                                                 &TELA-MATRIC=SIM }

        /* Tabela para geracao de LOG */
        CREATE tt-dctror-ant.
        ASSIGN tt-dctror-ant.cdsitdtl = crapass.cdsitdtl.
        
        IF  par_cddopcao = "E" THEN
            DO:
                IF  par_tptransa = 1 THEN
                    ASSIGN 
                        crapass.cdsitdtl = crapass.cdsitdtl - 1.
                ELSE
                    ASSIGN 
                        crapass.cdsitdtl = crapass.cdsitdtl - 4.
            END.
        ELSE
        IF  par_cddopcao = "I" THEN
            DO:
                IF  par_tptransa = 1 THEN
                    ASSIGN 
                        crapass.cdsitdtl = crapass.cdsitdtl + 1.
                ELSE
                    ASSIGN 
                        crapass.cdsitdtl = crapass.cdsitdtl + 4.
            END.

        /* Tabela para geracao de LOG */
        CREATE tt-dctror-atl.
        ASSIGN tt-dctror-atl.cdsitdtl = crapass.cdsitdtl.

        FIND crapsit WHERE 
             crapsit.cdcooper = par_cdcooper     AND
             crapsit.cdsitdtl = crapass.cdsitdtl NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapsit   THEN
            ASSIGN par_dssitdtl = FILL("?",15).
        ELSE
            ASSIGN par_dssitdtl = crapsit.dssitdtl.
        ASSIGN par_cdsitdtl = crapass.cdsitdtl.

        { sistema/generico/includes/b1wgenllog.i &TELA-CONTAS=NAO 
                                                 &TELA-MATRIC=SIM }
                
                ASSIGN aux_retornvl = "OK".

    END. /* Fim Gravar */

    RELEASE crapass.

    IF  (aux_cdcritic <> 0 OR aux_dscritic <> "")  THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
        END.

    IF  par_flgerlog  THEN
        RUN proc_gerar_log_tab 
                    ( INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT aux_dscritic,
                      INPUT aux_dsorigem,
                      INPUT aux_dstransa,
                      INPUT (IF aux_retornvl = "OK" THEN TRUE ELSE FALSE),
                      INPUT par_idseqttl,
                      INPUT par_nmdatela,
                      INPUT par_nrdconta,
                      INPUT TRUE,
                      INPUT BUFFER tt-dctror-ant:HANDLE,
                      INPUT BUFFER tt-dctror-atl:HANDLE ).
                    
    RETURN aux_retornvl.

END PROCEDURE.

/* ************************************************************************* */
/*                          Inclusao de Contra-ordem                         */
/* ************************************************************************* */
PROCEDURE inclui-contra:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_stlcmexc AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_stlcmcad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_dtemscch AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dsdctitg AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_flprovis AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtvalcor AS DATE                              NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-cheques.
    DEF  INPUT PARAM TABLE FOR tt-custdesc.
    DEF  INPUT PARAM par_tptransa AS INTE                              NO-UNDO. 
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO. 

    DEF OUTPUT PARAM log_tpatlcad AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM log_msgrecad AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-criticas.
    DEF OUTPUT PARAM TABLE FOR tt-contra.

    DEF VAR aux_dscrides AS CHAR                                       NO-UNDO.
    DEF VAR aux_dscricus AS CHAR                                       NO-UNDO.
    DEF VAR aux_retornvl AS CHAR INIT "NOK"                            NO-UNDO.
    DEF VAR aux_idsucess AS ROWID                                      NO-UNDO.
    DEF VAR aux_idcritic AS ROWID                                      NO-UNDO.
    DEF VAR aux_nrsucess AS INTE                                       NO-UNDO.
    DEF VAR aux_nrcritic AS INTE                                       NO-UNDO.
    DEF VAR aux_flagprov AS LOGICAL                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-criticas.
    EMPTY TEMP-TABLE tt-contra.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_nrsucess = 0
           aux_nrcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        /* ---------- Copia cheques selecionados e com critica
           para tt dos cheques para posterior tratamento */
        FOR EACH tt-custdesc NO-LOCK
            BREAK BY tt-custdesc.nrcheque:
          
            CREATE tt-cheques.
            BUFFER-COPY tt-custdesc TO tt-cheques.

        END.
        /* ---------- FIM  - Copia cheques selecionados */

        FIND crapass WHERE 
             crapass.cdcooper = par_cdcooper  AND
             crapass.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.

        FIND crapcop WHERE 
             crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        Cheques: FOR EACH tt-cheques NO-LOCK
            BREAK BY tt-cheques.cdbanchq
                    BY tt-cheques.cdagechq
                       BY tt-cheques.nrctachq
                          BY tt-cheques.nrinichq
                             BY tt-cheques.nrcheque:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            Critica: DO WHILE TRUE:
                
                /* Geracao de temp-table para LOG */
                CREATE tt-dctror-ant.
                ASSIGN tt-dctror-ant.cdcooper = par_cdcooper
                       tt-dctror-ant.nrdconta = par_nrdconta.

                IF  tt-cheques.dscritic <> "" THEN
                    LEAVE Critica.

                IF  NOT AVAILABLE crapcop  THEN
                     DO:
                         ASSIGN aux_cdcritic = 651.
                         LEAVE Critica.
                     END.

                IF  NOT AVAIL crapass THEN
                    DO:
                        ASSIGN aux_cdcritic = 9.
                        LEAVE Critica.
                    END.

                FIND craphis WHERE 
                     craphis.cdcooper = par_cdcooper AND
                     craphis.cdhistor = tt-cheques.cdhistor 
                     NO-LOCK NO-ERROR.
        
                IF  NOT AVAILABLE craphis   THEN
                    DO:
                        ASSIGN aux_cdcritic = 93.
                        LEAVE Critica.
                    END.

                Contador: DO aux_contador = 1 TO 10:

                    FIND crapfdc WHERE 
                         crapfdc.cdcooper = par_cdcooper AND
                         crapfdc.cdbanchq = tt-cheques.cdbanchq AND
                         crapfdc.cdagechq = tt-cheques.cdagechq AND
                         crapfdc.nrctachq = tt-cheques.nrctachq AND
                         crapfdc.nrcheque = 
                         INT(SUBSTR(STRING(tt-cheques.nrcheque,"9999999"),1,6))
                         USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAIL crapfdc THEN
                        IF  LOCKED crapfdc  THEN
                            DO:
                                IF  aux_contador = 10 THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 341.
                                        LEAVE Critica.
                                    END.
                                ELSE
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT Contador.
                                    END.
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 108.
                                LEAVE Critica.
                            END.
                    LEAVE Contador.
                END.
                
                IF   NOT tt-cheques.flprovis THEN
                     DO:
                         /* Grava somente para contra-ordem permanente */
                   
                         IF   (crapass.nrdctitg    = par_dsdctitg     AND
                               tt-cheques.cdbanchq = 1)               OR
                               tt-cheques.cdbanchq = 756              OR
                               tt-cheques.cdbanchq = crapcop.cdbcoctl THEN  
                               DO:
                                   RUN grava-crapcch 
                                       ( INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT par_flgerlog,
                                         INPUT par_dtmvtolt,
                                         INPUT crapfdc.cdbanchq,
                                         INPUT crapfdc.nrdconta,
                                         INPUT crapfdc.nrdctabb,
                                         INPUT tt-cheques.nrcheque,
                                         INPUT tt-cheques.cdhistor,
                                         INPUT par_stlcmexc, /* Inclusao */  
                                         INPUT par_stlcmcad, /* Exclusao */  
                                         INPUT par_dtemscch,
                                         INPUT tt-cheques.nrctachq,
                                         INPUT crapfdc.nrdctitg,
                                         INPUT crapfdc.nrseqems,
                                         INPUT crapfdc.cdagechq,
                                         OUTPUT TABLE tt-erro ).

                                   IF  RETURN-VALUE <> "OK" THEN
                                       DO:
                                           FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                           IF  AVAIL tt-erro THEN
                                               ASSIGN aux_cdcritic =
                                                        tt-erro.cdcritic.
                                       END.
                               END.        
                    END.

                LEAVE Critica.

            END. /* Fim DO WHILE - Critica */

            /* ---------- Criticas para erros de lock */
            IF  aux_cdcritic <> 0 THEN
                DO:
                    FIND crapcri WHERE 
                         crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.

                    IF  AVAIL crapcri THEN
                        ASSIGN tt-cheques.dscritic = crapcri.dscritic.
                END.
            /* ---------- FIM - Criticas para erros de lock */

            /* ---------- LOG efetivacoes e criticas */
            IF  par_flgerlog  THEN
                DO:
                    IF  tt-cheques.dscritic = "" AND aux_idsucess = ? THEN
                        DO:
                            ASSIGN aux_dstransa = 
                            "Inclusao de contra-ordem: Efetivacoes".
                
                            RUN proc_gerar_log 
                                ( INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT "",
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT TRUE,
                                  INPUT par_idseqttl,
                                  INPUT par_nmdatela,
                                  INPUT par_nrdconta,
                                 OUTPUT aux_idsucess ).
                        END.
                    IF  tt-cheques.dscritic <> "" AND aux_idcritic = ? THEN
                        DO:
                            ASSIGN aux_dstransa = 
                            "Inclusao de contra-ordem: Criticas".
    
                            RUN proc_gerar_log 
                                ( INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT "",
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT FALSE,
                                  INPUT par_idseqttl,
                                  INPUT par_nmdatela,
                                  INPUT par_nrdconta,
                                 OUTPUT aux_idcritic ).
                        END.
                END.
            /* ---------- FIM - LOG efetivacoes e criticas */

            /* ---------- Gera Temp-table de criticas */
            IF  tt-cheques.dscritic <> "" THEN
                DO:
                    CREATE tt-criticas.
                    ASSIGN tt-criticas.cdbanchq = tt-cheques.cdbanchq
                           tt-criticas.cdagechq = tt-cheques.cdagechq
                           tt-criticas.nrctachq = tt-cheques.nrctachq
                           tt-criticas.nrcheque = tt-cheques.nrcheque
                           tt-criticas.dscritic = tt-cheques.dscritic.

                    /* Geracao de temp-table para LOG */
                    CREATE tt-dctror-atl.
                    ASSIGN tt-dctror-atl.cdcooper = par_cdcooper
                           tt-dctror-atl.nrdconta = par_nrdconta
                           tt-dctror-atl.cdbanchq = tt-cheques.cdbanchq
                           tt-dctror-atl.cdagechq = tt-cheques.cdagechq
                           tt-dctror-atl.nrctachq = tt-cheques.nrctachq
                           tt-dctror-atl.nrcheque = tt-cheques.nrcheque
                           tt-dctror-atl.dscritic = tt-cheques.dscritic.
                END.
            ELSE
                DO:
                    CREATE crapcor.
                    ASSIGN crapcor.nrdconta = par_nrdconta
                           crapcor.nrdctabb = tt-cheques.nrctachq
                           crapcor.nrdctitg = crapfdc.nrdctitg
                           crapcor.nrcheque = tt-cheques.nrcheque
                           crapcor.cdhistor = tt-cheques.cdhistor
                           crapcor.dtemscor = par_dtmvtolt
                           crapcor.nrtalchq = crapfdc.nrseqems
                           crapcor.cdcooper = par_cdcooper
                           crapcor.cdoperad = par_cdoperad
                           crapcor.hrtransa = TIME
                           crapcor.dtmvtolt = par_dtmvtolt
                           crapcor.cdbanchq = crapfdc.cdbanchq
                           crapcor.cdagechq = crapfdc.cdagechq
                           crapcor.nrctachq = crapfdc.nrctachq
                           crapcor.dtvalcor = IF tt-cheques.flprovis THEN
                                                 par_dtvalcor
                                              ELSE ?
                           crapcor.flgativo = TRUE.
                    
                    VALIDATE crapcor.

                    IF  craphis.tplotmov = 8  THEN
                        ASSIGN crapfdc.incheque = 
                               IF  crapfdc.incheque = 0 THEN 2 ELSE 7.
                    ELSE
                    IF  craphis.tplotmov = 9  THEN
                        ASSIGN crapfdc.incheque = 
                               IF  crapfdc.incheque = 0 THEN 1 ELSE 6.

                     IF  tt-cheques.flprovis THEN
                         aux_flagprov = TRUE.
                     ELSE 
                         aux_flagprov = FALSE.                    
                    
                    IF   par_tptransa = 2 THEN /*  Tipo 2 - Contra-Ordem  */
                         RUN log-contra-cheque 
                            (INPUT par_dtmvtolt,
                             INPUT crapcor.cdoperad,
                             INPUT crapcor.cdhistor,
                             INPUT crapcor.nrdconta,
                             INPUT crapcor.nrcheque,  
                             INPUT crapcor.cdbanchq,
                             INPUT crapcor.cdagechq, 
                             INPUT par_cddopcao,
                             INPUT aux_flagprov).          

                    /* Geracao de temp-table para LOG */
                    CREATE tt-dctror-atl.
                    ASSIGN tt-dctror-atl.cdcooper = par_cdcooper
                           tt-dctror-atl.nrdconta = par_nrdconta
                           tt-dctror-atl.cdbanchq = tt-cheques.cdbanchq
                           tt-dctror-atl.cdagechq = tt-cheques.cdagechq
                           tt-dctror-atl.nrctachq = tt-cheques.nrctachq
                           tt-dctror-atl.nrcheque = tt-cheques.nrcheque.
                END.
            
            
            /* ---------- Grava LOG dos cheques */
            IF  tt-cheques.dscritic = "" THEN
                ASSIGN aux_nrsucess = aux_nrsucess + 1.
            ELSE
                ASSIGN aux_nrcritic = aux_nrcritic + 1.

            RUN log-contras 
                ( INPUT (IF  tt-cheques.dscritic = "" THEN aux_nrsucess
                             ELSE aux_nrcritic),
                  INPUT (IF  tt-cheques.dscritic = "" THEN aux_idsucess
                             ELSE aux_idcritic),
                  INPUT TABLE tt-dctror-ant,
                  INPUT TABLE tt-dctror-atl ).

            EMPTY TEMP-TABLE tt-dctror-ant.
            EMPTY TEMP-TABLE tt-dctror-atl.
            /* ---------- FIM - Grava LOG dos cheques */
                    
            /* ---------- Tratamento para impressao */
            FIND FIRST tt-contra WHERE 
                       NOT(tt-contra.flgfecha) NO-LOCK NO-ERROR.

            IF  AVAIL tt-contra THEN
                DO:
                    IF  tt-cheques.dscritic <> "" THEN
                        ASSIGN tt-contra.flgfecha = TRUE.
                    ELSE
                        ASSIGN tt-contra.nrfinchq = tt-cheques.nrcheque.

                    IF  tt-cheques.nrcheque = tt-cheques.nrfinchq THEN
                        ASSIGN tt-contra.flgfecha = TRUE.
                END.
            ELSE
            IF  tt-cheques.dscritic = "" THEN
                DO:
                    CREATE tt-contra.
                    BUFFER-COPY tt-cheques 
                        EXCEPT tt-cheques.dscritic
                               tt-cheques.nrinichq
                               tt-cheques.nrfinchq TO tt-contra
                        ASSIGN tt-contra.nrinichq = tt-cheques.nrcheque
                               tt-contra.nrfinchq = tt-cheques.nrcheque
                               tt-contra.flgfecha = FALSE.

                    IF  tt-cheques.nrcheque = tt-cheques.nrfinchq THEN
                        ASSIGN tt-contra.flgfecha = TRUE.
                END.
            /* ---------- FIM - Tratamento para impressao  */

        END. /* Fim CHEQUES: For each */

        ASSIGN aux_retornvl = "OK".
    END.

    RELEASE crapfdc.
    RELEASE crapcor.

    /* Opcao E ou I mesmo com erro retornara OK
       criticas serão verificadas de outra forma  */
    RETURN aux_retornvl.

END PROCEDURE.

/* ************************************************************************* */
/*                           Exclusao de Contra-ordem                        */
/* ************************************************************************* */
PROCEDURE exclui-contra:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.

    DEF  INPUT PARAM par_stlcmexc AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_stlcmcad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_dtemscch AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dsdctitg AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_flprovis AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-cheques.
    DEF  INPUT PARAM par_tptransa AS INTE                              NO-UNDO. 
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM log_msgrecad AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-criticas.
    DEF OUTPUT PARAM TABLE FOR tt-contra.

    DEF VAR aux_nrchqsdv AS INTE                                       NO-UNDO.
    DEF VAR aux_nrchqcdv AS INTE                                       NO-UNDO.
    DEF VAR aux_primeivz AS LOGI                                       NO-UNDO.
    DEF VAR aux_nrcheque AS INTE                                       NO-UNDO.
    DEF VAR aux_nrcalcul AS INTE                                       NO-UNDO.
    DEF VAR aux_retornvl AS CHAR INIT "NOK"                            NO-UNDO.
    DEF VAR aux_idsucess AS ROWID                                      NO-UNDO.
    DEF VAR aux_idcritic AS ROWID                                      NO-UNDO.
    DEF VAR aux_nrsucess AS INTE                                       NO-UNDO.
    DEF VAR aux_nrcritic AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-criticas.
    EMPTY TEMP-TABLE tt-contra.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_nrsucess = 0
           aux_nrcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).
    
    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        FIND crapass WHERE 
             crapass.cdcooper = par_cdcooper  AND
             crapass.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.

        FIND crapcop WHERE 
             crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        ASSIGN aux_primeivz = TRUE. 

        Cheques: FOR EACH tt-cheques NO-LOCK
            BREAK BY tt-cheques.cdbanchq
                    BY tt-cheques.cdagechq
                       BY tt-cheques.nrctachq
                           BY tt-cheques.nrinichq:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
            
            Critica: DO WHILE TRUE:

                /* Geracao de temp-table para LOG */
                CREATE tt-dctror-ant.
                ASSIGN tt-dctror-ant.cdcooper = par_cdcooper
                       tt-dctror-ant.cdbanchq = tt-cheques.cdbanchq
                       tt-dctror-ant.cdagechq = tt-cheques.cdagechq
                       tt-dctror-ant.nrctachq = tt-cheques.nrctachq
                       tt-dctror-ant.nrcheque = tt-cheques.nrcheque.

                IF  tt-cheques.dscritic <> "" THEN
                    LEAVE Critica.

                IF  NOT AVAILABLE crapcop  THEN
                    DO:
                        ASSIGN aux_cdcritic = 651.
                        LEAVE Critica.
                    END.

                IF  NOT AVAIL crapass THEN
                    DO:
                        ASSIGN aux_cdcritic = 9.
                        LEAVE Critica.
                    END.

                Contador: DO aux_contador = 1 TO 10:
                    FIND crapcor WHERE 
                         crapcor.cdcooper = par_cdcooper        AND
                         crapcor.cdbanchq = tt-cheques.cdbanchq AND
                         crapcor.cdagechq = tt-cheques.cdagechq AND
                         crapcor.nrctachq = tt-cheques.nrctachq AND
                         crapcor.nrcheque = tt-cheques.nrcheque AND
                         crapcor.flgativo = TRUE
                         USE-INDEX crapcor1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAIL crapcor THEN
                        IF  LOCKED crapcor  THEN
                            DO:
                                IF  aux_contador = 10 THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 341.
                                        LEAVE Critica.
                                    END.
                                ELSE
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT Contador.
                                    END.
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 111.
                                LEAVE Critica.
                            END.
                    LEAVE Contador.
                END.

                FIND crapfdc WHERE 
                     crapfdc.cdcooper = par_cdcooper AND
                     crapfdc.cdbanchq = tt-cheques.cdbanchq AND
                     crapfdc.cdagechq = tt-cheques.cdagechq AND
                     crapfdc.nrctachq = tt-cheques.nrctachq AND
                     crapfdc.nrcheque = 
                     INT(SUBSTR(STRING(tt-cheques.nrcheque,"9999999"),1,6))
                     USE-INDEX crapfdc1 NO-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crapfdc THEN
                    DO:
                        ASSIGN aux_cdcritic = 108.
                        LEAVE Critica.
                    END.

                Contador: DO aux_contador = 1 TO 10:
                    FIND crapalt WHERE 
                         crapalt.cdcooper = par_cdcooper     AND
                         crapalt.nrdconta = crapass.nrdconta AND
                         crapalt.dtaltera = par_dtmvtolt
                         USE-INDEX crapalt1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAIL crapalt THEN
                        IF  LOCKED crapalt  THEN
                            DO:
                                IF  aux_contador = 10 THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 341.
                                        LEAVE Critica.
                                    END.
                                ELSE
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT Contador.
                                    END.
                            END.
                    LEAVE Contador.
                END.


                IF  NOT tt-cheques.flprovis THEN
                   DO:
                    /* Grava somente para contra-ordem permanente */

                    /* Exclusivo BB */
                    IF (crapass.nrdctitg = par_dsdctitg  AND 
                        tt-cheques.cdbanchq = 1)         OR
                       (tt-cheques.cdbanchq = 756)       OR /*BANCOOB*/ 
                       (tt-cheques.cdbanchq = crapcop.cdbcoctl) THEN /*CECRED*/ 
                      DO:
                
                        RUN grava-crapcch 
                            ( INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT par_idorigem,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_flgerlog,
                              INPUT par_dtmvtolt,
                              INPUT crapfdc.cdbanchq,
                              INPUT crapfdc.nrdconta,
                              INPUT crapfdc.nrdctabb,
                              INPUT tt-cheques.nrcheque,
                              INPUT crapcor.cdhistor,
                              INPUT par_stlcmexc, /* Inclusao */  
                              INPUT par_stlcmcad, /* Exclusao */  
                              INPUT par_dtemscch,
                              INPUT tt-cheques.nrctachq,
                              INPUT crapfdc.nrdctitg,
                              INPUT crapfdc.nrseqems,
                              INPUT crapfdc.cdagechq,
                             OUTPUT TABLE tt-erro ).

                        IF  RETURN-VALUE <> "OK" THEN
                            DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                IF  AVAIL tt-erro THEN
                                    ASSIGN aux_cdcritic = tt-erro.cdcritic.
                            END.
                    END.
                END. /* END do IF NOT provis */
                LEAVE Critica.
            END.
            
            /* ---------- Criticas para erros de lock */
            IF  aux_cdcritic <> 0 THEN
                DO:
                    FIND crapcri WHERE 
                         crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.

                    IF  AVAIL crapcri THEN
                        ASSIGN tt-cheques.dscritic = crapcri.dscritic.
                    ELSE
                        ASSIGN tt-cheques.dscritic = 
                               "Nao foi possivel encontrar " +
                               "registro para critica".
                END.
            /* ---------- FIM - Criticas para erros de lock */
            
            /* ---------- LOG efetivacoes e criticas */
            IF  par_flgerlog  THEN
                DO:
                    IF  tt-cheques.dscritic = "" AND aux_idsucess = ? THEN
                        DO:
                            ASSIGN aux_dstransa = 
                            "Exclusao de contra-ordem: Efetivacoes".
                
                            RUN proc_gerar_log 
                                ( INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT "",
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT TRUE,
                                  INPUT par_idseqttl,
                                  INPUT par_nmdatela,
                                  INPUT par_nrdconta,
                                 OUTPUT aux_idsucess ).
                        END.
                    
                    IF  tt-cheques.dscritic <> "" AND aux_idcritic = ? THEN
                        DO:
                            ASSIGN aux_dstransa =  
                                    "Exclusao de contra-ordem: Criticas".
    
                            RUN proc_gerar_log 
                                ( INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT "",
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT FALSE,
                                  INPUT par_idseqttl,
                                  INPUT par_nmdatela,
                                  INPUT par_nrdconta,
                                 OUTPUT aux_idcritic ).
                        END.
                END.
            /* ---------- FIM - LOG efetivacoes e criticas */
            
            /* ---------- Gera Temp-table de criticas */
            IF  tt-cheques.dscritic <> "" THEN
                DO:
                    CREATE tt-criticas.
                    ASSIGN tt-criticas.cdbanchq = tt-cheques.cdbanchq
                           tt-criticas.cdagechq = tt-cheques.cdagechq
                           tt-criticas.nrctachq = tt-cheques.nrctachq
                           tt-criticas.nrcheque = tt-cheques.nrcheque
                           tt-criticas.dscritic = tt-cheques.dscritic.

                    /* Geracao de temp-table para LOG */
                    CREATE tt-dctror-atl.
                    ASSIGN tt-dctror-atl.cdcooper = par_cdcooper
                           tt-dctror-atl.nrdconta = par_nrdconta
                           tt-dctror-atl.cdbanchq = tt-cheques.cdbanchq
                           tt-dctror-atl.cdagechq = tt-cheques.cdagechq
                           tt-dctror-atl.nrctachq = tt-cheques.nrctachq
                           tt-dctror-atl.nrcheque = tt-cheques.nrcheque
                           tt-dctror-atl.dscritic = tt-cheques.dscritic.
                           
                END.
            ELSE /* Deleta contra-ordem/Atualiza rejeitados */
                DO: 
                    CREATE craprej.
                    ASSIGN craprej.dtmvtolt = par_dtmvtolt
                           craprej.dtdaviso = crapcor.dtemscor
                           craprej.nrdconta = crapcor.nrdconta
                           craprej.nrdctabb = crapcor.nrctachq
                           craprej.nrdctitg = crapcor.nrdctitg
                           craprej.cdhistor = crapcor.cdhistor
                           craprej.nrdolote = crapcor.nrtalchq
                           craprej.nrdocmto = crapcor.nrcheque
                           craprej.cdpesqbb = par_cdoperad
                           craprej.dshistor = par_nmdatela
                           craprej.cdcooper = par_cdcooper.

                    VALIDATE craprej.

                    /* Geracao de temp-table para LOG */
                    CREATE tt-dctror-atl.
                    ASSIGN tt-dctror-atl.cdcooper = par_cdcooper
                           tt-dctror-atl.nrdconta = par_nrdconta.

                    
                    /* Mar/2012 - Se Provis., nao deleta. Altera Situacao */
                    IF   tt-cheques.flprovis THEN
                         ASSIGN crapcor.flgativo = FALSE.
                    ELSE 
                         DELETE crapcor.

                    IF   par_tptransa = 2 THEN /*  Tipo 2 - Contra-Ordem  */
                         RUN log-contra-cheque 
                            (INPUT par_dtmvtolt,
                             INPUT par_cdoperad,
                             INPUT tt-cheques.cdhistor,
                             INPUT tt-cheques.nrdconta,
                             INPUT tt-cheques.nrcheque,  
                             INPUT tt-cheques.cdbanchq,
                             INPUT tt-cheques.cdagechq, 
                             INPUT par_cddopcao,
                             INPUT FALSE). 
                    
                    /* Alteração - Magui - 30/09/2002 */
                    IF  NOT AVAILABLE crapalt   THEN
                        DO:
                            CREATE crapalt.
                            ASSIGN crapalt.nrdconta = crapass.nrdconta
                                   crapalt.dtaltera = par_dtmvtolt
                                   crapalt.cdoperad = par_cdoperad
                                   crapalt.tpaltera = 2
                                   crapalt.dsaltera = 
                                            "excl.contra-ordem conta= " +
                                             STRING(par_nrdconta) + " chq. " + 
                                             STRING(tt-cheques.nrcheque) + ","
                                   crapalt.cdcooper = par_cdcooper.
                            
                            VALIDATE crapalt.
                        END.
                    ELSE
                /* Tratamentos - houver ou nao no log algum 
                   tipo de exclusao de contra-ordem - 
                   Guilherme - 24/10/2007 */
                        DO:
                            IF  crapalt.dsaltera MATCHES
                                "*excl.contra-ordem*" THEN
                                DO:
                                    IF  aux_primeivz = TRUE  THEN
                                        ASSIGN crapalt.dsaltera =
                                           crapalt.dsaltera
                                           + " excl.contra-ordem conta= " 
                                           + STRING(par_nrdconta) + " chq. " + 
                                           STRING(tt-cheques.nrcheque) 
                                           + ",". 
                                    ELSE     
                                    ASSIGN crapalt.dsaltera = 
                                           crapalt.dsaltera + " chq. " 
                                           + STRING(tt-cheques.nrcheque) 
                                           + ",".
                                END.                   
                            ELSE 
                                ASSIGN crapalt.dsaltera = crapalt.dsaltera 
                                       + " excl.contra-ordem conta= " +
                                       STRING(par_nrdconta) + " chq. " + 
                                       STRING(tt-cheques.nrcheque) + ",".
                        END. /* Fim do ELSE DO */

                    ASSIGN aux_primeivz = FALSE.
            END. /* Fim ELSE DO */
            
            /* ---------- Grava LOG dos cheques */
            IF  tt-cheques.dscritic = "" THEN
                ASSIGN aux_nrsucess = aux_nrsucess + 1.
            ELSE
                ASSIGN aux_nrcritic = aux_nrcritic + 1.

            RUN log-contras 
                ( INPUT (IF  tt-cheques.dscritic = "" THEN aux_nrsucess
                             ELSE aux_nrcritic),
                  INPUT (IF  tt-cheques.dscritic = "" THEN aux_idsucess
                             ELSE aux_idcritic),
                  INPUT TABLE tt-dctror-ant,
                  INPUT TABLE tt-dctror-atl ).

            EMPTY TEMP-TABLE tt-dctror-ant.
            EMPTY TEMP-TABLE tt-dctror-atl.
            /* ---------- FIM - Grava LOG dos cheques */
            
            /* ---------- Tratamento para impressao */
            FIND FIRST tt-contra WHERE 
                       NOT(tt-contra.flgfecha) NO-LOCK NO-ERROR.

            IF  AVAIL tt-contra THEN
                DO:
                    IF  tt-cheques.dscritic <> "" THEN
                        ASSIGN tt-contra.flgfecha = TRUE.
                    ELSE
                        ASSIGN tt-contra.nrfinchq = tt-cheques.nrcheque.

                    IF  tt-cheques.nrcheque = tt-cheques.nrfinchq THEN
                        ASSIGN tt-contra.flgfecha = TRUE.
                END.
            ELSE
            IF  tt-cheques.dscritic = "" THEN
                DO:
                    CREATE tt-contra.
                    BUFFER-COPY tt-cheques 
                        EXCEPT tt-cheques.dscritic
                               tt-cheques.nrinichq
                               tt-cheques.nrfinchq TO tt-contra
                        ASSIGN tt-contra.nrinichq = tt-cheques.nrcheque
                               tt-contra.nrfinchq = tt-cheques.nrcheque
                               tt-contra.flgfecha = FALSE.

                    IF  tt-cheques.nrcheque = tt-cheques.nrfinchq THEN
                        ASSIGN tt-contra.flgfecha = TRUE.
                END.
            /* ---------- FIM - Tratamento para impressao  */
            
        END. /* Fim do FOR EACH */
        
        /* Atualiza somente para contra-ordens validas */
        FOR EACH tt-contra NO-LOCK:
            DO aux_nrcheque = 
                TRUNCATE(tt-contra.nrinichq / 10,0)  TO
                TRUNCATE(tt-contra.nrfinchq / 10,0):

                ASSIGN aux_nrcalcul = aux_nrcheque * 10.

                ASSIGN aux_nrchqsdv = 
                       INT(SUBSTR(STRING(aux_nrcalcul,"9999999"),1,6))
                       aux_nrchqcdv = INT(aux_nrcalcul).

                Contador: DO aux_contador = 1 TO 10:

                    FIND crapfdc WHERE 
                         crapfdc.cdcooper = par_cdcooper       AND
                         crapfdc.cdbanchq = tt-contra.cdbanchq AND
                         crapfdc.cdagechq = tt-contra.cdagechq AND
                         crapfdc.nrctachq = tt-contra.nrctachq AND
                         crapfdc.nrcheque = aux_nrchqsdv
                         USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAIL crapfdc THEN
                        IF  LOCKED crapfdc  THEN
                            DO:
                                IF  aux_contador = 10 THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 341.
                                        UNDO Grava, LEAVE Grava.
                                    END.
                                ELSE
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT Contador.
                                    END.
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 108.
                                UNDO Grava, LEAVE Grava.
                            END.
                    LEAVE Contador.
                END.

                ASSIGN crapfdc.incheque = IF crapfdc.incheque > 5 THEN 5 
                                                                  ELSE 0. 
            END.
        END. /* Fim FOR EACH */

        ASSIGN aux_retornvl = "OK".
    END.

    RELEASE crapfdc.
    RELEASE crapcor.
    RELEASE crapalt.
    RELEASE craprej.

    /* Opcao E ou I mesmo com erro retornara OK
       criticas serão verificadas de outra forma  */
    RETURN aux_retornvl.

END PROCEDURE.

/* ************************************************************************* */
/*                            Gravacao dos dados                             */
/* ************************************************************************* */
PROCEDURE grava-dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_tptransa AS INTE                              NO-UNDO.

    DEF  INPUT PARAM par_tplotmov AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrinichq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_stlcmexc AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_stlcmcad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_dtemscch AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dsdctitg AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_flprovis AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtvalcor AS DATE                              NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-cheques.
    DEF  INPUT PARAM TABLE FOR tt-custdesc.
    

    DEF OUTPUT PARAM par_cdsitdtl AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_dssitdtl AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM log_msgrecad AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-criticas.
    DEF OUTPUT PARAM TABLE FOR tt-contra.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-criticas.
    EMPTY TEMP-TABLE tt-contra.
    
    DEF VAR aux_nrcpfcnpj_base AS DEC                                  NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.



    /* Para Ayllos Web */
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper
        NO-LOCK NO-ERROR.

    IF  par_flprovis  THEN DO:
        IF  par_dtvalcor = ? THEN DO:
    
            ASSIGN par_dtvalcor = crapdat.dtmvtopr + 1.
            
            DO WHILE TRUE:
                IF  CAN-DO("1,7", STRING(WEEKDAY(par_dtvalcor)))   
                OR  CAN-FIND(crapfer WHERE
                            crapfer.cdcooper = par_cdcooper  AND
                            crapfer.dtferiad = par_dtvalcor) THEN DO:
                     ASSIGN par_dtvalcor = par_dtvalcor + 1.
                END.
                ELSE LEAVE.
            END.
        END.
    END.

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        IF  par_cddopcao = "A" THEN
            DO:
                RUN altera-contra 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_flgerlog,
                      INPUT par_dtmvtolt,
                      INPUT par_tplotmov,
                      INPUT par_cdbanchq,
                      INPUT par_cdagechq,
                      INPUT par_nrctachq,
                      INPUT par_nrinichq,
                      INPUT par_cdhistor,
                      INPUT par_stlcmexc,
                      INPUT par_stlcmcad,
                      INPUT par_dtemscch,
                      INPUT par_dsdctitg,
                      INPUT par_flprovis,
                      INPUT par_dtvalcor,
                      INPUT par_tptransa,
                      INPUT par_cddopcao,
                     OUTPUT TABLE tt-erro,
                     OUTPUT TABLE tt-contra).

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN RETURN-VALUE.
            END.
        ELSE
        IF  par_cddopcao = "E" OR par_cddopcao = "I" THEN
            DO: /* Bloqueio/Prejuizo */
                IF  CAN-DO("1,3", STRING(par_tptransa)) THEN
                    DO:
                        RUN trata-bloqpreju 
                            ( INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT par_idorigem,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_flgerlog,
                              INPUT par_dtmvtolt,
                              INPUT par_cddopcao,
                              INPUT par_tptransa,
                             OUTPUT par_cdsitdtl,
                             OUTPUT par_dssitdtl,
                             OUTPUT log_tpatlcad,
                             OUTPUT log_msgatcad,
                             OUTPUT log_chavealt,
                             OUTPUT log_msgrecad ).

                        IF  RETURN-VALUE <> "OK" THEN
                            RETURN RETURN-VALUE.
                    END.
                ELSE /* Contra-Ordem/Aviso */
                IF  par_cddopcao = "E" AND par_tptransa = 2 THEN
                    DO:
                        RUN exclui-contra 
                            ( INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT par_idorigem,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_flgerlog,
                              INPUT par_dtmvtolt,
                              INPUT par_stlcmexc,
                              INPUT par_stlcmcad,
                              INPUT par_dtemscch,
                              INPUT par_dsdctitg,
                              INPUT par_flprovis,
                              INPUT TABLE tt-cheques,
                              INPUT par_tptransa,
                              INPUT par_cddopcao,
                             OUTPUT log_tpatlcad,
                             OUTPUT log_msgatcad,
                             OUTPUT log_chavealt,
                             OUTPUT log_msgrecad,
                             OUTPUT TABLE tt-erro,  
                             OUTPUT TABLE tt-criticas, 
                             OUTPUT TABLE tt-contra ). 

                        IF  RETURN-VALUE <> "OK" THEN
                            RETURN RETURN-VALUE.

                    END.  /*  Fim do IF .. THEN  */
                ELSE
                IF  par_cddopcao = "I" AND par_tptransa = 2 THEN
                    DO:
                        RUN inclui-contra 
                            ( INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT par_idorigem,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_flgerlog,
                              INPUT par_dtmvtolt,
                              INPUT par_stlcmexc,
                              INPUT par_stlcmcad,
                              INPUT par_dtemscch,
                              INPUT par_dsdctitg,
                              INPUT par_flprovis,
                              INPUT par_dtvalcor,
                              INPUT TABLE tt-cheques, 
                              INPUT TABLE tt-custdesc,
                              INPUT par_tptransa,
                              INPUT par_cddopcao,
                             OUTPUT log_tpatlcad, 
                             OUTPUT log_msgatcad, 
                             OUTPUT log_chavealt, 
                             OUTPUT log_msgrecad, 
                             OUTPUT TABLE tt-erro,  
                             OUTPUT TABLE tt-criticas,
                             OUTPUT TABLE tt-contra ).  

                        IF  RETURN-VALUE <> "OK" THEN
                            RETURN RETURN-VALUE.
                    END.
			   
               /* P442 - Bloquear pre-aprovado no caso de inclusao nas condicoes abaixo */
               IF CAN-DO("2,4,6,8", STRING(par_cdsitdtl)) AND  par_cddopcao = "I" THEN
                DO:
                  /* Buscar CPF/CNPJ raiz do associado */
                  FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                  IF AVAIL crapass THEN
                    DO:
                      aux_nrcpfcnpj_base = crapass.nrcpfcnpj_base.
                      
                      /*** Traz todos os registros de cada cooperativa ativa ***/
                      FOR EACH crapcop WHERE crapcop.flgativo = TRUE
                               NO-LOCK:

                        /* Buscar CPF/CNPJ raiz do associado */
                        FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                                                 crapass.nrcpfcnpj_base = aux_nrcpfcnpj_base NO-LOCK NO-ERROR.

                        IF AVAIL crapass THEN
                          DO:

                          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                          /* Efetuar a chamada a rotina Oracle */
                          RUN STORED-PROCEDURE pc_proces_perca_pre_aprovad
                            aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapcop.cdcooper
                                                                ,INPUT 0
                                                                ,INPUT crapass.nrdconta
                                                                ,INPUT crapass.inpessoa
                                                                ,INPUT crapass.nrcpfcnpj_base
                                                                ,INPUT par_dtmvtolt
                                                                ,INPUT 37
                                                                ,INPUT 0
                                                                ,INPUT 0
                                                                ,OUTPUT "").

                          /* Fechar o procedimento para buscarmos o resultado */
                          CLOSE STORED-PROC pc_proces_perca_pre_aprovad
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                          ASSIGN aux_dscritic = ""
                              aux_dscritic = pc_proces_perca_pre_aprovad.pr_dscritic WHEN pc_proces_perca_pre_aprovad.pr_dscritic <> ?.

                          IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                            DO:
                              RUN gera_erro (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT 1, /*sequencia*/
                                             INPUT aux_cdcritic,
                                             INPUT-OUTPUT aux_dscritic).

                                RETURN "NOK".

                            END. /* IF critic */

                          END. /* IF avail */

                      END. /* FOR */

                    END. /* IF Avail */

                END. /* IF par_cddopcao */
            END.
    END.

    RETURN "OK".

END PROCEDURE.


/* ************************************************************************* */
/*     Procedures para tratar crapcch (retirado de proc_tratar_crapcch.i)    */
/*     Controles da Dctror e Mantal para enviar ao Banco do Brasil           */
/* ************************************************************************* */
PROCEDURE grava-crapcch:

    /* Essa procedure faz a inclusao e a exclusao de registros na crapcch,
      as variaveis "par_stlcmexc" e "par_stlcmcad" recebem valores de acordo
      com o que sera feito(inclusao/exclusao).
      Se for uma INCLUSAO de contra-ordem no BB, ela verifica se ja existe uma
      EXCLUSAO da mesma contra-ordem que ainda NAO FOI ENVIADA, se houver, 
      entao essa exclusao sera deletada.
      Casa nao for encontrada essa EXCLUSAO NAO ENVIADA, ela verifica se ja
      houve uma INCLUSAO dessa MESMA contra-ordem, se houve, ela ATUALIZA os
      campos para ser enviada novamente, senao eh CRIADO um novo registro para
      fazer a INCLUSAO da contra-ordem no BB.
      No caso de uma EXCLUSAO o procedimento eh o mesmo de acordo com os 
      valores das variaveis "par_stlcmexc" e "par_stlcmcad" */

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.

    DEF  INPUT PARAM par_cdbanchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdctfdc AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdctabb AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrinichq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_stlcmexc AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_stlcmcad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_dtemscch AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrdctitg AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrseqems AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                       NO-UNDO.
    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_nrchqsdv AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    ASSIGN aux_flgtrans = FALSE.

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        IF  par_cdbanchq = 1 THEN
            DO:
                Contador: DO aux_contador = 1 TO 10:
                    FIND FIRST crapcch WHERE
                               crapcch.cdcooper = par_cdcooper AND
                               crapcch.nrdconta = par_nrdctfdc AND
                               crapcch.nrdctabb = par_nrdctabb AND
                               crapcch.nrchqini = par_nrinichq AND
                               crapcch.nrchqfim = par_nrinichq AND
                               crapcch.cdhistor <> 0           AND
                               crapcch.cdhistor = par_cdhistor AND
                               crapcch.tpopelcm = par_stlcmexc AND
                               crapcch.flgctitg = 0            AND
                               crapcch.cdbanchq = 1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAIL crapcch THEN
                        DO:
                            IF  LOCKED crapcch  THEN
                                DO:
                                    IF  aux_contador = 10 THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 341.
                                            UNDO Grava, LEAVE Grava.
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT Contador.
                                        END.
                                END.
                            ELSE
                                LEAVE Contador.
                        END.
                    ELSE
                        DO:
                            DELETE crapcch.
                            ASSIGN aux_flgtrans = TRUE.
                            LEAVE Grava.
                        END.
                END.

                Contador: DO aux_contador = 1 TO 10:
                    FIND FIRST crapcch WHERE
                               crapcch.cdcooper = par_cdcooper AND
                               crapcch.nrdconta = par_nrdctfdc AND
                               crapcch.nrdctabb = par_nrdctabb AND
                               crapcch.nrchqini = par_nrinichq AND
                               crapcch.nrchqfim = par_nrinichq AND
                               crapcch.cdhistor <> 0           AND
                               crapcch.tpopelcm = par_stlcmcad AND
                               crapcch.cdbanchq = 1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAIL crapcch THEN
                        DO:
                            IF  LOCKED crapcch  THEN
                                DO:
                                    IF  aux_contador = 10 THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 341.
                                            UNDO Grava, LEAVE Grava.
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT Contador.
                                        END.
                                END.
                            ELSE
                                DO:
                                    CREATE crapcch.
                                    ASSIGN crapcch.dtmvtolt =
                                                      IF  par_dtemscch = ? THEN
                                                          par_dtmvtolt
                                                      ELSE
                                                          par_dtemscch
                                           crapcch.nrdconta = par_nrdconta
                                           crapcch.nrdctabb = par_nrctachq
                                           crapcch.nrdctitg = par_nrdctitg
                                           crapcch.nrtalchq = par_nrseqems
                                           crapcch.cdhistor = par_cdhistor
                                           crapcch.nrchqini = par_nrinichq
                                           crapcch.nrchqfim = par_nrinichq
                                           crapcch.tpopelcm = par_stlcmcad
                                           crapcch.cdcooper = par_cdcooper
                                           crapcch.cdbanchq = par_cdbanchq
                                           crapcch.cdagechq = par_cdagechq
                                           crapcch.nrctachq = par_nrctachq
                                                              NO-ERROR.

                                    IF  ERROR-STATUS:ERROR THEN
                                        DO:
                                            ASSIGN aux_dscritic =
                                                   ERROR-STATUS:GET-MESSAGE(1).
                                            UNDO Grava, LEAVE Grava.
                                        END.

                                    VALIDATE crapcch.
                                    LEAVE Contador.
                                END.
                        END.
                    ELSE
                        DO:
                            IF  crapcch.flgctitg = 2   THEN
                                ASSIGN crapcch.flgctitg = 0
                                       crapcch.nrseqarq = 0
                                       crapcch.cdhistor = par_cdhistor.
                            ELSE
                                ASSIGN crapcch.cdhistor = par_cdhistor.

                            LEAVE Contador.
                         END.
                END.
            END.
        ELSE
            DO: /* BANCOOB e CECRED tem o mesmo tratamento */
                Contador: DO aux_contador = 1 TO 10:
                    /* Verifica qual foi a ultima movimentacao */
                    FIND LAST crapcch WHERE
                              crapcch.cdcooper = par_cdcooper AND
                              crapcch.nrdconta = par_nrdctfdc AND
                              crapcch.nrdctabb = par_nrdctabb AND
                              crapcch.nrchqini = par_nrinichq AND
                              crapcch.nrchqfim = par_nrinichq AND
                              crapcch.cdhistor <> 0           AND
                              crapcch.cdhistor = par_cdhistor AND
                              crapcch.cdbanchq = par_cdbanchq
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAIL crapcch THEN
                        DO:
                            IF  LOCKED crapcch  THEN
                                DO:
                                    IF  aux_contador = 10 THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 341.
                                            UNDO Grava, LEAVE Grava.
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT Contador.
                                        END.
                                END.
                            ELSE
                                LEAVE Contador.
                        END.
                    ELSE
                        LEAVE Contador.
                END.

                IF  AVAIL crapcch THEN
                    DO:
                        /* Se tem um movimento anterior de exclusao nao,
                        enviado somente deleta esse registro */
                        IF  crapcch.tpopelcm = par_stlcmexc   AND
                            crapcch.flgctitg = 0              THEN
                            DELETE crapcch.
                        ELSE
                        IF  crapcch.tpopelcm = par_stlcmcad   THEN
                            /* Nao reenvia a inclusao */
                            ASSIGN crapcch.cdhistor = par_cdhistor
                                   crapcch.tpopelcm = "3".
                        ELSE
                            DO:
                                CREATE crapcch.
                                ASSIGN crapcch.dtmvtolt =
                                                      IF  par_dtemscch = ? THEN
                                                          par_dtmvtolt
                                                      ELSE
                                                          par_dtemscch
                                       crapcch.nrdconta = par_nrdconta
                                       crapcch.nrdctabb = par_nrctachq
                                       crapcch.nrdctitg = par_nrdctitg
                                       crapcch.nrtalchq = par_nrseqems
                                       crapcch.cdhistor = par_cdhistor
                                       crapcch.nrchqini = par_nrinichq
                                       crapcch.nrchqfim = par_nrinichq
                                       crapcch.tpopelcm = par_stlcmcad
                                       crapcch.cdcooper = par_cdcooper
                                       crapcch.cdbanchq = par_cdbanchq
                                       crapcch.cdagechq = par_cdagechq
                                       crapcch.nrctachq = par_nrctachq 
                                                                           NO-ERROR.

                                IF  ERROR-STATUS:ERROR THEN
                                    DO:
                                        ASSIGN aux_dscritic =
                                               ERROR-STATUS:GET-MESSAGE(1).
                                        UNDO Grava, LEAVE Grava.
                                    END.
                                VALIDATE crapcch.
                            END.
                    END.
                ELSE
                    DO:
                        CREATE crapcch.
                        ASSIGN crapcch.dtmvtolt = IF  par_dtemscch = ? THEN
                                                      par_dtmvtolt
                                                  ELSE
                                                      par_dtemscch
                               crapcch.nrdconta = par_nrdconta
                               crapcch.nrdctabb = par_nrctachq
                               crapcch.nrdctitg = par_nrdctitg
                               crapcch.nrtalchq = par_nrseqems
                               crapcch.cdhistor = par_cdhistor
                               crapcch.nrchqini = par_nrinichq
                               crapcch.nrchqfim = par_nrinichq
                               crapcch.tpopelcm = par_stlcmcad
                               crapcch.cdcooper = par_cdcooper
                               crapcch.cdbanchq = par_cdbanchq
                               crapcch.cdagechq = par_cdagechq
                               crapcch.nrctachq = par_nrctachq NO-ERROR.

                        IF  ERROR-STATUS:ERROR THEN
                            DO:
                                ASSIGN aux_dscritic =
                                       ERROR-STATUS:GET-MESSAGE(1).
                                UNDO Grava, LEAVE Grava.
                            END.
                        VALIDATE crapcch.
                    END.
            END.

        ASSIGN aux_flgtrans = TRUE.

    END.

    RELEASE crapcch.

    IF  (NOT aux_flgtrans) OR (aux_cdcritic <> 0 OR aux_dscritic <> "")  THEN
        DO:
            IF  (aux_cdcritic = 0 AND aux_dscritic = "") THEN
                ASSIGN aux_dscritic = "Erro na transacao. Nao foi possivel" +
                                      " gravar os dados.".

            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/* ************************************************************************* */
/**                         Busca Contra-Ordens                             **/
/** Entrada: tt com as contra-ordens                                        **/
/** Saida  : tt com a contra-ordem ajustada e validada                      **/
/* ************************************************************************* */
PROCEDURE busca-contra-ordens:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrinichq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrfinchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flprovis AS LOGI                              NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-contra.
    DEF OUTPUT PARAM TABLE FOR tt-dctror.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrchqini AS INTE                                       NO-UNDO.
    DEF VAR aux_nrchqfin AS INTE                                       NO-UNDO.
    DEF VAR aux_flgexist AS LOGI INIT FALSE                            NO-UNDO.
    DEF VAR aux_dtrefere AS DATE									                     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dctror.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    Busca: DO WHILE TRUE:

        IF  par_cddopcao = "E" THEN
            DO:

                ASSIGN aux_nrchqini = par_nrinichq
                       aux_nrchqfin = IF   par_nrfinchq > 0  THEN
                                           par_nrfinchq
                                      ELSE par_nrinichq.
        
                FOR EACH crapcor WHERE crapcor.cdcooper  = par_cdcooper   AND
                                       crapcor.cdbanchq  = par_cdbanchq   AND
                                       crapcor.cdagechq  = par_cdagechq   AND
                                       crapcor.nrctachq  = par_nrctachq   AND
                                       crapcor.nrcheque >= aux_nrchqini   AND
                                       crapcor.nrcheque <= aux_nrchqfin   AND
                                       crapcor.flgativo  = TRUE
                                       NO-LOCK
                                       BREAK BY crapcor.cdcooper
                                                BY crapcor.cdbanchq
                                                   BY crapcor.cdagechq
                                                      BY crapcor.nrctachq
                                                         BY crapcor.nrcheque:
        
                    FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                                       craphis.cdhistor = crapcor.cdhistor
                                       NO-LOCK NO-ERROR.
        
                    IF  NOT AVAILABLE craphis  THEN
                        DO:
                            ASSIGN aux_cdcritic = 80.
                            LEAVE Busca.
                        END.
        
                    IF FIRST (crapcor.nrctachq) THEN
                        DO:
                            ASSIGN aux_flgexist = TRUE.
        
                            CREATE tt-dctror.
                            ASSIGN tt-dctror.cdcooper = crapcor.cdcooper
                                   tt-dctror.dtemscor = crapcor.dtemscor
                                   tt-dctror.nrtalchq = crapcor.nrtalchq
                                   tt-dctror.nrctachq = crapcor.nrctachq
                                   tt-dctror.cdhistor = crapcor.cdhistor
                                   tt-dctror.nrinichq = crapcor.nrcheque
                                   tt-dctror.nrfinchq = crapcor.nrcheque
                                   tt-dctror.cdbanchq = crapcor.cdbanchq
                                   tt-dctror.cdagechq = crapcor.cdagechq
                                   tt-dctror.nrdconta = crapcor.nrdconta
                                   tt-dctror.dtvalcor = crapcor.dtvalcor
                                   tt-dctror.flprovis = 
                                          IF   crapcor.dtvalcor <> ? THEN
                                               TRUE
                                          ELSE 
                                               FALSE
                                   tt-dctror.dsprovis =
                                         IF   crapcor.dtvalcor <> ? THEN
                                               "SIM"
                                          ELSE 
                                               "NAO"
                                   tt-dctror.flgativo = crapcor.flgativo.      
                        END.
        
                    IF  LAST (crapcor.nrctachq) THEN
                        DO:
                            ASSIGN tt-dctror.nrfinchq = crapcor.nrcheque
                                   tt-dctror.dshistor = STRING(crapcor.cdhistor,"9999")
                                                      + "-" + craphis.dshistor.
                        END.
                END.  /*  Fim do FOR EACH  */
        
                IF  NOT aux_flgexist THEN
                    DO:
                        ASSIGN aux_cdcritic = 254.
                        LEAVE Busca.
                    END.
            END.
        ELSE
            DO:
                FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                                   craphis.cdhistor = par_cdhistor
                                   NO-LOCK NO-ERROR.

                CREATE tt-dctror.
                ASSIGN tt-dctror.cdcooper = par_cdcooper
                       tt-dctror.nrctachq = par_nrctachq
                       tt-dctror.cdhistor = par_cdhistor
                       tt-dctror.dshistor = IF  AVAIL craphis 
                                                THEN craphis.dshistor ELSE ""
                       tt-dctror.nrinichq = par_nrinichq
                       tt-dctror.cdbanchq = par_cdbanchq
                       tt-dctror.cdagechq = par_cdagechq
                       tt-dctror.nrdconta = par_nrdconta
                       tt-dctror.flprovis = par_flprovis
                       tt-dctror.dsprovis =  IF  par_flprovis THEN
                                                 "SIM"
                                             ELSE 
                                                 "NAO".

                IF  par_cddopcao = "I" THEN
                    DO:
                        IF  par_nrfinchq > 0  THEN
                            ASSIGN tt-dctror.nrfinchq = par_nrfinchq.
                        ELSE 
                            ASSIGN tt-dctror.nrfinchq = par_nrinichq.
                        
                        FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                        
                        ASSIGN aux_dtrefere = fn_dia_util_anterior(par_cdcooper, crapdat.dtmvtolt, 1).
                           
                        FIND FIRST crapfdc WHERE crapfdc.cdcooper  = par_cdcooper AND
                                                 crapfdc.cdbanchq  = par_cdbanchq AND
                                                 crapfdc.cdagechq  = par_cdagechq AND
                                                 crapfdc.nrctachq  = par_nrctachq AND
                                                 crapfdc.nrcheque >= INTEGER(TRUNCATE((par_nrinichq / 10),0)) AND
                                                 crapfdc.dtliqchq <> ?            AND 
                                                 crapfdc.nrcheque <= INTEGER(TRUNCATE((tt-dctror.nrfinchq / 10),0)) AND 
                                                 crapfdc.dtliqchq <> aux_dtrefere
                                                 NO-LOCK NO-ERROR.
                        IF AVAIL crapfdc THEN
                           ASSIGN tt-dctror.dtliqchq = crapfdc.dtliqchq.
                            
                    END.
                ELSE
                    ASSIGN tt-dctror.nrfinchq = par_nrfinchq. 
        END.

        IF  par_cddopcao = "I" THEN
            DO:
                FIND FIRST tt-dctror NO-LOCK NO-ERROR.

                IF  AVAIL tt-dctror THEN
                    DO:
                       
                        FIND LAST crapcor WHERE crapcor.cdcooper  = tt-dctror.cdcooper  AND
                                                crapcor.cdbanchq  = tt-dctror.cdbanchq  AND
                                                crapcor.cdagechq  = tt-dctror.cdagechq  AND
                                                crapcor.nrctachq  = tt-dctror.nrctachq  AND
                                                crapcor.nrcheque >= tt-dctror.nrinichq  AND
                                                crapcor.nrcheque <= tt-dctror.nrfinchq  AND
                                                crapcor.flgativo  = TRUE NO-LOCK NO-ERROR.

                        IF AVAIL crapcor THEN
                        DO:
                            ASSIGN aux_dscritic = "Sustacao provisoria ja realizada anteriormente " +
                                                  "neste cheque em " + STRING(crapcor.dtmvtolt,"99/99/9999").
                            LEAVE Busca.

                        END.
                           

                       FIND LAST crapcor WHERE crapcor.cdcooper = tt-dctror.cdcooper  AND
                                                   crapcor.cdbanchq = tt-dctror.cdbanchq  AND
                                                   crapcor.cdagechq = tt-dctror.cdagechq  AND
                                                   crapcor.nrctachq = tt-dctror.nrctachq  AND
                                                  (crapcor.nrcheque = tt-dctror.nrinichq   OR
                                                   crapcor.nrcheque = tt-dctror.nrfinchq) AND
                                                   crapcor.flgativo = TRUE NO-LOCK NO-ERROR.
                       IF AVAIL crapcor THEN
                       DO:
                           ASSIGN aux_dscritic = "Sustacao provisoria ja realizada anteriormente " +
                                                 "neste cheque em " + STRING(crapcor.dtmvtolt,"99/99/9999").
                           LEAVE Busca.

                       END.


                       FIND LAST crapcor WHERE crapcor.cdcooper  = tt-dctror.cdcooper  AND
                                               crapcor.cdbanchq  = tt-dctror.cdbanchq  AND
                                               crapcor.cdagechq  = tt-dctror.cdagechq  AND
                                               crapcor.nrctachq  = tt-dctror.nrctachq  AND
                                               crapcor.nrcheque <= tt-dctror.nrinichq  AND
                                               crapcor.nrcheque >= tt-dctror.nrinichq  AND
                                               crapcor.flgativo = TRUE NO-LOCK NO-ERROR.
                        IF AVAIL crapcor THEN
                        DO:
                            ASSIGN aux_dscritic = "Sustacao provisoria ja realizada anteriormente " +
                                                  "neste cheque em " + STRING(crapcor.dtmvtolt,"99/99/9999").
                            LEAVE Busca.

                        END.

                        FIND LAST crapcor WHERE crapcor.cdcooper  = tt-dctror.cdcooper  AND
                                                crapcor.cdbanchq  = tt-dctror.cdbanchq  AND
                                                crapcor.cdagechq  = tt-dctror.cdagechq  AND
                                                crapcor.nrctachq  = tt-dctror.nrctachq  AND
                                                crapcor.nrcheque <= tt-dctror.nrfinchq  AND
                                                crapcor.nrcheque >= tt-dctror.nrfinchq  AND
                                                crapcor.flgativo = TRUE NO-LOCK NO-ERROR. 
                         IF AVAIL crapcor THEN
                         DO:
                             ASSIGN aux_dscritic = "Sustacao provisoria ja realizada anteriormente " +
                                                   "neste cheque em " + STRING(crapcor.dtmvtolt,"99/99/9999").
                             LEAVE Busca.

                         END.
                        
                        FIND LAST crapcor WHERE crapcor.cdcooper  = tt-dctror.cdcooper  AND
                                                crapcor.cdbanchq  = tt-dctror.cdbanchq  AND
                                                crapcor.cdagechq  = tt-dctror.cdagechq  AND
                                                crapcor.nrctachq  = tt-dctror.nrctachq  AND
                                                crapcor.nrcheque >= tt-dctror.nrinichq  AND
                                                crapcor.nrcheque <= tt-dctror.nrfinchq  AND
                                                crapcor.flgativo  = FALSE               AND
                                                crapcor.dtvalcor <> ?                   AND
                                                par_flprovis      = TRUE NO-LOCK NO-ERROR.
                        IF AVAIL crapcor THEN
                        DO:
                            ASSIGN aux_dscritic = "Sustacao provisoria ja realizada anteriormente " +
                                                  "neste cheque em " + STRING(crapcor.dtmvtolt,"99/99/9999").
                            LEAVE Busca.

                        END.

                        FIND LAST crapcor WHERE crapcor.cdcooper = tt-dctror.cdcooper  AND
                                                crapcor.cdbanchq = tt-dctror.cdbanchq  AND
                                                crapcor.cdagechq = tt-dctror.cdagechq  AND
                                                crapcor.nrctachq = tt-dctror.nrctachq  AND
                                               (crapcor.nrcheque = tt-dctror.nrinichq  OR
                                                crapcor.nrcheque = tt-dctror.nrfinchq) AND
                                                crapcor.flgativo = FALSE               AND
                                                crapcor.dtvalcor <> ?                  AND
                                                par_flprovis     = TRUE NO-LOCK NO-ERROR.           
                        IF AVAIL crapcor THEN
                        DO:
                            ASSIGN aux_dscritic = "Sustacao provisoria ja realizada anteriormente " +
                                                  "neste cheque em " + STRING(crapcor.dtmvtolt,"99/99/9999").
                            LEAVE Busca.

                        END.

                        FIND LAST crapcor WHERE crapcor.cdcooper  = tt-dctror.cdcooper  AND
                                                crapcor.cdbanchq  = tt-dctror.cdbanchq  AND
                                                crapcor.cdagechq  = tt-dctror.cdagechq  AND
                                                crapcor.nrctachq  = tt-dctror.nrctachq  AND
                                                crapcor.nrcheque <= tt-dctror.nrinichq  AND
                                                crapcor.nrcheque >= tt-dctror.nrinichq  AND
                                                crapcor.flgativo  = FALSE               AND
                                                crapcor.dtvalcor <> ?                   AND
                                                par_flprovis      = TRUE NO-LOCK NO-ERROR.
                        IF AVAIL crapcor THEN
                        DO:
                            ASSIGN aux_dscritic = "Sustacao provisoria ja realizada anteriormente " +
                                                  "neste cheque em " + STRING(crapcor.dtmvtolt,"99/99/9999").
                            LEAVE Busca.

                        END.

                        FIND LAST crapcor WHERE crapcor.cdcooper  = tt-dctror.cdcooper  AND
                                                crapcor.cdbanchq  = tt-dctror.cdbanchq  AND
                                                crapcor.cdagechq  = tt-dctror.cdagechq  AND
                                                crapcor.nrctachq  = tt-dctror.nrctachq  AND
                                                crapcor.nrcheque <= tt-dctror.nrfinchq  AND
                                                crapcor.nrcheque >= tt-dctror.nrfinchq  AND
                                                crapcor.flgativo  = FALSE               AND
                                                crapcor.dtvalcor <> ?                   AND
                                                par_flprovis      = TRUE NO-LOCK NO-ERROR.
                        IF AVAIL crapcor THEN
                        DO:
                            ASSIGN aux_dscritic = "Sustacao provisoria ja realizada anteriormente " +
                                                  "neste cheque em " + STRING(crapcor.dtmvtolt,"99/99/9999").
                            LEAVE Busca.

                        END.
                    END.
            END.
            
        LEAVE Busca.
    END.

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/* ************************************************************************* */
/**                     Impressao de Inclusao e Exclusao                    **/
/* ************************************************************************* */
PROCEDURE imprimir-dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
                                                                    
    DEF  INPUT PARAM TABLE FOR tt-contra.       
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                             
                                                                    
    DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                       NO-UNDO.
    DEF VAR aux_datahora AS CHAR FORMAT "x(20)"                        NO-UNDO.
    DEF VAR aux_nagencia AS CHAR                                       NO-UNDO.
    DEF VAR aux_numbanco AS CHAR FORMAT "x(3)"                         NO-UNDO.
    DEF VAR aux_numconta AS CHAR FORMAT "x(10)"                        NO-UNDO.
    DEF VAR aux_nrcheque AS CHAR FORMAT "x(10)"                        NO-UNDO.
    DEF VAR aux_nrchefim AS CHAR FORMAT "x(10)"                        NO-UNDO.
    DEF VAR aux_dcmotivo AS CHAR FORMAT "x(40)"                        NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR FORMAT "x(40)"                        NO-UNDO.
    DEF VAR aux_nmcidade AS CHAR FORMAT "x(150)"                       NO-UNDO.
    DEF VAR aux_descabec AS CHAR FORMAT "x(80)"                        NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR FORMAT "x(18)"                        NO-UNDO.
    DEF VAR aux_flprovis AS CHAR FORMAT "x(03)"                        NO-UNDO.

    DEF VAR rel_mmmvtolt AS CHAR FORMAT "x(17)"  EXTENT 12
                            INIT["de  Janeiro  de","de Fevereiro de",
                                 "de   Marco   de","de   Abril   de",
                                 "de   Maio    de","de   Junho   de",
                                 "de   Julho   de","de   Agosto  de",
                                 "de  Setembro de","de  Outubro  de",
                                 "de  Novembro de","de  Dezembro de"]
                                                                       NO-UNDO.

    FORM HEADER
                aux_descabec        AT 1
        aux_datahora    AT 100
        "PG.:" AT 125
        PAGE-NUMBER(str_1) AT  130 FORMAT "zz9" SKIP(2)
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_imprime_cab.

    FORM  
                aux_nmcidade SKIP(2)
        "A" SKIP
        crapcop.nmextcop
        " - "
        crapcop.nmrescop
        SKIP(4)
        "Solicito o cancelamento da Sustacao/Contraordem ao pagamento "
        "dos seguintes cheques, sob minha exclusiva responsabilidade:"
        SKIP(3)
        "Banco"          AT 13
        "Agencia"        AT 20
        "Conta"          AT 37
        "Cheque Inicial" AT 54
        "Cheque Final"   AT 72
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_imprime_cartao.

    FORM SKIP
        aux_numbanco        TO 18
        aux_nagencia    TO 31
        aux_numconta    TO 41
        aux_nrcheque    TO 68
        aux_nrchefim    TO 84
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_imprime_dados DOWN .

    FORM  
        aux_nmcidade SKIP(2)
        "A" SKIP
        crapcop.nmextcop
        " - "
        crapcop.nmrescop    SKIP(4)
        "Sob minha exclusiva responsabilidade, solicito nao acatar"
        " o(s) cheque(s) abaixo, de acordo com o(s) motivo(s)"
        " assinalado(s)."  SKIP(3)
        "Banco"          AT 05
        "Agencia"        AT 12
        "Conta"          AT 29
        "Cheque Inicial" AT 43
        "Cheque Final"   AT 61
        "Provisoria"     AT 77
        "Motivo"         AT 92
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_imprime_cartao2.

    FORM SKIP
        aux_numbanco         TO 10
        aux_nagencia         TO 23
        aux_numconta         TO 33
        aux_nrcheque         TO 57
        aux_nrchefim         TO 73
        aux_flprovis         TO 83
        aux_dcmotivo         AT 95 SKIP
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_imprime_dados2 DOWN .

    FORM SKIP(3)
        "Esclareco que assumo integral responsabilidade perante essa "
        "cooperativa, por quaisquer ocorrencias que advierem, eventualmente, "
        "do fiel cumprimento da presente, bem como pelas "
        "informacoes acima prestadas."
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_imprime_termo.

    FORM SKIP(3)
        "Esclareco que assumo integral responsabilidade perante essa"
        " cooperativa, por quaisquer ocorrencias que advierem, eventualmente,"
        SKIP
        "do fiel cumprimento da presente, bem como pelas informacoes acima"
        " prestadas. Estou ciente de que as informacoes relativas aos"
        SKIP
        "cheques com oposicao ao pagamento ou cancelados, serao encaminhados"
        " as entidades que mantem banco de dados para registro de"
        SKIP
        "cheques com Sustacao, Contraordem e Cancelamento."
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_imprime_termo2.

    FORM SKIP(5)
        "_________________________________________          "
        "            _________________________________________" SKIP

        crapass.nmprimtl
        aux_nmoperad AT 65 SKIP
        "CPF/CNPJ: " aux_nrcpfcgc AT 11
        aux_datahora AT 65 SKIP
        "C/C     : " aux_numconta AT 11
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_imprime_final.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_datahora =  string(TODAY,"99/99/9999") + " "
                           + STRING(TIME,"HH:MM").

    IF  par_cddopcao = "E" THEN
        ASSIGN aux_descabec = crapcop.nmrescop +
                              " - CANCELAMENTO SUSTACAO/CONTRAORDEM" .
    ELSE
    IF  par_cddopcao = "I" THEN
        ASSIGN aux_descabec = crapcop.nmrescop    + " - SUSTACAO/CONTRAORDEM".

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                          par_dsiduser.
    
    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").

    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    Gera: DO WHILE TRUE:

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        ASSIGN aux_nmcidade = crapcop.nmcidade.
               aux_nmcidade = aux_nmcidade + ", " + STRING(DAY(TODAY)) + " "
                                           + rel_mmmvtolt[MONTH(TODAY)]
                                           + " " + STRING(YEAR(TODAY)) + ".".

        VIEW STREAM str_1 FRAME f_imprime_cab.

        IF  par_cddopcao = "E" THEN
            DISPLAY STREAM str_1
                    aux_nmcidade
                    crapcop.nmextcop
                    crapcop.nmrescop
                    WITH FRAME f_imprime_cartao.
        ELSE
            DISPLAY STREAM str_1
                    aux_nmcidade
                    crapcop.nmextcop
                    crapcop.nmrescop
                    WITH FRAME f_imprime_cartao2.

        FOR EACH tt-contra NO-LOCK:

            ASSIGN aux_numbanco = STRING( tt-contra.cdbanchq)
                   aux_nagencia = STRING( tt-contra.cdagechq)
                   aux_numconta = STRING( tt-contra.nrctachq,"zzzz,zzz,z")
                   aux_nrcheque = STRING( tt-contra.nrinichq,"zzz,zzz,z")
                   aux_nrchefim = STRING( tt-contra.nrfinchq,"zzz,zzz,z")
                   aux_dcmotivo = STRING( tt-contra.cdhistor).

            IF   tt-contra.flprovis THEN
                 aux_flprovis = "SIM".
            ELSE
                 aux_flprovis = "NAO".
                 
            
            FIND FIRST craphis WHERE
                       craphis.cdhistor = tt-contra.cdhistor AND
                       craphis.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

            IF  AVAIL craphis THEN
                ASSIGN aux_dcmotivo = aux_dcmotivo + " - " + craphis.dsexthst.

            IF  par_cddopcao = "E" THEN
                DO:
                    DISPLAY STREAM str_1
                        aux_numbanco
                        aux_nagencia
                        aux_numconta
                        aux_nrcheque
                        aux_nrchefim SKIP
                        WITH FRAME f_imprime_dados.
                        DOWN WITH FRAME f_imprime_dados.
                END.
            ELSE
                DO:
                    DISPLAY STREAM str_1
                        aux_numbanco
                        aux_nagencia
                        aux_numconta
                        aux_nrcheque
                        aux_nrchefim
                        aux_flprovis
                        aux_dcmotivo SKIP
                        WITH FRAME f_imprime_dados2.
                        DOWN WITH FRAME f_imprime_dados2.
                END.
        END.

        IF  par_cddopcao = "E" THEN
            DISPLAY STREAM str_1 WITH FRAME f_imprime_termo.
        ELSE
            DISPLAY STREAM str_1 WITH FRAME f_imprime_termo2.

        FIND crapope WHERE crapope.cdcooper = par_cdcooper  AND
                           crapope.cdoperad = par_cdoperad  NO-LOCK NO-ERROR.

        IF  AVAILABLE crapope  THEN
            ASSIGN aux_nmoperad = crapope.cdoperad + " - " + crapope.nmoperad.
        ELSE
            ASSIGN aux_nmoperad = STRING(par_cdoperad,"x(10)") +
                                  " - NAO CADASTRADO".

        FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                 crapass.nrdconta = par_nrdconta
                                 NO-LOCK NO-ERROR.

        IF   crapass.inpessoa = 1 THEN   /* CPF */
             ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                    aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
        ELSE                             /* CNPJ */
             ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                    aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

         
        DISPLAY STREAM str_1
                crapass.nmprimtl
                aux_nmoperad
                aux_nrcpfcgc
                aux_datahora
                aux_numconta
                WITH FRAME f_imprime_final.

        OUTPUT STREAM str_1 CLOSE.

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Gera.
                    END.

                RUN envia-arquivo-web IN h-b1wgen0024 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT aux_nmarqimp,
                     OUTPUT par_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.    

        ASSIGN par_nmarqimp = aux_nmarqimp.

        LEAVE Gera.
    END.

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/* ************************************************************************* */
/**                       Valida Contra-Ordens Inseridas                    **/
/** Entrada: tt com todas as contra-ordens ajustadas                        **/
/** Saida  : tt com todos os cheques validos com/sem critica                **/
/**        : tt com os cheques em custodia/desconto                         **/
/* ************************************************************************* */
PROCEDURE valida-contra:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM aut_flgsenha AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM aut_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM aux_dsdctitg AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_flprovis AS LOGI                              NO-UNDO.
                                                                      
    DEF  INPUT PARAM TABLE FOR tt-contra.                             
    DEF OUTPUT PARAM par_pedsenha AS LOGI                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-cheques.
    DEF OUTPUT PARAM TABLE FOR tt-custdesc.

    EMPTY TEMP-TABLE tt-cheques.
    EMPTY TEMP-TABLE tt-custdesc.

    DEF VAR aux_nrcheque AS INTE                                       NO-UNDO.
    DEF VAR aux_nrcalcul AS INTE                                       NO-UNDO.
    DEF VAR aux_nrchqcdv AS INTE                                       NO-UNDO.
    DEF VAR aux_nrchqsdv AS INTE                                       NO-UNDO.
    DEF VAR aux_flggerou AS LOGI                                       NO-UNDO.
    DEF VAR aux_cdcriti2 AS INTE                                       NO-UNDO.
    DEF VAR aux_dtrefere AS DATE									   NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcriti2 = 0
           par_pedsenha = FALSE.

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    Valida: DO WHILE TRUE:

		/* Buscar o ultimo dia útil baseado na quantidade de dias de Float */
		ASSIGN aux_dtrefere = fn_dia_util_anterior(par_cdcooper, crapdat.dtmvtolt, 1).
		
        /* Verifica se algum cheque necessita de senha */
        IF  aut_cdoperad = "" THEN
            DO:
                Senha: FOR EACH tt-contra NO-LOCK:
        
                    Cheques: DO aux_nrcheque = 
                                TRUNCATE(tt-contra.nrinichq / 10,0)  TO
                                TRUNCATE(tt-contra.nrfinchq / 10,0):

                        ASSIGN aux_dscritic = ""
                               aux_cdcriti2 = 0.
        
                        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                            RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                
                        ASSIGN aux_nrcalcul = aux_nrcheque * 10.
        
                        RUN dig_fun IN h-b1wgen9999
                            ( INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT-OUTPUT aux_nrcalcul,
                             OUTPUT TABLE tt-erro ).

                        EMPTY TEMP-TABLE tt-erro.
        
                        IF  VALID-HANDLE(h-b1wgen9999)  THEN
                            DELETE PROCEDURE h-b1wgen9999.
        
                        ASSIGN aux_nrchqsdv = INT(SUBSTR(STRING(aux_nrcalcul, 
                                                                "9999999"),1,6))
                               aux_nrchqcdv = INT(aux_nrcalcul).
        
                        FIND crapfdc WHERE 
                             crapfdc.cdcooper = par_cdcooper AND
                             crapfdc.cdbanchq = tt-contra.cdbanchq AND
                             crapfdc.cdagechq = tt-contra.cdagechq AND
                             crapfdc.nrctachq = tt-contra.nrctachq AND
                             crapfdc.nrcheque = aux_nrchqsdv
                             USE-INDEX crapfdc1 
                             NO-LOCK NO-ERROR NO-WAIT.
                
                       /* Não retornar nas primeiras validações  */
                       IF  NOT AVAIL crapfdc                OR 
                           crapfdc.nrdconta <> par_nrdconta OR
                           crapfdc.dtemschq = ?             OR
                           crapfdc.dtretchq = ?             OR
                          (par_cddopcao = "E"              AND
                           crapfdc.nrpedido = 779          AND
                           crapcop.cdcooper = 1)            THEN
                            NEXT Cheques.
                        ELSE
                        IF  par_cddopcao = "E" AND 
                            CAN-DO("6,8",STRING(crapfdc.incheque)) THEN
                            DO:
                                ASSIGN par_pedsenha = TRUE.
                                LEAVE Valida.
                            END.
                        ELSE
                        IF  par_cddopcao = "I" AND
                            CAN-DO("5",STRING(crapfdc.incheque)) THEN
                            DO:
                                ASSIGN par_pedsenha = TRUE.
                                LEAVE Valida.
                            END.

                    END.
                END.
            END.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta
                           NO-LOCK NO-ERROR.

        FOR EACH tt-contra NO-LOCK:

            DO aux_nrcheque = TRUNCATE(tt-contra.nrinichq / 10,0)  TO
                              TRUNCATE(tt-contra.nrfinchq / 10,0):

                ASSIGN aux_dscritic = ""
                       aux_cdcriti2 = 0.

                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
        
                ASSIGN aux_nrcalcul = aux_nrcheque * 10.

                RUN dig_fun IN h-b1wgen9999
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT-OUTPUT aux_nrcalcul,
                     OUTPUT TABLE tt-erro ).

                EMPTY TEMP-TABLE tt-erro.

                IF  VALID-HANDLE(h-b1wgen9999)  THEN
                    DELETE PROCEDURE h-b1wgen9999.

                ASSIGN aux_nrchqsdv = INT(SUBSTR(STRING(aux_nrcalcul, 
                                                        "9999999"),1,6))
                       aux_nrchqcdv = INT(aux_nrcalcul).

                FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper       AND
                                   crapfdc.cdbanchq = tt-contra.cdbanchq AND
                                   crapfdc.cdagechq = tt-contra.cdagechq AND
                                   crapfdc.nrctachq = tt-contra.nrctachq AND
                                   crapfdc.nrcheque = aux_nrchqsdv
                                   USE-INDEX crapfdc1 NO-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crapass  THEN
                    DO:
                        ASSIGN aux_cdcriti2 = 9.
                    END.
                ELSE IF  NOT AVAIL crapfdc THEN
                    DO:
                        ASSIGN aux_cdcriti2 = 108.
                    END.
                ELSE
                IF  crapfdc.nrdconta <> par_nrdconta THEN
                    DO:
                        ASSIGN aux_cdcriti2 = 108.
                    END.
                ELSE
                IF  crapfdc.dtemschq = ?  THEN
                    DO:
                        ASSIGN aux_cdcriti2 = 108.
                    END.
                ELSE
                IF  crapfdc.dtretchq = ?  THEN
                    DO:
                        ASSIGN aux_cdcriti2 = 109.
                    END.
                ELSE
                IF  par_cddopcao = "E"     AND
                    crapfdc.nrpedido = 779 AND
                    crapcop.cdcooper = 1   THEN
                    DO:
                        ASSIGN aux_cdcriti2 = 323.
                    END.
                ELSE /* retorno do pedesenha.p para E */
                IF  par_cddopcao = "E" AND 
                    CAN-DO("6,8",STRING(crapfdc.incheque)) AND
                    aut_cdoperad = "888" THEN 
                    DO:
                        ASSIGN aux_cdcriti2 = 323.
                    END.
                ELSE
                IF  par_cddopcao = "E" AND 
                    CAN-DO("6,8",STRING(crapfdc.incheque)) AND
                    NOT aut_flgsenha THEN
                    DO:
                        ASSIGN aux_cdcriti2 = 323.
                    END.
                ELSE /* retorno do pedesenha.p para I */
                IF  par_cddopcao = "I" AND 
                    CAN-DO("5",STRING(crapfdc.incheque)) AND
                    aut_cdoperad = "888" THEN 
                    DO:
                        ASSIGN aux_cdcriti2 = 97.
                    END.
                ELSE
                IF  par_cddopcao = "I" AND 
                    CAN-DO("5",STRING(crapfdc.incheque)) AND
                    NOT aut_flgsenha THEN
                    DO:
                        ASSIGN aux_cdcriti2 = 97.
                    END.
                ELSE
                IF  par_cddopcao = "E" AND 
                    CAN-DO("0,5",STRING(crapfdc.incheque)) THEN
                    DO:
                        ASSIGN aux_cdcriti2 = 111.
                    END.
                ELSE
                IF  par_cddopcao = "I"              AND 
                    aux_dtrefere > crapfdc.dtliqchq THEN 
                    DO:
                        ASSIGN aux_dscritic = "Inclusao permitida apenas para cheques compensados a partir de " + String(aux_dtrefere,"99/99/9999") + " (D -1).".
                    END.
				ELSE
                IF  crapfdc.incheque = 8  THEN
                    DO:
                        ASSIGN aux_cdcriti2 = 320.
                    END.
                ELSE
                IF  par_cddopcao = "I" THEN 
                    DO:
                        IF   CAN-DO("1,2",STRING(crapfdc.incheque))  THEN
                             ASSIGN aux_cdcriti2 = 107.
                             
                        FIND LAST crapcor WHERE
                                  crapcor.cdcooper = par_cdcooper      AND
                                  crapcor.cdbanchq = crapfdc.cdbanchq  AND
                                  crapcor.cdagechq = crapfdc.cdagechq  AND
                                  crapcor.nrctachq = crapfdc.nrctachq  AND
                                  crapcor.nrcheque = aux_nrchqcdv      
                                  NO-LOCK NO-ERROR.

                        IF   AVAILABLE crapcor THEN
                             DO:
                                 IF   tt-contra.flprovis = TRUE THEN
                                      ASSIGN aux_dscritic = "Contra-ordem provisoria realizada em " + STRING(crapcor.dtemscor,"99/99/9999").
                                 ELSE
                                 IF   crapcor.dtvalcor = ? THEN
                                      aux_cdcriti2 = 107.
                                 ELSE
                                 IF   crapcor.dtvalcor >= crapdat.dtmvtolt AND
                                      crapcor.flgativo = TRUE THEN
                                      aux_cdcriti2 = 107.
                             END.
     
                        IF  crapass.nrdctitg = aux_dsdctitg  AND            
                            tt-contra.cdbanchq     = 1             THEN 
                            /* Exclusivo BB */                              
                            DO:  
                                FIND FIRST crapcch WHERE                    
                                      crapcch.cdcooper = par_cdcooper     AND 
                                      crapcch.nrdconta = par_nrdconta     AND 
                                      crapcch.nrdctitg = crapfdc.nrdctitg AND 
                                      crapcch.nrchqini = aux_nrchqcdv     AND 
                                      crapcch.nrchqfim = aux_nrchqcdv     AND 
                                      crapcch.cdhistor <> 0               AND 
                                     (crapcch.flgctitg = 1                OR
                                      crapcch.flgctitg = 4)               AND 
                                      crapcch.cdbanchq = 1  NO-LOCK NO-ERROR. 
                                                               
                                IF  AVAILABLE crapcch  THEN  
                                    ASSIGN aux_cdcriti2 = 219.
                            END.
                        ELSE
                            DO:
                                /* cheques que apresentam custodia/desconto  */
                                RUN trata-custodia-desconto
                                    ( INPUT par_cdcooper,
                                      INPUT tt-contra.cdbanchq,
                                      INPUT tt-contra.cdagechq,
                                      INPUT tt-contra.nrctachq,
                                      INPUT aux_nrchqsdv,
                                      INPUT crapfdc.cdcmpchq,
                                      INPUT crapfdc.nrdconta,
                                      INPUT aux_nrchqcdv,
                                      INPUT tt-contra.nrinichq,
                                      INPUT tt-contra.nrfinchq,
                                      INPUT tt-contra.cdhistor,
                                      INPUT par_flprovis,
                                     OUTPUT aux_cdcritic,
                                     OUTPUT aux_flggerou,
                                     INPUT-OUTPUT TABLE tt-custdesc ).

                                IF  aux_cdcritic <> 0 THEN
                                    aux_cdcriti2 = aux_cdcritic.
                                
                                IF  aux_flggerou THEN
                                    NEXT.
                            END.
                    END.
                ELSE
                IF  par_cddopcao = "E" THEN 
                    DO:
                        FIND LAST crapcor WHERE 
                                  crapcor.cdcooper = par_cdcooper      AND
                                  crapcor.cdbanchq = crapfdc.cdbanchq  AND
                                  crapcor.cdagechq = crapfdc.cdagechq  AND
                                  crapcor.nrctachq = crapfdc.nrctachq  AND
                                  crapcor.nrcheque = aux_nrchqcdv      AND
                                  crapcor.flgativo = TRUE
                                  USE-INDEX crapcor1 NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE crapcor THEN
                             ASSIGN aux_cdcriti2 = 111.
                        ELSE
                        IF   crapcor.dtvalcor = ?    AND
                             crapcor.dtmvtolt >= 04/01/2012 AND
                            (crapcor.cdhistor = 818  OR
                             crapcor.cdhistor = 817  OR
                             crapcor.cdhistor = 825  OR
                             crapcor.cdhistor = 835) THEN
                             ASSIGN aux_dscritic = 
                                           "Contra-ordem com alinea 20 ou 28".
                        ELSE
                        IF  crapass.nrdctitg    = aux_dsdctitg  AND
                            tt-contra.cdbanchq  = 1             THEN 
                            /* Exclusivo BB */                              
                            DO:                                             
                               FIND FIRST crapcch WHERE                    
                                     crapcch.cdcooper = par_cdcooper     AND 
                                     crapcch.nrdconta = par_nrdconta     AND 
                                     crapcch.nrdctitg = crapfdc.nrdctitg AND 
                                     crapcch.nrchqini = aux_nrcalcul     AND 
                                     crapcch.nrchqfim = aux_nrcalcul     AND 
                                     crapcch.cdhistor <> 0               AND 
                                     crapcch.flgctitg = 1                AND
                                     crapcch.cdbanchq = 1  NO-LOCK NO-ERROR. 

                               IF  AVAILABLE crapcch  THEN  
                                   ASSIGN aux_cdcriti2 = 219.
                            END.
                    END.

                IF  aux_cdcriti2 <> 0 THEN
                    DO:
                        FIND crapcri WHERE 
                             crapcri.cdcritic = aux_cdcriti2 NO-LOCK NO-ERROR.
                
                        IF  AVAIL crapcri THEN
                            ASSIGN aux_dscritic = crapcri.dscritic.
                    END.


                /* cheques validos ou com critica */
                CREATE tt-cheques.
                ASSIGN tt-cheques.cdbanchq = tt-contra.cdbanchq
                       tt-cheques.cdagechq = tt-contra.cdagechq
                       tt-cheques.nrctachq = tt-contra.nrctachq
                       tt-cheques.nrinichq = tt-contra.nrinichq
                       tt-cheques.nrfinchq = tt-contra.nrfinchq
                       tt-cheques.cdhistor = tt-contra.cdhistor
                       tt-cheques.nrcheque = aux_nrchqcdv
                       tt-cheques.nrdconta = par_nrdconta
                       tt-cheques.dscritic = aux_dscritic
                       tt-cheques.flprovis = tt-contra.flprovis
                       tt-cheques.flgativo = tt-contra.flgativo
                       aux_dscritic        = "".
                       
            END. /* Fim do DO aux_nrcheque */
        END.
        LEAVE Valida.
    END.



    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ..........................*/

PROCEDURE localiza-generi:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_lsconta2 AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    RUN fontes/ver_ctace.p(INPUT par_cdcooper,
                           INPUT 2,
                           OUTPUT par_lsconta2).

     RETURN "OK".

END PROCEDURE.



PROCEDURE trata-custodia-desconto:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrcheque AS INTE                              NO-UNDO.

    DEF  INPUT PARAM par_cdcmpchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrchqcdv AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrinichq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrfinchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flprovis AS LOGICAL                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_flggerou AS LOGI INIT FALSE                   NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-custdesc.

    DEF VAR aux_cdpesqui AS CHAR FORMAT "x(50)"                        NO-UNDO.
    DEF VAR aux_nragechq AS INTE                                       NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651.
            RETURN "OK".
        END.

    IF  par_nrdconta <> par_nrctachq   THEN
        DO:
         
            /*verifica se é uma conta cheque foi migrada*/
            FIND FIRST craptco 
            WHERE craptco.cdcooper = par_cdcooper 
              AND craptco.nrctaant = par_nrctachq 
              AND (craptco.cdcopant = 4  OR
                   craptco.cdcopant = 15 OR
                   craptco.cdcopant = 17 ) 
              AND craptco.flgativo = TRUE
              NO-LOCK NO-ERROR.

            /* se não é conta migrada*/
            IF NOT AVAIL(craptco) THEN 
            DO:                      
                FIND crapcst WHERE crapcst.cdcooper = par_cdcooper AND
                                   crapcst.cdcmpchq = par_cdcmpchq AND
                                   crapcst.cdbanchq = 1            AND
                                   crapcst.cdagechq = 95           AND
                                   crapcst.nrctachq = par_nrctachq AND
                                   crapcst.nrcheque = par_nrcheque AND
                                   crapcst.dtdevolu = ?      NO-LOCK NO-ERROR.
                                   
                IF  NOT AVAILABLE crapcst THEN
                    FIND crapcst WHERE crapcst.cdcooper = par_cdcooper AND
                                       crapcst.cdcmpchq = par_cdcmpchq AND
                                       crapcst.cdbanchq = 1            AND
                                       crapcst.cdagechq = 3420         AND
                                       crapcst.nrctachq = par_nrctachq AND
                                       crapcst.nrcheque = par_nrcheque AND
                                       crapcst.dtdevolu = ?           
                                       NO-LOCK NO-ERROR.

            END.
            ELSE
            DO:
               
                /* se é conta integrada buscar crapcst
                   usando banco/agencia informado do cheque*/
                   
                FIND crapcst WHERE crapcst.cdcooper = par_cdcooper AND
                                   crapcst.cdcmpchq = par_cdcmpchq AND
                                   crapcst.cdbanchq = par_cdbanchq AND
                                   crapcst.cdagechq = par_cdagechq AND
                                   crapcst.nrctachq = par_nrctachq AND
                                   crapcst.nrcheque = par_nrcheque AND
                                   crapcst.dtdevolu = ?     NO-LOCK NO-ERROR.
            END.

            IF  AVAILABLE crapcst   THEN
                DO:

                    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                       crapass.nrdconta = crapcst.nrdconta
                                       NO-LOCK NO-ERROR.
                    
                    /*verifica se é uma conta da crapcst foi migrada*/
                    FIND FIRST craptco
                         WHERE craptco.cdcooper = par_cdcooper
                           AND craptco.nrdconta = crapcst.nrdconta
                           AND (craptco.cdcopant = 4  OR
                                craptco.cdcopant = 15 OR
                                craptco.cdcopant = 17 )
                           AND craptco.flgativo = TRUE
                           NO-LOCK NO-ERROR.
                    
                    /*se for uma conta migrada deve buscar o operador
                     na cooperativa antiga*/
                    IF NOT AVAIL(craptco) THEN
                      FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                                         crapope.cdoperad = crapcst.cdoperad
                                         NO-LOCK NO-ERROR.
                    ELSE
                      FIND crapope WHERE crapope.cdcooper = craptco.cdcopant AND
                                         crapope.cdoperad = crapcst.cdoperad
                                         NO-LOCK NO-ERROR.
                  
                    ASSIGN aux_cdpesqui = 
                                  STRING(crapcst.dtmvtolt,"99/99/9999") + "-" +
                                  STRING(crapcst.cdagenci,"999") + "-" +
                                  STRING(crapcst.cdbccxlt,"999") + "-" +
                                  STRING(crapcst.nrdolote,"999999") + "-" +
                                  ENTRY(1,crapope.nmoperad," ").
                  
                    CREATE tt-custdesc.
                    ASSIGN tt-custdesc.nrdconta = crapass.nrdconta
                           tt-custdesc.nmprimtl = crapass.nmprimtl
                           tt-custdesc.dtliber1 = crapcst.dtlibera
                           tt-custdesc.cdpesqu1 = aux_cdpesqui
                           tt-custdesc.cdbanchq = par_cdbanchq
                           tt-custdesc.cdagechq = par_cdagechq
                           tt-custdesc.nrctachq = par_nrctachq
                           tt-custdesc.nrcheque = par_nrchqcdv
                           tt-custdesc.nrinichq = par_nrinichq
                           tt-custdesc.nrfinchq = par_nrfinchq
                           tt-custdesc.cdhistor = par_cdhistor
                           tt-custdesc.flprovis = par_flprovis
                           tt-custdesc.flgcusto = TRUE
                           par_flggerou = TRUE.
                END.
        END.
    ELSE
        DO:
            IF  par_cdbanchq = 756  THEN
                aux_nragechq = crapcop.cdagebcb.
            ELSE
            IF  par_cdbanchq = 85  THEN
                aux_nragechq = crapcop.cdagectl.
            
            FIND crapcst WHERE crapcst.cdcooper = par_cdcooper       AND
                               crapcst.cdcmpchq = par_cdcmpchq       AND
                               crapcst.cdbanchq = par_cdbanchq       AND
                               crapcst.cdagechq = aux_nragechq       AND
                               crapcst.nrctachq = par_nrctachq       AND
                               crapcst.nrcheque = par_nrcheque       AND
                               crapcst.dtdevolu = ?                  
                               NO-LOCK NO-ERROR.
            
            IF  AVAILABLE crapcst   THEN
                DO:
                    FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                       crapass.nrdconta = crapcst.nrdconta 
                                       NO-LOCK NO-ERROR.
    
                    ASSIGN aux_cdpesqui = 
                                  STRING(crapcst.dtmvtolt,"99/99/9999") + "-" +
                                  STRING(crapcst.cdagenci,"999") + "-" +
                                  STRING(crapcst.cdbccxlt,"999") + "-" +
                                  STRING(crapcst.nrdolote,"999999") + "-" +
                                  crapcst.cdoperad.

                    CREATE tt-custdesc.
                    ASSIGN tt-custdesc.nrdconta = crapass.nrdconta
                           tt-custdesc.nmprimtl = crapass.nmprimtl
                           tt-custdesc.dtliber1 = crapcst.dtlibera
                           tt-custdesc.cdpesqu1 = aux_cdpesqui
                           tt-custdesc.cdbanchq = par_cdbanchq
                           tt-custdesc.cdagechq = par_cdagechq
                           tt-custdesc.nrctachq = par_nrctachq
                           tt-custdesc.nrcheque = par_nrchqcdv
                           tt-custdesc.cdhistor = par_cdhistor
                           tt-custdesc.nrinichq = par_nrinichq
                           tt-custdesc.nrfinchq = par_nrfinchq
                           tt-custdesc.flprovis = par_flprovis
                           tt-custdesc.flgcusto = TRUE
                           par_flggerou = TRUE.
                END.
        END.

    /* Desconto */
    IF  par_nrdconta <> par_nrctachq  THEN
        DO:
            /*verifica se é uma conta cheque
              foi migrada*/
             FIND FIRST craptco 
            WHERE craptco.cdcooper = par_cdcooper 
              AND craptco.nrctaant = par_nrctachq 
              AND (craptco.cdcopant = 4  OR 
                   craptco.cdcopant = 15 OR
                   craptco.cdcopant = 17 ) 
              AND craptco.flgativo = TRUE
              NO-LOCK NO-ERROR.

            /* se não é conta migrada*/
            IF NOT AVAIL(craptco) THEN 
            DO:   
        
               FIND crapcdb WHERE crapcdb.cdcooper = par_cdcooper AND
                                   crapcdb.cdcmpchq = par_cdcmpchq AND
                                   crapcdb.cdbanchq = 1            AND
                                   crapcdb.cdagechq = 95           AND
                                   crapcdb.nrctachq = par_nrctachq AND
                                   crapcdb.nrcheque = par_nrcheque AND
                                   crapcdb.dtdevolu = ?      NO-LOCK NO-ERROR.
                                
                IF  NOT AVAILABLE crapcdb  THEN
                    FIND crapcdb WHERE crapcdb.cdcooper = par_cdcooper AND
                                       crapcdb.cdcmpchq = par_cdcmpchq AND
                                       crapcdb.cdbanchq = 1            AND
                                       crapcdb.cdagechq = 3420         AND
                                       crapcdb.nrctachq = par_nrctachq AND
                                       crapcdb.nrcheque = par_nrcheque AND
                                       crapcdb.dtdevolu = ?           
                                       NO-LOCK NO-ERROR.
           
            END.
            ELSE
            DO:
                /* se é conta integrada buscar crapcst
                   usando banco/agencia informado do cheque*/
                FIND crapcdb WHERE crapcdb.cdcooper = par_cdcooper AND
                                   crapcdb.cdcmpchq = par_cdcmpchq AND
                                   crapcdb.cdbanchq = par_cdbanchq AND
                                   crapcdb.cdagechq = par_cdagechq AND
                                   crapcdb.nrctachq = par_nrctachq AND
                                   crapcdb.nrcheque = par_nrcheque AND
                                   crapcdb.dtdevolu = ?           
                                   NO-LOCK NO-ERROR.
            END.

            IF  AVAILABLE crapcdb  THEN
                DO:
                    FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                       crapass.nrdconta = crapcdb.nrdconta
                                       NO-LOCK NO-ERROR.
                      
                    /*verifica se é uma conta da crapcdb foi migrada*/
                    FIND FIRST craptco
                   WHERE craptco.cdcooper = par_cdcooper
                     AND craptco.nrdconta = crapcdb.nrdconta
                     AND (craptco.cdcopant = 4  OR
                          craptco.cdcopant = 15 OR
                          craptco.cdcopant = 17 )
                     AND craptco.flgativo = TRUE
                     NO-LOCK NO-ERROR.
                   
                    /*se for uma conta migrada deve buscar o operador
                     na cooperativa antiga*/
                    IF NOT AVAIL(craptco) THEN
                      FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                                         crapope.cdoperad = crapcdb.cdoperad
                                         NO-LOCK NO-ERROR.
                    ELSE
                      FIND crapope WHERE crapope.cdcooper = craptco.cdcopant AND
                                         crapope.cdoperad = crapcdb.cdoperad
                                         NO-LOCK NO-ERROR.                
                      
                    ASSIGN aux_cdpesqui = 
                                  STRING(crapcdb.dtmvtolt,"99/99/9999") + "-" +
                                  STRING(crapcdb.cdagenci,"999") + "-" +
                                  STRING(crapcdb.cdbccxlt,"999") + "-" +
                                  STRING(crapcdb.nrdolote,"999999") + "-" +
                                  ENTRY(1,crapope.nmoperad," ").

                    FIND FIRST tt-custdesc WHERE 
                               tt-custdesc.nrdconta = crapass.nrdconta AND
                               tt-custdesc.cdbanchq = par_cdbanchq     AND
                               tt-custdesc.cdagechq = par_cdagechq     AND
                               tt-custdesc.nrctachq = par_nrctachq     AND
                               tt-custdesc.nrcheque = par_nrchqcdv
                               NO-LOCK NO-ERROR.

                    IF  NOT AVAIL tt-custdesc THEN
                        DO:
                            CREATE tt-custdesc.
                            ASSIGN tt-custdesc.nrdconta = crapass.nrdconta
                                   tt-custdesc.nmprimtl = crapass.nmprimtl
                                   tt-custdesc.cdbanchq = par_cdbanchq
                                   tt-custdesc.cdagechq = par_cdagechq
                                   tt-custdesc.nrctachq = par_nrctachq
                                   tt-custdesc.nrcheque = par_nrchqcdv
                                   tt-custdesc.cdhistor = par_cdhistor
                                   tt-custdesc.nrinichq = par_nrinichq
                                   tt-custdesc.nrfinchq = par_nrfinchq.
                        END.
                    ASSIGN tt-custdesc.dtliber2 = crapcdb.dtlibera
                           tt-custdesc.cdpesqu2 = aux_cdpesqui
                           tt-custdesc.flprovis = par_flprovis
                           tt-custdesc.flgdesco = TRUE
                           par_flggerou = TRUE.
                END.
        END.
    ELSE
        DO:
            IF  par_cdbanchq = 756  THEN
                aux_nragechq = crapcop.cdagebcb.
            ELSE
            IF  par_cdbanchq = 85  THEN
                aux_nragechq = crapcop.cdagectl.

            FIND crapcdb WHERE crapcdb.cdcooper = par_cdcooper     AND
                               crapcdb.cdcmpchq = par_cdcmpchq     AND
                               crapcdb.cdbanchq = par_cdbanchq     AND
                               crapcdb.cdagechq = aux_nragechq     AND
                               crapcdb.nrctachq = par_nrctachq     AND
                               crapcdb.nrcheque = par_nrcheque     AND
                               crapcdb.dtdevolu = ?                
                               NO-LOCK NO-ERROR.
                                
            IF  AVAILABLE crapcdb  THEN
                DO:
                    FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                       crapass.nrdconta = crapcdb.nrdconta 
                                       NO-LOCK NO-ERROR.
    
                    ASSIGN aux_cdpesqui = 
                                  STRING(crapcdb.dtmvtolt,"99/99/9999") + "-" +
                                  STRING(crapcdb.cdagenci,"999") + "-" +
                                  STRING(crapcdb.cdbccxlt,"999") + "-" +
                                  STRING(crapcdb.nrdolote,"999999") + "-" +
                                  crapcdb.cdoperad.

                    CREATE tt-custdesc.
                    ASSIGN tt-custdesc.nrdconta = crapass.nrdconta
                           tt-custdesc.nmprimtl = crapass.nmprimtl
                           tt-custdesc.dtliber2 = crapcdb.dtlibera
                           tt-custdesc.cdpesqu2 = aux_cdpesqui
                           tt-custdesc.cdbanchq = par_cdbanchq
                           tt-custdesc.cdagechq = par_cdagechq
                           tt-custdesc.nrctachq = par_nrctachq
                           tt-custdesc.nrcheque = par_nrchqcdv
                           tt-custdesc.cdhistor = par_cdhistor
                           tt-custdesc.nrinichq = par_nrinichq
                           tt-custdesc.nrfinchq = par_nrfinchq
                           tt-custdesc.flprovis = par_flprovis
                           tt-custdesc.flgdesco = TRUE
                           par_flggerou = TRUE.
                END.
        END.  

    RETURN "OK".

END PROCEDURE.


PROCEDURE gera-log:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-contra. 
    DEF OUTPUT PARAM par_msgretor AS CHAR                              NO-UNDO.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

    FOR EACH tt-contra NO-LOCK:
        ASSIGN aux_dstransa = "NAO CONFIRMADA - Exclusao de Contra Ordem:" +
                              " Conta: "         + STRING(tt-contra.nrdconta) +
                              " Conta Cheque: "  + STRING(tt-contra.nrctachq) +
                              " Cheque inicio: " + STRING(tt-contra.nrinichq) +
                              " Cheque fim: "    + STRING(tt-contra.nrfinchq).

        RUN proc_gerar_log ( INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT FALSE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT tt-contra.nrdconta,
                            OUTPUT aux_nrdrowid ).
    END.

    FIND FIRST crapcri WHERE crapcri.cdcritic = 79 NO-LOCK NO-ERROR.

    IF  AVAIL crapcri THEN
        ASSIGN par_msgretor = crapcri.dscritic.

    RETURN "OK".

END PROCEDURE.

/*  LOG DE CONTRA-ORDEM  */

PROCEDURE log-contra-cheque:

    DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrcheque AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdbanchq AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdagechq AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_flagprov AS LOGICAL                           NO-UNDO.

    DEF VAR aux_nmdamsge AS CHAR                                      NO-UNDO.
       
    IF   par_cddopcao = "A" AND par_flagprov THEN 
         aux_nmdamsge = 
                 "ALTERACAO DE CONTRA-ORDEM DE PROVISORIA PARA PERMANENTE".
    ELSE
    IF   par_cddopcao = "A" THEN
         aux_nmdamsge = "ALTERACAO DE CONTRA-ORDEM".
    ELSE
    IF   par_cddopcao = "I" AND par_flagprov THEN 
         aux_nmdamsge = "INCLUSAO DE CONTRA-ORDEM PROVISORIA".
    ELSE
    IF   par_cddopcao = "I" THEN 
         aux_nmdamsge = "INCLUSAO DE CONTRA-ORDEM PERMANENTE".
    ELSE 
    IF   par_cddopcao = "E" THEN
         aux_nmdamsge = "EXCLUSAO DE CONTRA-ORDEM".
                    
    UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " - " +
                      STRING(TIME,"HH:MM:SS") + " - " + STRING(aux_nmdamsge) +
                      "' --> '" + " Operador: " + par_cdoperad + 
                      " Hst: " + STRING(par_cdhistor,"zzz9") + 
                      " Banco: " + STRING(par_cdbanchq,"z,zz9") + 
                      " Agencia: " + STRING(par_cdagechq,"z,zz9") +
                      " Nro.Conta: " + STRING(par_nrdconta,"zzzz,zzz,9") +
                      " Nro.Cheque: " + STRING(par_nrcheque,"zz,zz9") +
                      " >> /usr/coop/" + crapcop.dsdircop + "/log/dctror.log").  
                          
END PROCEDURE.

/*...........................................................................*/