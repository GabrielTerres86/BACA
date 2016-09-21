/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0127.p
    Autor   : Gabriel Capoia
    Data    : Dezembro/2011                      Ultima atualizacao: 06/10/2015

    Objetivo  : BO de Comunicacao XML x BO - Tela VALPRO

    Alteracoes: 06/10/2015 - Incluindo validacao de protocolo MD5 - Sicredi
                            (Andre Santos - SUPERO)
   
.............................................................................*/

                                                                             

/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_nrdocmto AS INTE                                           NO-UNDO.
DEF VAR aux_dtmvtolx AS DATE                                           NO-UNDO.
DEF VAR aux_horproto AS INTE                                           NO-UNDO.
DEF VAR aux_minproto AS INTE                                           NO-UNDO.
DEF VAR aux_segproto AS INTE                                           NO-UNDO.
DEF VAR aux_vlprotoc AS DECI                                           NO-UNDO.
DEF VAR aux_dsprotoc AS CHAR                                           NO-UNDO.
DEF VAR aux_nrseqaut AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_msgretur AS CHAR                                           NO-UNDO.
DEF VAR aux_msgerror AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0127tt.i } 
                    
/*............................... PROCEDURES ................................*/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "dtmvtopr" THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "nrdocmto" THEN aux_nrdocmto = INTE(tt-param.valorCampo).
            WHEN "dtmvtolx" THEN aux_dtmvtolx = DATE(tt-param.valorCampo).
            WHEN "horproto" THEN aux_horproto = INTE(tt-param.valorCampo).
            WHEN "minproto" THEN aux_minproto = INTE(tt-param.valorCampo).
            WHEN "segproto" THEN aux_segproto = INTE(tt-param.valorCampo).
            WHEN "vlprotoc" THEN aux_vlprotoc = DECI(tt-param.valorCampo).
            WHEN "dsprotoc" THEN aux_dsprotoc = tt-param.valorCampo.
            WHEN "nrseqaut" THEN aux_nrseqaut = tt-param.valorCampo.
            
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE. /* valores_entrada */

/* ------------------------------------------------------------------------ */
/*                    Valida os Dados do Protocolo Informado                */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Protocolo:

    RUN Valida_Protocolo IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_cdprogra,
                                 INPUT aux_idorigem,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_dtmvtopr,
                                 INPUT aux_nmdatela,
                                 INPUT aux_cddopcao,
                                 INPUT aux_nrdconta,
                                 INPUT aux_nrdocmto,
                                 INPUT aux_dtmvtolx,
                                 INPUT aux_horproto,
                                 INPUT aux_minproto,
                                 INPUT aux_segproto,
                                 INPUT aux_vlprotoc,
                                 INPUT aux_dsprotoc,
                                 INPUT aux_nrseqaut,
                                 INPUT TRUE,
                                OUTPUT aux_nmdcampo,
                                OUTPUT aux_msgretur,
                                OUTPUT aux_msgerror,
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "msgretur", INPUT aux_msgretur).
           RUN piXmlAtributo (INPUT "msgerror", INPUT aux_msgerror).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Valida_Protocolo */


/* ------------------------------------------------------------------------ */
/*         Valida os Dados do Protocolo MD5 Informado - SICREDI             */
/* ------------------------------------------------------------------------ */
PROCEDURE pc_valida_protocolo:

    RUN pc_valida_protocolo IN hBO
                           (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_cdprogra,
                            INPUT aux_idorigem,
                            INPUT aux_dtmvtolt,
                            INPUT aux_dtmvtopr,
                            INPUT aux_nmdatela,
                            INPUT aux_cddopcao,
                            INPUT aux_nrdconta,
                            INPUT aux_nrdocmto,
                            INPUT aux_dtmvtolx,
                            INPUT aux_horproto,
                            INPUT aux_minproto,
                            INPUT aux_segproto,
                            INPUT aux_vlprotoc,
                            INPUT aux_dsprotoc,
                            INPUT aux_nrseqaut,
                            INPUT TRUE,        
                           OUTPUT aux_nmdcampo,
                           OUTPUT aux_msgretur,
                           OUTPUT aux_msgerror,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro  THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                      "validacao de dados.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
        RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
        RUN piXmlSave.
    END.
    ELSE DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "msgretur", INPUT aux_msgretur).
        RUN piXmlAtributo (INPUT "msgerror", INPUT aux_msgerror).
        RUN piXmlSave.
    END.
    

END PROCEDURE.
