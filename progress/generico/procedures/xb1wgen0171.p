/*.............................................................................

   Programa: xb1wgen0171.p
   Autor   : Guilherme/SUPERO
   Data    : Agosto/2013                     Ultima atualizacao: 20/05/2016

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao referente a tela GRAVAM, 
               Procedimentos do GRAVAMES

   Alteracoes: 20/05/2016 - Ajustes decorrente a conversção da tela GRAVAM
							(Andrei - RKAM).

............................................................................ */

DEF VAR aux_cdcooper LIKE crapcop.cdcooper                             NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci LIKE crapass.cdagenci                             NO-UNDO.

DEF VAR aux_nrdconta LIKE crapass.nrdconta                             NO-UNDO.
DEF VAR aux_nrctrpro LIKE crapepr.nrctremp                             NO-UNDO.
DEF VAR aux_cdlcremp LIKE crapepr.cdlcremp                             NO-UNDO.
DEF VAR aux_dssitfin AS CHAR FORMAT "X(1)"                             NO-UNDO.
DEF VAR aux_cddopcao AS CHAR FORMAT "X(1)"                             NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_flgexist AS LOG                                            NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_cdfinemp AS INTE FORMAT "zzz"                              NO-UNDO.
DEF VAR ret_dsfinemp AS CHAR FORMAT "x(25)"                            NO-UNDO.
DEF VAR ret_dssitfin AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0171tt.i }



/*................................ PROCEDURES ................................*/

/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "nrctrpro" THEN aux_nrctrpro = INTE(tt-param.valorCampo).
            WHEN "cdfinemp" THEN aux_cdfinemp = INTE(tt-param.valorCampo).
            WHEN "cdlcremp" THEN aux_cdlcremp = INTE(tt-param.valorCampo).
            WHEN "dssitfin" THEN aux_dssitfin = STRING(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = STRING(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

PROCEDURE registrar_gravames:

    RUN registrar_gravames IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_nrdconta,
                                   INPUT aux_nrctrpro,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_cddopcao,
                                  OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.     
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.
    
        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    
    END.
    ELSE DO:

        RUN piXmlNew.
        RUN piXmlSave.

    END.

END PROCEDURE.

/******************************************************************************/
