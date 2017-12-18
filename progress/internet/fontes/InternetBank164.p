/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank164.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Carlos Rafael Tanholi
   Data    : Janeiro/2016                        Ultima atualizacao: 00/00/0000
   
   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Gera impressao do CET de emprestimos pre-aprovado
   
   Alteracoes: 
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF VAR h-b1wgen0002i AS HANDLE NO-UNDO.
DEF VAR aux_dscritic AS CHAR NO-UNDO.

DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdoperad AS CHAR        NO-UNDO.
DEFINE INPUT  PARAMETER par_nmdatela AS CHAR        NO-UNDO.
DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
DEFINE INPUT  PARAMETER par_dtmvtopr AS DATE        NO-UNDO.
DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
DEFINE INPUT  PARAMETER par_recidepr AS CHAR        NO-UNDO.
DEFINE INPUT  PARAMETER par_idimpres AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_flgescra AS LOGICAL     NO-UNDO.
DEFINE INPUT  PARAMETER par_nrpagina AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_flgemail AS LOGICAL     NO-UNDO.
DEFINE INPUT  PARAMETER par_dsiduser AS CHAR        NO-UNDO.
DEFINE INPUT  PARAMETER par_dtcalcul AS DATE        NO-UNDO.
DEFINE INPUT  PARAMETER par_inproces AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_promsini AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdprogra AS CHAR        NO-UNDO.
DEFINE INPUT  PARAMETER par_flgentra AS LOGICAL     NO-UNDO.
DEFINE OUTPUT PARAMETER xml_dsmsgerr AS CHAR        NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_flgentrv AS LOGI                        NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                        NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                        NO-UNDO.
DEF VAR aux_dsdirarq AS CHAR                        NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                        NO-UNDO.


IF  VALID-HANDLE(h-b1wgen0002i)  THEN
    DELETE PROCEDURE h-b1wgen0002i.

RUN sistema/generico/procedures/b1wgen0002i.p PERSISTENT
    SET h-b1wgen0002i.               
                
IF  NOT VALID-HANDLE(h-b1wgen0002i)  THEN
  DO:
      ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0002i.".
             xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
              
      RETURN "NOK".
  END.
      
  RUN gera-impressao-empr IN h-b1wgen0002i(INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT par_dtmvtolt,
                                           INPUT par_dtmvtopr,
                                           INPUT par_flgerlog,
                                           INPUT par_recidepr,
                                           INPUT par_idimpres,
                                           INPUT par_flgescra,
                                           INPUT par_nrpagina,
                                           INPUT par_flgemail,
                                           INPUT par_dsiduser,
                                           INPUT par_dtcalcul,
                                           INPUT par_inproces,
                                           INPUT par_promsini,
                                           INPUT par_cdprogra,
                                           INPUT par_flgentra,
                                          OUTPUT aux_flgentrv,
                                          OUTPUT aux_nmarqimp,
                                          OUTPUT aux_nmarqpdf,
                                          OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0002i.


IF  RETURN-VALUE = "NOK"  THEN
  DO:
      FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                  
      IF  AVAILABLE tt-erro  THEN
          aux_dscritic = tt-erro.dscritic.
      ELSE           
          aux_dscritic = "Nao foi possivel imprimir.".
                 
      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

      RETURN "NOK".    
  END.
ELSE 
  DO:
    IF par_cdprogra = "" THEN DO:
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<nmarqpdf>" + aux_nmarqpdf + "</nmarqpdf>".
        RETURN "OK".
    END.
    ELSE DO:   
        ASSIGN aux_nmarquiv = SUBSTR(aux_nmarqpdf,R-INDEX(aux_nmarqpdf,"/") + 1)
               aux_nmarqpdf = SUBSTR(aux_nmarqpdf,1,R-INDEX(aux_nmarqpdf,"/")).
        
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<nmarqpdf>" + aux_nmarquiv + "</nmarqpdf>" +                                      
                                       "<dssrvarq>" + aux_nmarqimp + "</dssrvarq>" +
                                       "<dsdirarq>" + aux_nmarqpdf + "</dsdirarq>".
        RETURN "OK".    
    END.
  END.