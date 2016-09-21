/*..............................................................................

   Programa: xb1wgen0150.p
   Autor   : Lucas Lunelli
   Data    : Fevereiro/2013                 Ultima atualizacao: 16/01/2013

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO150 (b1wgen0150.p) [ADMISS]

   Alteracoes: 16/01/2013 - Alterado modo como era recebido flag flgabcap
                            para gravar corretamente (Tiago).

..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                       NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                       NO-UNDO.             
DEF VAR aux_nrdcaixa AS INTE                                       NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                       NO-UNDO.
DEF VAR aux_nrregist AS INTE                                       NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                       NO-UNDO.
DEF VAR aux_qtregist AS INTE                                       NO-UNDO.
DEF VAR aux_qtassmes AS INTE                                       NO-UNDO.
DEF VAR aux_qtadmmes AS INTE                                       NO-UNDO.
DEF VAR aux_qtdslmes AS INTE                                       NO-UNDO.
DEF VAR aux_nrmatric AS INTE                                       NO-UNDO.
DEF VAR aux_qtparcap AS INTE                                       NO-UNDO.
DEF VAR aux_qtdemmes AS INTE                                       NO-UNDO.
DEF VAR aux_numdopac AS INTE                                       NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                       NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                       NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdocamp AS CHAR                                       NO-UNDO.

DEF VAR aux_dtdecons AS DATE                                       NO-UNDO.
DEF VAR aux_dtatecon AS DATE                                       NO-UNDO.
DEF VAR aux_dtdemiss AS DATE                                       NO-UNDO.

DEF VAR aux_vlcapini AS DECI                                       NO-UNDO.
DEF VAR aux_vlcapsub AS DECI                                       NO-UNDO.

DEF VAR aux_flgerlog AS LOGI                                       NO-UNDO.
DEF VAR aux_flgabcap AS LOGI                                       NO-UNDO.
DEF VAR aux_flgabcch AS CHAR                                       NO-UNDO.

{ sistema/generico/includes/b1wgen0150tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }

/* .........................PROCEDURES................................... */

/**************************************************************************
       Procedure para atribuicao dos dados de entrada enviados por XML
**************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param NO-LOCK:
/*
       MESSAGE  "xbo150 " tt-param.nomeCampo tt-param.valorCampo.
*/
        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).           
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nmdocamp" THEN aux_nmdocamp = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "numdopac" THEN aux_numdopac = INTE(tt-param.valorCampo).
            WHEN "qtregist" THEN aux_qtregist = INTE(tt-param.valorCampo).
            WHEN "qtparcap" THEN aux_qtparcap = INTE(tt-param.valorCampo).
            WHEN "vlcapini" THEN aux_vlcapini = DECI(tt-param.valorCampo).
            WHEN "vlcapsub" THEN aux_vlcapsub = DECI(tt-param.valorCampo).
            WHEN "flgabcap" THEN aux_flgabcch = tt-param.valorCampo.
            WHEN "dtdemiss" THEN aux_dtdemiss = DATE(tt-param.valorCampo).
            WHEN "dtdecons" THEN aux_dtdecons = DATE(tt-param.valorCampo).
            WHEN "dtatecon" THEN aux_dtatecon = DATE(tt-param.valorCampo).
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

/*****************************************************************************
  Consultar dados da tela ADMISS
******************************************************************************/
PROCEDURE consulta-admiss:

    RUN consulta-admiss IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_dtmvtolt,
                                OUTPUT aux_qtassmes,
                                OUTPUT aux_qtadmmes,
                                OUTPUT aux_qtdslmes,
                                OUTPUT aux_vlcapini,
                                OUTPUT aux_nrmatric,
                                OUTPUT aux_qtparcap,
                                OUTPUT aux_vlcapsub,
                                OUTPUT aux_flgabcap,
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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
           RUN piXmlAtributo (INPUT "qtassmes", INPUT aux_qtassmes).
           RUN piXmlAtributo (INPUT "qtadmmes", INPUT aux_qtadmmes).
           RUN piXmlAtributo (INPUT "qtdslmes", INPUT aux_qtdslmes).
           RUN piXmlAtributo (INPUT "vlcapini", INPUT aux_vlcapini).
           RUN piXmlAtributo (INPUT "nrmatric", INPUT aux_nrmatric).
           RUN piXmlAtributo (INPUT "qtparcap", INPUT aux_qtparcap).
           RUN piXmlAtributo (INPUT "vlcapsub", INPUT aux_vlcapsub).
           RUN piXmlAtributo (INPUT "flgabcap", INPUT aux_flgabcap).
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Realizar as alterações de dados da tela ADMISS
******************************************************************************/
PROCEDURE altera-admiss:

    IF  aux_flgabcch = "NO" THEN
        ASSIGN aux_flgabcap = FALSE.
    ELSE
        ASSIGN aux_flgabcap = TRUE.

    RUN altera-admiss IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_dtmvtolt,
                              INPUT aux_flgerlog,
                              INPUT aux_vlcapini,
                              INPUT aux_vlcapsub,
                              INPUT aux_qtparcap,
                              INPUT aux_flgabcap,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Lista admissões de um PAC na tela ADMISS
******************************************************************************/
PROCEDURE lista-admiss-pac:

    RUN lista-admiss-pac IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_numdopac,
                                 INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist), 
                                 INPUT aux_nriniseq, 
                                 OUTPUT aux_qtregist, 
                                 OUTPUT aux_qtadmmes,
                                 OUTPUT TABLE tt-admiss,
                                 OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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
           RUN piXmlExport  (INPUT TEMP-TABLE tt-admiss:HANDLE,
                             INPUT "Admissoes").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlAtributo (INPUT "qtadmmes",INPUT STRING(aux_qtadmmes)).
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Lista demissões de um PAC na tela ADMISS
******************************************************************************/
PROCEDURE lista-demiss-pac:

    RUN lista-demiss-pac IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_numdopac,
                                 INPUT aux_dtdemiss,
                                 INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist), 
                                 INPUT aux_nriniseq, 
                                 OUTPUT aux_qtregist, 
                                 OUTPUT aux_qtdemmes,
                                 OUTPUT TABLE tt-demiss,
                                 OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-demiss:HANDLE,
                             INPUT "Demissoes").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlAtributo (INPUT "qtdemmes",INPUT STRING(aux_qtdemmes)).
           RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************
  Rotina de impressão da tela ADMISS      
******************************************************************************/
PROCEDURE impressao-admiss:

    RUN impressao-admiss IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_dsiduser,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_idorigem,
                                 INPUT aux_numdopac,
                                 INPUT aux_dtdecons,
                                 INPUT aux_dtatecon, 
                                 OUTPUT aux_nmarqimp, 
                                 OUTPUT aux_nmarqpdf,
                                 OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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
           RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
           RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
           RUN piXmlSave.
        END.

END PROCEDURE.
