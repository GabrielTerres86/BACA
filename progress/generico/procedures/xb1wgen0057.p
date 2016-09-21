/*.............................................................................

    Programa: xb1wgen0057.p
    Autor   : Jose Luis
    Data    : Marco/2010                   Ultima atualizacao: 22/09/2010

    Objetivo  : BO de Comunicacao XML x BO de Contas Conjuge (b1wgen0057.p)

    Alteracoes: 22/09/2010 -  Recebe parametro 'msgconta' no busca_dados 
                              e passa no XML. (Gabriel - DB1).
   
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
DEF VAR aux_nrctacje AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcjg AS CHAR                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_cdnatocp AS INTE                                           NO-UNDO.
DEF VAR aux_cdocpcje AS INTE                                           NO-UNDO.
DEF VAR aux_cdturnos AS INTE                                           NO-UNDO.
DEF VAR aux_cdnvlcgo AS INTE                                           NO-UNDO.
DEF VAR aux_nmconjug AS CHAR                                           NO-UNDO.
DEF VAR aux_dtnasccj AS DATE                                           NO-UNDO.
DEF VAR aux_tpdoccje AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdoccje AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoedcje AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufdcje AS CHAR                                           NO-UNDO.
DEF VAR aux_dtemdcje AS DATE                                           NO-UNDO.
DEF VAR aux_gresccje AS INTE                                           NO-UNDO.
DEF VAR aux_cdfrmttl AS INTE                                           NO-UNDO.
DEF VAR aux_tpcttrab AS INTE                                           NO-UNDO.
DEF VAR aux_nmextemp AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdocnpj AS CHAR                                           NO-UNDO.
DEF VAR aux_dsproftl AS CHAR                                           NO-UNDO.
DEF VAR aux_nrfonemp AS CHAR                                           NO-UNDO.
DEF VAR aux_nrramemp AS INTE                                           NO-UNDO.
DEF VAR aux_dtadmemp AS DATE                                           NO-UNDO.
DEF VAR aux_vlsalari AS DECI                                           NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                           NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0057tt.i }
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
            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
            WHEN "nrctacje" THEN aux_nrctacje = INTE(tt-param.valorCampo).
            WHEN "nrcpfcjg" OR WHEN "nrcpfcje" THEN
                aux_nrcpfcjg = tt-param.valorCampo.
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "cdnatopc" THEN aux_cdnatocp = INTE(tt-param.valorCampo).
            WHEN "cdocpcje" THEN aux_cdocpcje = INTE(tt-param.valorCampo).
            WHEN "cdnvlcgo" THEN aux_cdnvlcgo = INTE(tt-param.valorCampo).
            WHEN "cdturnos" THEN aux_cdturnos = INTE(tt-param.valorCampo).
            WHEN "nmconjug" THEN aux_nmconjug = tt-param.valorCampo.
            WHEN "dtnasccj" THEN aux_dtnasccj = DATE(tt-param.valorCampo).
            WHEN "tpdoccje" THEN aux_tpdoccje = tt-param.valorCampo.
            WHEN "nrdoccje" THEN aux_nrdoccje = tt-param.valorCampo.
            WHEN "cdoedcje" THEN aux_cdoedcje = tt-param.valorCampo.
            WHEN "cdufdcje" THEN aux_cdufdcje = tt-param.valorCampo.
            WHEN "dtemdcje" THEN aux_dtemdcje = DATE(tt-param.valorCampo).
            WHEN "grescola" THEN aux_gresccje = INTE(tt-param.valorCampo).
            WHEN "cdfrmttl" THEN aux_cdfrmttl = INTE(tt-param.valorCampo).
            WHEN "tpcttrab" THEN aux_tpcttrab = INTE(tt-param.valorCampo).
            WHEN "nmextemp" THEN aux_nmextemp = tt-param.valorCampo.
            WHEN "nrdocnpj" THEN aux_nrdocnpj = tt-param.valorCampo.
            WHEN "dsproftl" THEN aux_dsproftl = tt-param.valorCampo.
            WHEN "nrfonemp" THEN aux_nrfonemp = tt-param.valorCampo.
            WHEN "nrramemp" THEN aux_nrramemp = INTE(tt-param.valorCampo).
            WHEN "dtadmemp" THEN aux_dtadmemp = DATE(tt-param.valorCampo).
            WHEN "vlsalari" THEN aux_vlsalari = DECI(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    

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
                            INPUT aux_cddopcao,
                            INPUT aux_nrdrowid,
                            INPUT aux_nrctacje,
                            INPUT DEC(aux_nrcpfcjg),
                           OUTPUT aux_msgconta,
                           OUTPUT TABLE tt-crapcje,
                           OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RETURN.
        END.

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcje:HANDLE,
                             INPUT "Conjuge").
            RUN piXmlAtributo (INPUT "msgconta", INPUT aux_msgconta).
            RUN piXmlSave.
        END.
END.

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
                             INPUT aux_nrcpfcjg,
                             INPUT aux_nmconjug,
                             INPUT aux_dtnasccj,
                             INPUT aux_tpdoccje,
                             INPUT aux_cdufdcje,
                             INPUT aux_gresccje,
                             INPUT aux_cdfrmttl,
                             INPUT aux_cdnatocp,
                             INPUT aux_cdocpcje,
                             INPUT aux_tpcttrab,
                             INPUT aux_nmextemp,
                             INPUT aux_nrdocnpj,
                             INPUT aux_dsproftl,
                             INPUT aux_cdnvlcgo,
                             INPUT aux_cdturnos,
                             INPUT aux_dtadmemp,
                             INPUT aux_nrctacje,
                           OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           CREATE tt-erro.
           ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
           RETURN.
        END.

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

PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO (INPUT aux_cdcooper, 
                            INPUT aux_cdagenci, 
                            INPUT aux_nrdcaixa, 
                            INPUT aux_cdoperad, 
                            INPUT aux_nmdatela, 
                            INPUT aux_idorigem, 
                            INPUT aux_nrdconta, 
                            INPUT aux_idseqttl, 
                            INPUT YES, 
                            INPUT aux_nrctacje,
                            INPUT DEC(aux_nrcpfcjg),
                            INPUT aux_nmconjug,
                            INPUT aux_dtnasccj,
                            INPUT aux_tpdoccje,
                            INPUT aux_nrdoccje,
                            INPUT aux_cdoedcje,
                            INPUT aux_cdufdcje,
                            INPUT aux_dtemdcje,
                            INPUT aux_gresccje,
                            INPUT aux_cdfrmttl,
                            INPUT aux_cdnatocp,
                            INPUT aux_cdocpcje,
                            INPUT aux_tpcttrab,
                            INPUT aux_nmextemp,
                            INPUT aux_nrdocnpj,
                            INPUT aux_dsproftl,
                            INPUT aux_cdnvlcgo,
                            INPUT aux_nrfonemp,
                            INPUT aux_nrramemp,
                            INPUT aux_cdturnos,
                            INPUT aux_dtadmemp,
                            INPUT aux_vlsalari,
                            INPUT aux_dtmvtolt,
                            INPUT aux_cddopcao,
                           OUTPUT aux_tpatlcad,
                           OUTPUT aux_msgatcad,
                           OUTPUT aux_chavealt,
                           OUTPUT aux_msgrvcad,
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
           RUN piXmlAtributo (INPUT "msgalert", INPUT TRIM(aux_msgalert)).
           RUN piXmlAtributo (INPUT "msgrvcad", INPUT TRIM(aux_msgrvcad)).
           RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
           RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
           RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
           RUN piXmlSave.
        END.
END.
