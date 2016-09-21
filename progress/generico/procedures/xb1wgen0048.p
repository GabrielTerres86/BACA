/*..............................................................................

    Programa: sistema/generico/procedures/xb1wgen0048.p
    Autor   : Jose Luis
    Data    : Marco/2010                      Ultima atualizacao: 00/00/0000   

    Objetivo  : BO de Comunicacao XML Vs BO de INFORMACOES ADICIONAIS

    Alteracoes: 
   
..............................................................................*/

                                                                             
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrinfcad AS INTE                                           NO-UNDO.
DEF VAR aux_nrpatlvr AS INTE                                           NO-UNDO.
DEF VAR aux_nrperger AS INTE                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_dsinfadi AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0048tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }


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
            WHEN "nrinfcad" THEN aux_nrinfcad = INTE(tt-param.valorCampo).
            WHEN "nrpatlvr" THEN aux_nrpatlvr = INTE(tt-param.valorCampo).
            WHEN "nrperger" THEN aux_nrperger = INTE(tt-param.valorCampo).
            WHEN "dsinfadi" THEN aux_dsinfadi = tt-param.valorCampo.
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    


/******************************************************************************/
/**       Procedure para carregar informacoes adicionais do associado        **/
/******************************************************************************/
PROCEDURE obtem-informacoes-adicionais:

    RUN obtem-informacoes-adicionais IN hBO (INPUT aux_cdcooper,
                                             INPUT aux_cdagenci,
                                             INPUT aux_nrdcaixa,
                                             INPUT aux_cdoperad,
                                             INPUT aux_nmdatela,
                                             INPUT aux_idorigem,
                                             INPUT aux_nrdconta,
                                             INPUT aux_idseqttl,
                                             INPUT TRUE,
                                            OUTPUT TABLE tt-inf-adicionais,
                                            OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE = "NOK"  THEN
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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-inf-adicionais:HANDLE,
                        INPUT "InfAdicional").

END PROCEDURE.


/******************************************************************************/
/**        Procedure para validar informacoes adicionais do associado        **/
/******************************************************************************/
PROCEDURE validar-informacoes-adicionais:

    RUN validar-informacoes-adicionais IN hBO (INPUT aux_cdcooper,
                                               INPUT aux_cdagenci,
                                               INPUT aux_nrdcaixa,
                                               INPUT aux_cdoperad,
                                               INPUT aux_nmdatela,
                                               INPUT aux_idorigem,
                                               INPUT aux_nrdconta,
                                               INPUT aux_idseqttl,
                                               INPUT aux_nrinfcad,
                                               INPUT aux_nrperger,
                                               INPUT aux_nrpatlvr,
                                               INPUT TRUE,
                                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                    CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "validacao de dados.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**       Procedure para atualizar informacoes adicionais do associado       **/
/******************************************************************************/
PROCEDURE atualizar-informacoes-adicionais:

    RUN atualizar-informacoes-adicionais IN hBO 
                             (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_nrdconta,
                              INPUT aux_idseqttl,
                              INPUT aux_dtmvtolt,
                              INPUT (IF NUM-ENTRIES(aux_dsinfadi,"|") > 0 THEN 
                                        ENTRY(1,aux_dsinfadi,"|") ELSE ""), 
                              INPUT (IF NUM-ENTRIES(aux_dsinfadi,"|") > 1 THEN 
                                        ENTRY(2,aux_dsinfadi,"|")  ELSE ""), 
                              INPUT (IF NUM-ENTRIES(aux_dsinfadi,"|") > 2 THEN 
                                        ENTRY(3,aux_dsinfadi,"|") ELSE ""), 
                              INPUT (IF NUM-ENTRIES(aux_dsinfadi,"|") > 3 THEN 
                                        ENTRY(4,aux_dsinfadi,"|") ELSE ""), 
                              INPUT (IF NUM-ENTRIES(aux_dsinfadi,"|") > 4 THEN 
                                        ENTRY(5,aux_dsinfadi,"|") ELSE ""), 
                              INPUT aux_nrinfcad,
                              INPUT aux_nrperger,
                              INPUT aux_nrpatlvr,
                              INPUT TRUE,
                             OUTPUT aux_tpatlcad,
                             OUTPUT aux_msgatcad,
                             OUTPUT aux_chavealt,
                             OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "gravacao de dados.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "tpatlcad", INPUT STRING(aux_tpatlcad)).
            RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
            RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
            RUN piXmlSave.
        END.

END PROCEDURE.


/*............................................................................*/
