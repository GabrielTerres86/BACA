/*.............................................................................

    Programa: xb1wgen0069.p
    Autor   : Jose Luis
    Data    : Abril/2010                   Ultima atualizacao: 00/00/0000   

    Objetivo  : BO de Comunicacao XML x BO - CONTAS, FINANCEIRO (FATURAMENTO)

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
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrposext AS INTE                                           NO-UNDO.
DEF VAR aux_vlrftbru AS DECI                                           NO-UNDO.
DEF VAR aux_mesftbru AS INTE                                           NO-UNDO.
DEF VAR aux_anoftbru AS INTE                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0069tt.i } 
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }
                                             
/*............................... PROCEDURES ................................*/
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
            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nrposext" THEN aux_nrposext = INTE(tt-param.valorCampo).
            WHEN "mesftbru" THEN aux_mesftbru = INTE(tt-param.valorCampo).
            WHEN "anoftbru" THEN aux_anoftbru = INTE(tt-param.valorCampo).
            WHEN "vlrftbru" THEN aux_vlrftbru = DECI(tt-param.valorCampo).
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    

PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT YES,
                            INPUT aux_nrposext,
                           OUTPUT TABLE tt-faturam,
                           OUTPUT TABLE tt-erro) .

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-faturam:HANDLE,
                             INPUT "Faturamento").
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Valida_Dados:

    RUN Valida_Dados IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT YES,
                             INPUT aux_dtmvtolt,
                             INPUT aux_cddopcao,
                             INPUT aux_vlrftbru,
                             INPUT aux_mesftbru,
                             INPUT aux_anoftbru,
                             INPUT aux_nrposext,
                            OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE = "NOK" THEN
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

PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT TRUE,
                            INPUT aux_cddopcao,
                            INPUT aux_dtmvtolt,
                            INPUT aux_vlrftbru,
                            INPUT aux_mesftbru,
                            INPUT aux_anoftbru,
                            INPUT aux_nrposext,
                            INPUT aux_nrdrowid,
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
           RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
           RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
           RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
           RUN piXmlSave.
        END.

END PROCEDURE.
