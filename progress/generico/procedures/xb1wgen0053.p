/*.............................................................................

    Programa: xb1wgen0053.p
    Autor   : Jose Luis
    Data    : Janeiro/2010                   Ultima atualizacao: 25/10/2016

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Contas (b1wgen0053.p)

   Alteracoes: 23/07/2015 - Reformulacao cadastral (Gabriel-RKAM)
               
			   01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
			                Transferencia entre PAs (Heitor - RKAM)
   
			   25/10/2016 - Validacao da data de licenca Melhoria 310 (Tiago/Thiago)
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
DEF VAR aux_dtcnscpf AS DATE                                           NO-UNDO.
DEF VAR aux_dtmovime AS DATE                                           NO-UNDO.
DEF VAR aux_dtiniatv AS DATE                                           NO-UNDO.
DEF VAR aux_cdsitcpf AS INTE                                           NO-UNDO.
DEF VAR aux_qtfoltal AS INTE                                           NO-UNDO.
DEF VAR aux_nmfatasi AS CHAR                                           NO-UNDO.
DEF VAR aux_qtfilial AS INTE                                           NO-UNDO.
DEF VAR aux_qtfuncio AS INTE                                           NO-UNDO.
DEF VAR aux_dsendweb AS CHAR                                           NO-UNDO.
DEF VAR aux_nmtalttl AS CHAR                                           NO-UNDO.
DEF VAR aux_dtcadass AS DATE                                           NO-UNDO.
DEF VAR aux_cdnatjur AS INTE                                           NO-UNDO.
DEF VAR aux_dsnatjur AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS CHAR                                           NO-UNDO.
DEF VAR aux_cdclcnae AS INTE                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrlicamb AS DECI                                           NO-UNDO.
DEF VAR aux_dtvallic AS DATE										   NO-UNDO.
DEF VAR aux_tpregtrb AS INTE										   NO-UNDO.
DEF VAR aux_impdecpjcoop AS CHAR NO-UNDO.

{ sistema/generico/includes/b1wgen0053tt.i }
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
          WHEN "dtcnscpf" THEN aux_dtcnscpf = DATE(tt-param.valorCampo).
          WHEN "dtmovime" THEN aux_dtmovime = DATE(tt-param.valorCampo).
          WHEN "dtiniatv" THEN aux_dtiniatv = DATE(tt-param.valorCampo).
          WHEN "cdsitcpf" THEN aux_cdsitcpf = INTE(tt-param.valorCampo).
          WHEN "qtfoltal" THEN aux_qtfoltal = INTE(tt-param.valorCampo).
          WHEN "nmfatasi" THEN aux_nmfatasi = tt-param.valorCampo.
          WHEN "qtfilial" THEN aux_qtfilial = INTE(tt-param.valorCampo).
          WHEN "dsendweb" THEN aux_dsendweb = tt-param.valorCampo.
          WHEN "nmtalttl" THEN aux_nmtalttl = tt-param.valorCampo.
          WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
          WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
          WHEN "cdnatjur" THEN aux_cdnatjur = INTE(tt-param.valorCampo).
          WHEN "dsnatjur" THEN aux_dsnatjur = tt-param.valorCampo.
          WHEN "nrcpfcgc" THEN aux_nrcpfcgc = tt-param.valorCampo.
          WHEN "qtfuncio" THEN aux_qtfuncio = INTE(tt-param.valorCampo).
          WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
          WHEN "dtcadass" THEN aux_dtcadass = DATE(tt-param.valorCampo).
          WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
          WHEN "cdcnae"   THEN aux_cdclcnae = INTE(tt-param.valorCampo).
          WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
          WHEN "nrlicamb" THEN aux_nrlicamb = DECI(tt-param.valorCampo).
		  WHEN "dtvallic" THEN aux_dtvallic = DATE(tt-param.valorCampo).
		  WHEN "tpregtrb" THEN aux_tpregtrb = INTE(tt-param.valorCampo).
          WHEN "impdecpjcoop" THEN aux_impdecpjcoop = tt-param.valorCampo.

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
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE tt-dados-jur).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-jur:HANDLE,
                             INPUT "DadosJuridico").
            RUN piXmlSave.         
        END.
        
END PROCEDURE.

PROCEDURE Valida_Dados:

    RUN valida_dados IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_idseqttl,
                             INPUT aux_nmfatasi,
                             INPUT aux_dtcnscpf,
                             INPUT aux_dtmvtolt,
                             INPUT aux_dtcadass,
                             INPUT aux_dtiniatv,
                             INPUT aux_cdsitcpf,
                             INPUT aux_cdnatjur,
                             INPUT aux_cdseteco,
                             INPUT aux_cdrmativ,
                             INPUT aux_nmtalttl,
                             INPUT aux_qtfoltal,
                             INPUT aux_nrlicamb,
                             INPUT aux_dtvallic,
                             INPUT aux_cdclcnae,
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
                             INPUT aux_qtfoltal,
                             INPUT aux_dtcnscpf,
                             INPUT aux_cdsitcpf,
                             INPUT aux_nmfatasi,
                             INPUT aux_cdnatjur,
                             INPUT aux_dtiniatv,
                             INPUT aux_cdrmativ,
                             INPUT aux_qtfilial,
                             INPUT aux_qtfuncio,
                             INPUT aux_dsendweb,
                             INPUT aux_nmtalttl,
                             INPUT aux_cdseteco,
                             INPUT aux_cdclcnae,
                             INPUT "A",
                             INPUT aux_dtmvtolt,
                             INPUT aux_nrlicamb,
							 INPUT aux_dtvallic,
							 INPUT aux_tpregtrb,
                            OUTPUT aux_tpatlcad,
                            OUTPUT aux_msgatcad,
                            OUTPUT aux_chavealt,
                            OUTPUT aux_impdecpjcoop,
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
            RUN piXmlAtributo (INPUT "impdecpjcoop", INPUT aux_impdecpjcoop).
            RUN piXmlSave.
        END.

END PROCEDURE.


