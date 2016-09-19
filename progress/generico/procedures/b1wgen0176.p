/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0176.p
    Autor   : Gabriel Capoia (DB1)
    Data    : 19/09/2013                     Ultima atualizacao: 16/06/2016

    Objetivo  : Tranformacao BO tela GT0002.

    Alteracoes: 06/03/2014 - Incluso VALIDATE (Daniel)
                
                16/05/2016 - #412560 Inclusao de comentarios nos codigos das 
                             criticas (Carlos)

                15/06/2016 - Correcao da paginacao para filtro que tras apenas 
                             um registro (Carlos)
        
............................................................................*/

/*............................. DEFINICOES .................................*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0176tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nrregist AS INTE                                        NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                        NO-UNDO.
DEF VAR par_loginusr AS CHAR                                        NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                        NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                        NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                        NO-UNDO.
DEF VAR par_numipusr AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.


/*................................ PROCEDURES ..............................*/

/* -------------------------------------------------------------------------- */
/*       EFETUA A PESQUISA MANUTENCAO DE CONVENIOS POR COOPERATIVA            */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdepart AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdconven AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcooped AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-gt0002.
    DEF OUTPUT PARAM TABLE FOR tt-gt0002-aux.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Dados Manutencao de Convenios por Cooperativa".              

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-gt0002-aux.
        EMPTY TEMP-TABLE tt-gt0002.
        EMPTY TEMP-TABLE tt-erro.

        IF  par_cddopcao = "C"  THEN DO:

            IF  par_cdconven <> 0 AND
                par_cdcooped <> 0 THEN DO:

                FOR FIRST gnconve FIELDS(nmempres cdcooper)
                    WHERE gnconve.cdconven = par_cdconven NO-LOCK: END.

                IF  NOT AVAILABLE gnconve THEN
                    DO:
                        ASSIGN aux_cdcritic = 563  /* Convenio  nao Cadastrado */
                               aux_dscritic = ""
                               par_nmdcampo = "cdcooper".
                        LEAVE Busca.
                    END.

                CREATE tt-gt0002.

                IF  AVAIL tt-gt0002 THEN
                    ASSIGN  tt-gt0002.nmempres = gnconve.nmempres
                            tt-gt0002.cdcooped = gnconve.cdcooper.

                FOR FIRST crapcop FIELDS(nmrescop)
                    WHERE crapcop.cdcooper = par_cdcooped NO-LOCK: END.

                IF  NOT AVAIL crapcop THEN
                    DO:
                        ASSIGN aux_cdcritic = 794 /* Cooperativa Invalida */
                               aux_dscritic = ""
                               par_nmdcampo = "cdcooper".
                        LEAVE Busca.
                    END.

                IF  AVAIL tt-gt0002 THEN
                    ASSIGN  tt-gt0002.nmrescop = crapcop.nmrescop.

                FOR FIRST gncvcop FIELDS(cdcooper cdconven)
                    WHERE gncvcop.cdconven = par_cdconven AND
                          gncvcop.cdcooper = par_cdcooped NO-LOCK: END.

                IF  NOT AVAIL gncvcop THEN
                    DO:
                        ASSIGN aux_cdcritic = 796 /* Convenio_Cooperativa nao Cadastrado */
                               aux_dscritic = ""
                               par_nmdcampo = "cdconven".
                        LEAVE Busca.
                    END.

                ASSIGN tt-gt0002.cdcooper = gncvcop.cdcooper
                       tt-gt0002.cdconven = gncvcop.cdconven.

                IF  par_idorigem = 5 THEN DO:
                    RUN pi_paginacao
                    ( INPUT par_nrregist,
                      INPUT par_nriniseq,
                      INPUT TABLE tt-gt0002,
                     OUTPUT par_qtregist,
                     OUTPUT TABLE tt-gt0002-aux).
                           
                    EMPTY TEMP-TABLE tt-gt0002.
                END.

                
            END. /*par_cdconven <> 0 AND par_cdcooper <> 0*/
            ELSE 
                DO:
                      FOR EACH gncvcop 
                         WHERE gncvcop.cdconven >= par_cdconven AND
                               gncvcop.cdcooper >= par_cdcooped NO-LOCK,
      
                          FIRST crapcop 
                          WHERE crapcop.cdcooper = gncvcop.cdcooper NO-LOCK,
      
                          FIRST gnconve 
                          WHERE gnconve.cdconve = gncvcop.cdconve NO-LOCK
      
                          BY gncvcop.cdcooper
                              BY gncvcop.cdconven:
      
                          CREATE tt-gt0002.
                          ASSIGN tt-gt0002.cdcooper = gncvcop.cdcooper
                                 tt-gt0002.nmrescop = crapcop.nmrescop
                                 tt-gt0002.cdconven = gncvcop.cdconven
                                 tt-gt0002.nmempres = gnconve.nmempres
                                 tt-gt0002.cdcooped = gnconve.cdcooper.
                    END.

                    IF  par_idorigem = 5 THEN DO:
                        RUN pi_paginacao
                        ( INPUT par_nrregist,
                          INPUT par_nriniseq,
                          INPUT TABLE tt-gt0002,
                         OUTPUT par_qtregist,
                         OUTPUT TABLE tt-gt0002-aux).

                        EMPTY TEMP-TABLE tt-gt0002.
                        
                    END.


                END. /* FIM ELSE */

        END. /* par_cddopcao = "C" */
        ELSE 
            IF  CAN-DO("I,E",par_cddopcao) THEN DO:

                IF  par_dsdepart <> "TI"         AND
                    par_dsdepart <> "FINANCEIRO" AND
                    par_dsdepart <> "COMPE"      THEN
                    DO:
                               aux_dscritic = "".
                        LEAVE Busca.
                    END.


                IF  par_cdconven = 0 THEN
                    DO:
                        ASSIGN aux_cdcritic = 474 /* Codigo e/ou numero do convenio invalido. */
                               aux_dscritic = ""
                               par_nmdcampo = "cdconven".
                        LEAVE Busca.
                    END.

                FOR FIRST gnconve FIELDS(nmempres)
                    WHERE gnconve.cdconven = par_cdconven NO-LOCK: END.

                IF  NOT AVAILABLE gnconve THEN
                    DO:
                        ASSIGN aux_cdcritic = 563  /* Convenio  nao Cadastrado */
                               aux_dscritic = ""
                               par_nmdcampo = "cdcooper".
                        LEAVE Busca.
                    END.

                CREATE tt-gt0002.

                IF  AVAIL tt-gt0002 THEN
                    ASSIGN  tt-gt0002.nmempres = gnconve.nmempres.

                IF  par_cdcooped = 0 THEN
                    DO:
                        ASSIGN aux_cdcritic = 794 /* Cooperativa Invalida */
                               aux_dscritic = ""
                               par_nmdcampo = "cdcooper".
                        LEAVE Busca.
                    END.

                FOR FIRST crapcop FIELDS(nmrescop)
                    WHERE crapcop.cdcooper = par_cdcooped NO-LOCK: END.

                IF  NOT AVAIL crapcop THEN
                    DO:
                        ASSIGN aux_cdcritic = 794 /* Cooperativa Invalida */
                               aux_dscritic = ""
                               par_nmdcampo = "cdcooper".
                        LEAVE Busca.
                    END.

                IF  AVAIL tt-gt0002 THEN
                    ASSIGN  tt-gt0002.nmrescop = crapcop.nmrescop.

                FOR FIRST gncvcop FIELDS()
                    WHERE gncvcop.cdconven = par_cdconven AND
                          gncvcop.cdcooper = par_cdcooped NO-LOCK: END.

                IF  par_cddopcao <> "I" THEN DO:
                    IF  NOT AVAIL gncvcop THEN
                        DO:
                            ASSIGN aux_cdcritic = 796 /* Convenio_Cooperativa nao Cadastrado */
                                   aux_dscritic = ""
                                   par_nmdcampo = "cdconven".
                            LEAVE Busca.
                        END.
                END.
                ELSE 
                IF  AVAIL gncvcop THEN 
                    DO:
                        ASSIGN aux_cdcritic = 795 /* Convenio por Cooperativa ja Cadastrado */
                               aux_dscritic = ""
                               par_nmdcampo = "cdconven".
                        LEAVE Busca.
                    END.

                IF  par_idorigem = 5 THEN DO:
                    CREATE tt-gt0002-aux.
                    BUFFER-COPY tt-gt0002 TO tt-gt0002-aux.
                    EMPTY TEMP-TABLE tt-gt0002.
                END.

            END. /* CAN-DO("I,E",par_cddopcao) */
        ELSE DO:
            ASSIGN aux_cdcritic = 14 /* Opcao errada. */
                   aux_dscritic = ""
                   par_nmdcampo = "cddopcao".
            LEAVE Busca.
        END.

        LEAVE Busca.

    END. /* Busca */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.

            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */

