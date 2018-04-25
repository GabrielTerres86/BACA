/*.............................................................................

   Programa: xb1wgen0135.p
   Autor   : Fabricio
   Data    : Fevereiro/2012                     Ultima atualizacao: 10/04/2018

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO - Tela TRAESP.

   Alteracoes: 08/03/2018 - Alterado tipo do parametro docmto de INT para DECIMAL
                            Chamado 851313 (Antonio R JR)
............................................................................ */

DEF VAR aux_cdcooper AS INTE NO-UNDO.
DEF VAR aux_cdagenci AS INTE NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE NO-UNDO.
DEF VAR aux_cdoperad AS CHAR NO-UNDO.
DEF VAR aux_nrdconta AS INTE NO-UNDO.
DEF VAR aux_dttransa AS DATE NO-UNDO.
DEF VAR aux_cdbccxlt AS INTE NO-UNDO.
DEF VAR aux_nrdolote AS INTE NO-UNDO.
DEF VAR aux_nrdocmto AS DECIMAL NO-UNDO.
DEF VAR aux_nmrescop AS CHAR NO-UNDO.
DEF VAR aux_cdopecxa AS INTE NO-UNDO.
DEF VAR aux_tpdocmto AS INTE NO-UNDO.
DEF VAR aux_nrseqaut AS INTE NO-UNDO.
DEF VAR aux_nrdctabb AS INTE NO-UNDO.
DEF VAR aux_tpoperac AS INTE NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR NO-UNDO.
DEF VAR aux_contador AS INTE NO-UNDO.
DEF VAR aux_nriniseq AS INTE NO-UNDO.
DEF VAR aux_nrregist AS INTE NO-UNDO.
DEF VAR aux_identifi AS INTE NO-UNDO.
DEF VAR aux_infocoaf AS LOGI NO-UNDO.
DEF VAR aux_justific AS CHAR NO-UNDO.
DEF VAR aux_idorigem AS INTE NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0135tt.i }


/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    DEF VAR aux_rowidapp AS ROWID NO-UNDO.

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper"  THEN aux_cdcooper =  INTE(tt-param.valorCampo).
            WHEN "cdagenci"  THEN aux_cdagenci =  INTE(tt-param.valorCampo).
            WHEN "nrdcaixa"  THEN aux_nrdcaixa =  INTE(tt-param.valorCampo).
            WHEN "cdoperad"  THEN aux_cdoperad =  tt-param.valorCampo.
            WHEN "nrdconta"  THEN aux_nrdconta =  INTE(tt-param.valorCampo).
            WHEN "dttransa"  THEN aux_dttransa =  DATE(tt-param.valorCampo).
            WHEN "dtmvtolt"  THEN aux_dtmvtolt =  DATE(tt-param.valorCampo).
            WHEN "cdbccxlt"  THEN aux_cdbccxlt =  INTE(tt-param.valorCampo).
            WHEN "nrdolote"  THEN aux_nrdolote =  INTE(tt-param.valorCampo).
            WHEN "nrdocmto"  THEN aux_nrdocmto =  INTE(tt-param.valorCampo).
            WHEN "nmrescop"  THEN aux_nmrescop =  tt-param.valorCampo.
            WHEN "cdopecxa"  THEN aux_cdopecxa =  INTE(tt-param.valorCampo).
            WHEN "tpdocmto"  THEN aux_tpdocmto =  DECIMAL(tt-param.valorCampo).
            WHEN "nrseqaut"  THEN aux_nrseqaut =  INTE(tt-param.valorCampo).
            WHEN "nrdctabb"  THEN aux_nrdctabb =  INTE(tt-param.valorCampo).
            WHEN "tpoperac"  THEN aux_tpoperac =  INTE(tt-param.valorCampo).
            WHEN "nriniseq"  THEN aux_nriniseq =  INTE(tt-param.valorCampo).
            WHEN "nrregist"  THEN aux_nrregist =  INTE(tt-param.valorCampo).
            WHEN "identifi"  THEN aux_identifi =  INTE(tt-param.valorCampo).
            WHEN "infocoaf"  THEN aux_infocoaf =  LOGICAL(tt-param.valorCampo).
            WHEN "justific"  THEN aux_justific =  tt-param.valorCampo.
            WHEN "idorigem"  THEN aux_idorigem = INTE(tt-param.valorCampo).
        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "Fechamento" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-crapcme.
                       ASSIGN aux_rowidapp = ROWID(tt-crapcme).
                    END.

                FIND tt-crapcme WHERE ROWID(tt-crapcme) = aux_rowidapp
                                      NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "cdcooper" THEN
                        tt-crapcme.cdcooper = INTE(tt-param-i.valorCampo).
                    WHEN "cdagenci" THEN
                        tt-crapcme.cdagenci = INTE(tt-param-i.valorCampo).
                    WHEN "nrdconta" THEN
                        tt-crapcme.nrdconta = INTE(tt-param-i.valorCampo).
                    WHEN "dtmvtolt" THEN
                        tt-crapcme.dtmvtolt = DATE(tt-param-i.valorCampo).
                    WHEN "nrdocmto" THEN
                        tt-crapcme.nrdocmto = DECI(tt-param-i.valorCampo).
                END CASE.
            END.
        END CASE.
    END.

