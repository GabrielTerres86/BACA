/*.............................................................................

    Programa: xb1wgen0061.p
    Autor   : Jose Luis
    Data    : Marco/2010                   Ultima atualizacao: 00/00/0000   

    Objetivo  : BO de Comunicacao XML x BO - CLIENTE FINANCEIRO

    Alteracoes: 
   
.............................................................................*/

                                                                             

/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_tpregist AS INTE                                           NO-UNDO.
DEF VAR aux_desopcao AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_nrseqdig AS INTE                                           NO-UNDO.
DEF VAR aux_cddbanco AS INTE                                           NO-UNDO.
DEF VAR aux_cdageban AS INTE                                           NO-UNDO.
DEF VAR aux_dtabtcct AS DATE                                           NO-UNDO.
DEF VAR aux_nrdctasf AS INTE                                           NO-UNDO.
DEF VAR aux_dgdconta AS CHAR                                           NO-UNDO.
DEF VAR aux_nminsfin AS CHAR                                           NO-UNDO.
DEF VAR aux_dtmvtosf AS DATE                                           NO-UNDO.
DEF VAR aux_dtdenvio AS DATE                                           NO-UNDO.
DEF VAR aux_dsdepart AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0061tt.i }

/*............................... PROCEDURES ................................*/
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
            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "tpregist" THEN aux_tpregist = INTE(tt-param.valorCampo).
            WHEN "nrseqdig" THEN aux_nrseqdig = INTE(tt-param.valorCampo).
            WHEN "desopcao" THEN aux_desopcao = INTE(tt-param.valorCampo).
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
            WHEN "cddbanco" THEN aux_cddbanco = INTE(tt-param.valorCampo).
            WHEN "cdageban" THEN aux_cdageban = INTE(tt-param.valorCampo).
            WHEN "dtabtcct" THEN aux_dtabtcct = DATE(tt-param.valorCampo).
            WHEN "nrdctasf" THEN aux_nrdctasf = INTE(tt-param.valorCampo).
            WHEN "dgdconta" THEN aux_dgdconta = tt-param.valorCampo.
            WHEN "nminsfin" THEN aux_nminsfin = tt-param.valorCampo.
            WHEN "dtmvtosf" THEN aux_dtmvtosf = DATE(tt-param.valorCampo).
            WHEN "dtdenvio" THEN aux_dtdenvio = DATE(tt-param.valorCampo).
            WHEN "dsdepart" THEN aux_dsdepart = tt-param.valorCampo.

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    

PROCEDURE busca_dados:

    RUN Busca_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT YES,
                            INPUT aux_cddopcao,
                            INPUT aux_nrdrowid,
                            INPUT aux_dtmvtolt,
                            INPUT aux_tpregist,
                            INPUT aux_nrseqdig,
                            INPUT aux_dsdepart,
                           OUTPUT TABLE tt-dadoscf,
                           OUTPUT TABLE tt-crapsfn,
                           OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).
                END.
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-dadoscf:HANDLE,
                             INPUT "ClienteFinanceiro").
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapsfn:HANDLE,
                             INPUT "SistemaFinanceiro").
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Valida_Dados:

    RUN Valida_Dados IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT YES,
                             INPUT aux_cddopcao,
                             INPUT (IF aux_desopcao = 1 THEN YES ELSE NO),
                             INPUT aux_nrcpfcgc,
                             INPUT aux_tpregist,
                             INPUT aux_nrseqdig,
                             INPUT aux_cddbanco,
                             INPUT aux_cdageban,
                             INPUT aux_dtabtcct,
                             INPUT aux_nrdctasf,
                             INPUT aux_dgdconta,
                             INPUT aux_nminsfin,
                             INPUT aux_dtmvtosf,
                             INPUT aux_dtmvtolt,
                             INPUT aux_dsdepart,
                             INPUT aux_dtdenvio,
                            OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).
                END.
    
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
           RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT TRUE,
                            INPUT aux_cddopcao,
                            INPUT (IF aux_desopcao = 1 THEN YES ELSE NO),
                            INPUT aux_nrcpfcgc,
                            INPUT aux_tpregist,
                            INPUT aux_nrseqdig,
                            INPUT aux_dtmvtolt,
                            INPUT aux_cddbanco,
                            INPUT aux_cdageban,
                            INPUT aux_dtabtcct,
                            INPUT aux_nrdctasf,
                            INPUT aux_dgdconta,
                            INPUT aux_nminsfin,
                           OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

    IF  RETURN-VALUE <> "OK" THEN
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
           RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Exclui_Dados:

    RUN Exclui_Dados IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT YES,
                             INPUT (IF aux_desopcao = 1 THEN YES ELSE NO),
                             INPUT aux_nrcpfcgc,
                             INPUT aux_tpregist,
                             INPUT aux_nrseqdig,
                             INPUT aux_dtmvtolt,
                             INPUT aux_dtmvtosf,
                             INPUT aux_dtdenvio,
                            OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "exclusao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "msgalert", INPUT TRIM(aux_msgalert)).
           RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Busca_Impressao:

    RUN Busca_Impressao IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT YES,
                                INPUT aux_nrcpfcgc,
                                INPUT aux_tpregist,
                                INPUT aux_nrseqdig,
                                INPUT aux_dtmvtolt,
                               OUTPUT TABLE tt-fichacad,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-fichacad:HANDLE,
                             INPUT "FichaCadastral").
            RUN piXmlSave.
        END.

END PROCEDURE.
