/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0094.p
    Autor   : Gabriel Capoia dos Santos
    Data    : Junho/2011                       Ultima atualizacao: 00/00/0000

    Objetivo  : BO de Comunicacao XML x BO - Tela MANTAL

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
DEF VAR aux_cdbanchq AS INTE                                           NO-UNDO.
DEF VAR aux_cdagechq AS INTE                                           NO-UNDO.
DEF VAR aux_nrctachq AS INTE                                           NO-UNDO.
DEF VAR aux_nrinichq AS INTE                                           NO-UNDO.
DEF VAR aux_nrfimchq AS INTE                                           NO-UNDO.
DEF VAR aux_nriniche AS INTE                                           NO-UNDO.
DEF VAR aux_nrfimche AS INTE                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_nmoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.


{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0094tt.i } 
                    
/*............................... PROCEDURES ................................*/
PROCEDURE valores_entrada:

    DEFINE VARIABLE aux_rowidaux AS ROWID       NO-UNDO.

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nmoperad" THEN aux_nmoperad = tt-param.valorCampo.
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "cdbanchq" THEN aux_cdbanchq = INTE(tt-param.valorCampo).
            WHEN "cdagechq" THEN aux_cdagechq = INTE(tt-param.valorCampo).
            WHEN "nrctachq" THEN aux_nrctachq = INTE(tt-param.valorCampo).
            WHEN "nrinichq" THEN aux_nrinichq = INTE(tt-param.valorCampo).
            WHEN "nrfimchq" THEN aux_nrfimchq = INTE(tt-param.valorCampo).
            WHEN "nriniche" THEN aux_nriniche = INTE(tt-param.valorCampo).
            WHEN "nrfimche" THEN aux_nrfimche = INTE(tt-param.valorCampo).
            
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:
        
        CASE tt-param-i.nomeTabela:

            WHEN "Cheques" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-cheques.
                       ASSIGN aux_rowidaux = ROWID(tt-cheques).
                    END.

                FIND tt-cheques WHERE ROWID(tt-cheques) = aux_rowidaux
                                      NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "cdbanchq" THEN
                        tt-cheques.cdbanchq = INTE(tt-param-i.valorCampo).
                    WHEN "cdagechq" THEN
                        tt-cheques.cdagechq = INTE(tt-param-i.valorCampo).
                    WHEN "nrctachq" THEN
                        tt-cheques.nrctachq = DECI(tt-param-i.valorCampo).
                    WHEN "nrcheque" THEN
                        tt-cheques.nrcheque = INTE(tt-param-i.valorCampo).
                END CASE.
            END.

            WHEN "Criticas" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                        CREATE tt-criticas.
                        ASSIGN aux_rowidaux = ROWID(tt-criticas).
                    END.

                FIND tt-criticas WHERE ROWID(tt-criticas) = aux_rowidaux
                                       NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "cdbanchq" THEN
                        tt-criticas.cdbanchq = INTE(tt-param-i.valorCampo).
                    WHEN "cdagechq" THEN
                        tt-criticas.cdagechq = INTE(tt-param-i.valorCampo).
                    WHEN "nrctachq" THEN
                        tt-criticas.nrctachq = DECI(tt-param-i.valorCampo).
                    WHEN "nrcheque" THEN
                        tt-criticas.nrcheque = INTE(tt-param-i.valorCampo).
                    WHEN "cdcritic" THEN
                        tt-criticas.cdcritic = INTE(tt-param-i.valorCampo).
                END CASE.
            END.

        END CASE.
    END.
    
END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                      BUSCA OS DADOS DO ASSOCIADO                         */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_cddopcao,
                            INPUT YES,         
                           OUTPUT TABLE tt-infoass,
                           OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RETURN.
        END.

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
           RUN piXmlExport (INPUT TEMP-TABLE tt-infoass:HANDLE,
                            INPUT "Associado").
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                      BUSCA OS DADOS DO ASSOCIADO                         */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Agencia:

    RUN Busca_Agencia IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdbanchq,
                             OUTPUT aux_cdagechq,
                             OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RETURN.
        END.

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
           RUN piXmlAtributo (INPUT "cdagechq", INPUT aux_cdagechq).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                        VALIDA OS DADOS INFORMADOS                        */
/* ------------------------------------------------------------------------ */

PROCEDURE Valida_Dados:

    RUN Valida_Dados IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_dtmvtolt,
                             INPUT aux_cddopcao,
                             INPUT aux_nrdconta,
                             INPUT aux_nrctachq,
                             INPUT aux_cdbanchq,
                             INPUT aux_cdagechq,
                             INPUT aux_nrinichq,
                             INPUT aux_nrfimchq,
                            OUTPUT aux_nmdcampo,
                            OUTPUT aux_nriniche,
                            OUTPUT aux_nrfimche,
                            OUTPUT TABLE tt-chequedc,
                            OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.

           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-chequedc:HANDLE,
                            INPUT "Custodia").
           RUN piXmlAtributo (INPUT "nriniche", INPUT aux_nriniche).
           RUN piXmlAtributo (INPUT "nrfimche", INPUT aux_nrfimche).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------- */
/*                   REALIZA A GRAVACAO DOS DADOS DOS CHEQUES                */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_dtmvtolt,
                            INPUT aux_cddopcao,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT aux_nrctachq,
                            INPUT aux_cdbanchq,
                            INPUT aux_cdagechq,
                            INPUT aux_nriniche,
                            INPUT aux_nrfimche,
                            INPUT TRUE, /*flgerlog*/
                           OUTPUT TABLE tt-criticas,
                           OUTPUT TABLE tt-cheques,
                           OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.

           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-criticas:HANDLE,
                            INPUT "Criticas").
           RUN piXmlExport (INPUT TEMP-TABLE tt-cheques:HANDLE,
                            INPUT "Cheques").
           RUN piXmlSave.
        END.

END.

/* ------------------------------------------------------------------------ */
/*                          GERA IMPRESSÃO DO TERMO                         */
/* ------------------------------------------------------------------------ */
PROCEDURE Imprime_Termo:

    RUN Imprime_Termo IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_dtmvtolt,
                              INPUT aux_nmoperad,
                              INPUT aux_dsiduser,
                              INPUT aux_nrdconta,
                              INPUT TRUE, /*flgerlog*/
                              INPUT TABLE tt-criticas,
                              INPUT TABLE tt-cheques,
                             OUTPUT aux_nmarqimp,
                             OUTPUT aux_nmarqpdf,
                             OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.

           RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.
END.
