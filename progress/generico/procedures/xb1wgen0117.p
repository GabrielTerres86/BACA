
/*..............................................................................

   Programa: xb1wgen0117.p
   Autor   : Adriano
   Data    : Setembro/2011                     Ultima atualizacao: 15/09/2014

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO Generica (b1wgen0117.p)

   Alteracoes: 15/09/2014 - Chamado 152916 (Jonata-RKAM).

..............................................................................*/

DEF VAR aux_nrcpfcgc AS DEC                                NO-UNDO.
DEF VAR aux_idseqttl AS INT                                NO-UNDO.
DEF VAR aux_nmpessoa AS CHAR                               NO-UNDO.
DEF VAR aux_cdcopsol AS INT                                NO-UNDO.
DEF VAR aux_nmpessol AS CHAR                               NO-UNDO.
DEF VAR aux_dsjusinc AS CHAR                               NO-UNDO.
DEF VAR aux_cdcooper AS INT                                NO-UNDO.
DEF VAR aux_cdagenci AS INT                                NO-UNDO. 
DEF VAR aux_nrdcaixa AS INT                                NO-UNDO.
DEF VAR aux_existcpf AS LOG                                NO-UNDO.
DEF VAR aux_nrregist AS INT                                NO-UNDO.
DEF VAR aux_nriniseq AS INT                                NO-UNDO.
DEF VAR aux_qtregist AS INT                                NO-UNDO.
DEF VAR aux_nmextcop AS CHAR                               NO-UNDO.
DEF VAR aux_msgretor AS INT                                NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                               NO-UNDO.
DEF VAR aux_flgpagin AS LOG                                NO-UNDO.
DEF VAR aux_nrregres AS INT                                NO-UNDO.
DEF VAR aux_dsjusexc AS CHAR                               NO-UNDO.
DEF VAR aux_dtexclus AS DATE                               NO-UNDO.
DEF VAR aux_idorigem AS INT                                NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                               NO-UNDO.
DEF VAR aux_tporigem AS INT                                NO-UNDO.
DEF VAR aux_cdbccxlt AS INT                                NO-UNDO.
DEF VAR aux_cdagelib AS INT                                NO-UNDO.
DEF VAR aux_cdopelib AS CHAR                               NO-UNDO.
DEF VAR aux_nrdconta AS INT                                NO-UNDO.
DEF VAR aux_dsjuslib AS CHAR                               NO-UNDO.
DEF VAR aux_cdoperac AS INT                                NO-UNDO.
DEF VAR aux_cdcoplib AS INT                                NO-UNDO.
DEF VAR aux_flgsiste AS LOG                                NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                               NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                               NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                               NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                               NO-UNDO.
DEF VAR aux_todostit AS CHAR                               NO-UNDO.
DEF VAR aux_tprelato AS INTE                               NO-UNDO.
DEF VAR aux_dtinicio AS DATE                               NO-UNDO.
DEF VAR aux_dtdfinal AS DATE                               NO-UNDO.


{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0117tt.i }



/* .........................PROCEDURES................................... */


/**************************************************************************
       Procedure para atribuicao dos dados de entrada enviados por XML
**************************************************************************/

PROCEDURE valores_entrada:

    FOR EACH tt-param NO-LOCK:

        CASE tt-param.nomeCampo:
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DEC(tt-param.valorCampo).
            WHEN "nmpessoa" THEN aux_nmpessoa = tt-param.valorCampo.
            WHEN "cdcopsol" THEN aux_cdcopsol = INT(tt-param.valorCampo).
            WHEN "nmpessol" THEN aux_nmpessol = tt-param.valorCampo.
            WHEN "dsjusinc" THEN aux_dsjusinc = tt-param.valorCampo.
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INT(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INT(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nmextcop" THEN aux_nmextcop = tt-param.valorCampo.
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "flgpagin" THEN aux_flgpagin = LOGICAL(tt-param.valorCampo).
            WHEN "nrregres" THEN aux_nrregres = INT(tt-param.valorCampo).
            WHEN "dsjusexc" THEN aux_dsjusexc = tt-param.valorCampo.
            WHEN "dtexclus" THEN aux_dtexclus = DATE(tt-param.valorCampo).
            WHEN "tporigem" THEN aux_tporigem = INTE(tt-param.valorCampo).
            WHEN "cdbccxlt" THEN aux_cdbccxlt = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "cdagelib" THEN aux_cdagelib = INT(tt-param.valorCampo).
            WHEN "cdopelib" THEN aux_cdopelib = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INT(tt-param.valorCampo).
            WHEN "dsjuslib" THEN aux_dsjuslib = tt-param.valorCampo.
            WHEN "cdoperac" THEN aux_cdoperac = INT(tt-param.valorCampo).
            WHEN "cdcoplib" THEN aux_cdcoplib = INT(tt-param.valorCampo).
            WHEN "flgsiste" THEN aux_flgsiste = LOGICAL(tt-param.valorCampo).
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "idseqttl" THEN aux_idseqttl = INT(tt-param.valorCampo).
            WHEN "tprelato" THEN aux_tprelato = INT(tt-param.valorCampo).
            WHEN "dtinicio" THEN aux_dtinicio = DATE(tt-param.valorCampo).
            WHEN "dtdfinal" THEN aux_dtdfinal = DATE(tt-param.valorCampo).
            
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.



/*****************************************************************************
  Realiza consulta crapcrt
******************************************************************************/
PROCEDURE consultar_cad_restritivo:
    
    RUN consultar_cad_restritivo IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_idorigem,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_cdoperad,
                                        INPUT aux_cddopcao,
                                        INPUT aux_nrcpfcgc,
                                        INPUT aux_nmpessoa,
                                        INPUT aux_nrregist,
                                        INPUT aux_nriniseq,
                                        INPUT aux_flgpagin,
                                        OUTPUT aux_qtregist,
                                        OUTPUT TABLE tt-crapcrt,
                                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro THEN
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcrt:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "qtregist", INPUT STRING(aux_qtregist)).
            RUN piXmlSave.

        END.

END PROCEDURE.


/*****************************************************************************
  Realiza inclusao na crapcrt
******************************************************************************/
PROCEDURE incluir_cad_restritivo:

    RUN incluir_cad_restritivo IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_idorigem,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nrcpfcgc,
                                       INPUT aux_nmpessoa,
                                       INPUT aux_cdcopsol,
                                       INPUT aux_nmpessol,
                                       INPUT aux_cdbccxlt,
                                       INPUT aux_dsjusinc,
                                       INPUT aux_tporigem,
                                       OUTPUT aux_msgretor,
                                       OUTPUT aux_nmdcampo,
                                       OUTPUT TABLE tt-erro).
             
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF NOT AVAILABLE tt-erro THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "operacao.".
               END.
            
            RUN piXmlNew. 
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
            RUN piXmlSave.
        END.

