/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank171.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Lunelli
   Data    : Maio/2016                         Ultima atualizacao:           
   
   Dados referentes ao programa: Alteraçoes Oferta DEBAUT Sicredi [PROJ320]
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Retornar motivos para o cancelamento do DEBAUT
   
   Alteracoes:
   
..............................................................................*/
 
                                                                               
CREATE WIDGET-POOL.

{ sistema/generico/includes/b1wgen0092tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/var_ibank.i }

DEF VAR h-b1wgen0092 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER                        NO-UNDO.
DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER                        NO-UNDO.
DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER                        NO-UNDO.
DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER                        NO-UNDO.
DEFINE INPUT  PARAMETER par_cdoperad AS CHAR                           NO-UNDO.
DEFINE INPUT  PARAMETER par_idorigem AS INTEGER                        NO-UNDO.
DEFINE INPUT  PARAMETER par_nmdatela AS CHAR                           NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF  NOT VALID-HANDLE(h-b1wgen0092) THEN
    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

RUN obtem-motivos-cancelamento-debaut IN h-b1wgen0092(INPUT par_cdcooper,
                                                      INPUT par_cdagenci,
                                                      INPUT par_nrdcaixa,
                                                      INPUT par_cdoperad,
                                                      INPUT par_nmdatela,
                                                      INPUT par_idorigem,
                                                      INPUT par_nrdconta,
                                                      INPUT crapdat.dtmvtolt,
                                                     OUTPUT TABLE tt-motivos-cancel-debaut,
                                                     OUTPUT TABLE tt-erro).
IF  VALID-HANDLE(h-b1wgen0092) THEN
    DELETE PROCEDURE h-b1wgen0092.
       
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Nao foi possivel carregar motivos do " +
                           "cancelamento de autorizacao de debito automatico.".
            
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
        
        RETURN "NOK".
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<MOTIVOS_CAN_DEBAUT>".

FOR EACH tt-motivos-cancel-debaut NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<MOTIVOS><idmotivo>" +       
                                   STRING(tt-motivos-cancel-debaut.idmotivo) +
                                   "</idmotivo><dsmotivo>" +
                                   TRIM(tt-motivos-cancel-debaut.dsmotivo) +
                                   "</dsmotivo></MOTIVOS>".
                             
END. /** Fim do FOR EACH tt-motivos-cancel-debaut **/

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</MOTIVOS_CAN_DEBAUT>".
        
RETURN "OK".


/*............................................................................*/
