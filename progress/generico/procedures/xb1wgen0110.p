/*..............................................................................

   Programa: xb1wgen0110.p
   Autor   : Adriano
   Data    : Agosto/2011                        Ultima atualizacao: 11/04/2013

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO Generica (b1wgen0110.p)

   Alteracoes: 11/04/2013 - Incluido novos parametros e ajusta a ordem dos 
                            mesmos nas procedures envia_email_alerta,
                            alerta_fraude e na funcao fget_existe_risco_cpfcnpj
                            (Adriano).
   

..............................................................................*/

DEF VAR aux_nmdatela AS CHAR                               NO-UNDO.
DEF VAR aux_dsoperac AS CHAR                               NO-UNDO.
DEF VAR aux_cdcooper AS INT                                NO-UNDO.
DEF VAR aux_nrcpfcgc AS DEC                                NO-UNDO.
DEF VAR aux_nmoperad AS CHAR                               NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                               NO-UNDO.
DEF VAR aux_nrdconta AS INT                                NO-UNDO.
DEF VAR aux_idorigem AS INT                                NO-UNDO.
DEF VAR aux_cdagenci AS INT                                NO-UNDO.
DEF VAR aux_nrdcaixa AS INT                                NO-UNDO.
DEF VAR aux_idseqttl AS INT                                NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                               NO-UNDO.
DEF VAR aux_nmpessoa AS CHAR                               NO-UNDO.
DEF VAR aux_bloqueia AS LOGICAL                            NO-UNDO.
DEF VAR aux_cdoperac AS INT                                NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


FUNCTION fget_existe_risco_cpfcnpj 
         RETURNS LOGICAL (INPUT par_nrcpfcgc AS DECIMAL,
                          OUTPUT par_nmpessoa AS CHAR) FORWARD.


/* .........................PROCEDURES................................... */


/**************************************************************************
       Procedure para atribuicao dos dados de entrada enviados por XML
**************************************************************************/

PROCEDURE valores_entrada:

    FOR EACH tt-param NO-LOCK:

        CASE tt-param.nomeCampo:
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "dsoperac" THEN aux_dsoperac = tt-param.valorCampo.           
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DEC(tt-param.valorCampo).
            WHEN "nmoperad" THEN aux_nmoperad = tt-param.valorCampo.
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INT(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INT(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INT(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INT(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INT(tt-param.valorCampo).
            WHEN "nmprimtl" THEN aux_nmprimtl = tt-param.valorCampo.
            WHEN "nmpessoa" THEN aux_nmpessoa = tt-param.valorCampo.
            WHEN "bloqueia" THEN aux_bloqueia = LOGICAL(tt-param.valorCampo).
            WHEN "cdoperac" THEN aux_cdoperac = INT(tt-param.valorCampo).
            

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

/*****************************************************************************
  Envia e-mail 
******************************************************************************/
PROCEDURE envia_email_alerta:
    
    RUN envia_email_alerta IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_idorigem,
                                   INPUT aux_nrcpfcgc,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT aux_nmprimtl,
                                   INPUT aux_nmpessoa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_dsoperac,
                                   OUTPUT TABLE tt-erro).
             
    IF RETURN-VALUE = "NOK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
           
           IF NOT AVAILABLE tt-erro THEN
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
  Alerta fraude 
******************************************************************************/
PROCEDURE alerta_fraude:

    RUN alerta_fraude IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_dtmvtolt,
                              INPUT aux_idorigem,
                              INPUT aux_nrcpfcgc,
                              INPUT aux_nrdconta,
                              INPUT aux_idseqttl,
                              INPUT aux_bloqueia,
                              INPUT aux_cdoperac,
                              INPUT aux_dsoperac,
                              OUTPUT TABLE tt-erro).

   
    IF RETURN-VALUE = "NOK"  THEN
       DO: 
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF NOT AVAILABLE tt-erro THEN
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
  Verifica se o cpf em questao esta no cadastro restritivo
******************************************************************************/


FUNCTION fget_existe_risco_cpfcnpj RETURNS LOG (INPUT aux_nrcpfcgc AS DEC,
                                                OUTPUT aux_nmpessoa AS CHAR):


    RETURN DYNAMIC-FUNCTION("fget_existe_risco_cpfcnpj" IN hBO,
                            INPUT aux_nrcpfcgc,
                            OUTPUT aux_nmpessoa).


END.
