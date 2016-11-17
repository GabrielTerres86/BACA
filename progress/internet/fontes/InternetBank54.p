/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank54.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Janeiro/2009                     Ultima atualizacao: 00/00/0000
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Alteracao de Informativo 
   
   Alteracoes: 
 
..............................................................................*/
 
CREATE WIDGET-POOL.

{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0037 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrdrowid AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_cdperiod AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdseqinc AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

RUN sistema/generico/procedures/b1wgen0037.p PERSISTENT SET h-b1wgen0037.
                
IF  NOT VALID-HANDLE(h-b1wgen0037)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0037.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
      
RUN alterar-informativo IN h-b1wgen0037 (INPUT par_cdcooper,
                                         INPUT 90,             /** PAC      **/
                                         INPUT 900,            /** Caixa    **/
                                         INPUT "996",          /** Operador **/
                                         INPUT "INTERNETBANK", /** Tela     **/
                                         INPUT 3,              /** Origem   **/
                                         INPUT par_nrdconta,
                                         INPUT 1,              /** Titular  **/
                                         INPUT par_nrdrowid,
                                         INPUT par_cdperiod,
                                         INPUT par_cdseqinc,
                                         INPUT TRUE,           /** Logar    **/
                                        OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0037.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE           
            aux_dscritic = "Nao foi possivel alterar o informativo.".
                   
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".    
    END.

RETURN "OK".

/*............................................................................*/
