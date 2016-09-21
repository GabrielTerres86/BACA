/* .........................................................................

   Programa: xb1wgen0098.p
   Autor   : Henrique
   Data    : Maio/2011                    Ultima Atualizacao: 05/11/2013  
   
   Dados referentes ao programa:
   
   Objetivo  : BO de Comunicacao XML vs BO referente a tela ESKECI 
               (b1wgen0098.p).
              
   Alteracoes: 19/01/2012 - Alterado nrsencar para dssencar (Guilherme).
   
               05/11/2013 - Adicionado param cdoperad em proc busca-cartao.
                            (Jorge).

..........................................................................*/

DEF VAR aux_cdcooper AS INTE                                       NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                       NO-UNDO.             
DEF VAR aux_nrdcaixa AS INTE                                       NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                       NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                       NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                       NO-UNDO.
DEF VAR aux_nrcartao AS DECI                                       NO-UNDO.
DEF VAR aux_nrsennov AS CHAR                                       NO-UNDO.
DEF VAR aux_nrsencon AS CHAR                                       NO-UNDO.

{ sistema/generico/includes/b1wgen0098tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/* .........................PROCEDURES................................... */


/**************************************************************************
       Procedure para atribuicao dos dados de entrada enviados por XML
**************************************************************************/

PROCEDURE valores_entrada:

    FOR EACH tt-param NO-LOCK:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).           
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrcartao" THEN aux_nrcartao = DECI(tt-param.valorCampo).
            WHEN "nrsennov" THEN aux_nrsennov = tt-param.valorCampo.
            WHEN "nrsencon" THEN aux_nrsencon = tt-param.valorCampo.
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

/*****************************************************************************
  Carregar os dados do cooperado a partir do numero do cartao 
******************************************************************************/
PROCEDURE busca-cartao:
    
    RUN busca-cartao IN hBO (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nrcartao,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-crapcrm).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        RUN piXmlSaida (INPUT TEMP-TABLE tt-crapcrm:HANDLE,
                        INPUT "Dados").

END PROCEDURE.

/*****************************************************************************
  Verifica a nova senha do cartao do cooperado
******************************************************************************/
PROCEDURE verifica-nova-senha:

    RUN verifica-nova-senha IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT TRUE,
                                    INPUT aux_nrcartao,
                                    INPUT aux_nrsennov,
                                    INPUT aux_nrsencon,
                                   OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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

END.

/*****************************************************************************
  Atualiza a senha do cartao do cooperado
******************************************************************************/
PROCEDURE grava-nova-senha:

    RUN grava-nova-senha IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT TRUE,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_nrcartao,
                                 INPUT aux_nrsennov,
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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
