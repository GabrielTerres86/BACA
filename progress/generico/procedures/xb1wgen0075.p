/*.............................................................................

    Programa: xb1wgen0075.p
    Autor   : Jose Luis Marchezoni
    Data    : Maio/2010                   Ultima atualizacao: 14/10/2013

    Objetivo  : BO de Comunicacao XML x BO - CONTAS, COMERCIAL

    Alteracoes: 22/09/2010 -  Recebe parametro 'msgconta' no busca_dados 
                              e passa no XML. (Gabriel - DB1).
                              
                19/04/2011 - Inclusão de parametro CEP no valida_dados.
                             (André - DB1) 
                             
                05/12/2011 - Criado as procedures:
                             - Busca_Rendimentos
                             - Grava_Rendimentos
                             (Adriano).
                             
                14/10/2013 - Adicionado parameto aux_cotcance na chamada
                             da procedure Grava_Dados. (Fabricio)
                             
   
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
DEF VAR aux_cdnatopc AS INTE                                           NO-UNDO.
DEF VAR aux_cdocpttl AS INTE                                           NO-UNDO.
DEF VAR aux_tpcttrab AS INTE                                           NO-UNDO.
DEF VAR aux_cdempres AS INTE                                           NO-UNDO.
DEF VAR aux_nmextemp AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfemp AS CHAR                                           NO-UNDO.
DEF VAR aux_dsproftl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdnvlcgo AS INTE                                           NO-UNDO.
DEF VAR aux_nrcadast AS INTE                                           NO-UNDO.
DEF VAR aux_ufresct1 AS CHAR                                           NO-UNDO.
DEF VAR aux_endrect1 AS CHAR                                           NO-UNDO.
DEF VAR aux_bairoct1 AS CHAR                                           NO-UNDO.
DEF VAR aux_cidadct1 AS CHAR                                           NO-UNDO.
DEF VAR aux_complcom AS CHAR                                           NO-UNDO.
DEF VAR aux_cepedct1 AS INTE                                           NO-UNDO.
DEF VAR aux_cxpotct1 AS INTE                                           NO-UNDO.
DEF VAR aux_nmdsecao AS CHAR                                           NO-UNDO.
DEF VAR aux_cdturnos AS INTE                                           NO-UNDO.
DEF VAR aux_dtadmemp AS DATE                                           NO-UNDO.
DEF VAR aux_nrendcom AS INTE                                           NO-UNDO.
DEF VAR aux_vlsalari AS DECI                                           NO-UNDO.
DEF VAR aux_tpdrendi AS INTE                                           NO-UNDO.
DEF VAR aux_vldrendi AS DECI                                           NO-UNDO.
DEF VAR aux_tpdrend2 AS INTE                                           NO-UNDO.
DEF VAR aux_vldrend2 AS DECI                                           NO-UNDO.
DEF VAR aux_tpdrend3 AS INTE                                           NO-UNDO.
DEF VAR aux_vldrend3 AS DECI                                           NO-UNDO.
DEF VAR aux_tpdrend4 AS INTE                                           NO-UNDO.
DEF VAR aux_vldrend4 AS DECI                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                           NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                           NO-UNDO.
DEF VAR aux_dsjusren AS CHAR                                           NO-UNDO.
DEF VAR aux_dsjusre2 AS CHAR                                           NO-UNDO.
DEF VAR aux_flgexist AS LOG                                            NO-UNDO.
DEF VAR aux_nriniseq AS INT                                            NO-UNDO.
DEF VAR aux_nrregist AS INT                                            NO-UNDO.
DEF VAR aux_flgpagin AS LOG                                            NO-UNDO.
DEF VAR aux_qtregist AS INT                                            NO-UNDO.
DEF VAR aux_cotcance AS CHAR                                           NO-UNDO.
DEF VAR aux_inpolexp AS INTE                                           NO-UNDO.
DEF VAR aux_tpexposto           AS INTE                                NO-UNDO.
DEF VAR aux_cdrelacionamento    AS INTE                                NO-UNDO.
DEF VAR aux_dtinicio            AS DATE                                NO-UNDO.
DEF VAR aux_dttermino           AS DATE                                NO-UNDO.
DEF VAR aux_nmempresa           AS CHAR                                NO-UNDO.
DEF VAR aux_nrcnpj_empresa      AS DECI                                NO-UNDO.
DEF VAR aux_nmpolitico          AS CHAR                                NO-UNDO.
DEF VAR aux_nrcpf_politico      AS DECI                                NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0075tt.i } 
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
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).
            WHEN "cdnatopc" THEN aux_cdnatopc = INTE(tt-param.valorCampo).
            WHEN "cdocpttl" THEN aux_cdocpttl = INTE(tt-param.valorCampo).
            WHEN "tpcttrab" THEN aux_tpcttrab = INTE(tt-param.valorCampo).
            WHEN "cdempres" THEN aux_cdempres = INTE(tt-param.valorCampo).
            WHEN "nmextemp" THEN aux_nmextemp = tt-param.valorCampo.
            WHEN "nrcpfemp" THEN aux_nrcpfemp = tt-param.valorCampo.
            WHEN "dsproftl" THEN aux_dsproftl = tt-param.valorCampo.
            WHEN "cdnvlcgo" THEN aux_cdnvlcgo = INTE(tt-param.valorCampo).
            WHEN "nrcadast" THEN aux_nrcadast = INTE(tt-param.valorCampo).
            WHEN "ufresct1" THEN aux_ufresct1 = tt-param.valorCampo.
            WHEN "endrect1" THEN aux_endrect1 = tt-param.valorCampo.
            WHEN "bairoct1" THEN aux_bairoct1 = tt-param.valorCampo.
            WHEN "cidadct1" THEN aux_cidadct1 = tt-param.valorCampo.
            WHEN "complcom" THEN aux_complcom = tt-param.valorCampo.
            WHEN "nrendcom" THEN aux_nrendcom = INTE(tt-param.valorCampo).
            WHEN "cepedct1" THEN aux_cepedct1 = INTE(tt-param.valorCampo).
            WHEN "cxpotct1" THEN aux_cxpotct1 = INTE(tt-param.valorCampo).
            WHEN "nmdsecao" THEN aux_nmdsecao = tt-param.valorCampo.
            WHEN "cdturnos" THEN aux_cdturnos = INTE(tt-param.valorCampo).
            WHEN "dtadmemp" THEN aux_dtadmemp = DATE(tt-param.valorCampo).
            WHEN "vlsalari" THEN aux_vlsalari = DECI(tt-param.valorCampo).
            WHEN "tpdrendi" THEN aux_tpdrendi = INTE(tt-param.valorCampo).
            WHEN "vldrendi" THEN aux_vldrendi = DECI(tt-param.valorCampo).
            WHEN "tpdrend2" THEN aux_tpdrend2 = INTE(tt-param.valorCampo).
            WHEN "vldrend2" THEN aux_vldrend2 = DECI(tt-param.valorCampo).
            WHEN "tpdrend3" THEN aux_tpdrend3 = INTE(tt-param.valorCampo).
            WHEN "vldrend3" THEN aux_vldrend3 = DECI(tt-param.valorCampo).
            WHEN "tpdrend4" THEN aux_tpdrend4 = INTE(tt-param.valorCampo).
            WHEN "vldrend4" THEN aux_vldrend4 = DECI(tt-param.valorCampo).
            WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
            WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
            WHEN "dsjusren" THEN aux_dsjusren = tt-param.valorCampo.
            WHEN "dsjusre2" THEN aux_dsjusre2 = tt-param.valorCampo.
            WHEN "flgexist" THEN aux_flgexist = LOGICAL(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INT(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INT(tt-param.valorCampo).
            WHEN "flgpagin" THEN aux_flgpagin = LOGICAL(tt-param.valorCampo).
            WHEN "qtregist" THEN aux_qtregist = INT(tt-param.valorCampo).
            WHEN "inpolexp" THEN aux_inpolexp = INT(tt-param.valorCampo).
            WHEN "cdrelacionamento" THEN aux_cdrelacionamento = INTE(tt-param.valorCampo).
            WHEN "dtinicio"         THEN aux_dtinicio         = DATE(tt-param.valorCampo).
            WHEN "dttermino"        THEN aux_dttermino        = DATE(tt-param.valorCampo).
            WHEN "nmempresa"        THEN aux_nmempresa        = tt-param.valorCampo.
            WHEN "nrcnpj_empresa"   THEN aux_nrcnpj_empresa   = DECI(tt-param.valorCampo).
            WHEN "nmpolitico"       THEN aux_nmpolitico       = tt-param.valorCampo.
            WHEN "nrcpf_politico"   THEN aux_nrcpf_politico   = DECI(tt-param.valorCampo).
            WHEN "tpexposto"        THEN aux_tpexposto        = INTE(tt-param.valorCampo).

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
                            INPUT aux_cddopcao,
                            INPUT aux_cdempres,
                            INPUT aux_cdnatopc,
                            INPUT aux_cdocpttl,
                            INPUT aux_tpcttrab,
                            INPUT aux_nmdsecao,
                            INPUT aux_dsproftl,
                            INPUT aux_cdnvlcgo,
                            INPUT aux_cdturnos,
                            INPUT aux_dtadmemp,
                            INPUT aux_vlsalari,
                            INPUT aux_nrcadast,
                            INPUT aux_tpdrendi,
                            INPUT aux_vldrendi,
                            INPUT aux_tpdrend2,
                            INPUT aux_vldrend2,
                            INPUT aux_tpdrend3,
                            INPUT aux_vldrend3,
                            INPUT aux_tpdrend4,
                            INPUT aux_vldrend4,
                            INPUT aux_inpolexp,
                           OUTPUT aux_msgconta,
                           OUTPUT TABLE tt-comercial,
                           OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-comercial:HANDLE,
                             INPUT "Comercial").
            /*Alterção: Passo atributo para web*/
            RUN piXmlAtributo (INPUT "msgconta", INPUT aux_msgconta).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Busca_Dados_PPE:

    RUN Busca_Dados_PPE IN hBO 
                           (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT YES,
                            INPUT aux_cddopcao,
                           OUTPUT aux_msgconta,
                           OUTPUT TABLE tt-ppe,
                           OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-ppe:HANDLE,
                             INPUT "PPE").
            /*Alterção: Passo atributo para web*/
            RUN piXmlAtributo (INPUT "msgconta", INPUT aux_msgconta).
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
                             INPUT aux_cdnatopc,
                             INPUT aux_cdocpttl,
                             INPUT aux_tpcttrab,
                             INPUT aux_cdempres,
                             INPUT aux_nmextemp,
                             INPUT aux_nrcpfemp,
                             INPUT aux_dsproftl,
                             INPUT aux_cdnvlcgo,
                             INPUT aux_nrcadast,
                             INPUT aux_ufresct1,
                             INPUT aux_cdturnos,
                             INPUT aux_dtadmemp,
                             INPUT aux_vlsalari,
                             INPUT aux_tpdrendi,
                             INPUT aux_vldrendi,
                             INPUT aux_tpdrend2,
                             INPUT aux_vldrend2,
                             INPUT aux_tpdrend3,
                             INPUT aux_vldrend3,
                             INPUT aux_tpdrend4,
                             INPUT aux_vldrend4,
                             INPUT aux_cepedct1,
                             INPUT aux_endrect1,
                             INPUT aux_inpolexp,
                            OUTPUT aux_nmdcampo,
                            OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

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
                            INPUT aux_nrdrowid,
                            INPUT aux_cdnatopc,
                            INPUT aux_cdocpttl,
                            INPUT aux_tpcttrab,
                            INPUT aux_cdempres,
                            INPUT aux_nmextemp,
                            INPUT DECI(aux_nrcpfemp),
                            INPUT aux_dsproftl,
                            INPUT aux_cdnvlcgo,
                            INPUT aux_nrcadast,
                            INPUT aux_ufresct1,
                            INPUT aux_endrect1,
                            INPUT aux_bairoct1,
                            INPUT aux_cidadct1,
                            INPUT aux_complcom,
                            INPUT aux_cepedct1,
                            INPUT aux_cxpotct1,
                            INPUT aux_cdturnos,
                            INPUT aux_dtadmemp,
                            INPUT aux_vlsalari,
                            INPUT aux_nmdsecao,
                            INPUT aux_nrendcom,
                            INPUT aux_tpdrendi,
                            INPUT aux_vldrendi,
                            INPUT aux_tpdrend2,
                            INPUT aux_tpdrend3,
                            INPUT aux_tpdrend4,
                            INPUT aux_vldrend2,
                            INPUT aux_vldrend3,
                            INPUT aux_vldrend4,
                            INPUT aux_inpolexp,
                           OUTPUT aux_tpatlcad,
                           OUTPUT aux_msgatcad,
                           OUTPUT aux_chavealt,
                           OUTPUT aux_msgrvcad,
                           OUTPUT aux_cotcance,
                           OUTPUT TABLE tt-erro) NO-ERROR .

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

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
           RUN piXmlAtributo (INPUT "msgrvcad", INPUT aux_msgrvcad).
           RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
           RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
           RUN piXmlAtributo (INPUT "cotcance", INPUT aux_cotcance).
           RUN piXmlSave.
        END.

