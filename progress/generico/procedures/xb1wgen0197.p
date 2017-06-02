/* ............................................................................

   Programa: sistema/generico/procedures/xb1wgen0197.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : Maio/2017.                       Ultima atualizacao:  /  /  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : BO de Comunicacao XML VS BO de envio de informacoes 
               para o Desligamento de cooperados (b1wgen0197.p)

   Alteracoes:
   
.............................................................................*/   


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0197tt.i }

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
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.                 
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).  
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo). 
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            
        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/  
END PROCEDURE.


/******************************************************************************/
/**           Procedure para verificar regras da esteira                     **/
/******************************************************************************/
PROCEDURE busca_inf_produtos:
    
     RUN busca_inf_produtos IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,                                    
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT aux_dtmvtolt,
                                    OUTPUT aux_dscritic,
                                    OUTPUT TABLE tt-inf-produto).
       
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            
            CREATE tt-erro.            
            ASSIGN tt-erro.dscritic = aux_dscritic.
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.    
    ELSE 
        DO:
          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-inf-produto:HANDLE,
                           INPUT "Produtos").
          RUN piXmlSave.  
        END.        

END PROCEDURE.    