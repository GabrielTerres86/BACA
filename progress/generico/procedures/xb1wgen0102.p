/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0102.p
    Autor   : Gabriel Capoia dos Santos
    Data    : Julho/2011                       Ultima atualizacao: 00/00/0000

    Objetivo  : BO de Comunicacao XML x BO - Telas de extrato

    Alteracoes: 
   
.............................................................................*/

                                                                             

/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrpro AS INTE                                           NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_idseqbem AS INTE                                           NO-UNDO.
DEF VAR aux_flgalfid AS LOGI                                           NO-UNDO.
DEF VAR aux_flgperte AS LOGI                                           NO-UNDO.
DEF VAR aux_dtvigseg AS DATE                                           NO-UNDO.
DEF VAR aux_flglbseg AS LOGI                                           NO-UNDO.
DEF VAR aux_flgrgcar AS LOGI                                           NO-UNDO.

DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0102tt.i } 

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
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrctrpro" THEN aux_nrctrpro = INTE(tt-param.valorCampo).
            WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
            WHEN "idseqbem" THEN aux_idseqbem = INTE(tt-param.valorCampo).
            WHEN "flgalfid" THEN aux_flgalfid = LOGICAL(tt-param.valorCampo).
            WHEN "flgperte" THEN aux_flgperte = LOGICAL(tt-param.valorCampo).
            WHEN "dtvigseg" THEN aux_dtvigseg = DATE(tt-param.valorCampo).
            WHEN "flglbseg" THEN aux_flglbseg = LOGICAL(tt-param.valorCampo).
            WHEN "flgrgcar" THEN aux_flgrgcar = LOGICAL(tt-param.valorCampo).
            WHEN "nmdcampo" THEN aux_nmdcampo = tt-param.valorCampo.
            
        END CASE.

    END. /** Fim do FOR EACH tt-param **/


END PROCEDURE. /* valores_entrada */

/*****************************************************************************/
/*                                Buscar dados                               */
/*****************************************************************************/
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_cddopcao,
                            INPUT aux_nrctremp,
                            INPUT TRUE, /* LOG */
                           OUTPUT TABLE tt-infoepr,
                           OUTPUT TABLE tt-aliena,
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

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlExport (INPUT TEMP-TABLE tt-infoepr:HANDLE,
                             INPUT "Associado").
            RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-infoepr:HANDLE,
                             INPUT "Associado").
            RUN piXmlExport (INPUT TEMP-TABLE tt-aliena:HANDLE,
                             INPUT "Alienacao").
            RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************/
/*                                Valida dados                               */
/*****************************************************************************/
PROCEDURE Valida_Dados:

    RUN Valida_Dados IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_dtmvtolt,
                             INPUT aux_cddopcao,
                             INPUT aux_nrdconta,
                             INPUT aux_nrctremp,
                             INPUT aux_idseqbem,
                             INPUT aux_flgalfid,
                             INPUT aux_flgperte,
                             INPUT aux_dtvigseg,
                            OUTPUT TABLE tt-mensagens,
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

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-mensagens:HANDLE,
                             INPUT "Mensagens").
            RUN piXmlSave.
        END.

END PROCEDURE.

/*****************************************************************************/
/*                                 Grava dados                               */
/*****************************************************************************/
PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_dtmvtolt,
                            INPUT aux_cddopcao,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT aux_nrctrpro,
                            INPUT aux_idseqbem,
                            INPUT aux_flgalfid,
                            INPUT aux_dtvigseg,
                            INPUT aux_flglbseg,
                            INPUT aux_flgrgcar,
                            INPUT aux_flgperte,
                            INPUT TRUE, /* LOG */
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

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlSave.

        END.

        ELSE
            DO:
                RUN piXmlNew.
                RUN piXmlSave.
            END.

END PROCEDURE.