END PROCEDURE.

PROCEDURE consulta-transacoes-especie:

    RUN consulta-transacoes-especie IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_nrdconta,
                                            INPUT aux_dttransa,
                                            INPUT aux_nriniseq,
                                            INPUT aux_nrregist,
                                           OUTPUT aux_contador,
                                           OUTPUT TABLE tt-transacoes-especie,
                                           OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel realizar a " +
                                              "consulta.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.

    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-transacoes-especie:HANDLE,
                         INPUT "DADOS").
        RUN piXmlAtributo (INPUT "nrtotreg", INPUT aux_contador).
        RUN piXmlSave.
    END.


END PROCEDURE.

PROCEDURE consulta-transacoes-sem-documento:

    RUN consulta-transacoes-sem-documento IN hBO (INPUT aux_cdcooper,
                                                  INPUT aux_cdagenci,
                                                  INPUT aux_nrdcaixa,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_nriniseq,
                                                  INPUT aux_nrregist,
                                                 OUTPUT aux_contador,
                                            OUTPUT TABLE tt-transacoes-especie,
                                            OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel realizar a consulta.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-transacoes-especie:HANDLE, 
                         INPUT "DADOS").
        RUN piXmlAtributo (INPUT "nrtotreg", INPUT aux_contador).
        RUN piXmlSave.
    END.

END PROCEDURE.

PROCEDURE consulta-controle-movimentacao:

    RUN consulta-controle-movimentacao IN hBO (INPUT aux_cdcooper,
                                               INPUT aux_cdagenci,
                                               INPUT aux_nrdcaixa,
                                               INPUT aux_dttransa,
                                               INPUT aux_cdbccxlt,
                                               INPUT aux_nrdolote,
                                               INPUT aux_nrdocmto,
                                               INPUT aux_nrdconta,
                                            OUTPUT TABLE tt-transacoes-especie,
                                            OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel realizar a consulta.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-transacoes-especie:HANDLE, 
                         INPUT "DADOS").
        RUN piXmlSave.
    END.

END PROCEDURE.

PROCEDURE reimprime-controle-movimentacao:

    RUN reimprime-controle-movimentacao IN hBO (INPUT aux_cdcooper,
                                                INPUT aux_nmrescop,
                                                INPUT aux_cdagenci,
                                                INPUT aux_nrdcaixa,
                                                INPUT aux_cdopecxa,
                                                INPUT aux_dttransa,
                                                INPUT aux_cdbccxlt,
                                                INPUT aux_nrdolote,
                                                INPUT aux_nrdocmto,
                                                INPUT aux_tpdocmto,
                                                INPUT aux_nrseqaut,
                                                INPUT aux_nrdctabb,
                                                INPUT aux_tpoperac,
                                                INPUT aux_idorigem,
                                               OUTPUT aux_nmarqimp,
                                               OUTPUT aux_nmarqpdf,
                                               OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel realizar a impressao.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
        RUN piXmlSave.
    END.

END PROCEDURE.

PROCEDURE imprime-listagem-transacoes:

    RUN imprime-listagem-transacoes IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_idorigem,
                                           OUTPUT aux_nmarqimp,
                                           OUTPUT aux_nmarqpdf,
                                           OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel realizar a impressao.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
        RUN piXmlSave.
    END.

END PROCEDURE.

PROCEDURE consulta-dados-fechamento:

    RUN consulta-dados-fechamento IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                         OUTPUT aux_contador,
                                         OUTPUT TABLE tt-crapcme,
                                         OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel realizar a consulta.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-crapcme:HANDLE, 
                         INPUT "Dados").
        RUN piXmlAtributo (INPUT "nrtotreg", INPUT aux_contador).
        RUN piXmlSave.
    END.


END PROCEDURE.

PROCEDURE efetua-confirmacao-sisbacen:

    RUN efetua-confirmacao-sisbacen IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_identifi,
                                            INPUT aux_infocoaf,
                                            INPUT aux_justific,
                                            INPUT TABLE tt-crapcme,
                                           OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel realizar o fechamento.".
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

END PROCEDURE.
