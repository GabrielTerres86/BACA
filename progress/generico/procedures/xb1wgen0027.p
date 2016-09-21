/*.............................................................................

   Programa: xb1wgen0027.p
   Autor   : Guilherme
   Data    : Fevereiro/2008                     Ultima atualizacao: 10/03/2009

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Ocorrencias (b1wgen0027.p)

   Alteracoes: 10/03/2009 - Adicionar extratos_emitidos_no_cash (Guilherme).

............................................................................ */


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_dtrefere AS DATE                                           NO-UNDO.
        
{ sistema/generico/includes/b1wgen0027tt.i }
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
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.           
            WHEN "dtrefere" THEN aux_dtrefere = DATE(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/******************************************************************************/
/**               Procedure para listar ocorrencias                          **/
/******************************************************************************/
PROCEDURE lista_ocorren:

    RUN lista_ocorren IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nrdconta,
                              INPUT aux_dtmvtolt,
                              INPUT aux_dtmvtopr,
                              INPUT aux_inproces,
                              INPUT aux_idorigem,
                              INPUT aux_idseqttl,
                              INPUT aux_nmdatela,
                              INPUT TRUE,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-ocorren).

    IF  RETURN-VALUE = "NOK"  THEN
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-ocorren:HANDLE,
                        INPUT "Dados").

END PROCEDURE.

PROCEDURE lista_contra-ordem:

    RUN lista_contra-ordem IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idorigem,
                                   INPUT aux_idseqttl,
                                   INPUT aux_nmdatela,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-contra_ordem).

    RUN piXmlSaida (INPUT TEMP-TABLE tt-contra_ordem:HANDLE,
                    INPUT "Dados").

END PROCEDURE.

PROCEDURE lista_emprestimos:

    RUN lista_emprestimos IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nrdconta,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_dtmvtopr,
                                  INPUT aux_inproces,
                                  INPUT aux_idorigem,
                                  INPUT aux_idseqttl,
                                  INPUT aux_nmdatela,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-emprestimos).

    IF  RETURN-VALUE = "NOK"  THEN
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-emprestimos:HANDLE,
                        INPUT "Dados").

END PROCEDURE.

PROCEDURE lista_prejuizos:

    RUN lista_prejuizos IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nrdconta,
                                INPUT aux_dtmvtolt,
                                INPUT aux_dtmvtopr,
                                INPUT aux_inproces,
                                INPUT aux_idorigem,
                                INPUT aux_idseqttl,
                                INPUT aux_nmdatela,
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-prejuizos).

    IF  RETURN-VALUE = "NOK"  THEN
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-prejuizos:HANDLE,
                        INPUT "Dados").

END PROCEDURE.

PROCEDURE lista_spc:

    RUN lista_spc IN hBO (INPUT aux_cdcooper,
                          INPUT aux_cdagenci,
                          INPUT aux_nrdcaixa,
                          INPUT aux_cdoperad,
                          INPUT aux_nrdconta,
                          INPUT aux_idorigem,
                          INPUT aux_idseqttl,
                          INPUT aux_nmdatela,
                         OUTPUT TABLE tt-erro,
                         OUTPUT TABLE tt-spc).

    IF  RETURN-VALUE = "NOK"  THEN
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-spc:HANDLE,
                        INPUT "Dados").

END PROCEDURE.

PROCEDURE lista_estouros:

    RUN lista_estouros IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nrdconta,
                               INPUT aux_idorigem,
                               INPUT aux_idseqttl,
                               INPUT aux_nmdatela,
                              OUTPUT TABLE tt-erro,
                              OUTPUT TABLE tt-estouros).

    IF  RETURN-VALUE = "NOK"  THEN
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-estouros:HANDLE,
                        INPUT "Dados").

END PROCEDURE.

PROCEDURE extratos_emitidos_no_cash:

    RUN extratos_emitidos_no_cash IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_nmdatela,
                                          INPUT aux_dtrefere,
                                          INPUT aux_idorigem,
                                          INPUT TRUE,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-extcash).
                
    IF  RETURN-VALUE = "NOK"  THEN
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-extcash:HANDLE,
                        INPUT "Dados").

END PROCEDURE.

/* .......................................................................... */

