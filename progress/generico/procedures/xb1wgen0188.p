
/*..............................................................................

    Programa: xb1wgen0188.p
    Autor   : Carlos Rafael Tanholi
    Data    : Janeiro/2016                     Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Objetivo  : BO de Comunicacao XML VS BO de credito pre-aprovado (b1wgen0188.p)
    
    Alteracoes: 

..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO. 


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
            WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).

        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/   

END PROCEDURE.


/*******************************************************************************/
/**    Procedure para para gerar demonstrativo para impressão no Ayllos Web   **/
/*******************************************************************************/

PROCEDURE imprime_demonstrativo_ayllos_web:
    
    RUN imprime_demonstrativo_ayllos_web IN hBO (INPUT aux_cdcooper,
                                                 INPUT aux_cdagenci,
                                                 INPUT aux_nrdcaixa,
                                                 INPUT aux_cdoperad,
                                                 INPUT aux_nmdatela,
                                                 INPUT aux_idorigem,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT aux_nrctremp,                                                 
                                                OUTPUT aux_nmarqimp,
                                                OUTPUT aux_nmarqpdf,                                                
                                                OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro THEN
            DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a operacao.".
            END.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
        RUN piXmlSave.
    END.    

END PROCEDURE.



