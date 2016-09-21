/*.............................................................................

    Programa: sistema/generico/procedures/xb1wgen0165.p
    Autor   : Renersson Ricardo Agostini (GATI)
    Data    : Julho/2013                    Ultima atualizacao: 13/11/2014

    Objetivo  : BO de Comunicacao XML x BO 
                Tela - EMPRES
                BO - sistema/generico/procedures/b1wgen0165.p
                Consultar contratos de empréstimos de cooperado.
                
    Alteracoes: 13/11/2014 - Adicioando parametro aux_flgempt0, utilizado em 
                             Busca_contrato.
                             (Jorge/Elton) - SD 168151           

.............................................................................*/

/*...........................................................................*/
DEFINE VARIABLE aux_cdcooper AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_nrdconta AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_nmdatela AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_nrctremp AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_dtcalcul AS DATE        NO-UNDO.
DEFINE VARIABLE aux_flgerlog AS LOGICAL     NO-UNDO.
DEFINE VARIABLE aux_cdbccxlt AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_cdagenci AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_cdoperad AS CHARACTER FORMAT "x(10)"  NO-UNDO.
DEFINE VARIABLE aux_idorigem AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_cdprogra AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_nrdcaixa AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_idseqttl AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_flgcondc AS LOGICAL     NO-UNDO.
DEFINE VARIABLE aux_nmdcampo AS CHAR        NO-UNDO.
DEFINE VARIABLE aux_flgempt0 AS LOGICAL     NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0165tt.i }
/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:
     FOR EACH tt-param:

         CASE tt-param.nomeCampo:
             WHEN "cdcooper" THEN aux_cdcooper = INTEGER(tt-param.valorCampo).
             WHEN "nrdconta" THEN aux_nrdconta = INTEGER(tt-param.valorCampo).
             WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "nrctremp" THEN aux_nrctremp = INTEGER(tt-param.valorCampo).
             WHEN "dtcalcul" THEN aux_dtcalcul = DATE(tt-param.valorCampo).
             WHEN "cdbccxlt" THEN aux_cdbccxlt = INTEGER(tt-param.valorCampo).
             WHEN "cdagenci" THEN aux_cdagenci = INTEGER(tt-param.valorCampo).
             WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "idorigem" THEN aux_idorigem = INTEGER(tt-param.valorCampo).
             WHEN "idseqttl" THEN aux_idseqttl = INTEGER(tt-param.valorCampo).
             WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
             WHEN "dtmvtopr" THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
             WHEN "inproces" THEN aux_inproces = INTEGER(tt-param.valorCampo).
             WHEN 'nrdcaixa' THEN aux_nrdcaixa = INT(tt-param.valorCampo).
             WHEN 'cdprogra' THEN aux_cdprogra = tt-param.valorCampo.
             WHEN 'flgcondc' THEN aux_flgcondc = LOGICAL(tt-param.valorCampo).
             WHEN 'flgempt0' THEN aux_flgempt0 = LOGICAL(tt-param.valorCampo).
         END CASE.

     END. /** Fim do FOR EACH tt-param **/

 END PROCEDURE. /* valores_entrada */

PROCEDURE Busca_contrato:
    RUN Busca_contrato IN hBO (INPUT aux_cdcooper, 
                               INPUT aux_cdagenci, 
                               INPUT aux_nrdcaixa, 
                               INPUT aux_cdoperad, 
                               INPUT aux_dtmvtolt, 
                               INPUT aux_idorigem, 
                               INPUT aux_nmdatela, 
                               INPUT aux_cdprogra, 
                               INPUT aux_nrdconta,
                               INPUT aux_flgerlog,
                               INPUT aux_cdbccxlt,
                               INPUT aux_flgempt0,
                               OUTPUT aux_nmdcampo,
                               OUTPUT TABLE tt-crapass,
                               OUTPUT TABLE tt-crapepr,
                               OUTPUT TABLE tt-erro).
    
    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
          IF NOT AVAILABLE tt-erro THEN
             DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                          "operacao.".
             END.
             
          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
          RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
          RUN piXmlSave.
       END.
    ELSE
       DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapass:HANDLE,
                            INPUT "cooperado").
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapepr:HANDLE,
                            INPUT "contratos").
           RUN piXmlSave.
       END.

END PROCEDURE.

PROCEDURE Busca_emprestimo:
    
    RUN Busca_emprestimo IN hBO (INPUT aux_cdcooper, 
                                 INPUT aux_cdagenci,
                                 INPUT aux_cdbccxlt,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_dtmvtopr,
                                 INPUT aux_dtcalcul,
                                 INPUT aux_nrctremp,
                                 INPUT aux_cdprogra,
                                 INPUT aux_inproces,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_flgerlog,
                                 INPUT aux_flgcondc,
                                 OUTPUT aux_nmdcampo,
                                 OUTPUT TABLE tt-pesqsr,
                                 OUTPUT TABLE tt-erro).
    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
          IF NOT AVAILABLE tt-erro THEN
             DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                          "operacao.".
             END.
             
          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
          RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
          RUN piXmlSave.
       END.
    ELSE
       DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-pesqsr:HANDLE,
                            INPUT "detcontrato").
           RUN piXmlSave.
       END.
END PROCEDURE.


