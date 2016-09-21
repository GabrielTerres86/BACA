/*..............................................................................

   Programa: xb1wgen0169.p
   Autor   : Jorge I. Hamaguchi
   Data    : Agosto/2013                 Ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO169 (b1wgen0169.p) [CADRET]

   Alteracoes: 

..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                       NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                       NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                       NO-UNDO.
DEF VAR aux_nrtabela AS INTE                                       NO-UNDO.
DEF VAR aux_cdretorn AS INTE                                       NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                       NO-UNDO.
DEF VAR aux_cdoperac AS CHAR                                       NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                       NO-UNDO.
DEF VAR aux_dsretorn AS CHAR                                       NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0169tt.i }

/* .........................PROCEDURES................................... */

/**************************************************************************
       Procedure para atribuicao dos dados de entrada enviados por XML
**************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param NO-LOCK:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "nmdcampo" THEN aux_nmdcampo = tt-param.valorCampo.
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "cdoperac" THEN aux_cdoperac = tt-param.valorCampo.
            WHEN "nrtabela" THEN aux_nrtabela = INTE(tt-param.valorCampo).
            WHEN "cdretorn" THEN aux_cdretorn = INTE(tt-param.valorCampo).
            WHEN "dsretorn" THEN aux_dsretorn = tt-param.valorCampo.
               
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.



/*****************************************************************************
  Consulta de retorno      
******************************************************************************/
PROCEDURE consultar_cadret:
    
    RUN consultar_cadret IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_cddopcao,
                                 INPUT aux_cdoperac,
                                 INPUT aux_nrtabela,
                                 INPUT aux_cdretorn,
                                OUTPUT aux_nmdcampo,
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-cadret).
    
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlSaida (INPUT TEMP-TABLE tt-cadret:HANDLE,
                            INPUT "cadret").
        END.

END PROCEDURE.

/*****************************************************************************
  Incluir cadastro de retorno      
******************************************************************************/
PROCEDURE incluir_cadret:
    
    RUN incluir_cadret IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_dtmvtolt,
                               INPUT aux_cddopcao,
                               INPUT aux_cdoperac,
                               INPUT aux_nrtabela,
                               INPUT aux_cdretorn,
                               INPUT aux_dsretorn,
                              OUTPUT aux_nmdcampo,
                              OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdreturn", INPUT "OK").
            RUN piXmlSave.
        END.

END PROCEDURE.


/*****************************************************************************
  Alterar cadastro de retorno      
******************************************************************************/
PROCEDURE alterar_cadret:
    
    RUN alterar_cadret IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_dtmvtolt,
                               INPUT aux_cddopcao,
                               INPUT aux_cdoperac,
                               INPUT aux_nrtabela,
                               INPUT aux_cdretorn,
                               INPUT aux_dsretorn,
                              OUTPUT aux_nmdcampo,
                              OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdreturn", INPUT "OK").
            RUN piXmlSave.
        END.

END PROCEDURE.

