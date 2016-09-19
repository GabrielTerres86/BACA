/*.............................................................................

   Programa: xb1wgen0031.p
   Autor   : Guilherme
   Data    : Julho/2008                     Ultima atualizacao: 28/06/2011 

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Anotacoes (b1wgen0031.p)

   Alteracoes: 28/06/2011 - Incluida procedure busca-alteracoes utilizada pela
                            tela ALTERA (Henrique).

............................................................................ */


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.
DEF VAR aux_cdrelato AS INTE                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0031tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nmrotina" THEN aux_nmrotina = tt-param.valorCampo.
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "cdrelato" THEN aux_cdrelato = INTE(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

/*****************************************************************************
  Buscar alteracoes na conta do cooperado.
******************************************************************************/
PROCEDURE busca-alteracoes:

    DEF VAR aux_nmprimtl AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrdctitg AS CHAR                                       NO-UNDO.
    DEF VAR aux_dssititg AS CHAR                                       NO-UNDO.

    RUN busca-alteracoes IN hBO (INPUT  aux_cdcooper,
                                 INPUT  aux_nrdconta,
                                 OUTPUT aux_nmprimtl,
                                 OUTPUT aux_nrdctitg,
                                 OUTPUT aux_dssititg,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-crapalt).

    IF  RETURN-VALUE = "NOK"  THEN
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-crapalt:HANDLE,
                               INPUT "Dados").
            RUN piXmlAtributo (INPUT "nmprimtl", INPUT aux_nmprimtl).
            RUN piXmlAtributo (INPUT "nrdctitg", INPUT aux_nrdctitg).
            RUN piXmlAtributo (INPUT "dssititg", INPUT aux_dssititg).
            RUN piXmlSave.
        END.

END PROCEDURE /* FIM busca-alteracoes */


/* ......................................................................... */
