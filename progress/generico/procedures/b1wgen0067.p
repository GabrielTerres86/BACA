/*.............................................................................

    Programa: b1wgen0067.p
    Autor   : Jose Luis (DB1)
    Data    : Abril/2010                   Ultima atualizacao: 13/12/2013   

    Objetivo  : Tranformacao BO tela CONTAS - FINANCEIRO - BANCOS

    Alteracoes: 13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
   
.............................................................................*/

/*............................. DEFINICOES ..................................*/
{ sistema/generico/includes/b1wgen0067tt.i &TT-LOG=SIM }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
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
    DEF  INPUT PARAM par_nrdlinha AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-banco.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabjfn FOR crapjfn.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados dos Bancos"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-banco.
        EMPTY TEMP-TABLE tt-erro.   

        IF  NOT CAN-FIND(crapass WHERE crapass.cdcooper = par_cdcooper  AND
                                       crapass.nrdconta = par_nrdconta) THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
            END.

        IF  par_cddopcao = "I" THEN
            LEAVE Busca.
        
        FOR FIRST crabjfn FIELDS(cddbanco dstipope vlropera garantia dsvencto
                                 cdopejfn dtaltjfn)
                          WHERE crabjfn.cdcooper = par_cdcooper AND
                                crabjfn.nrdconta = par_nrdconta NO-LOCK:
            
            DO aux_contador = 1 TO EXTENT(crabjfn.cddbanco):
                IF  crabjfn.cddbanco[aux_contador] = 0 THEN
                    NEXT.

                IF  par_nrdlinha <> 0 AND (par_nrdlinha <> aux_contador) THEN
                    NEXT.

                CREATE tt-banco.
                ASSIGN 
                    tt-banco.nrdlinha = aux_contador
                    tt-banco.cddbanco = crabjfn.cddbanco[aux_contador]
                    tt-banco.dstipope = CAPS(crabjfn.dstipope[aux_contador])
                    tt-banco.vlropera = crabjfn.vlropera[aux_contador]
                    tt-banco.garantia = CAPS(crabjfn.garantia[aux_contador])
                    tt-banco.dsvencto = crabjfn.dsvencto[aux_contador].

                FOR FIRST crapban FIELDS(nmresbcc)
                                  WHERE crapban.cdbccxlt = tt-banco.cddbanco
                                        NO-LOCK:
                    ASSIGN tt-banco.dsdbanco = crapban.nmresbcc.
                END.

                ASSIGN 
                    tt-banco.cdoperad = crabjfn.cdopejfn[2]
                    tt-banco.dtaltjfn = crabjfn.dtaltjfn[2]
                    tt-banco.nrdrowid = ROWID(crabjfn).

                FOR FIRST crapope FIELDS(nmoperad)
                                  WHERE crapope.cdcooper = par_cdcooper AND 
                                        crapope.cdoperad = tt-banco.cdoperad 
                                        NO-LOCK:
                    ASSIGN tt-banco.nmoperad = crapope.nmoperad.
                END.
            END.
        END.

        IF  CAN-DO("A,E",par_cddopcao) AND 
            NOT TEMP-TABLE tt-banco:HAS-RECORDS THEN
            DO:
               ASSIGN aux_dscritic = "Registro do Banco nao foi encontrado.".
               LEAVE Busca.
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
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_returnvl = "OK"
                                   THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.

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
    DEF  INPUT PARAM par_cddbanco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dstipope AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlropera AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_garantia AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsvencto AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Valida dados dos Bancos"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        /* validar o banco */
        IF  NOT CAN-FIND(crapban WHERE crapban.cdbccxlt = par_cddbanco) THEN
            DO:
               ASSIGN aux_dscritic = "Banco nao cadastrado.".
               LEAVE Valida.
            END.

        /* tipo de operacao financeira */
        IF  par_dstipope = "" THEN
            DO:
               ASSIGN aux_dscritic = "O tipo de operacao realizada com a " +
                                     "inst. financeira deve ser informado.".
               LEAVE Valida.
            END.

        /* valor da operacao */
        IF  par_vlropera = 0 THEN 
            DO:
               ASSIGN aux_dscritic = "O valor da operacao financeira deve " +
                                     "ser informado.".
               LEAVE Valida.
            END.

        /* tipo de garantia */
        IF  par_garantia = "" THEN
            DO:
               ASSIGN aux_dscritic = "O tipo da garantia deve ser informado.".
               LEAVE Valida.
            END.
         
        /* Vencimento */
        IF  par_dsvencto = "" THEN
            DO:
               ASSIGN aux_dscritic = "Informe o vencimento da operacao ou " + 
                                     "VARIOS para diversas datas.".
               LEAVE Valida.
            END.

        IF  UPPER(par_dsvencto) <> "VARIOS" THEN
            DO:
               IF  LENGTH(par_dsvencto) <> 10  THEN
                   DO:
                      aux_cdcritic = 13.
                      LEAVE Valida.
                   END.

               DATE(par_dsvencto) NO-ERROR.
               IF  ERROR-STATUS:ERROR THEN
                   DO:
                      aux_cdcritic = 13.
                      LEAVE Valida.
                   END.
            END.

        IF  par_cddopcao = "I" THEN
            DO:
               FOR FIRST crapjfn FIELDS(cddbanco) 
                                 WHERE crapjfn.cdcooper = par_cdcooper AND
                                       crapjfn.nrdconta = par_nrdconta NO-LOCK:

                   IF  crapjfn.cddbanco[5] <> 0 THEN
                       DO:
                          ASSIGN aux_dscritic = "Cadastro completo. Maximo 5" +
                                                "cadastros".
                          LEAVE Valida.
                       END.
               END.
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
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog AND aux_returnvl <> "OK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_returnvl = "OK"
                                   THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.

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
    DEF  INPUT PARAM par_nrdlinha AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddbanco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dstipope AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlropera AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_garantia AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsvencto AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_atualope AS LOG                                     NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = (IF par_cddopcao = "E" THEN "Exclui" 
                        ELSE IF par_cddopcao = "I" THEN
                             "Inclui" ELSE "Altera") + 
                       " dados dos Bancos"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

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

            IF  NOT AVAILABLE crapjfn THEN
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
                           CASE par_cddopcao:
                               WHEN "I" THEN DO:
                                   CREATE crapjfn.
                                   ASSIGN
                                       crapjfn.cdcooper = par_cdcooper
                                       crapjfn.nrdconta = par_nrdconta.
                                   VALIDATE crapjfn.
                                   LEAVE ContadorJfn.
                               END.
                               WHEN "A" OR WHEN "E" THEN DO:
                                   aux_dscritic = "Dados financeiros do " + 
                                                  "Associado nao cadastrado.".
                                   LEAVE ContadorJfn.  
                               END.
                           END CASE.
                        END.
                END.
            ELSE
                LEAVE ContadorJfn.
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
        
        /* obter a ultima posicao do array, inclusao */
        IF  par_nrdlinha = 0 THEN
            DO:
               Contador: DO aux_contador = 1 TO EXTENT(crapjfn.cddbanco):
                   IF  crapjfn.cddbanco[aux_contador] = 0 THEN
                       DO:
                          ASSIGN par_nrdlinha = aux_contador.
                          LEAVE Contador.
                       END.
               END.
            END.

        /* atualizacao do operador */
        ASSIGN aux_atualope = YES.

        CASE par_cddopcao:
           WHEN "E" THEN
               ASSIGN
                  par_cddbanco = 0
                  par_dstipope = ""
                  par_vlropera = 0
                  par_garantia = ""
                  par_dsvencto = "".
           WHEN "A" THEN DO:
               IF  crapjfn.cddbanco[par_nrdlinha] <> par_cddbanco OR
                   crapjfn.dstipope[par_nrdlinha] <> par_dstipope OR
                   crapjfn.vlropera[par_nrdlinha] <> par_vlropera OR
                   crapjfn.garantia[par_nrdlinha] <> par_garantia OR
                   crapjfn.dsvencto[par_nrdlinha] <> par_dsvencto THEN
                   ASSIGN aux_atualope = YES.
               ELSE 
                   ASSIGN aux_atualope = NO.
           END.
        END CASE.

        ASSIGN
            crapjfn.cddbanco[par_nrdlinha] = par_cddbanco
            crapjfn.dstipope[par_nrdlinha] = UPPER(par_dstipope)
            crapjfn.vlropera[par_nrdlinha] = par_vlropera
            crapjfn.garantia[par_nrdlinha] = UPPER(par_garantia)
            crapjfn.dsvencto[par_nrdlinha] = UPPER(par_dsvencto).

        IF  aux_atualope THEN
            ASSIGN
                crapjfn.cdopejfn[2] = par_cdoperad
                crapjfn.dtaltjfn[2] = par_dtmvtolt.

        IF  par_flgerlog THEN
            DO:
               CREATE tt-crapjfn-atl.
               BUFFER-COPY crapjfn TO tt-crapjfn-atl.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Grava.
    END.

    RELEASE crapjfn.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

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
              INPUT (IF aux_returnvl = "OK" THEN TRUE ELSE FALSE),
              INPUT par_idseqttl, 
              INPUT par_nmdatela, 
              INPUT par_nrdconta, 
              INPUT YES,
              INPUT BUFFER tt-crapjfn-ant:HANDLE,
              INPUT BUFFER tt-crapjfn-atl:HANDLE ).

    RETURN aux_returnvl.

END PROCEDURE.

