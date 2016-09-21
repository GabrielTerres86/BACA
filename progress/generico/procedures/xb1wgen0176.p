/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0176.p
     Autor   : Gabriel Capoia
     Data    : 19/09/2013                    Ultima atualizacao: 00/00/0000

     Objetivo  : BO de Comunicacao XML x BO - Tela GT0002

     Alteracoes: 

............................................................................*/


/*..........................................................................*/

DEF VAR aux_cdcooper AS INTE                                         NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                         NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                         NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                         NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                         NO-UNDO.
DEF VAR aux_idorigem AS INTE                                         NO-UNDO.
DEF VAR aux_dsdepart AS CHAR                                         NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF VAR aux_cdconven AS INTE                                         NO-UNDO.
DEF VAR aux_cdcooped AS INTE                                         NO-UNDO.
DEF VAR aux_nrregist AS INTE                                         NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                         NO-UNDO.

DEF VAR aux_qtregist AS INTE                                         NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                         NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0176tt.i }

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
             WHEN "dsdepart" THEN aux_dsdepart = tt-param.valorCampo.
             WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "cdconven" THEN aux_cdconven = INTE(tt-param.valorCampo).
             WHEN "cdcooped" THEN aux_cdcooped = INTE(tt-param.valorCampo).
             WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).

         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */


/* -------------------------------------------------------------------------- */
/*       EFETUA A PESQUISA MANUTENCAO DE CONVENIOS POR COOPERATIVA            */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Dados:
    
    RUN Busca_Dados IN hBO
                  (  INPUT aux_cdcooper,
                     INPUT aux_cdagenci,
                     INPUT aux_nrdcaixa,
                     INPUT aux_cdoperad,
                     INPUT aux_nmdatela,
                     INPUT aux_idorigem,
                     INPUT aux_dsdepart,
                     INPUT aux_cddopcao,
                     INPUT aux_cdconven,
                     INPUT aux_cdcooped,
                     INPUT aux_nrregist,
                     INPUT aux_nriniseq,
                     INPUT TRUE,
                    OUTPUT aux_qtregist,
                    OUTPUT aux_nmdcampo,
                    OUTPUT TABLE tt-gt0002,
                    OUTPUT TABLE tt-gt0002-aux,
                    OUTPUT TABLE tt-erro).
                    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-gt0002-aux:HANDLE,
                            INPUT "Dados").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

/* ------------------------------------------------------------------------ */
/*                        GRAVA DADOS DOS OPERADORES                        */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Dados:
    
    RUN Grava_Dados IN hBO
                  (  INPUT aux_cdcooper,
                     INPUT aux_cdagenci,
                     INPUT aux_nrdcaixa,
                     INPUT aux_cdoperad,
                     INPUT aux_dtmvtolt,
                     INPUT aux_nmdatela,
                     INPUT aux_idorigem,
                     INPUT aux_cddopcao,
                     INPUT aux_cdconven,
                     INPUT aux_cdcooped,
                    OUTPUT TABLE tt-erro).
                    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
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

END PROCEDURE. /* Grava_Dados */
