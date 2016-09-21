/*.............................................................................

    Programa: b1wgen0068.p
    Autor   : Jose Luis (DB1)
    Data    : Abril/2010                   Ultima atualizacao: 13/12/2013   

    Objetivo  : Tranformacao BO tela CONTAS - FINANCEIRO - RESULTADO

    Alteracoes: 13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
   
.............................................................................*/

/*............................. DEFINICOES ..................................*/
{ sistema/generico/includes/b1wgen0068tt.i &TT-LOG=SIM }
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

    DEF OUTPUT PARAM TABLE FOR tt-resultado.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabjfn FOR crapjfn.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados do Resultado"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-resultado.
        EMPTY TEMP-TABLE tt-erro.   

        IF  NOT CAN-FIND(crapass WHERE crapass.cdcooper = par_cdcooper  AND
                                       crapass.nrdconta = par_nrdconta) THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
            END.

        CREATE tt-resultado.

        FOR FIRST crabjfn FIELDS(vlrctbru vlctdpad vldspfin ddprzrec ddprzpag
                                 cdopejfn dtaltjfn)
                          WHERE crabjfn.cdcooper = par_cdcooper AND
                                crabjfn.nrdconta = par_nrdconta NO-LOCK:
            
            ASSIGN 
                tt-resultado.vlrctbru = crabjfn.vlrctbru
                tt-resultado.vlctdpad = crabjfn.vlctdpad
                tt-resultado.vldspfin = crabjfn.vldspfin
                tt-resultado.ddprzrec = crabjfn.ddprzrec
                tt-resultado.ddprzpag = crabjfn.ddprzpag
                tt-resultado.cdoperad = crabjfn.cdopejfn[3]
                tt-resultado.dtaltjfn = crabjfn.dtaltjfn[3]
                tt-resultado.nrdrowid = ROWID(crabjfn).

            FOR FIRST crapope FIELDS(nmoperad)
                              WHERE crapope.cdcooper = par_cdcooper AND 
                                    crapope.cdoperad = tt-resultado.cdoperad 
                                    NO-LOCK:
                ASSIGN tt-resultado.nmoperad = crapope.nmoperad.
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
    DEF  INPUT PARAM par_vlrctbru AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlctdpad AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vldspfin AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_ddprzrec AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ddprzpag AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Valida dados do Resultado"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

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
                            INPUT (IF aux_retorno = "OK"
                                   THEN TRUE ELSE FALSE),
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
    DEF  INPUT PARAM par_vlrctbru AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlctdpad AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vldspfin AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_ddprzrec AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ddprzpag AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = (IF par_cddopcao = "E" THEN "Exclui" 
                        ELSE IF par_cddopcao = "I" THEN
                             "Inclui" ELSE "Altera") + 
                       " dados do Resultado"
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
                            CREATE crapjfn.
                            ASSIGN
                                crapjfn.cdcooper = par_cdcooper
                                crapjfn.nrdconta = par_nrdconta.
                            VALIDATE crapjfn.
                            LEAVE ContadorJfn.
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
        
        ASSIGN
            crapjfn.vlrctbru    = par_vlrctbru
            crapjfn.vlctdpad    = par_vlctdpad
            crapjfn.vldspfin    = par_vldspfin
            crapjfn.ddprzrec    = par_ddprzrec
            crapjfn.ddprzpag    = par_ddprzpag
            crapjfn.cdopejfn[3] = par_cdoperad
            crapjfn.dtaltjfn[3] = par_dtmvtolt.

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

