/*.............................................................................

     Programa: sistema/generico/procedures/xb1wgen0108.p
     Autor   : Rogerius Militão
     Data    : Agosto/2011                       Ultima atualizacao: 00/00/0000

     Objetivo  : BO de Comunicacao XML x BO - Telas concbb

     Alteracoes: 

.............................................................................*/



/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_dtmvtolx AS DATE                                           NO-UNDO.
DEF VAR aux_cdagencx AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixx AS INTE                                           NO-UNDO.
DEF VAR aux_inss     AS LOGICAL                                        NO-UNDO.
DEF VAR aux_valorpag AS DECIMAL                                        NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.

DEF VAR aux_flggeren AS LOGICAL                                        NO-UNDO.
DEF VAR aux_mrsgetor AS CHAR                                           NO-UNDO.
DEF VAR aux_msgprint AS CHAR                                           NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.

DEF VAR aux_registro AS ROWID                                          NO-UNDO.

{ sistema/generico/includes/b1wgen0108tt.i }
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
             WHEN "dtmvtolx" THEN aux_dtmvtolx = DATE(tt-param.valorCampo).
             WHEN "cdagencx" THEN aux_cdagencx = INTE(tt-param.valorCampo).
             WHEN "nrdcaixx" THEN aux_nrdcaixx = INTE(tt-param.valorCampo).
             WHEN "inss"     THEN aux_inss     = LOGICAL(tt-param.valorCampo).
             WHEN "valorpag" THEN aux_valorpag = DECIMAL(tt-param.valorCampo).
             WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
             WHEN "flggeren" THEN aux_flggeren = LOGICAL(tt-param.valorCampo).
             WHEN "mrsgetor" THEN aux_mrsgetor = tt-param.valorCampo.
             WHEN "msgprint" THEN aux_msgprint = tt-param.valorCampo.
             WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.
             WHEN "nmarqpdf" THEN aux_nmarqpdf = tt-param.valorCampo.
             WHEN "qtregist" THEN aux_qtregist = INTE(tt-param.valorCampo).
             WHEN "registro" THEN aux_registro = TO-ROWID(tt-param.valorCampo).

         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */

/* ------------------------------------------------------------------------ */
/*                    EFETUA A BUSCA DOS DADOS DA CONCBB                    */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_dtmvtolt,
                      INPUT aux_cddopcao,
                      INPUT aux_dtmvtolx,
                      INPUT aux_cdagencx,
                      INPUT aux_nrdcaixx,
                      INPUT aux_inss,
                      INPUT aux_valorpag,
                      INPUT aux_nrregist,
                      INPUT aux_nriniseq,
                      INPUT YES,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-concbb,
                     OUTPUT TABLE tt-movimentos,
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
           RUN piXmlExport   (INPUT TEMP-TABLE tt-concbb:HANDLE,
                              INPUT "Concbb").
           RUN piXmlExport   (INPUT TEMP-TABLE tt-movimentos:HANDLE,
                              INPUT "Movimentos").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*       BUSCA VALORES DO MOVIMENTO LANÇADO PELO BB NO DIA ANTERIOR         */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Movimento:

    RUN Busca_Movimento IN hBO
                        ( INPUT aux_cdcooper,
                          INPUT aux_cdagenci,
                          INPUT aux_nrdcaixa,
                          INPUT aux_dtmvtolt,
                          INPUT aux_cdagencx,
                          INPUT aux_nrdcaixx,
                          INPUT aux_dtmvtolx,
                          INPUT aux_flggeren,
                         OUTPUT aux_mrsgetor,
                         OUTPUT aux_msgprint,
                         OUTPUT TABLE tt-total,
                         OUTPUT TABLE tt-mensagens,
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
           RUN piXmlExport   (INPUT TEMP-TABLE tt-total:HANDLE,
                              INPUT "Total").
           RUN piXmlAtributo (INPUT "mrsgetor",INPUT STRING(aux_mrsgetor)).
           RUN piXmlAtributo (INPUT "msgprint",INPUT STRING(aux_msgprint)).
           RUN piXmlExport   (INPUT TEMP-TABLE tt-mensagens:HANDLE,
                              INPUT "Mensagens").
           RUN piXmlSave.
        END.

END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                      LISTA FATURAS DA TELA CONCBB                        */
/* ------------------------------------------------------------------------ */
PROCEDURE Lista_Faturas:

    RUN Lista_Faturas IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_idorigem,
                        INPUT aux_dtmvtolt,
                        INPUT aux_dsiduser,
                        INPUT aux_cdagencx,
                        INPUT aux_nrdcaixx,
                        INPUT aux_dtmvtolx,
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

/* ------------------------------------------------------------------------ */
/*                       LISTA LOTES DA TELA CONCBB                         */
/* ------------------------------------------------------------------------ */
PROCEDURE Lista_Lotes:

    RUN Lista_Lotes   IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_idorigem,
                        INPUT aux_dtmvtolt,
                        INPUT aux_dsiduser,
                        INPUT aux_cdagencx,
                        INPUT aux_nrdcaixx,
                        INPUT aux_dtmvtolx,
                        INPUT aux_registro,
                        INPUT aux_inss,
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

