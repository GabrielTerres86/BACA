/*.............................................................................

   Programa: xb1wgen0154.p
   Autor   : Fabricio
   Data    : Marco/2013                     Ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO - Tela ICFJUD.

   Alteracoes: 
............................................................................ */

DEF VAR aux_cdcooper AS INTE NO-UNDO.
DEF VAR aux_cdagenci AS INTE NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE NO-UNDO.
DEF VAR aux_cdoperad AS CHAR NO-UNDO.
DEF VAR aux_nrctaori AS DECI NO-UNDO.
DEF VAR aux_dtinireq AS DATE NO-UNDO.
DEF VAR aux_intipreq AS INTE NO-UNDO.
DEF VAR aux_cdbanori AS INTE NO-UNDO.
DEF VAR aux_cdbanreq AS INTE NO-UNDO.
DEF VAR aux_cdagereq AS INTE NO-UNDO.
DEF VAR aux_nrctareq AS DECI NO-UNDO.
DEF VAR aux_dacaojud AS CHAR NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR NO-UNDO.
DEF VAR aux_cdtipcta AS INTE NO-UNDO.
DEF VAR aux_dsdocmc7 AS CHAR NO-UNDO.
DEF VAR aux_tpdconta AS CHAR NO-UNDO.
DEF VAR aux_dtdtroca AS DATE NO-UNDO.
DEF VAR aux_vldopera AS DECI NO-UNDO.
DEF VAR aux_nrsctareq AS CHAR NO-UNDO.
DEF VAR aux_listaacaojud AS CHAR NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0154tt.i }


/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    DEF VAR aux_rowidicf AS ROWID NO-UNDO.

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper"  THEN aux_cdcooper =  INTE(tt-param.valorCampo).
            WHEN "cdagenci"  THEN aux_cdagenci =  INTE(tt-param.valorCampo).
            WHEN "nrdcaixa"  THEN aux_nrdcaixa =  INTE(tt-param.valorCampo).
            WHEN "cdoperad"  THEN aux_cdoperad =  tt-param.valorCampo.
            WHEN "nrctaori"  THEN aux_nrctaori =  DECI(tt-param.valorCampo).
            WHEN "dtinireq"  THEN aux_dtinireq =  DATE(tt-param.valorCampo).
            WHEN "intipreq"  THEN aux_intipreq =  INTE(tt-param.valorCampo).
            WHEN "cdbanori"  THEN aux_cdbanori =  INTE(tt-param.valorCampo).
            WHEN "cdbanreq"  THEN aux_cdbanreq =  INTE(tt-param.valorCampo).
            WHEN "cdagereq"  THEN aux_cdagereq =  INTE(tt-param.valorCampo).
            WHEN "nrctareq"  THEN aux_nrctareq =  DECI(tt-param.valorCampo).
            WHEN "cdtipcta"  THEN aux_cdtipcta =  INTE(tt-param.valorCampo).
            WHEN "dacaojud"  THEN aux_dacaojud =  tt-param.valorCampo.
            WHEN "dsdocmc7"  THEN aux_dsdocmc7 =  tt-param.valorCampo.
            WHEN "tpdconta"  THEN aux_tpdconta =  tt-param.valorCampo.
            WHEN "dtdtroca"  THEN aux_dtdtroca =  DATE(tt-param.valorCampo).
            WHEN "vldopera"  THEN aux_vldopera =  DECI(tt-param.valorCampo).
            WHEN "nrsctareq"  THEN aux_nrsctareq =  tt-param.valorCampo.
            WHEN "listaacaojud"  THEN aux_listaacaojud =  tt-param.valorCampo.
        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "DadosICF" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-consulta-icf.
                       ASSIGN aux_rowidicf = ROWID(tt-consulta-icf).
                    END.

                FIND tt-consulta-icf WHERE ROWID(tt-consulta-icf) = aux_rowidicf
                                      NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "dtinireq" THEN
                        tt-consulta-icf.dtinireq = DATE(tt-param-i.valorCampo).
                    WHEN "dtfimreq" THEN
                        tt-consulta-icf.dtfimreq = DATE(tt-param-i.valorCampo).
                    WHEN "cdbanori" THEN
                        tt-consulta-icf.cdbanori = INTE(tt-param-i.valorCampo).
                    WHEN "nrctaori" THEN
                        tt-consulta-icf.nrctaori = DECI(tt-param-i.valorCampo).
                    WHEN "cdbanreq" THEN
                        tt-consulta-icf.cdbanreq = INTE(tt-param-i.valorCampo).
                    WHEN "cdagereq" THEN
                        tt-consulta-icf.cdagereq = INTE(tt-param-i.valorCampo).
                    WHEN "nrctareq" THEN
                        tt-consulta-icf.nrctareq = DECI(tt-param-i.valorCampo).
                    WHEN "nrcpfcgc" THEN
                        tt-consulta-icf.nrcpfcgc = DECI(tt-param-i.valorCampo).
                    WHEN "nmprimtl" THEN
                        tt-consulta-icf.nmprimtl = tt-param-i.valorCampo.
                    WHEN "dacaojud" THEN
                        tt-consulta-icf.dacaojud = tt-param-i.valorCampo.
                    WHEN "cdcritic" THEN
                        tt-consulta-icf.cdcritic = INTE(tt-param-i.valorCampo).
                    WHEN "cdtipcta" THEN
                        tt-consulta-icf.cdtipcta = INTE(tt-param-i.valorCampo).
                    WHEN "dsdocmc7" THEN
                        tt-consulta-icf.dsdocmc7 = tt-param-i.valorCampo.
                END CASE.
            END.
        END CASE.
    END.

