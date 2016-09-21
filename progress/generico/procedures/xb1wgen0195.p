/*..............................................................................

   Programa: xb1wgen0195.p
   Autor   : Odirlei Busana (AMcom)
   Data    : Marco/2016                     Ultima atualizacao: 10/03/2016

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de envio de informacoes 
               para a Esteira de Credito (b1wgen0195.p)

   Alteracoes:
   
.............................................................................*/   


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_nrctremp_novo AS INTE                                      NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_flreiflx AS INTE                                           NO-UNDO.
DEF VAR aux_tpenvest AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

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
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.                 
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).  
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo). 
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "dtmvtopr" THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
            WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
            WHEN "nrctremp_novo" THEN aux_nrctremp_novo = INTE(tt-param.valorCampo).
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.  
            WHEN "flreiflx" THEN aux_flreiflx = INTE(tt-param.valorCampo).
            WHEN "tpenvest" THEN aux_tpenvest = tt-param.valorCampo.  
            
        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/  
END PROCEDURE.


/******************************************************************************/
/**           Procedure para verificar regras da esteira                     **/
/******************************************************************************/
PROCEDURE verifica_regras_esteira:
    
     RUN verifica_regras_esteira IN hBO        
                         ( INPUT aux_cdcooper, 
                           INPUT aux_nrdconta, 
                           INPUT aux_nrctremp, 
                          OUTPUT aux_dscritic, 
                          OUTPUT aux_dscritic).
       
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            
            CREATE tt-erro.            
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.    

END PROCEDURE.    

/******************************************************************************/
/**           Procedure para enviar a proposta para esteira                     **/
/******************************************************************************/
PROCEDURE Enviar_proposta_esteira:
    
     RUN Enviar_proposta_esteira IN hBO        
                         ( INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_nmdatela,
                           INPUT aux_cdoperad,
                           INPUT aux_idorigem,
                           INPUT aux_nrdconta,
                           INPUT aux_dtmvtolt,
                           INPUT aux_dtmvtopr,
                           INPUT aux_nrctremp,
                           INPUT aux_nrctremp_novo,
                           INPUT aux_dsiduser,
                           INPUT aux_flreiflx,
                           INPUT aux_tpenvest,
                          OUTPUT aux_cdcritic, 
                          OUTPUT aux_dscritic).
       
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            
            CREATE tt-erro.            
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END. 
    ELSE 
        DO:
            CREATE tt-msg-confirma.
            ASSIGN tt-msg-confirma.dsmensag = "Proposta Enviada para Esteira com Sucesso.".            
            
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                             INPUT "Mensagem").
            RUN piXmlSave.
        END.    

END PROCEDURE.    