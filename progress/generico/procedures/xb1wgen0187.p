
/*.............................................................................

   Programa: xb1wgen0187.p
   Autor   : Jorge I. Hamaguchi
   Data    : Março/2014                      Ultima atualizacao: //

   Dados referentes ao programa:

   Objetivo  : BO DE PROCEDURES REF. A TELA DEVDOC.
   
   Alteracoes :
   
.............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cdmotdev AS INTE                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_nrdocmto AS DECI                                           NO-UNDO.
DEF VAR aux_dtmvtodc AS DATE                                           NO-UNDO.
DEF VAR aux_vldocmto AS DECI                                           NO-UNDO.
DEF VAR aux_cdbandoc AS INTE                                           NO-UNDO.
DEF VAR aux_cdagedoc AS INTE                                           NO-UNDO.
DEF VAR aux_nrctadoc AS DECI                                           NO-UNDO.
DEF VAR aux_documtos AS CHAR                                           NO-UNDO.


{ sistema/generico/includes/b1wgen0187tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i }

/*****************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML    **/
/*****************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).    
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nrdocmto" THEN aux_nrdocmto = DECI(tt-param.valorCampo).
            WHEN "dtmvtodc" THEN aux_dtmvtodc = DATE(tt-param.valorCampo).
            WHEN "vldocmto" THEN aux_vldocmto = DECI(tt-param.valorCampo).
            WHEN "cdbandoc" THEN aux_cdbandoc = INTE(tt-param.valorCampo).
            WHEN "cdagedoc" THEN aux_cdagedoc = INTE(tt-param.valorCampo).
            WHEN "nrctadoc" THEN aux_nrctadoc = DECI(tt-param.valorCampo).
            WHEN "cdmotdev" THEN aux_cdmotdev = INTE(tt-param.valorCampo).
            WHEN "documtos" THEN aux_documtos = tt-param.valorCampo.

        END CASE.
    END. /* tt-param */

END.

PROCEDURE busca_crapddc:

    RUN busca_crapddc IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_dtmvtolt,
                              INPUT aux_dtmvtoan,
                              INPUT aux_dtmvtodc,
                              INPUT aux_nrregist,
                              INPUT aux_nriniseq,
                             OUTPUT aux_qtregist,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-crapddc).
                               
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapddc:HANDLE, 
                             INPUT "DADOS").
            RUN piXmlAtributo (INPUT "qtregist", INPUT INTEGER(aux_qtregist)).
            RUN piXmlSave.
        END.

END.

PROCEDURE atualiza_doc:

    RUN atualiza_doc IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_dtmvtolt,
                             INPUT aux_nrdocmto,
                             INPUT aux_dtmvtodc,
                             INPUT aux_vldocmto,
                             INPUT aux_cdbandoc,
                             INPUT aux_cdagedoc,
                             INPUT aux_nrctadoc,
                             INPUT aux_cdmotdev,
                            OUTPUT TABLE tt-erro).
                               
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
            RUN piXmlSave.
        END.

END.

PROCEDURE consulta_doc:
    
    RUN consulta_doc IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_dtmvtolt,
                             INPUT aux_nrdocmto,
                             INPUT aux_dtmvtodc,
                             INPUT aux_vldocmto,
                             INPUT aux_cdbandoc,
                             INPUT aux_cdagedoc,
                             INPUT aux_nrctadoc,
                             INPUT aux_cdmotdev,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-crapddc).
                               
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapddc:HANDLE, 
                             INPUT "DADOS").
            RUN piXmlSave.
        END.

END.

PROCEDURE salva_docs:

    RUN salva_docs IN hBO (INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_cdoperad,
                           INPUT aux_nmdatela,
                           INPUT aux_idorigem,
                           INPUT aux_dtmvtolt,
                           INPUT aux_documtos,
                          OUTPUT TABLE tt-erro).
                               
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
            RUN piXmlSave.
        END.

END.

