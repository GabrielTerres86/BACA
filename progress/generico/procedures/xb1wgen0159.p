/*.............................................................................

   Programa: xb1wgen0159.p
   Autor   : Lucas R.
   Data    : Julho/2013                     Ultima atualizacao: 27/08/2013

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao referente a tela CONTAS, Imunidade Tributaria.

   Alteracoes: 27/08/2013 - Ajustando xBO para requisicoes Ayllos(WEB)
                            (Andre Santos - SUPERO)
                            
............................................................................ */

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO. 
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_cdsitcad AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_cddentid AS INTE                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_tprelimt AS INTE                                           NO-UNDO.
DEF VAR aux_dtrefini AS DATE                                           NO-UNDO.
DEF VAR aux_dtreffim AS DATE                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR FORMAT "x(30)"                            NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR FORMAT "x(30)"                            NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR FORMAT "x(30)"                            NO-UNDO.
DEF VAR aux_dscancel AS CHAR FORMAT "x(30)"                            NO-UNDO.
DEF VAR aux_cdopcimp AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0159tt.i }
                                       
/*................................ PROCEDURES ................................*/

/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:
    
    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "cdsitcad" THEN aux_cdsitcad = INTE(tt-param.valorCampo).
            WHEN "cddentid" THEN aux_cddentid = INTE(tt-param.valorCampo).
            WHEN "tprelimt" THEN aux_tprelimt = INTE(tt-param.valorCampo).
            WHEN "dtrefini" THEN aux_dtrefini = DATE(tt-param.valorCampo).
            WHEN "dtreffim" THEN aux_dtreffim = DATE(tt-param.valorCampo).
            WHEN "cdopcimp" THEN aux_cdopcimp = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "dscancel" THEN aux_dscancel = tt-param.valorCampo.
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

PROCEDURE consulta-imunidade:
    
    RUN consulta-imunidade IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_nrcpfcgc,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-imunidade,
                                  OUTPUT TABLE tt-contas-ass).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").

        END.
    ELSE DO:   
        RUN piXmlNew.
        RUN piXmlExport(INPUT TEMP-TABLE tt-contas-ass:HANDLE,
                        INPUT "Associado").
        RUN piXmlExport(INPUT TEMP-TABLE tt-imunidade:HANDLE,
                        INPUT "Imunidade").
        RUN piXmlSave.
    END.


END PROCEDURE.


PROCEDURE consulta-imunidade-contas:
    
    RUN consulta-imunidade-contas IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_nrcpfcgc,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-imunidade).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").

        END.
    ELSE DO:   
        RUN piXmlNew.
        RUN piXmlExport(INPUT TEMP-TABLE tt-imunidade:HANDLE,
                        INPUT "Imunidade").
        RUN piXmlSave.
    END.


END PROCEDURE.


PROCEDURE altera-imunidade:

    RUN altera-imunidade IN hBO
                       (INPUT aux_cdcooper,
                        INPUT aux_nrcpfcgc,
                        INPUT aux_cdsitcad,
                        INPUT aux_dscancel,
                        INPUT aux_cdoperad,
                        INPUT aux_dtmvtolt,
                        INPUT aux_nmdatela,
                        OUTPUT TABLE tt-erro).
   
   IF  RETURN-VALUE <> "OK" THEN
       DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF NOT AVAILABLE tt-erro THEN
            DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = "Nao foi possivel gerar arquivo " +
                                          "de impressao.".
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

PROCEDURE gravar-imunidade:

    RUN gravar-imunidade IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_nrcpfcgc,
                                 INPUT aux_cdsitcad,
                                 INPUT aux_cddentid,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE gera_impressao:

    RUN gera_impressao IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_dtmvtolt,
                        INPUT aux_tprelimt,
                        INPUT aux_dtrefini,
                        INPUT aux_dtreffim,
                        INPUT aux_cdsitcad,
                        INPUT 5, /*par_idorigem*/
                        OUTPUT aux_nmarquiv,
                        OUTPUT aux_nmarqpdf,
                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF NOT AVAILABLE tt-erro THEN
            DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = "Nao foi possivel gerar arquivo " +
                                          "de impressao.".
            END.
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE imprime-imunidade:
   
   RUN imprime-imunidade IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_nrcpfcgc,
                         INPUT aux_cddentid,
                         INPUT 5, /*par_idorigem*/
                         INPUT aux_cdopcimp,
                         OUTPUT aux_nmarquiv,
                         OUTPUT aux_nmarqpdf,
                         OUTPUT TABLE tt-erro).
    
   IF  RETURN-VALUE <> "OK" THEN
       DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel gerar arquivo " +
                                              "de impressao.".
                END.
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.
