/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank40.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Maio/2008.                        Ultima atualizacao: 03/03/2009
   
   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Baixa ou Exclusao de Boletos da Internet
   
   Alteracoes: 25/07/2008 - Gerar log com detalhes do boleto (David).
               
               11/09/2008 - Incluir parametro com numero do convenio (David).
               
               03/11/2008 - Inclusao widget-pool (martin)
 
               03/03/2009 - Melhorias no servico de cobranca (David).
               
..............................................................................*/
 
CREATE WIDGET-POOL. 
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wnet0001 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_idtransa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcnvcob LIKE crapcob.nrcnvcob                    NO-UNDO.
DEF  INPUT PARAM par_nrdocmto LIKE crapcob.nrdocmto                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

RUN sistema/internet/procedures/b1wnet0001.p PERSISTENT SET h-b1wnet0001.

IF  NOT VALID-HANDLE(h-b1wnet0001)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0001.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN exclusao-baixa-boleto IN h-b1wnet0001 (INPUT par_cdcooper,
                                           INPUT 90,             /** PAC    **/
                                           INPUT 900,            /** Caixa  **/
                                           INPUT "996",          /** Operad **/
                                           INPUT "INTERNETBANK", /** Tela   **/
                                           INPUT "3",            /** Origem **/
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT par_dtmvtolt,
                                           INPUT par_idtransa,
                                           INPUT par_nrcnvcob,
                                           INPUT par_nrdocmto,
                                           INPUT TRUE,           /** Logar  **/
                                          OUTPUT TABLE tt-erro).
        
DELETE PROCEDURE h-b1wnet0001.
        
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
        IF  AVAILABLE tt-erro  THEN
            ASSIGN aux_dscritic = tt-erro.dscritic.
        ELSE
            ASSIGN aux_dscritic = "Nao foi possivel concluir a requisicao.".
            
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                      
        RETURN "NOK".
    END.
             
RETURN "OK".
    
/*............................................................................*/
