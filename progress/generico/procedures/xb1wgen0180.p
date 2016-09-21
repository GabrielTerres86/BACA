/*.............................................................................

   Programa: xb1wgen0180.p
   Autor   : Lucas R.
   Data    : Novembro/2013                      Ultima atualizacao: //

   Dados referentes ao programa:

   Objetivo  : BO DE PROCEDURES REF. A TELA CONCAP.
   
   Alteracoes :
   
.............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.
DEF VAR aux_opcaoimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.

DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_vltotapl AS DEC                                            NO-UNDO.
DEF VAR aux_vltotrgt AS DEC                                            NO-UNDO.
DEF VAR aux_vlcapliq AS DEC                                            NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0180tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i }

/*****************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML    **/
/*****************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "opcaoimp" THEN aux_opcaoimp = tt-param.valorCampo.
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nmendter" THEN aux_nmendter = tt-param.valorCampo.

        END CASE.
    END. /* tt-param */

END.

PROCEDURE consulta-captacao:

    RUN consulta-captacao IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_cdagenci,
                                  INPUT aux_opcaoimp,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_cdprogra,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrregist,
                                  INPUT aux_nriniseq,
                                 OUTPUT aux_qtregist,
                                 OUTPUT aux_vltotrgt,
                                 OUTPUT aux_vltotapl,
                                 OUTPUT aux_vlcapliq,
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-captacao).
                               
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel consultar os " +
                                              "registros.".
                END.
    
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-captacao:HANDLE, 
                             INPUT "DADOS").
            RUN piXmlAtributo (INPUT "qtregist", INPUT INTEGER(aux_qtregist)).
            RUN piXmlAtributo (INPUT "vltotrgt", INPUT DECIMAL(aux_vltotrgt)).
            RUN piXmlAtributo (INPUT "vltotapl", INPUT DECIMAL(aux_vltotapl)).
            RUN piXmlAtributo (INPUT "vlcapliq", INPUT DECIMAL(aux_vlcapliq)).
            RUN piXmlSave.
        END.

END.

PROCEDURE imprime-captacao:

    RUN imprime-captacao IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_cdagenci,
                                 INPUT aux_opcaoimp,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_cdprogra,
                                 INPUT aux_idorigem,
                                 INPUT aux_nmendter,
                                OUTPUT aux_nmarqimp,
                                OUTPUT aux_nmarqpdf,
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "impressao dos dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
           RUN piXmlSave.
        END.

END.
