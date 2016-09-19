/*.............................................................................

    Programa: xb1wgen0062.p
    Autor   : Jose Luis
    Data    : Marco/2010                   Ultima atualizacao: 25/11/2014

    Objetivo  : BO de Comunicacao XML x BO - IMPRESSAO FICHA CADASTRAL

    Alteracoes: 
                03/07/2013 - Inclusao da tabela tt-fcad-poder no retorno
                             Busca_Impressao (Jean Michel).
                             
                25/11/2014 - Remoção do Endividamento e dos Bens dos representantes
                             por caracterizar quebra de sigilo bancário 
                             (Douglas - Chamado 194831)
                             
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
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0062tt.i }

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

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

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
                                INPUT aux_dtmvtolt,
                               OUTPUT TABLE tt-fcad,
                               OUTPUT TABLE tt-fcad-telef,
                               OUTPUT TABLE tt-fcad-email,
                               OUTPUT TABLE tt-fcad-psfis,
                               OUTPUT TABLE tt-fcad-filia,
                               OUTPUT TABLE tt-fcad-comer,
                               OUTPUT TABLE tt-fcad-cbens,
                               OUTPUT TABLE tt-fcad-depen,
                               OUTPUT TABLE tt-fcad-ctato,
                               OUTPUT TABLE tt-fcad-respl,
                               OUTPUT TABLE tt-fcad-cjuge,
                               OUTPUT TABLE tt-fcad-psjur,
                               OUTPUT TABLE tt-fcad-regis,
                               OUTPUT TABLE tt-fcad-procu,
                               /*OUTPUT TABLE tt-fcad-bensp,*/
                               OUTPUT TABLE tt-fcad-refer,
                               OUTPUT TABLE tt-fcad-poder,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad:HANDLE,
                             INPUT "FCad").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-telef:HANDLE,
                             INPUT "FCadTelefone").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-email:HANDLE,
                             INPUT "FCadEmail").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-psfis:HANDLE,
                             INPUT "FCadIdenticacaoPF").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-filia:HANDLE,
                             INPUT "FCadFiliacao").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-comer:HANDLE,
                             INPUT "FCadComercial").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-cbens:HANDLE,
                             INPUT "FCadBens").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-depen:HANDLE,
                             INPUT "FCadDependentes").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-ctato:HANDLE,
                             INPUT "FCadContatos").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-respl:HANDLE,
                             INPUT "FCadRespLegal").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-cjuge:HANDLE,
                             INPUT "FCadConjuge").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-psjur:HANDLE,
                             INPUT "FCadIdenticacaoPJ").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-regis:HANDLE,
                             INPUT "FCadRegistro").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-procu:HANDLE,
                             INPUT "FCadProcuradores").
            /*RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-bensp:HANDLE,
                             INPUT "FCadBensProcurad").*/
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-refer:HANDLE,
                             INPUT "FCadReferencias").
            RUN piXmlExport (INPUT TEMP-TABLE tt-fcad-poder:HANDLE,
                             INPUT "FCadPoderes").
            RUN piXmlSave.
        END.

END PROCEDURE.

