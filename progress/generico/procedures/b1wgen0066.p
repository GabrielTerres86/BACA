/*.............................................................................

    Programa: b1wgen0066.p
    Autor   : Jose Luis (DB1)
    Data    : Abril/2010                   Ultima atualizacao: 13/12/2013   

    Objetivo  : Tranformacao BO tela CONTAS - FINANCEIRO - ATIVO/PASSIVO

    Alteracoes: 13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge) 
   
.............................................................................*/

/*............................. DEFINICOES ..................................*/
{ sistema/generico/includes/b1wgen0066tt.i &TT-LOG=SIM }
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

    DEF OUTPUT PARAM TABLE FOR tt-atvpass.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabjfn FOR crapjfn.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados do Ativo/Passivo"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-atvpass.
        EMPTY TEMP-TABLE tt-erro.   

        IF  NOT CAN-FIND(crapass WHERE crapass.cdcooper = par_cdcooper  AND
                                       crapass.nrdconta = par_nrdconta) THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
            END.

        CREATE tt-atvpass.

        FOR FIRST crabjfn FIELDS(mesdbase anodbase vlcxbcaf vlctarcb vlrestoq
                                 vloutatv vlrimobi vlfornec vloutpas vldivbco
                                 dtaltjfn cdopejfn)
                          WHERE crabjfn.cdcooper = par_cdcooper AND
                                crabjfn.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  AVAILABLE crabjfn THEN
            ASSIGN 
               tt-atvpass.mesdbase = crabjfn.mesdbase
               tt-atvpass.anodbase = crabjfn.anodbase
               tt-atvpass.vlcxbcaf = crabjfn.vlcxbcaf
               tt-atvpass.vlctarcb = crabjfn.vlctarcb
               tt-atvpass.vlrestoq = crabjfn.vlrestoq
               tt-atvpass.vloutatv = crabjfn.vloutatv
               tt-atvpass.vlrimobi = crabjfn.vlrimobi
               tt-atvpass.vlfornec = crabjfn.vlfornec
               tt-atvpass.vloutpas = crabjfn.vloutpas
               tt-atvpass.vldivbco = crabjfn.vldivbco
               tt-atvpass.dtaltjfn = crabjfn.dtaltjfn[1]
               tt-atvpass.cdopejfn = crabjfn.cdopejfn[1]
               tt-atvpass.nrdrowid = ROWID(crabjfn).

        FOR FIRST crapope FIELDS(nmoperad)
                          WHERE crapope.cdcooper = par_cdcooper AND 
                                crapope.cdoperad = tt-atvpass.cdopejfn NO-LOCK:
            ASSIGN tt-atvpass.nmoperad = crapope.nmoperad.
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
    DEF  INPUT PARAM par_mesdbase AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_anodbase AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Valida dados do Ativo/Passivo"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.   

        IF  par_mesdbase < 1 AND par_mesdbase > 12 THEN
            DO:
               ASSIGN aux_cdcritic = 13.
               LEAVE Valida.
            END.

        IF  par_anodbase < 1970 AND par_anodbase > 2040 THEN
            DO:
               ASSIGN aux_cdcritic = 13.
               LEAVE Valida.
            END.

        IF  par_mesdbase > MONTH(par_dtmvtolt) AND 
            par_anodbase >= YEAR(par_dtmvtolt) THEN
            DO:
               ASSIGN aux_cdcritic = 13.
               LEAVE Valida.
            END.
        ELSE
            IF  par_anodbase > YEAR(par_dtmvtolt) THEN
                DO:
                   ASSIGN aux_cdcritic = 13.
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
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog AND aux_returnvl <> "OK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_returnvl = "OK" THEN YES ELSE NO),
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
    DEF  INPUT PARAM par_mesdbase AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_anodbase AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlcxbcaf AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlctarcb AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrestoq AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vloutatv AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrimobi AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlfornec AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vloutpas AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vldivbco AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdopejfn AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = (IF par_cddopcao = "E" THEN "Exclui" 
                        ELSE IF par_cddopcao = "I" THEN
                             "Inclui" ELSE "Altera") + 
                       " dados do Ativo/Passivo"
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

               
        CREATE tt-crapjfn-ant.
        BUFFER-COPY crapjfn TO tt-crapjfn-ant.

        ASSIGN 
            crapjfn.mesdbase    = par_mesdbase
            crapjfn.anodbase    = par_anodbase
            crapjfn.vlcxbcaf    = par_vlcxbcaf
            crapjfn.vlctarcb    = par_vlctarcb
            crapjfn.vlrestoq    = par_vlrestoq
            crapjfn.vloutatv    = par_vloutatv
            crapjfn.vlrimobi    = par_vlrimobi
            crapjfn.vlfornec    = par_vlfornec
            crapjfn.vloutpas    = par_vloutpas
            crapjfn.vldivbco    = par_vldivbco
            crapjfn.dtaltjfn[1] = par_dtmvtolt
            crapjfn.cdopejfn[1] = par_cdopejfn.

               
        CREATE tt-crapjfn-atl.
        BUFFER-COPY crapjfn TO tt-crapjfn-atl.

        { sistema/generico/includes/b1wgenllog.i }

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
              INPUT YES, /* gravar log dos itens */
              INPUT BUFFER tt-crapjfn-ant:HANDLE,
              INPUT BUFFER tt-crapjfn-atl:HANDLE ).

    RETURN aux_returnvl.

END PROCEDURE.

