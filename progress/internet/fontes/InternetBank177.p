/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank177.p
   Sistema : Internet - Integralizaçao de Cotas
   Sigla   : CRED
   Autor   : Ricardo Linhares
   Data    : Setembro/2016.                       Ultima atualizacao: 
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Efetuar cancelmaento da integralizaçao de cota
   
   Alteracoes: 
..............................................................................*/
 
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF VAR h-b1wgen0021 AS HANDLE NO-UNDO.
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
DEFINE INPUT  PARAMETER par_nrdrowid AS CHAR        NO-UNDO.
DEFINE OUTPUT PARAMETER xml_dsmsgerr AS CHAR        NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

IF  VALID-HANDLE(h-b1wgen0021)  THEN
    DELETE PROCEDURE h-b1wgen0021.

RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
    SET h-b1wgen0021.               
                
IF  NOT VALID-HANDLE(h-b1wgen0021)  THEN
  DO:
      ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0002i."
             xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
              
      RETURN "NOK".
  END.
      
  RUN cancela_integralizacao IN h-b1wgen0021(INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT par_nrdrowid,
                                            OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0021.


IF  RETURN-VALUE = "NOK"  THEN
  DO:
      FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                  
      IF  AVAILABLE tt-erro THEN
          ASSIGN aux_dscritic = tt-erro.dscritic.
      ELSE           
          ASSIGN aux_dscritic = "Nao foi possível cancelar integralicao.".
                 
      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

      RETURN "NOK".    
  END.
ELSE 
  DO:
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<dsmsg>Cancelamento efetuado com sucesso.</dsmsg>".
    RETURN "OK".
  END.