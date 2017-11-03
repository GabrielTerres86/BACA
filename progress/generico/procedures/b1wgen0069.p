/*.............................................................................

    Programa: b1wgen0069.p
    Autor   : Jose Luis (DB1)
    Data    : Abril/2010                   Ultima atualizacao: 22/09/2017

    Objetivo  : Tranformacao BO tela CONTAS - FINANCEIRO - FATURAMENTO

                                                                         
    Alteracoes: 22/08/2011 - Criado validacao na procedure Valida_Dados
                             para nao permitir informar valor zerado no 
                             faturamento nas opcoes "A/I" (Adriano). 
    
                04/10/2013 - Criacao de registro na crapdoc quando salvar ou 
                             alterar registros na procudeure Grava_Dados(Jean Michel). 
                             
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)  
                
                07/04/2014 - Alteracao de gravacao de registro na crapdoc, tpdocmto de
                             17 para 12 (Jean Michel).  
                
                03/08/2015 - Adicionado validacao para nao permitir faturamento anterior
                             a data inicial das atividades conforme solicitado no chamado
                             304923 (Kelvin).
                                       
                
                      
                22/09/2017 - Adicionar tratamento para caso o inpessoa for juridico gravar 
                             o idseqttl como zero (Luacas Ranghetti #756813)
.............................................................................*/

/*............................. DEFINICOES ..................................*/
{ sistema/generico/includes/b1wgen0069tt.i &TT-LOG=SIM }
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_log.i}
{ sistema/generico/includes/gera_erro.i}
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.

