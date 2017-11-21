/*.............................................................................

    Programa: b1wgen0065.p
    Autor   : Jose Luis (DB1)
    Data    : Abril/2010                   Ultima atualizacao: 22/09/2017

    Objetivo  : Tranformacao BO tela CONTAS - REGISTRO

    Alteracoes: 04/10/2013 - Criacao de registro na crapdoc quando salvar ou 
                             alterar registros na procudeure Grava_Dados
                             (Jean Michel).
                             
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)  
                
                05/05/2014 - Alterar tpdocmto de 16 para 11 (Lucas R.)			    	

                11/08/2017 - Incluído o número do cpf ou cnpj na tabela crapdoc.
                             Projeto 339 - CRM. (Lombardi)
                
                22/09/2017 - Adicionar tratamento para caso o inpessoa for juridico gravar 
                             o idseqttl como zero (Luacas Ranghetti #756813)
.............................................................................*/

/*............................. DEFINICOES ..................................*/
{ sistema/generico/includes/b1wgen0065tt.i &TT-LOG=SIM }
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

    DEF OUTPUT PARAM TABLE FOR tt-registro.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabjur FOR crapjur.
    DEF BUFFER crabjfn FOR crapjfn.

    &SCOPED-DEFINE CAMPOS-JUR vlfatano vlcaprea dtregemp nrregemp orregemp~
                              dtinsnum nrinsmun nrinsest flgrefis nrcdnire

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados do Registro"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-registro.
        EMPTY TEMP-TABLE tt-erro.   

        IF  NOT CAN-FIND(crapass WHERE crapass.cdcooper = par_cdcooper  AND
                                       crapass.nrdconta = par_nrdconta) THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
            END.

        FOR FIRST crabjur FIELDS({&CAMPOS-JUR})
                          WHERE crabjur.cdcooper = par_cdcooper AND
                                crabjur.nrdconta = par_nrdconta NO-LOCK:

            BUFFER-COPY crabjur USING {&CAMPOS-JUR} TO tt-registro.
        END.

        FOR FIRST crabjfn FIELDS(perfatcl)
                          WHERE crabjfn.cdcooper = par_cdcooper AND
                                crabjfn.nrdconta = par_nrdconta NO-LOCK:

            ASSIGN tt-registro.perfatcl = crabjfn.perfatcl.
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
    DEF  INPUT PARAM par_vlfatano AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlcaprea AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtregemp AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregemp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_orregemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_perfatcl AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Valida dados do Registro"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.   

        IF  par_vlfatano = 0 THEN
            DO:
               ASSIGN aux_dscritic = "Informe o faturamento anual.".
               LEAVE Valida.
            END.

        IF  par_vlcaprea = 0 THEN
            DO:
               ASSIGN aux_dscritic = "Informe o capital realizado da empresa.".
               LEAVE Valida.
            END.

        IF  par_dtregemp = ? THEN
            DO:
               ASSIGN aux_dscritic = "Informe a data de registro da empresa.".
               LEAVE Valida.
            END.

        IF  par_nrregemp = 0 THEN
            DO:
               ASSIGN aux_dscritic = "Informe o numero de registro da " + 
                                     "empresa.".
               LEAVE Valida.
            END.

        IF  par_orregemp = "" THEN
            DO:
               ASSIGN aux_dscritic = "Informe o orgao onde a empresa foi " + 
                                     "registrada.".
               LEAVE Valida.        
            END.

        IF  par_perfatcl <= 0 OR par_perfatcl > 100 THEN
            DO:
               ASSIGN aux_dscritic = "Percentual de concentracao " + 
                                     "faturamento unico cliente incorreto.".
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
    DEF  INPUT PARAM par_vlfatano AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlcaprea AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtregemp AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregemp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_orregemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtinsnum AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinsmun AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrinsest AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgrefis AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrcdnire AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_perfatcl AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_idseqttl AS INT                                     NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = (IF par_cddopcao = "E" THEN "Exclui" 
                        ELSE IF par_cddopcao = "I" THEN
                             "Inclui" ELSE "Altera") + 
                       " dados do Registro"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.   

        ContadorJur: DO aux_contador = 1 TO 10:

            FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                               crapjur.nrdconta = par_nrdconta 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapjur THEN
                DO:
                   IF  LOCKED(crapjur) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 aux_dscritic = "Associado sendo alterado" +
                                                " em outra estacao." .
                                 LEAVE ContadorJur.
                              END.
                          ELSE 
                              DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorJur.
                              END.
                       END.
                   ELSE 
                       DO:
                           ASSIGN aux_cdcritic = 72.
                           LEAVE ContadorJur.
                       END.
                END.
            ELSE 
                LEAVE ContadorJur.
        END.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

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

        EMPTY TEMP-TABLE tt-registro-ant.
        EMPTY TEMP-TABLE tt-registro-atl.

        IF  par_flgerlog THEN
            DO:
               CREATE tt-registro-ant.
               IF  NOT NEW crapjfn THEN
                   DO:
                       BUFFER-COPY crapjfn TO tt-registro-ant.
                       BUFFER-COPY crapjur TO tt-registro-ant.
                   END.
            END.

        ASSIGN aux_idseqttl = 0.

        IF  crapjur.dtregemp <> par_dtregemp OR
            crapjur.nrregemp <> par_nrregemp  THEN
            DO:
               
               ContadorDoc11: DO aux_contador = 1 TO 10:
        
                    FIND FIRST crapdoc WHERE 
                               crapdoc.cdcooper = par_cdcooper AND
                               crapdoc.nrdconta = par_nrdconta AND
                               crapdoc.tpdocmto = 11           AND
                               crapdoc.dtmvtolt = par_dtmvtolt AND
                               crapdoc.idseqttl = aux_idseqttl AND
                               crapdoc.nrcpfcgc = crapass.nrcpfcgc
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF NOT AVAILABLE crapdoc THEN
                        DO:
                            IF LOCKED(crapdoc) THEN
                                DO:
                                    IF aux_contador = 10 THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 341.
                                            LEAVE ContadorDoc11.
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
                                           crapdoc.tpdocmto = 11
                                           crapdoc.idseqttl = aux_idseqttl
                                           crapdoc.nrcpfcgc = crapass.nrcpfcgc.
                                    VALIDATE crapdoc.        
                                    LEAVE ContadorDoc11.
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN crapdoc.flgdigit = FALSE
                                   crapdoc.dtmvtolt = par_dtmvtolt.
        
                            LEAVE ContadorDoc11.
                        END.
                END.
                         
            END.

        ASSIGN 
            crapjur.vlfatano = par_vlfatano 
            crapjur.vlcaprea = par_vlcaprea 
            crapjur.dtregemp = par_dtregemp 
            crapjur.nrregemp = par_nrregemp 
            crapjur.orregemp = par_orregemp 
            crapjur.dtinsnum = par_dtinsnum 
            crapjur.nrinsmun = par_nrinsmun 
            crapjur.nrinsest = par_nrinsest 
            crapjur.flgrefis = par_flgrefis 
            crapjur.nrcdnire = par_nrcdnire
            crapjfn.perfatcl = par_perfatcl NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
               LEAVE Grava.
            END.

        IF  par_flgerlog THEN
            DO:
               CREATE tt-registro-atl.
               BUFFER-COPY crapjfn TO tt-registro-atl.
               BUFFER-COPY crapjur TO tt-registro-atl.
            END.

        { sistema/generico/includes/b1wgenllog.i }

        ASSIGN aux_returnvl = "OK".

        LEAVE Grava.
    END.

    RELEASE crapjur.
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
        /* log da tabela crapjur */
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
              INPUT YES, /*log dos itens*/
              INPUT BUFFER tt-registro-ant:HANDLE,
              INPUT BUFFER tt-registro-atl:HANDLE ).

    RETURN aux_returnvl.

END PROCEDURE.

