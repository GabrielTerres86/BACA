/*.............................................................................

     Programa: sistema/generico/procedures/xb1wgen0121.p
     Autor   : Rogerius Militão
     Data    : Outubro/2011                       Ultima atualizacao: 27/04/2012

     Objetivo  : BO de Comunicacao XML x BO - Telas sumlot

     Alteracoes: 27/04/2012 - Alterado chamada de função Gera_Criticas para 
                              passar parâmetro dtmvtoan (Guilherme Maba).

.............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.

DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagencx AS INTE                                           NO-UNDO. 
DEF VAR aux_cdbccxlt AS INTE                                           NO-UNDO. 
DEF VAR aux_qtcompln AS INTE                                           NO-UNDO. 
DEF VAR aux_vlcompap AS DECIMAL                                        NO-UNDO. 
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO. 
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO. 

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:
            
             WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
             WHEN "dtmvtoan" THEN aux_dtmvtoan = DATE(tt-param.valorCampo).
             WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
             
             WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "cdagencx" THEN aux_cdagencx = INTE(tt-param.valorCampo).
             WHEN "cdbccxlt" THEN aux_cdbccxlt = INTE(tt-param.valorCampo).
             WHEN "qtcompln" THEN aux_qtcompln = INTE(tt-param.valorCampo).
             WHEN "vlcompap" THEN aux_vlcompap = DECIMAL(tt-param.valorCampo).
             WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.
             WHEN "nmarqpdf" THEN aux_nmarqpdf = tt-param.valorCampo.

         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */

/* ------------------------------------------------------------------------ */
/*                  BUSCA AS CRITICAS PARA TELA SUMLOT                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Criticas:

    RUN Gera_Criticas IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_dtmvtolt,
                      INPUT aux_dtmvtoan,
                      INPUT aux_idorigem,
                      INPUT aux_dsiduser,
                      INPUT aux_cdagencx,
                      INPUT aux_cdbccxlt,
                     OUTPUT aux_qtcompln,
                     OUTPUT aux_vlcompap,
                     OUTPUT aux_nmdcampo,
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
           RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "qtcompln", INPUT aux_qtcompln).
           RUN piXmlAtributo (INPUT "vlcompap", INPUT aux_vlcompap).
           RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE.
