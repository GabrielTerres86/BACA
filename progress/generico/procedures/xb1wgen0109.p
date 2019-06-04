/*.............................................................................

     Programa: sistema/generico/procedures/xb1wgen0109.p
     Autor   : Rogerius Militão
     Data    : Agosto/2011                       Ultima atualizacao: 21/03/2019

     Objetivo  : BO de Comunicacao XML x BO - Telas imprel

     Alteracoes: 21/03/2019 - Adicionado do campo periodo na tabela tt-nmrelato para utilizar no 
                              relatorio 219. Acelera - Reapresentacao automática de cheques (Lombardi).

.............................................................................*/



/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrelat AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenca AS INTE                                           NO-UNDO.
DEF VAR aux_cdperiod AS INTE INIT 1                                    NO-UNDO.
DEF VAR aux_flgtermi AS LOGICAL                                        NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0109tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:
            
             WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
             WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
             WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "nrdrelat" THEN aux_nrdrelat = INTE(tt-param.valorCampo).
             WHEN "cdagenca" THEN aux_cdagenca = INTE(tt-param.valorCampo).
             WHEN "cdperiod" THEN aux_cdperiod = INTE(tt-param.valorCampo).
             WHEN "flgtermi" THEN aux_flgtermi = LOGICAL(tt-param.valorCampo).
             WHEN "contador" THEN aux_contador = INTE(tt-param.valorCampo).
             WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.
             WHEN "nmarqpdf" THEN aux_nmarqpdf = tt-param.valorCampo.

         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */

/* ------------------------------------------------------------------------ */
/*                  GERA LISTA COM RELATÓRIOS DO SISTEMA                    */
/* ------------------------------------------------------------------------ */
PROCEDURE Lista_Relatorios:

    RUN Lista_Relatorios IN hBO
                         ( OUTPUT TABLE tt-nmrelato ).    

    RUN piXmlNew.
    RUN piXmlExport   (INPUT TEMP-TABLE tt-nmrelato:HANDLE,
                      INPUT "Relatorio").
    RUN piXmlSave.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                     GERA IMPRESSAO COM RELATORIOS                        */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Impressao:

    RUN Gera_Impressao IN hBO
                        ( INPUT aux_cdcooper,
                          INPUT aux_cdagenci,
                          INPUT aux_nrdcaixa,
                          INPUT aux_idorigem,
                          INPUT aux_dsiduser,
                          INPUT aux_cddopcao,
                          INPUT aux_nrdrelat,
                          INPUT aux_cdagenca,
                          INPUT aux_cdperiod,
                         OUTPUT aux_nmarqimp,
                         OUTPUT aux_nmarqpdf,
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
           RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
           RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
           RUN piXmlSave.
        END.

END PROCEDURE.

