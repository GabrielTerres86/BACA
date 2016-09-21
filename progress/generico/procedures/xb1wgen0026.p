/*.............................................................................

   Programa: xb1wgen0026.p
   Autor   : Guilherme
   Data    : Fevereiro/2008                     Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Convenios (b1wgen0026.p)

   Alteracoes: 

............................................................................ */


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_dtiniper AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0026tt.i }
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
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "dtiniper" THEN aux_dtiniper = DATE(tt-param.valorCampo).
            WHEN "dtfimper" THEN aux_dtfimper = DATE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/******************************************************************************/
/**               Procedure para lista os convenios                          **/
/******************************************************************************/
PROCEDURE lista_conven:

    RUN lista_conven IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nrdconta,
                             INPUT aux_idorigem,
                             INPUT aux_idseqttl,
                             INPUT aux_nmdatela,
                             INPUT TRUE, /* Gerar Log */
                            OUTPUT TABLE tt-conven,
                            OUTPUT TABLE tt-totconven).

    RUN piXmlNew.
    RUN piXmlExport (INPUT TEMP-TABLE tt-conven:HANDLE,
                     INPUT "Dados").
    RUN piXmlExport (INPUT TEMP-TABLE tt-totconven:HANDLE,
                     INPUT "Total").
    RUN piXmlSave.         

END PROCEDURE.

