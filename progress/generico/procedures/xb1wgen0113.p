/*.............................................................................

   Programa: xb1wgen0113.p
   Autor   : Fabricio
   Data    : Setembro/2011                     Ultima atualizacao: 22/12/2011

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO - Tela SOLINS.

   Alteracoes: 22/12/2011 - Tratamento de erros e leituras de tabelas (Tiago).

............................................................................ */

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nridtrab AS DECI                                           NO-UNDO.
DEF VAR aux_nrbenefi AS DECI                                           NO-UNDO.
DEF VAR aux_nmbenefi AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS INTE                                           NO-UNDO.
DEF VAR aux_motivsol AS INTE                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR INIT ""                                   NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INT                                            NO-UNDO. 
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.

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
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nridtrab" THEN aux_nridtrab = DECI(tt-param.valorCampo).
            WHEN "nrbenefi" THEN aux_nrbenefi = DECI(tt-param.valorCampo).
            WHEN "nmbenefi" THEN aux_nmbenefi = tt-param.valorCampo.
            WHEN "cddopcao" THEN aux_cddopcao = INTE(tt-param.valorCampo).
            WHEN "motivsol" THEN aux_motivsol = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

PROCEDURE cadastra_solicitacao:
    
    RUN cadastra_solicitacao IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_cdoperad,
                                     INPUT aux_idorigem, /* Ayllos WEB */
                                     INPUT aux_nridtrab,
                                     INPUT aux_nrbenefi,
                                     INPUT aux_nmbenefi,
                                     INPUT aux_cddopcao,
                                     INPUT aux_motivsol,
                                     INPUT aux_dsiduser,
                                     OUTPUT aux_nmarqimp,
                                     OUTPUT aux_nmarqpdf,
                                     OUTPUT aux_dscritic).

    IF  RETURN-VALUE = "OK"  THEN
        DO:

            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlAtributo (INPUT "dscritic", INPUT STRING(aux_dscritic)).
            RUN piXmlSave.

        END.
    ELSE
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

END PROCEDURE.
