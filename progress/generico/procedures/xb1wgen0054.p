/*.............................................................................

    Programa: xb1wgen0054.p
    Autor   : Jose Luis
    Data    : Janeiro/2010                   Ultima atualizacao: 22/09/2010

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Contas Filiacao (b1wgen0054.p)

   Alteracoes: 22/09/2010 -  Recebe parametro 'msgconta' no busca_dados 
                              e passa no XML. (Gabriel - DB1).
   
.............................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_nmpaittl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmmaettl AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                           NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0054tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }

/*...........................................................................*/
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
            WHEN "nmpaittl" THEN aux_nmpaittl = tt-param.valorCampo.
            WHEN "nmmaettl" THEN aux_nmmaettl = tt-param.valorCampo.
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.

        END CASE.

    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.    

/*****************************************************************************/
/**      Procedure para carregar dados para montar o cabeçalho da tela      **/
/*****************************************************************************/
PROCEDURE busca_dados:

    RUN Busca_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT YES,
                           OUTPUT aux_msgconta,
                           OUTPUT TABLE tt-filiacao,
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
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-filiacao:HANDLE,
                             INPUT "Filiacao").
            RUN piXmlAtributo (INPUT "msgconta", INPUT aux_msgconta).
            RUN piXmlSave.
        END.
        
END PROCEDURE.

PROCEDURE valida_dados:

    RUN Valida_Dados IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT YES,
                             INPUT aux_nmmaettl,
                             INPUT aux_nmpaittl,
                            OUTPUT aux_nmdcampo,
                            OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE = "NOK" THEN
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
           RUN piXmlSave.
        END.

END.

/*****************************************************************************/
/**      Procedure para gravar os dados para montar o cabeçalho da tela     **/
/*****************************************************************************/
PROCEDURE grava_dados:

    RUN Grava_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT YES,
                            INPUT aux_nmmaettl,
                            INPUT aux_nmpaittl,
                            INPUT aux_cddopcao,
                            INPUT aux_dtmvtolt,
                           OUTPUT aux_msgalert,
                           OUTPUT aux_tpatlcad,
                           OUTPUT aux_msgatcad,
                           OUTPUT aux_chavealt,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
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
            RUN piXmlAtributo (INPUT "msgalert", INPUT aux_msgalert).
            RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
            RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
            RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
            RUN piXmlSave.
        END.

END PROCEDURE.
