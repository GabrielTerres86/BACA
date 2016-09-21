/*.............................................................................

    Programa: sistema/generico/procedures/Xb1wgen0174.p 
    Autor   : Oliver Fagionato (GATI)
    Data    : Setembro/2013                     Ultima alteracao: 24/11/2014

    Objetivo  : BO de Comunicacao XML x BO 
                Tela CLDMES
                Consultar e realizar fechamento de movimenta‡äes de credito.

    Alteracoes: 24/11/2014 - Ajustes para liberacao (Adriano).
               
.............................................................................*/
DEFINE VARIABLE aux_nmarqpdf AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_cdcooper AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_nrdcaixa AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_cdoperad AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_idorigem AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_cdagenci AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_nmdatela AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_nrdconta AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_cdprogra AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_tdtmvtol AS DATE                                NO-UNDO.
DEFINE VARIABLE aux_nmarqimp AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_nmresage AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_nrregist AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_nriniseq AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_qtregist AS INTE                                NO-UNDO.
DEFINE VARIABLE aux_cdbccxlt AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_cdagepac AS INTEGER                             NO-UNDO.
                                                                    
DEFINE VARIABLE par_dscritic AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE par_nmarqimp AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE par_nmarquiv AS CHARACTER                           NO-UNDO.

/*............................. DEFINICOES ..................................*/

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0174tt.i }

/*............................... PROCEDURES ................................*/
PROCEDURE valores_entrada:
    FOR EACH tt-param:
        CASE tt-param.nomeCampo:
            WHEN "cdcooper"    THEN aux_cdcooper    = INT(tt-param.valorCampo).
            WHEN "cdagenci"    THEN aux_cdagenci    = INT(tt-param.valorCampo).
            WHEN 'nrdcaixa'    THEN aux_nrdcaixa    = INT(tt-param.valorCampo).
            WHEN "cdoperad"    THEN aux_cdoperad    = tt-param.valorCampo.
            WHEN "dtmvtolt"    THEN aux_dtmvtolt    = DATE(tt-param.valorCampo).
            WHEN "idorigem"    THEN aux_idorigem    = INT(tt-param.valorCampo).
            WHEN "nmdatela"    THEN aux_nmdatela    = tt-param.valorCampo.
            WHEN "cdprogra"    THEN aux_cdprogra    = tt-param.valorCampo.
            WHEN 'tdtmvtol'    THEN aux_tdtmvtol    = DATE(tt-param.valorCampo).
            WHEN "nrdconta"    THEN aux_nrdconta    = INT(tt-param.valorCampo).
            WHEN "nmresage"    THEN aux_nmresage    = tt-param.valorCampo.
            WHEN "nrregist"    THEN aux_nrregist    = INT(tt-param.valorCampo).
            WHEN "nriniseq"    THEN aux_nriniseq    = INT(tt-param.valorCampo).
            WHEN "qtregist"    THEN aux_qtregist    = INT(tt-param.valorCampo).
            WHEN "cdbccxlt"    THEN aux_cdbccxlt    = INT(tt-param.valorCampo).
            WHEN "cdagepac"    THEN aux_cdagepac    = INT(tt-param.valorCampo).
        END CASE.
    END. /* FOR EACH tt-param */
END PROCEDURE. /* valores_entrada */

PROCEDURE Fechamento_diario:

    RUN Fechamento_diario IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT aux_cdprogra,
                                  INPUT aux_tdtmvtol,
                                  OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
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
END PROCEDURE.

PROCEDURE Carrega_creditos:

    RUN Carrega_creditos IN hBO(INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_dtmvtolt,
                                INPUT aux_idorigem,
                                INPUT aux_nmdatela,
                                INPUT aux_cdprogra,
                                INPUT aux_cdagepac,
                                INPUT aux_tdtmvtol,
                                INPUT aux_nrregist,
                                INPUT aux_nriniseq,
                                OUTPUT aux_qtregist,
                                OUTPUT TABLE tt-creditos,
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-creditos:HANDLE,
                             INPUT "creditos").
            RUN piXmlAtributo(INPUT "qtregist", INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE gera_relatorio_diario:

    RUN gera_relatorio_diario IN hBO(INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_idorigem,
                                     INPUT aux_nmdatela,
                                     INPUT aux_cdprogra,
                                     INPUT aux_nrdconta,
                                     INPUT aux_tdtmvtol,
                                     OUTPUT aux_nmarqimp,
                                     OUTPUT aux_nmarqpdf,
                                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
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
            RUN piXmlAtributo(INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo(INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

