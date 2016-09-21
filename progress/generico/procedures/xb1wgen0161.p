/*.............................................................................

   Programa: xb1wgen0161.p
   Autor   : Andre Santos - SUPERO
   Data    : Julho/2013                     Ultima atualizacao: 25/07/2013

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao referente a tela LISEPR, 
               Pesquisa Emprestimos Liberados.

   Alteracoes: 
   
............................................................................ */

DEF VAR aux_cdcooper LIKE crapcop.cdcooper                             NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci LIKE crapass.cdagenci                             NO-UNDO.
DEF VAR aux_cdlcremp LIKE crapepr.cdlcremp                             NO-UNDO.
DEF VAR aux_cddotipo AS CHAR FORMAT "X(1)"                             NO-UNDO.
DEF VAR aux_cddopcao AS CHAR FORMAT "X(1)"                             NO-UNDO.
DEF VAR aux_dtinicio AS DATE                                           NO-UNDO.
DEF VAR aux_dttermin AS DATE                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_flgexist AS LOG                                            NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_cdagesel AS INTE                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_tipsaida AS INT                                            NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_vlrtotal AS DEC                                            NO-UNDO.

DEF VAR aux_nrdcaixa AS INT                                            NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0161tt.i }
                                       
/*................................ PROCEDURES ................................*/

/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:
    
    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "dtmvtopr" THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "cdlcremp" THEN aux_cdlcremp = INTE(tt-param.valorCampo).
            WHEN "cddotipo" THEN aux_cddotipo = STRING(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = STRING(tt-param.valorCampo).
            WHEN "dtinicio" THEN aux_dtinicio = DATE(tt-param.valorCampo).
            WHEN "dttermin" THEN aux_dttermin = DATE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = STRING(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = STRING(tt-param.valorCampo).
            WHEN "nmdcampo" THEN aux_nmdcampo = STRING(tt-param.valorCampo).
            WHEN "cdagesel" THEN aux_cdagesel = INTE(tt-param.valorCampo).
            WHEN "dsiduser" THEN aux_dsiduser = STRING(tt-param.valorCampo).
            WHEN "tipsaida" THEN aux_tipsaida = INT(tt-param.valorCampo).
            WHEN "nmarquiv" THEN aux_nmarquiv = STRING(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

PROCEDURE busca_emprestimos:

    RUN busca_emprestimos IN hBO(INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_idorigem,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_cddopcao,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_dtmvtopr,
                                 INPUT aux_cdagesel,
                                 INPUT aux_dtinicio,
                                 INPUT aux_dttermin,
                                 INPUT aux_cdlcremp,
                                 INPUT aux_cddotipo,
                                 INPUT aux_nrregist,
                                 INPUT aux_nriniseq,
                                 INPUT aux_dsiduser,
                                 INPUT aux_nmarquiv,
                                 INPUT aux_tipsaida,
                                 OUTPUT aux_nmdcampo,
                                 OUTPUT aux_qtregist,
                                 OUTPUT aux_vlrtotal,
                                 OUTPUT aux_nmarqimp,
                                 OUTPUT aux_nmarqpdf,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-emprestimo).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF NOT AVAILABLE tt-erro THEN
             DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
             END.

          RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").

       END.
    ELSE 
       DO:
          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-emprestimo:HANDLE,
                           INPUT "Emprestimo").
          RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
          RUN piXmlAtributo (INPUT "vlrtotal",INPUT STRING(aux_vlrtotal)).
          RUN piXmlAtributo (INPUT "nmarqimp",
                             INPUT STRING(aux_nmarqimp)).
          RUN piXmlAtributo (INPUT "nmarqpdf",
                             INPUT STRING(aux_nmarqpdf)).
          RUN piXmlAtributo (INPUT "nmdcampo",
                             INPUT STRING(aux_nmdcampo)).
          RUN piXmlSave.

       END.

END PROCEDURE.


