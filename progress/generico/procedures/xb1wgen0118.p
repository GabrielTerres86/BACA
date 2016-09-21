/*............................................................................
   
   Programa: xb1wgen0118.p                  
   Autor(a): Gabriel
   Data    : 07/10/2011                        Ultima atualizacao: 14/03/2013

   Dados referentes ao programa:

   Objetivo  : xBO de comunicacao com a BO de Transferencia entre Cooperativas

   Alteracoes: 27/12/2102 - Tratar paginacao na listagem (Gabriel). 
        
               14/03/2013 - Incluir campo de origem (Gabriel).  
   
............................................................................*/

DEF VAR aux_cdcooper AS INTE                                          NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                          NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                          NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                          NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                          NO-UNDO.
DEF VAR aux_idorigem AS INTE                                          NO-UNDO. 

DEF VAR aux_vlaprcoo AS DECI                                          NO-UNDO.
DEF VAR aux_tpoperac AS INTE                                          NO-UNDO.
DEF VAR aux_tpdenvio AS INTE                                          NO-UNDO.
DEF VAR aux_dttransa AS DATE                                          NO-UNDO.
DEF VAR aux_nrregist AS INTE                                          NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                          NO-UNDO.
DEF VAR aux_qtregist AS INTE                                          NO-UNDO.
DEF VAR aux_cdpacrem AS INTE                                          NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0118tt.i }

   
/*............................... PROCEDURES ...............................*/

PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "vlaprcoo" THEN aux_vlaprcoo = DECI(tt-param.valorCampo).
            WHEN "tpoperac" THEN aux_tpoperac = INTE(tt-param.valorCampo).
            WHEN "tpdenvio" THEN aux_tpdenvio = INTE(tt-param.valorCampo).
            WHEN "dttransa" THEN aux_dttransa = DATE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "cdpacrem" THEN aux_cdpacrem = INTE(tt-param.valorCampo).
           
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/*****************************************************************************
 Procedure para valores parametrizados na TRFCOP. 
*****************************************************************************/
PROCEDURE busca-parametro:

    RUN busca-parametro IN hbo (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_dtmvtolt,
                                INPUT FALSE,
                               OUTPUT TABLE tt-erro,
                               OUTPUT aux_vlaprcoo).
                       
    IF   RETURN-VALUE <> "OK"   THEN
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
    ELSE
         DO:
             RUN piXmlNew. 
             RUN piXmlAtributo (INPUT "vlaprcoo", 
                                INPUT STRING(aux_vlaprcoo,"zzz,zzz,zz9.99")).
             RUN piXmlSave.
         END.

END PROCEDURE.


/*****************************************************************************
 Alterar os parametros da TRFCOP.
*****************************************************************************/
PROCEDURE altera-parametro:

    RUN altera-parametro IN hbo (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_vlaprcoo,
                                 INPUT aux_dtmvtolt,
                                 INPUT FALSE,
                                OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE <> "OK"   THEN
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
    ELSE
         DO:
             RUN piXmlNew. 
             RUN piXmlSave.
         END.

END PROCEDURE.


/*****************************************************************************
 Buscar as operacoes (Transferencia/Deposito) para a TRFCOP.
*****************************************************************************/
PROCEDURE busca-operacoes:

    RUN busca-operacoes IN hbo(INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_dttransa,
                               INPUT aux_tpoperac,
                               INPUT aux_tpdenvio,
                               INPUT aux_cdpacrem,
                               INPUT aux_dtmvtolt,
                               INPUT aux_nrregist,
                               INPUT aux_nriniseq,
                               INPUT FALSE,
                              OUTPUT aux_qtregist,
                              OUTPUT TABLE tt-crapldt,
                              OUTPUT TABLE tt-erro).


    IF   RETURN-VALUE <> "OK"   THEN
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
    ELSE
         DO:
             RUN piXmlNew. 
             RUN piXmlExport (INPUT TEMP-TABLE tt-crapldt:HANDLE,
                              INPUT "Operacoes").
             RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
             RUN piXmlSave.
         END.

END PROCEDURE.


/* ........................................................................ */
