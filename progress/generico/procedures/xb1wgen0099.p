/*.............................................................................

    Programa: sistema/generico/procedures/xb1wgen0099.p
    Autor   : Gabriel
    Data    : Maio/2011               Ultima Atualizacao:
     
    Dados referentes ao programa:
   
    Objetivo  : XBO de comunicacao com a BO b1wgen0099.p
                 
    Alteracoes: 

.............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_cdconven AS INTE                                           NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.

DEF VAR par_nmempres AS CHAR                                           NO-UNDO.
DEF VAR par_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR par_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR par_nmdcampo AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0099tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }

/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:
    
        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "cdconven" THEN aux_cdconven = INTE(tt-param.valorCampo).
            WHEN "nmendter" THEN aux_nmendter = tt-param.valorCampo.

        END.

    END.

END PROCEDURE.


/*****************************************************************************
 Validar o convenio digitado na tela DECONV.
 Traz os titulares da conta para selecionar na tela DECONV.
*****************************************************************************/
PROCEDURE valida-traz-titulares:

    RUN valida-traz-titulares IN hBo (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_nrdconta,
                                      INPUT aux_cdconven,
                                      INPUT aux_dtmvtolt,
                                      INPUT TRUE,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT par_nmdcampo,
                                     OUTPUT par_nmempres,
                                     OUTPUT TABLE tt-titulares).

    IF   RETURN-VALUE <> "OK"  THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
             IF  NOT AVAILABLE tt-erro  THEN
                 DO:
                     CREATE tt-erro.
                     ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                               "operacao.".
                 END.
                 
             RUN piXmlNew.
             RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                              INPUT "Erro").
             RUN piXmlAtributo (INPUT "nmdcampo",INPUT par_nmdcampo).
             RUN piXmlSave.
         END.
    ELSE 
         DO:
             RUN piXmlNew.
             RUN piXmlExport   (INPUT TEMP-TABLE tt-titulares:HANDLE,
                                INPUT "Titulares").
             RUN piXmlAtributo (INPUT "nmempres",INPUT par_nmempres).             
             RUN piXmlSave.
         END. 

END PROCEDURE.


/*****************************************************************************
 Gerar a declaracao impressa da tela DECONV
*****************************************************************************/
PROCEDURE gera-declaracao:

   RUN gera-declaracao IN hBo (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_nrdconta,
                               INPUT aux_idseqttl,
                               INPUT aux_cdconven,
                               INPUT aux_nmendter,
                               INPUT aux_dtmvtolt,
                               INPUT TRUE,
                              OUTPUT TABLE tt-erro,
                              OUTPUT par_nmarqimp,
                              OUTPUT par_nmarqpdf).

   IF   RETURN-VALUE <> "OK"  THEN
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
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT par_nmarqpdf).
            RUN piXmlSave.
        END.

END PROCEDURE.


/* ......................................................................... */