END PROCEDURE.

PROCEDURE inclui-registro-icf:

    RUN inclui-registro-icf IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_nrctaori,
                                    INPUT aux_cdbanori,
                                    INPUT aux_cdbanreq,
                                    INPUT aux_cdagereq,
                                    INPUT aux_nrctareq,
                                    INPUT aux_dacaojud,
                                    INPUT aux_cdoperad,
                                    INPUT aux_dsdocmc7,
                                    INPUT aux_tpdconta,
                                    INPUT aux_dtdtroca,
                                    INPUT aux_vldopera,
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

PROCEDURE reenviar-registros-icf:

    RUN reenviar-registros-icf IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_nrsctareq,
                                       INPUT aux_listaacaojud,
                                       OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel reenviar os registros selecionados.".
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

PROCEDURE busca-cooperado:

    RUN busca-cooperado IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_nrctaori,
                               OUTPUT aux_nmprimtl,
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
        RUN piXmlAtributo (INPUT "nmprimtl", INPUT aux_nmprimtl).
        RUN piXmlSave.
    END.

END PROCEDURE.

PROCEDURE consulta-icf:

    RUN consulta-icf IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_dtinireq,
                             INPUT aux_intipreq,
                             INPUT aux_cdbanreq,
                             INPUT aux_cdagereq,
                             INPUT aux_nrctareq,
                             INPUT aux_dsdocmc7,
                            OUTPUT TABLE tt-consulta-icf,
                            OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
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
        RUN piXmlExport (INPUT TEMP-TABLE tt-consulta-icf:HANDLE, INPUT "DADOS").
        RUN piXmlSave.
    END.


END PROCEDURE.

PROCEDURE imprime-icf:

    RUN imprime-icf IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_dtmvtolt,
                            INPUT aux_dtinireq,
                            INPUT aux_intipreq,
                            INPUT aux_cdbanreq,
                            INPUT aux_cdagereq,
                            INPUT aux_nrctareq,
                            INPUT TABLE tt-consulta-icf,
                            OUTPUT aux_nmarqpdf,
                           OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel imprimir os registros.".
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