/*............................. PROCEDURES ..................................*/
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrposext AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-faturam.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabjfn FOR crapjfn.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados do Faturamento"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-faturam.
        EMPTY TEMP-TABLE tt-erro.   

        IF  NOT CAN-FIND(crapass WHERE crapass.cdcooper = par_cdcooper  AND
                                       crapass.nrdconta = par_nrdconta) THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
            END.

        FOR FIRST crabjfn FIELDS(vlrftbru mesftbru anoftbru cdopejfn dtaltjfn)
                          WHERE crabjfn.cdcooper = par_cdcooper AND
                                crabjfn.nrdconta = par_nrdconta NO-LOCK:

            DO aux_contador = 1 TO EXTENT(crabjfn.vlrftbru):
                IF  crabjfn.mesftbru[aux_contador] = 0 AND 
                    crabjfn.anoftbru[aux_contador] = 0 THEN
                    NEXT.

                IF  par_nrposext <> 0 AND (par_nrposext <> aux_contador) THEN
                    NEXT.

                CREATE tt-faturam.

                ASSIGN 
                    tt-faturam.nrposext = aux_contador
                    tt-faturam.vlrftbru = crabjfn.vlrftbru[aux_contador]
                    tt-faturam.mesftbru = crabjfn.mesftbru[aux_contador]
                    tt-faturam.anoftbru = crabjfn.anoftbru[aux_contador]
                    tt-faturam.cdoperad = crabjfn.cdopejfn[4]
                    tt-faturam.dtaltjfn = crabjfn.dtaltjfn[4]
                    tt-faturam.nrdrowid = ROWID(crabjfn).

                FOR FIRST crapope FIELDS(nmoperad)
                                  WHERE crapope.cdcooper = par_cdcooper AND 
                                        crapope.cdoperad = tt-faturam.cdoperad 
                                        NO-LOCK:
                    ASSIGN tt-faturam.nmoperad = crapope.nmoperad.
                END.
            END.

            IF  NOT TEMP-TABLE tt-faturam:HAS-RECORDS THEN
                DO:
                   CREATE tt-faturam.

                   ASSIGN 
                       tt-faturam.cdoperad = crabjfn.cdopejfn[4]
                       tt-faturam.dtaltjfn = crabjfn.dtaltjfn[4].

                   FOR FIRST crapope FIELDS(nmoperad)
                                     WHERE crapope.cdcooper = par_cdcooper AND 
                                           crapope.cdoperad = tt-faturam.cdoperad 
                                           NO-LOCK:
                       ASSIGN tt-faturam.nmoperad = crapope.nmoperad.
                   END.
                END.
        END.

        LEAVE Busca.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE
        ASSIGN aux_retorno = "OK".

    IF  par_flgerlog THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlrftbru AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_mesftbru AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_anoftbru AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrposext AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Valida dados do Faturamento"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        IF  par_cddopcao = "I" OR par_cddopcao = "A" THEN
            DO:
               FOR FIRST crapjfn FIELDS(vlrftbru mesftbru anoftbru)
                                 WHERE crapjfn.cdcooper = par_cdcooper AND
                                       crapjfn.nrdconta = par_nrdconta 
                                       NO-LOCK:
    
                   DO aux_contador = 1 TO EXTENT(crapjfn.vlrftbru):
                       IF  (crapjfn.mesftbru[aux_contador] = par_mesftbru AND
                            crapjfn.anoftbru[aux_contador] = par_anoftbru) AND 
                           par_nrposext <> aux_contador THEN
                           DO:             
                              aux_dscritic = "Ja existe um faturamento com " + 
                                             "este mes e ano.".
                              LEAVE Valida.
                           END.
                   END.
               END.
            END.
        
        FIND FIRST crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                 crapjur.nrdconta = par_nrdconta NO-LOCK.
        
        /*Se o ano informado for menor que o ano inicial das atividades gera critica*/
        IF  par_anoftbru < YEAR(crapjur.dtiniatv) THEN
            DO:
                ASSIGN aux_dscritic = "Ano de faturamento inferior a data inicial das atividades".
                LEAVE Valida.
            END.

        /*Se o ano for igual ao ano inicial das atividades e o mes informado 
          for menor que o ano inicial das atividades gera critica*/
        IF  par_anoftbru = YEAR(crapjur.dtiniatv)  AND 
            par_mesftbru < MONTH(crapjur.dtiniatv) THEN
            DO:
                ASSIGN aux_dscritic = "Mes de faturamento inferior a data inicial das atividades".
                LEAVE Valida.

            END.
        
        /* validar o mes */
        IF  par_mesftbru < 1 OR par_mesftbru > 12 THEN
            DO:
               ASSIGN aux_dscritic = "Mes de faturamento incorreto.".
               LEAVE Valida.
            END.

        /* validar o ano */
        IF  par_anoftbru < 1000 OR par_anoftbru > YEAR(par_dtmvtolt) THEN
            DO:
                ASSIGN aux_dscritic = "Ano de faturamento incorreto.".
                LEAVE Valida.
            END.

        /* validar o mes e ano */
        IF  par_anoftbru = YEAR (par_dtmvtolt)   AND
            par_mesftbru > MONTH(par_dtmvtolt)   THEN
            DO:
               ASSIGN aux_dscritic = "Mes de faturamento incorreto.".
               LEAVE Valida.
            END.

        /* Validar o valor de faturamento */
        IF par_vlrftbru = 0 THEN
           DO:
              ASSIGN aux_dscritic = "Valor do faturamento invalido.".
              LEAVE Valida.

           END.


        LEAVE Valida.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE
        ASSIGN aux_retorno = "OK".

    IF  par_flgerlog AND aux_retorno <> "OK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK" THEN YES ELSE NO),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlrftbru AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_mesftbru AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_anoftbru AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrposext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_anoftbru AS INTE                                    NO-UNDO.
    DEF VAR aux_mesftbru AS INTE                                    NO-UNDO.
    DEF VAR aux_idseqttl AS INT                                     NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = (IF par_cddopcao = "E" THEN "Exclui" 
                        ELSE IF par_cddopcao = "I" THEN
                             "Inclui" ELSE "Altera") + 
                       " dados do Faturamento"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.   

        ContadorJfn: DO aux_contador = 1 TO 10:
            FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper AND 
                               crapjfn.nrdconta = par_nrdconta
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAILABLE crapjfn THEN
                 DO:
                     IF  LOCKED(crapjfn) THEN
                         DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                   ASSIGN aux_cdcritic = 341.
                                   LEAVE ContadorJfn.
                                END.
                            ELSE 
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT ContadorJfn.
                                END.
                         END.
                     ELSE 
                         DO:
                             IF  par_cddopcao = "I" THEN
                                 DO:
                                     CREATE crapjfn.
                                     ASSIGN
                                         crapjfn.cdcooper = par_cdcooper
                                         crapjfn.nrdconta = par_nrdconta.
                                     VALIDATE crapjfn.
                                 END.
                             ELSE 
                                 DO:
                                    aux_dscritic = "Dados do financeiros " +
                                                   "FATURAMENTO nao foram " +
                                                   "encontrados.".
                                    LEAVE ContadorJfn.
                                 END.
                         END.
                 END.
            ELSE LEAVE ContadorJfn.
        END.
        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".
                UNDO Grava, LEAVE Grava.
            END.
            
        IF  crapass.inpessoa <> 1 THEN
            ASSIGN aux_idseqttl = 0.
        ELSE 
            ASSIGN aux_idseqttl = par_idseqttl.
            
        IF  par_cddopcao = "I" OR
            par_cddopcao = "A" THEN
            DO:
                ContadorDoc12: DO aux_contador = 1 TO 10:
            
                    FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                       crapdoc.nrdconta = par_nrdconta AND
                                       crapdoc.tpdocmto = 12            AND
                                       crapdoc.dtmvtolt = par_dtmvtolt AND
                                       crapdoc.idseqttl = aux_idseqttl 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF NOT AVAILABLE crapdoc THEN
                        DO:
                            IF LOCKED(crapdoc) THEN
                                DO:
                                    IF aux_contador = 10 THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 341.
                                            LEAVE ContadorDoc12.
                                        END.
                                    ELSE 
                                        DO: 
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                END.
                            ELSE
                                DO: 
                                    CREATE crapdoc.
                                    ASSIGN crapdoc.cdcooper = par_cdcooper
                                           crapdoc.nrdconta = par_nrdconta
                                           crapdoc.flgdigit = FALSE
                                           crapdoc.dtmvtolt = par_dtmvtolt
                                           crapdoc.tpdocmto = 12
                                           crapdoc.idseqttl = aux_idseqttl.
                                           
                                    VALIDATE crapdoc.        
                                    LEAVE ContadorDoc12.
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN crapdoc.flgdigit = FALSE
                                   crapdoc.dtmvtolt = par_dtmvtolt.
        
                            LEAVE ContadorDoc12.
                        END.
                END.
            END.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.

        { sistema/generico/includes/b1wgenalog.i }

        EMPTY TEMP-TABLE tt-crapjfn-ant.
        EMPTY TEMP-TABLE tt-crapjfn-atl.

        IF  par_flgerlog THEN
            DO:
               CREATE tt-crapjfn-ant.
               IF  NOT NEW crapjfn THEN
                   BUFFER-COPY crapjfn TO tt-crapjfn-ant.
            END.

        /* obter a ultima posicao do array, caso de inclusao */
        IF  par_nrposext = 0 THEN
            DO:
               Contador: DO aux_contador = 1 TO EXTENT(crapjfn.vlrftbru):
                   IF  crapjfn.mesftbru[aux_contador] = 0 AND 
                       crapjfn.anoftbru[aux_contador] = 0 THEN
                       DO:
                          ASSIGN par_nrposext = aux_contador.
                          LEAVE Contador.
                       END.
               END.
            END.

        CASE par_cddopcao:
            WHEN "E" THEN DO:
                ASSIGN
                    par_vlrftbru = 0
                    par_mesftbru = 0
                    par_anoftbru = 0.
            END.
            WHEN "I" THEN DO:
                ASSIGN 
                    aux_anoftbru = crapjfn.anoftbru[1]
                    aux_mesftbru = crapjfn.mesftbru[1]
                    par_nrposext = 1.

                DO aux_contador = 2 TO 12:

                   /* Pega a data mais antiga, e substitui pela nova inserida*/
                   IF  (aux_anoftbru = crapjfn.anoftbru[aux_contador] AND 
                        aux_mesftbru > crapjfn.mesftbru[aux_contador]) OR
                       aux_anoftbru > crapjfn.anoftbru[aux_contador] THEN
                       ASSIGN 
                          aux_anoftbru = crapjfn.anoftbru[aux_contador]
                          aux_mesftbru = crapjfn.mesftbru[aux_contador]
                          par_nrposext = aux_contador.
    
                END. /* Fim do DO TO */
            END.
        END CASE.

        ASSIGN
            crapjfn.vlrftbru[par_nrposext] = par_vlrftbru
            crapjfn.mesftbru[par_nrposext] = par_mesftbru
            crapjfn.anoftbru[par_nrposext] = par_anoftbru
            crapjfn.cdopejfn[4]            = par_cdoperad
            crapjfn.dtaltjfn[4]            = par_dtmvtolt NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
               UNDO Grava, LEAVE Grava.
            END.

        IF  par_flgerlog THEN
            DO:
               CREATE tt-crapjfn-atl.
               BUFFER-COPY crapjfn TO tt-crapjfn-atl.
            END.

        { sistema/generico/includes/b1wgenllog.i }

        ASSIGN aux_retorno = "OK".

        LEAVE Grava.
    END.

    RELEASE crapjfn.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_retorno = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.

    IF  par_flgerlog THEN
        RUN proc_gerar_log_tab
               ( INPUT par_cdcooper,
                 INPUT par_cdoperad,
                 INPUT aux_dscritic,
                 INPUT aux_dsorigem,
                 INPUT aux_dstransa,
                 INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
                 INPUT par_idseqttl,
                 INPUT par_nmdatela,
                 INPUT par_nrdconta,
                 INPUT YES,
                 INPUT BUFFER tt-crapjfn-ant:HANDLE,
                 INPUT BUFFER tt-crapjfn-atl:HANDLE ).

    RETURN aux_retorno.

END PROCEDURE.

