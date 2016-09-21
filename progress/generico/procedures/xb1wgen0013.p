/*..............................................................................

   Programa: xb1wgen0013.p
   Autor   : Guilherme / SUPERO
   Data    : Marco/2013                   Ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO013 (b1wgen0013.p) [BLQRGT]

   Alteracoes: 

..............................................................................*/

DEF VAR par_cdcooper AS INTE                                       NO-UNDO.
DEF VAR aux_cdcooper AS INTE                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                       NO-UNDO.
DEF VAR aux_cdfiltro AS INTE                                       NO-UNDO.
DEF VAR aux_nrregist AS INTE                                       NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                       NO-UNDO.
DEF VAR aux_qtregist AS INTE                                       NO-UNDO.


DEF VAR aux_dtiniper AS DATE                                       NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                       NO-UNDO.

DEF VAR aux_dsdatela AS CHAR                                       NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.


{ sistema/generico/includes/b1wgen0013tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }

/* .........................PROCEDURES................................... */

/**************************************************************************
       Procedure para atribuicao dos dados de entrada enviados por XML
**************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param NO-LOCK:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdcopsel" THEN par_cdcooper = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtiniper" THEN aux_dtiniper = DATE(tt-param.valorCampo).
            WHEN "dtfimper" THEN aux_dtfimper = DATE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "dsdatela" THEN aux_dsdatela = tt-param.valorCampo.
            WHEN "cdfiltro" THEN aux_cdfiltro = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.




/********* LISTA COOPERATIVAS *********/
PROCEDURE consulta-cooperativas:

    RUN consulta-cooperativas IN hBO(
                                OUTPUT TABLE tt-cooper,
                                OUTPUT TABLE tt-erro).


    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-cooper:HANDLE,
                             INPUT "CRAPCOP").
            RUN piXmlSave.
        END.

END PROCEDURE.



/********** REGISTRA LOG DE ACESSO  *********/
PROCEDURE registra-log-acesso-telas:

    RUN registra-log-acesso-telas IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_dsdatela,
                                          INPUT aux_idorigem,
                                          INPUT aux_cdoperad,
                                          INPUT aux_dtmvtolt,
                                         OUTPUT TABLE tt-erro).
    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel salvar o registro.".
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


/********* CONSULTA NUNCA ACESSADAS *********/
PROCEDURE consulta-nunca-acessados:

    RUN consulta-nunca-acessados IN hBO (INPUT par_cdcooper,
                                         INPUT aux_idorigem,
                                         INPUT aux_dtiniper,
                                         INPUT aux_dtfimper,
                                         INPUT aux_nriniseq,
                                         INPUT aux_nrregist,
                                        OUTPUT aux_qtregist,
                                        OUTPUT TABLE tt-resultados,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-resultados:HANDLE,
                            INPUT "Resultados").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlSave.
        END.


END PROCEDURE.


/********* CONSULTA ACESSADAS *********/
PROCEDURE consulta-acessadas:

    RUN consulta-acessadas IN hBO (INPUT par_cdcooper,
                                   INPUT aux_dsdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_dtiniper,
                                   INPUT aux_dtfimper,
                                   INPUT aux_nriniseq,
                                   INPUT aux_nrregist,
                                  OUTPUT aux_qtregist,
                                  OUTPUT TABLE tt-resultados,
                                  OUTPUT TABLE tt-detalhes,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-resultados:HANDLE,
                            INPUT "Resultados").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlSave.
        END.

END PROCEDURE.


/********* CONSULTA NAO ACESSADAS *********/
PROCEDURE consulta-nao-acessadas:

    RUN consulta-nao-acessadas IN hBO (INPUT par_cdcooper,
                                       INPUT aux_dsdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_dtiniper,
                                       INPUT aux_dtfimper,
                                       INPUT aux_nriniseq,
                                       INPUT aux_nrregist,
                                      OUTPUT aux_qtregist,
                                      OUTPUT TABLE tt-resultados,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-resultados:HANDLE,
                            INPUT "Resultados").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlSave.
        END.

END PROCEDURE.


/********* EXIBE DETALHES  *********/
PROCEDURE exibe-detalhes:

    RUN exibe-detalhes IN hBO (INPUT par_cdcooper,
                               INPUT aux_dsdatela,
                               INPUT aux_idorigem,
                               INPUT aux_dtiniper,
                               INPUT aux_dtfimper,
                               INPUT aux_nriniseq,
                               INPUT aux_nrregist,
                              OUTPUT aux_qtregist,
                              OUTPUT TABLE tt-detalhe-pesquisa,
                              OUTPUT TABLE tt-detalhes,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-detalhe-pesquisa:HANDLE,
                            INPUT "Detalhes").
           RUN piXmlAtributo (INPUT "qtregdet",INPUT STRING(aux_qtregist)).
           RUN piXmlSave.
        END.

END PROCEDURE.


