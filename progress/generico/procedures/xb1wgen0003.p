/*..............................................................................

   Programa: xb1wgen0003.p
   Autor   : Murilo/David
   Data    : Junho/2007                       Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Lancamentos Futuros e Cheques Nao 
               Compensados (b1wgen0003.p)

   Alteracoes: 

..............................................................................*/


DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.

DEF VAR aux_vllautom AS DECI                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0003tt.i }
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
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.


/******************************************************************************/
/**         Procedure para consultar lancamentos futuros do associado        **/
/******************************************************************************/
PROCEDURE consulta-lancamento:

    RUN consulta-lancamento IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idorigem,
                                    INPUT aux_idseqttl,
                                    INPUT aux_nmdatela,
                                    INPUT TRUE, /* Gerar Log */
                                   OUTPUT TABLE tt-totais-futuros,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-lancamento_futuro).
    
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-totais-futuros:HANDLE,
                             INPUT "Saldo").
            RUN piXmlExport (INPUT TEMP-TABLE tt-lancamento_futuro:HANDLE,
                             INPUT "Lancamentos").        
            RUN piXmlSave.           
                                        
        END.                   
                        
 
END PROCEDURE.


/******************************************************************************/
/**           Procedure para listar cheques pendentes do cooperado           **/
/******************************************************************************/
PROCEDURE selecao_cheques_pendentes:

    DEF VAR aux_qtcheque AS INTE                                    NO-UNDO.
    DEF VAR aux_qtcordem AS INTE                                    NO-UNDO.

    RUN selecao_cheques_pendentes IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_nmdatela,
                                          INPUT aux_idorigem,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                         OUTPUT aux_qtcheque,
                                         OUTPUT aux_qtcordem,
                                         OUTPUT TABLE cratfdc,
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
            RUN piXmlExport (INPUT TEMP-TABLE cratfdc:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "qtcheque",INPUT STRING(aux_qtcheque)).
            RUN piXmlAtributo (INPUT "qtcordem",INPUT STRING(aux_qtcordem)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/*............................................................................*/