END PROCEDURE.


PROCEDURE Grava_Rendimentos:

    
    RUN Grava_Rendimentos IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT YES,
                                  INPUT aux_cddopcao,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_tpdrendi,
                                  INPUT aux_vldrendi,
                                  INPUT aux_tpdrend2,
                                  INPUT aux_vldrend2,
                                  INPUT aux_dsjusren,
                                  INPUT aux_dsjusre2,
                                  OUTPUT aux_tpatlcad,
                                  OUTPUT aux_msgatcad,
                                  OUTPUT aux_chavealt,
                                  OUTPUT aux_msgrvcad,
                                  OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "gravacao dos rendimentos.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
           RUN piXmlAtributo (INPUT "msgrvcad", INPUT aux_msgrvcad).
           RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
           RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
           RUN piXmlSave.

        END.

END PROCEDURE.



PROCEDURE Busca_Rendimentos:


    RUN Busca_Rendimentos IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_nrdrowid,
                                  INPUT aux_nriniseq,
                                  INPUT aux_nrregist,
                                  INPUT aux_flgpagin,
                                  OUTPUT aux_qtregist,
                                  OUTPUT aux_flgexist,
                                  OUTPUT TABLE tt-rendimentos,
                                  OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca dos rendimentos.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-rendimentos:HANDLE,
                            INPUT "Rendimentos").
           RUN piXmlAtributo (INPUT "qtregist", INPUT STRING(aux_qtregist)).
           RUN piXmlSave.

        END.
        

END PROCEDURE.


PROCEDURE Grava_Dados_Ppe:

    RUN Grava_Dados_Ppe IN hBO 
                           (INPUT aux_cdcooper,
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
                            INPUT aux_tpexposto,
                            INPUT aux_cdocpttl,
                            INPUT aux_cdrelacionamento,
                            INPUT aux_dtinicio,
                            INPUT aux_dttermino,
                            INPUT aux_nmempresa,
                            INPUT aux_nrcnpj_empresa,
                            INPUT aux_nmpolitico,
                            INPUT aux_nrcpf_politico,
                            
                           OUTPUT aux_tpatlcad,
                           OUTPUT aux_msgatcad,
                           OUTPUT aux_chavealt,
                           OUTPUT aux_msgrvcad,
                           OUTPUT aux_cotcance,
                           OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN.
        END.

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
           RUN piXmlAtributo (INPUT "msgrvcad", INPUT aux_msgrvcad).
           RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
           RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
           RUN piXmlAtributo (INPUT "cotcance", INPUT aux_cotcance).
           RUN piXmlSave.
        END.

END PROCEDURE.


