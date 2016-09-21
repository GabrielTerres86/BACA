/*.............................................................................

    Programa: xb1wgen0066.p
    Autor   : Jose Luis
    Data    : Abril/2010                   Ultima atualizacao: 00/00/0000   

    Objetivo  : BO de Comunicacao XML x BO - CONTAS, FINANCEIRO (ATIVO/PASSIVO)

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
DEF VAR aux_mesdbase AS INTE                                           NO-UNDO.
DEF VAR aux_anodbase AS INTE                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_vlcxbcaf AS DECI                                           NO-UNDO.
DEF VAR aux_vlctarcb AS DECI                                           NO-UNDO.
DEF VAR aux_vlrestoq AS DECI                                           NO-UNDO.
DEF VAR aux_vloutatv AS DECI                                           NO-UNDO.
DEF VAR aux_vlrimobi AS DECI                                           NO-UNDO.
DEF VAR aux_vlfornec AS DECI                                           NO-UNDO.
DEF VAR aux_vloutpas AS DECI                                           NO-UNDO.
DEF VAR aux_vldivbco AS DECI                                           NO-UNDO.
DEF VAR aux_cdopejfn AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0066tt.i } 
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }
                                             
/*............................... PROCEDURES ................................*/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN 
                ASSIGN 
                   aux_cdoperad = tt-param.valorCampo
                   aux_cdopejfn = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
            WHEN "mesdbase" THEN aux_mesdbase = INTE(tt-param.valorCampo).
            WHEN "anodbase" THEN aux_anodbase = INTE(tt-param.valorCampo).
            WHEN "vlcxbcaf" THEN aux_vlcxbcaf = DECI(tt-param.valorCampo).
            WHEN "vlctarcb" THEN aux_vlctarcb = DECI(tt-param.valorCampo).
            WHEN "vlrestoq" THEN aux_vlrestoq = DECI(tt-param.valorCampo).
            WHEN "vloutatv" THEN aux_vloutatv = DECI(tt-param.valorCampo).
            WHEN "vlrimobi" THEN aux_vlrimobi = DECI(tt-param.valorCampo).
            WHEN "vlfornec" THEN aux_vlfornec = DECI(tt-param.valorCampo).
            WHEN "vloutpas" THEN aux_vloutpas = DECI(tt-param.valorCampo).
            WHEN "vldivbco" THEN aux_vldivbco = DECI(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
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
                           OUTPUT TABLE tt-atvpass,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-atvpass:HANDLE,
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
                             INPUT TRUE,
                             INPUT aux_mesdbase,
                             INPUT aux_anodbase,
                             INPUT aux_dtmvtolt,
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
                            INPUT "A",
                            INPUT aux_dtmvtolt,
                            INPUT aux_mesdbase,
                            INPUT aux_anodbase,
                            INPUT aux_vlcxbcaf,
                            INPUT aux_vlctarcb,
                            INPUT aux_vlrestoq,
                            INPUT aux_vloutatv,
                            INPUT aux_vlrimobi,
                            INPUT aux_vlfornec,
                            INPUT aux_vloutpas,
                            INPUT aux_vldivbco,
                            INPUT aux_cdopejfn,
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