PROCEDURE pi_paginacao:

    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-gt0002.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-gt0002-aux.

    ASSIGN aux_nrregist = par_nrregist.

    Pagina: DO ON ERROR UNDO Pagina, LEAVE Pagina:
        EMPTY TEMP-TABLE tt-gt0002-aux.

        FOR EACH tt-gt0002:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginação */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                    CREATE tt-gt0002-aux.
                    BUFFER-COPY tt-gt0002 TO tt-gt0002-aux.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.

    END. /* Pagina */

    RETURN "OK".

END PROCEDURE. /*pi_paginacao*/

PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdconven AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcooped AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava Manutencao de Convenios por Cooperativa"
           aux_cdcritic = 0
           aux_returnvl = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        IF  par_cdconven = 0 THEN
            DO:
                ASSIGN aux_cdcritic = 474 /* Codigo e/ou numero do convenio invalido */
                       aux_dscritic = "".
                LEAVE Grava.
            END.

        IF  par_cdcooped = 0 THEN
            DO:
                ASSIGN aux_cdcritic = 794 /* Cooperativa Invalida */
                       aux_dscritic = "".
                LEAVE Grava.
            END.

        FOR FIRST crapcop FIELDS(nmrescop dsdircop)
            WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAIL crapcop THEN
            DO:
                ASSIGN aux_cdcritic = 794 /* Cooperativa Invalida */
                       aux_dscritic = "".
                LEAVE Grava.
            END.

        FOR FIRST gncvcop FIELDS()
            WHERE gncvcop.cdconven = par_cdconven AND
                  gncvcop.cdcooper = par_cdcooped NO-LOCK: END.

        IF  par_cddopcao <> "I" THEN DO:
            IF  NOT AVAIL gncvcop THEN
                DO:
                    ASSIGN aux_cdcritic = 796 /* Convenio_Cooperativa nao Cadastrado */
                           aux_dscritic = "".
                    LEAVE Grava.
                END.
        END.
        ELSE
        IF  AVAIL gncvcop THEN 
            DO:
                ASSIGN aux_cdcritic = 795 /* Convenio por Cooperativa ja Cadastrado */
                       aux_dscritic = "".
                LEAVE Grava.
            END.

        IF  par_cddopcao = "I" THEN DO:

            CREATE gncvcop.

            ASSIGN gncvcop.cdconven = par_cdconven    
                   gncvcop.cdcooper = par_cdcooped.
            VALIDATE gncvcop.

        END.
        ELSE IF  par_cddopcao = "E" THEN DO:

            Contador: DO aux_contador = 1 TO 10:

                FIND gncvcop WHERE
                     gncvcop.cdconven = par_cdconven AND
                     gncvcop.cdcooper = par_cdcooped EXCLUSIVE-LOCK NO-ERROR.

                IF  NOT AVAIL gncvcop THEN
                    DO:
                        IF  LOCKED(gncvcop) THEN
                            DO:
                                IF  aux_contador = 10 THEN
                                    DO: 
                                        aux_cdcritic = 77. /* Tabela sendo alterada p/ outro terminal */
                                        LEAVE Contador.
    
                                    END.
                                ELSE 
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT Contador.
                                    END.
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 796 /* Convenio_coop. nao Cadastrado */
                                       aux_dscritic = "".
    
                                LEAVE Contador.
    
                            END.
    
                    END.
                ELSE
                    LEAVE Contador.
    
            END. /* Contador */
            
            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                UNDO Grava, LEAVE Grava.

            DELETE gncvcop.

        END.
        ELSE DO:
            ASSIGN aux_cdcritic = 14 /* Opcao errada. */
                   aux_dscritic = "".
            LEAVE Grava.
        END.

        IF par_cddopcao = "I" THEN 
          UNIX SILENT VALUE("echo " + STRING(TODAY, "99/99/9999") + " " + 
          STRING(TIME,"HH:MM:SS") + "' --> '" + 
          " Operador " + STRING(par_cdoperad)  +
          " incluiu  o convenio: "  + STRING(par_cdconven)  +
          ", cooperativa " + STRING(par_cdcooped) +
          ". >> /usr/coop/" + crapcop.dsdircop + "/log/gt0002.log").
        ELSE
          UNIX SILENT VALUE("echo " + STRING(TODAY, "99/99/9999") + " " + 
          STRING(TIME,"HH:MM:SS") + "' --> '" + 
          " Operador " + STRING(par_cdoperad)  +
          " excluiu  o convenio: "  +  STRING(par_cdconven)  +
          ", cooperativa " + STRING(par_cdcooped) +
          ". >> /usr/coop/" + crapcop.dsdircop + "/log/gt0002.log").

        LEAVE Grava.

    END. /* Grava */

    RELEASE gncvcop.

    IF  aux_dscritic <> "" OR 
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
            
            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Dados */