END PROCEDURE.


/*****************************************************************************
  Realiza exclusao crapcrt
******************************************************************************/
PROCEDURE excluir_cad_restritivo:
    
    RUN excluir_cad_restritivo IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_idorigem,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nrcpfcgc,
                                       INPUT aux_nrregres,
                                       INPUT aux_dsjusexc,
                                       INPUT aux_dtexclus,
                                       OUTPUT aux_nmdcampo,
                                       OUTPUT TABLE tt-erro).
             
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
            
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.

        END.
    ELSE
        DO: 
            RUN piXmlNew.
            RUN piXmlSave.

        END.

END PROCEDURE.


/*****************************************************************************
  Realiza liberacao craplju
******************************************************************************/
PROCEDURE liberar_cad_restritivo:
    
    RUN liberar_cad_restritivo IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_idorigem,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_cdoperad,
                                       INPUT aux_cdcoplib,
                                       INPUT aux_cdagelib,
                                       INPUT aux_cdopelib,
                                       INPUT aux_nrdconta,
                                       INPUT aux_nrcpfcgc,
                                       INPUT aux_dsjuslib,
                                       INPUT aux_cdoperac,
                                       INPUT aux_flgsiste,
                                       OUTPUT aux_nmdcampo,
                                       OUTPUT TABLE tt-erro).
             
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
            
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.

        END.
    ELSE
        DO: 
            RUN piXmlNew.
            RUN piXmlSave.

        END.

END PROCEDURE.


/*****************************************************************************
  Gera relatorio com as justificativas
******************************************************************************/
PROCEDURE gera_relatorio:

    RUN gera_relatorio IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_idorigem,
                               INPUT aux_dtmvtolt,
                               INPUT aux_nrcpfcgc,
                               INPUT aux_nmpessoa,
                               INPUT aux_dsiduser,
                               INPUT aux_tprelato,
                               INPUT aux_dtinicio,
                               INPUT aux_dtdfinal,
                               OUTPUT aux_nmarqimp,
                               OUTPUT aux_nmarqpdf,
                               OUTPUT TABLE tt-erro).
             
    IF RETURN-VALUE = "NOK"  THEN
       DO: 
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF NOT AVAILABLE tt-erro THEN
             DO:    
                 CREATE tt-erro.
                 ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                           "operacao.".
             END.
          
          RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").

       END.
    ELSE
       DO: 
          RUN piXmlNew.
          RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
          RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
          RUN piXmlSave.

       END.

END PROCEDURE.


/*****************************************************************************
  Consulta todos as contas em que o CPF possui algum vinculo
******************************************************************************/
PROCEDURE consulta_vinculo:

    RUN consulta_vinculo IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_idorigem,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nrcpfcgc,
                                 INPUT aux_nriniseq,
                                 INPUT aux_nrregist,
                                 OUTPUT aux_qtregist,
                                 OUTPUT aux_nmdcampo,
                                 OUTPUT TABLE tt-vinculo,
                                 OUTPUT TABLE tt-erro).

   
    IF RETURN-VALUE = "NOK"  THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
          
          IF NOT AVAILABLE tt-erro THEN
             DO:
                 CREATE tt-erro.
                 ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                           "operacao.".
             END.
          
          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
          RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
          RUN piXmlSave.

       END.
    ELSE
       DO: 
          RUN piXmlNew.
          RUN piXmlExport(INPUT TEMP-TABLE tt-vinculo:HANDLE, INPUT "Vinculo").
          RUN piXmlAtributo(INPUT "qtregist", INPUT STRING(aux_qtregist)).
          RUN piXmlSave.

       END.

END PROCEDURE.

