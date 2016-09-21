/*.............................................................................

    Programa: xb1wgen0056.p
    Autor   : Jose Luis
    Data    : Marco/2010                   Ultima atualizacao: 22/09/2010

    Objetivo  : BO de Comunicacao XML x BO de Contas Bens (b1wgen0056.p)

    Alteracoes: 22/09/2010 -  Recebe parametro no busca_dados e passa
                             no XML. (Gabriel - DB1).
   
.............................................................................*/

                                                                             

/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_dsrelbem AS CHAR                                           NO-UNDO.
DEF VAR aux_persemon AS DECI                                           NO-UNDO.
DEF VAR aux_qtprebem AS DECI                                           NO-UNDO.
DEF VAR aux_vlprebem AS DECI                                           NO-UNDO.
DEF VAR aux_vlrdobem AS DECI                                           NO-UNDO.
DEF VAR aux_idseqbem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dtaltbem AS DATE                                           NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                           NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0056tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }

/*...........................................................................*/
PROCEDURE valores_entrada:

    FOR EACH tt-param:
    
        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "dsrelbem" THEN aux_dsrelbem = STRING(tt-param.valorCampo).
            WHEN "persemon" THEN aux_persemon = DECI(tt-param.valorCampo).
            WHEN "qtprebem" THEN aux_qtprebem = DECI(tt-param.valorCampo).
            WHEN "vlprebem" THEN aux_vlprebem = DECI(tt-param.valorCampo).
            WHEN "vlrdobem" THEN aux_vlrdobem = DECI(tt-param.valorCampo).
            WHEN "idseqbem" THEN aux_idseqbem = INTE(tt-param.valorCampo).
            WHEN "dtaltbem" THEN aux_dtaltbem = DATE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    

PROCEDURE busca-dados:

    RUN Busca-Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nrdconta,
                            INPUT aux_idorigem,
                            INPUT aux_nmdatela,
                            INPUT aux_idseqttl,
                            INPUT YES,
                            INPUT aux_idseqbem,
                            INPUT aux_cddopcao,
                            INPUT aux_nrdrowid,
                          OUTPUT aux_msgconta,
                          OUTPUT TABLE tt-crapbem,
                          OUTPUT TABLE tt-erro )  NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao." .
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapbem:HANDLE,
                             INPUT "Bens").
             /*Alterção: Passo atributo para web*/
            RUN piXmlAtributo (INPUT "msgconta", INPUT aux_msgconta).
            RUN piXmlSave.
        END.

END.

PROCEDURE valida-dados:

    RUN Valida-Dados IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_nrdconta,
                             INPUT aux_idorigem,
                             INPUT aux_nmdatela,
                             INPUT aux_idseqttl,
                             INPUT aux_cdoperad,
                             INPUT aux_cddopcao,
                             INPUT aux_dsrelbem,
                             INPUT aux_persemon,
                             INPUT aux_qtprebem,
                             INPUT aux_vlprebem,
                             INPUT aux_vlrdobem,
                             INPUT aux_idseqbem,
                            OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlSave.
        END.

END.

PROCEDURE altera-registro:

    RUN altera-registro IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT YES,
                                INPUT aux_nrdrowid,
                                INPUT aux_dsrelbem,
                                INPUT aux_dtmvtolt,
                                INPUT aux_dtmvtolt,
                                INPUT aux_cddopcao,
                                INPUT aux_persemon,
                                INPUT aux_qtprebem,
                                INPUT aux_vlprebem,
                                INPUT aux_vlrdobem,
                                INPUT aux_idseqbem,
                               OUTPUT aux_msgalert,
                               OUTPUT aux_tpatlcad,
                               OUTPUT aux_msgatcad,
                               OUTPUT aux_chavealt,
                               OUTPUT aux_msgrvcad,
                               OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "msgalert", INPUT TRIM(aux_msgalert)).
           RUN piXmlAtributo (INPUT "msgrvcad", INPUT TRIM(aux_msgrvcad)).
           RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
           RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
           RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
           RUN piXmlSave.
        END.

END.

PROCEDURE inclui-registro:

    RUN inclui-registro IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT YES,         
                                INPUT aux_dsrelbem,
                                INPUT aux_dtaltbem,
                                INPUT aux_dtmvtolt,
                                INPUT aux_cddopcao,
                                INPUT aux_persemon,
                                INPUT aux_qtprebem,
                                INPUT aux_vlprebem,
                                INPUT aux_vlrdobem,
                               OUTPUT aux_msgalert,
                               OUTPUT aux_tpatlcad,
                               OUTPUT aux_msgatcad,
                               OUTPUT aux_chavealt,
                               OUTPUT aux_msgrvcad,
                               OUTPUT TABLE tt-erro) NO-ERROR.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "msgalert", INPUT TRIM(aux_msgalert)).
           RUN piXmlAtributo (INPUT "msgrvcad", INPUT TRIM(aux_msgrvcad)).
           RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
           RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
           RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
           RUN piXmlSave.
        END.

END.

PROCEDURE exclui-registro:

    RUN exclui-registro IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT aux_nrdrowid,
                                INPUT aux_idseqbem,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT YES,
                                INPUT aux_dtmvtolt,
                                INPUT "E",
                               OUTPUT aux_msgalert,
                               OUTPUT aux_tpatlcad,
                               OUTPUT aux_msgatcad,
                               OUTPUT aux_chavealt,
                               OUTPUT aux_msgrvcad,
                               OUTPUT TABLE tt-erro) NO-ERROR.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "msgalert", INPUT TRIM(aux_msgalert)).
           RUN piXmlAtributo (INPUT "msgrvcad", INPUT TRIM(aux_msgrvcad)).
           RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
           RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
           RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
           RUN piXmlSave.
        END.
END.

