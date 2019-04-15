/*.............................................................................

    Programa: xb1wgen0065.p
    Autor   : Jose Luis
    Data    : Abril/2010                   Ultima atualizacao: 15/04/2019   

    Objetivo  : BO de Comunicacao XML x BO - CONTAS - REGISTRO

    Alteracoes: 15/04/2019 - Melhoria no tratamento do Error-status para 
                             correcao do problema PRB0041543 
                             (Jose Eduardo -Mouts)
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
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_vlfatano AS DECI                                           NO-UNDO.
DEF VAR aux_vlcaprea AS DECI                                           NO-UNDO.
DEF VAR aux_dtregemp AS DATE                                           NO-UNDO.
DEF VAR aux_nrregemp AS DECI                                           NO-UNDO.
DEF VAR aux_orregemp AS CHAR                                           NO-UNDO.
DEF VAR aux_dtinsnum AS DATE                                           NO-UNDO.
DEF VAR aux_nrinsmun AS DECI                                           NO-UNDO.
DEF VAR aux_nrinsest AS DECI                                           NO-UNDO.
DEF VAR aux_flgrefis AS LOG                                            NO-UNDO.
DEF VAR aux_nrcdnire AS DECI                                           NO-UNDO.
DEF VAR aux_perfatcl AS DECI                                           NO-UNDO.
                                                                       
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0065tt.i } 
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
            WHEN "vlfatano" THEN aux_vlfatano = DECI(tt-param.valorCampo).
            WHEN "vlcaprea" THEN aux_vlcaprea = DECI(tt-param.valorCampo).
            WHEN "dtregemp" THEN aux_dtregemp = DATE(tt-param.valorCampo).
            WHEN "nrregemp" THEN aux_nrregemp = DECI(tt-param.valorCampo).
            WHEN "orregemp" THEN aux_orregemp = tt-param.valorCampo.
            WHEN "dtinsnum" THEN aux_dtinsnum = DATE(tt-param.valorCampo).
            WHEN "nrinsmun" THEN aux_nrinsmun = DECI(tt-param.valorCampo).
            WHEN "nrinsest" THEN aux_nrinsest = DECI(tt-param.valorCampo).
            WHEN "flgrefis" THEN aux_flgrefis = LOGICAL(tt-param.valorCampo).
            WHEN "nrcdnire" THEN aux_nrcdnire = DECI(tt-param.valorCampo).
            WHEN "perfatcl" THEN aux_perfatcl = DECI(tt-param.valorCampo).
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
                           OUTPUT TABLE tt-registro,
                           OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" THEN
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-registro:HANDLE,
                             INPUT "Informativos").
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
                             INPUT aux_vlfatano,
                             INPUT aux_vlcaprea,
                             INPUT aux_dtregemp,
                             INPUT aux_nrregemp,
                             INPUT aux_orregemp,
                             INPUT aux_perfatcl,
                            OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" THEN
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
                            INPUT aux_vlfatano,
                            INPUT aux_vlcaprea,
                            INPUT aux_dtregemp,
                            INPUT aux_nrregemp,
                            INPUT aux_orregemp,
                            INPUT aux_dtinsnum,
                            INPUT aux_nrinsmun,
                            INPUT aux_nrinsest,
                            INPUT aux_flgrefis,
                            INPUT aux_nrcdnire,
                            INPUT aux_perfatcl,
                           OUTPUT aux_tpatlcad,
                           OUTPUT aux_msgatcad,
                           OUTPUT aux_chavealt,
                           OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:NUM-MESSAGES > 0 THEN
        DO:
            IF  NOT CAN-FIND(FIRST tt-erro) THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "gravacao de dados. " + 
                                              ERROR-STATUS:GET-MESSAGE(1).
                END.
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.

    IF  RETURN-VALUE <> "OK" THEN
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
