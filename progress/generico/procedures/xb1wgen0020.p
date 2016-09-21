/*..............................................................................

   Programa: xb1wgen0020.p
   Autor   : Murilo/David
   Data    : Setembro/2007                     Ultima atualizacao: 08/02/2012

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Conta Investimento (b1wgen0020.p)

   Alteracoes: 01/10/2008 - Adaptar alteracoes na procedure obtem-resgate
                            (David).
                            
               08/02/2012 - Incluir parametro em extrato_investimento (David).

..............................................................................*/


DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrdocmto AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO. 
DEF VAR aux_inconfir AS INTE                                           NO-UNDO.

DEF VAR aux_vlresgat AS DECI                                           NO-UNDO.
DEF VAR aux_vlsldant AS DECI                                           NO-UNDO.

DEF VAR aux_dtiniper AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0020tt.i }
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
            WHEN "vlresgat" THEN aux_vlresgat = DECI(tt-param.valorCampo).
            WHEN "nrdocmto" THEN aux_nrdocmto = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "inconfir" THEN aux_inconfir = INTE(tt-param.valorCampo).
        END CASE.
        
    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.


/******************************************************************************/
/**             Procedure para obter saldo da conta investimento             **/
/******************************************************************************/
PROCEDURE obtem-saldo-investimento:

    RUN obtem-saldo-investimento IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_dtmvtolt,
                                        OUTPUT TABLE tt-saldo-investimento).
 
    RUN piXmlSaida (INPUT TEMP-TABLE tt-saldo-investimento:HANDLE,
                    INPUT "Dados").
                     
END PROCEDURE.


/******************************************************************************/
/**          Procedure para consultar extrato da conta investimento          **/
/******************************************************************************/
PROCEDURE extrato_investimento:

    RUN extrato_investimento IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_dtiniper,
                                     INPUT aux_dtfimper,
                                     INPUT TRUE,
                                    OUTPUT aux_vlsldant,
                                    OUTPUT TABLE tt-extrato_inv).
    
    RUN piXmlNew.
    RUN piXmlExport (INPUT TEMP-TABLE tt-extrato_inv:HANDLE,
                     INPUT "Dados").
    RUN piXmlAtributo (INPUT "vlsldant",INPUT TRIM(STRING(aux_vlsldant))).
    RUN piXmlSave.
                                            
END PROCEDURE.


/******************************************************************************/
/**            Procedure para gerar resgate na conta investimento            **/
/******************************************************************************/
PROCEDURE obtem-resgate:

    RUN obtem-resgate IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_nrdconta,
                              INPUT aux_idseqttl,
                              INPUT aux_dtmvtolt,
                              INPUT aux_vlresgat,
                              INPUT aux_inconfir,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-msg-confirma).
            
    IF  RETURN-VALUE = "NOK"  THEN
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
            FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-msg-confirma  THEN
                RUN piXmlSaida (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                                INPUT "Confirmacao").
            ELSE
                DO:
                    RUN piXmlNew.
                    RUN piXmlSave.
                END.
        END.

END PROCEDURE.


/******************************************************************************/
/**       Procedure para cancelar resgate gerado na conta investimento       **/
/******************************************************************************/
PROCEDURE obtem-cancelamento:

    RUN obtem-cancelamento IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_nrdocmto,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
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


/*............................................................................*/
