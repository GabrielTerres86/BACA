/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0164.p
     Autor   : Jéssica Laverde Gracino (DB1)
     Data    : 30/10/2013                    Ultima atualizacao: 00/00/0000

     Objetivo  : BO de Comunicacao XML x BO - Tela ENDAVA

     Alteracoes: 19/03/2015 - Incluir a paginação dos resultados para web (Vanessa).

............................................................................*/


/*..........................................................................*/

DEF VAR aux_cdcooper     AS INTE                                     NO-UNDO.
DEF VAR aux_cdagenci     AS INTE                                     NO-UNDO.
DEF VAR aux_cdoperad     AS CHAR                                     NO-UNDO.
DEF VAR aux_nmdatela     AS CHAR                                     NO-UNDO.
DEF VAR aux_tpctrato     AS INTE                                     NO-UNDO.
DEF VAR aux_pro_cpfcgc   AS DECI                                     NO-UNDO.

DEF VAR aux_nrctremp     AS INTE                                     NO-UNDO.
DEF VAR aux_nrdconta     AS INTE                                     NO-UNDO.
DEF VAR aux_dsendav1     AS CHAR                                     NO-UNDO.
DEF VAR aux_dsendav2     AS CHAR                                     NO-UNDO.
DEF VAR aux_nrendere     AS INTE                                     NO-UNDO.
DEF VAR aux_nrfonres     AS CHAR                                     NO-UNDO.
DEF VAR aux_complend     AS CHAR                                     NO-UNDO.
DEF VAR aux_nrcxapst     AS INTE                                     NO-UNDO.
DEF VAR aux_dsdemail     AS CHAR                                     NO-UNDO.
DEF VAR aux_nmcidade     AS CHAR                                     NO-UNDO.
DEF VAR aux_cdufresd     AS CHAR                                     NO-UNDO.
DEF VAR aux_nrcepend     AS INTE                                     NO-UNDO.
DEF VAR aux_idorigem     AS INTE                                     NO-UNDO.
DEF VAR aux_nrregist     AS INTE                                     NO-UNDO.
DEF VAR aux_nriniseq     AS INTE                                     NO-UNDO.
DEF VAR aux_qtregist     AS INTE                                     NO-UNDO.




{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0164tt.i }

/*............................... PROCEDURES ................................*/

PROCEDURE valores_entrada:

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:

             WHEN "cdcooper"     THEN aux_cdcooper     = INTE(tt-param.valorCampo).
             WHEN "cdagenci"     THEN aux_cdagenci     = INTE(tt-param.valorCampo).
             WHEN "cdoperad"     THEN aux_cdoperad     = tt-param.valorCampo.
             WHEN "nmdatela"     THEN aux_nmdatela     = tt-param.valorCampo.
             WHEN "tpctrato"     THEN aux_tpctrato     = INTE(tt-param.valorCampo).
             WHEN "pro_cpfcgc"   THEN aux_pro_cpfcgc   = DECI(tt-param.valorCampo).
             
             WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
             WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
             WHEN "dsendav1" THEN aux_dsendav1 = tt-param.valorCampo.
             WHEN "dsendav2" THEN aux_dsendav2 = tt-param.valorCampo.
             WHEN "nrendere" THEN aux_nrendere = INTE(tt-param.valorCampo).
             WHEN "nrfonres" THEN aux_nrfonres = tt-param.valorCampo.
             WHEN "complend" THEN aux_complend = tt-param.valorCampo.
             WHEN "nrcxapst" THEN aux_nrcxapst = INTE(tt-param.valorCampo).
             WHEN "dsdemail" THEN aux_dsdemail = tt-param.valorCampo.
             WHEN "nmcidade" THEN aux_nmcidade = tt-param.valorCampo.
             WHEN "cdufresd" THEN aux_cdufresd = tt-param.valorCampo.
             WHEN "nrcepend" THEN aux_nrcepend = INTE(tt-param.valorCampo).
             WHEN "idorigem" THEN aux_idorigem     = INTE(tt-param.valorCampo).
             WHEN "nrcepend" THEN aux_nrcepend = INTE(tt-param.valorCampo).
             WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
             WHEN "qtregist" THEN aux_qtregist = INTE(tt-param.valorCampo).
             
         END CASE. 

     END. /** Fim do FOR EACH tt-param **/


END PROCEDURE. /* valores_entrada */


/* -------------------------------------------------------------------------- */
/*                  EFETUA A PESQUISA MANUTENCAO DE ENDERECOS                 */
/* -------------------------------------------------------------------------- */
PROCEDURE busca_crapavt:
    
    RUN busca_crapavt IN hbo
                  (  INPUT aux_cdcooper,
                     INPUT aux_cdagenci,
                     INPUT aux_cdoperad,
                     INPUT aux_dtmvtolt,
                     INPUT aux_nmdatela,
                     INPUT 4,
                     INPUT aux_pro_cpfcgc,
                     INPUT aux_idorigem,
                     INPUT aux_nrregist,
                     INPUT aux_nriniseq,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-crapavt,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-crapavt:HANDLE,
                            INPUT "Dados").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlSave.
        END.

END PROCEDURE. /* busca_crapavt */

/* ------------------------------------------------------------------------ */
/*                        GRAVA DADOS DOS ENDERECOS                         */
/* ------------------------------------------------------------------------ */
PROCEDURE grava_crapavt:
    
    RUN grava_crapavt IN hBO
                  (  INPUT aux_cdcooper,
                     INPUT aux_cdagenci, 
                     INPUT aux_pro_cpfcgc,
                     INPUT aux_nrctremp,
                     INPUT aux_nrdconta,
                     INPUT aux_tpctrato,
                     INPUT aux_dtmvtolt,
                     INPUT aux_dsendav1,
                     INPUT aux_dsendav2,
                     INPUT aux_nrendere,
                     INPUT aux_nrfonres,
                     INPUT aux_complend,
                     INPUT aux_nrcxapst,
                     INPUT aux_dsdemail,
                     INPUT aux_nmcidade,
                     INPUT aux_cdufresd,
                     INPUT aux_nrcepend,
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

END PROCEDURE. /* grava_crapavt */



