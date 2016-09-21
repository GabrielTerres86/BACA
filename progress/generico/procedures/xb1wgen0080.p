/*.............................................................................

    Programa: xb1wgen0080.p
    Autor   : Guilherme
    Data    : Agosto/2011                   Ultima atualizacao:   /  /    

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Parti Empre Contas (b1wgen0080.p)

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
DEF VAR aux_cdseteco AS INTE                                           NO-UNDO.
DEF VAR aux_nmseteco AS CHAR                                           NO-UNDO.
DEF VAR aux_cdrmativ AS INTE                                           NO-UNDO.
DEF VAR aux_nmrmativ AS CHAR                                           NO-UNDO.
DEF VAR aux_dsrmativ AS CHAR                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_dtmovime AS DATE                                           NO-UNDO.
DEF VAR aux_dtiniatv AS DATE                                           NO-UNDO.
DEF VAR aux_nmfatasi AS CHAR                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_qtfilial AS INTE                                           NO-UNDO.
DEF VAR aux_qtfuncio AS INTE                                           NO-UNDO.
DEF VAR aux_dsendweb AS CHAR                                           NO-UNDO.
DEF VAR aux_dtcadass AS DATE                                           NO-UNDO.
DEF VAR aux_cdnatjur AS INTE                                           NO-UNDO.
DEF VAR aux_dsnatjur AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdctato AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcto AS DECI                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_persocio AS DECI                                           NO-UNDO.
DEF VAR aux_vledvmto AS DECI                                           NO-UNDO.
DEF VAR aux_dtadmsoc AS DATE                                           NO-UNDO.



{ sistema/generico/includes/b1wgen0080tt.i }
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
          WHEN "cdseteco" THEN aux_cdseteco = INTE(tt-param.valorCampo).
          WHEN "nmseteco" THEN aux_nmseteco = tt-param.valorCampo.
          WHEN "cdrmativ" THEN aux_cdrmativ = INTE(tt-param.valorCampo).
          WHEN "nmrmativ" THEN aux_nmrmativ = tt-param.valorCampo.
          WHEN "dsrmativ" THEN aux_dsrmativ = tt-param.valorCampo.
          WHEN "dtmovime" THEN aux_dtmovime = DATE(tt-param.valorCampo).
          WHEN "dtiniatv" THEN aux_dtiniatv = DATE(tt-param.valorCampo).
          WHEN "nmfatasi" THEN aux_nmfatasi = tt-param.valorCampo.
          WHEN "nmprimtl" THEN aux_nmprimtl = tt-param.valorCampo.
          WHEN "qtfilial" THEN aux_qtfilial = INTE(tt-param.valorCampo).
          WHEN "dsendweb" THEN aux_dsendweb = tt-param.valorCampo.
          WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
          WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
          WHEN "cdnatjur" THEN aux_cdnatjur = INTE(tt-param.valorCampo).
          WHEN "dsnatjur" THEN aux_dsnatjur = tt-param.valorCampo.
          WHEN "nrcpfcgc" THEN aux_nrcpfcgc = tt-param.valorCampo.
          WHEN "qtfuncio" THEN aux_qtfuncio = INTE(tt-param.valorCampo).
          WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
          WHEN "dtcadass" THEN aux_dtcadass = DATE(tt-param.valorCampo).
          WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
          WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
          WHEN "nrdctato" THEN aux_nrdctato = INTE(tt-param.valorCampo).
          WHEN "nrcpfcto" THEN aux_nrcpfcto = DECI(tt-param.valorCampo).
          WHEN "nrdrowid" THEN aux_nrdrowid = TO-ROWID(tt-param.valorCampo).    
          WHEN "persocio" THEN aux_persocio = DECI(tt-param.valorCampo).
          WHEN "vledvmto" THEN aux_vledvmto = DECI(tt-param.valorCampo).
          WHEN "dtadmsoc" THEN aux_dtadmsoc = DATE(tt-param.valorCampo).

      END CASE.

  END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    

/*****************************************************************************/
/**     Procedure para carregar dados para montar o cabeçalho da tela       **/
/*****************************************************************************/
PROCEDURE busca_dados:

    RUN busca_dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT YES,
                            INPUT aux_cddopcao,
                            INPUT aux_nrdctato,
                            INPUT aux_nrcpfcgc,
                            INPUT aux_nrdrowid,
                           OUTPUT TABLE tt-crapepa,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapepa:HANDLE,
                             INPUT "Empresa_Participante").
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
                             INPUT aux_nrdctato,
                             INPUT aux_nrcpfcgc,
                             INPUT aux_nmfatasi,
                             INPUT aux_dtmvtolt,
                             INPUT aux_dtiniatv,
                             INPUT aux_cdnatjur,
                             INPUT aux_cdseteco,
                             INPUT aux_cdrmativ,
                             INPUT aux_dtadmsoc,
                             INPUT aux_persocio,
                             INPUT aux_vledvmto,
                             INPUT aux_cddopcao,
                            OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "validacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
            RETURN "NOK".
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
                             INPUT YES,
                             INPUT aux_nrdctato,
                             INPUT aux_nrcpfcgc,
                             INPUT aux_nmprimtl,
                             INPUT aux_nmfatasi,
                             INPUT aux_cdnatjur,
                             INPUT aux_dtiniatv,
                             INPUT aux_cdrmativ,
                             INPUT aux_qtfilial,
                             INPUT aux_qtfuncio,
                             INPUT aux_dsendweb,
                             INPUT aux_cdseteco,
                             INPUT aux_cddopcao,
                             INPUT aux_dtmvtolt,
                             INPUT aux_dtadmsoc,
                             INPUT aux_persocio,
                             INPUT aux_vledvmto,
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
                                              "gravacao.".
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


PROCEDURE Exclui_Dados:

    RUN Exclui_Dados IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT YES,
                             INPUT aux_nrcpfcgc,
                            OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE tt-erro  THEN
                CREATE tt-erro.
                    
            ASSIGN tt-erro.dscritic = tt-erro.dscritic + " - " + 
                                      ERROR-STATUS:GET-MESSAGE(1).
    
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
