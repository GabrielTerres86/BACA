/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank76.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Janeiro/2012                        Ultima atualizacao: 07/11/2012

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Verificar se o cooperado já possui Letras de Segurança 
               cadastradas
   
   Alteracoes: 07/11/2012 - Ajuste de parametros (David).
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0032tt.i }

DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdoperad AS CHAR        NO-UNDO.
DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_nmdatela AS CHAR        NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wgen0032 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.

DEF VAR aux_flgcadas AS LOGI                                           NO-UNDO.

RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h-b1wgen0032.

IF  NOT VALID-HANDLE(h-b1wgen0032)  THEN
DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0032.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            
    RETURN "NOK".
END.

RUN verifica-letras-seguranca IN h-b1wgen0032 (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                              OUTPUT aux_flgcadas).

DELETE PROCEDURE h-b1wgen0032.

IF  RETURN-VALUE <> "OK"  THEN
DO:
    FIND LAST tt-erro NO-LOCK NO-ERROR.

    IF AVAIL tt-erro THEN
        ASSIGN aux_dscritic = tt-erro.dscritic.
    ELSE
        ASSIGN aux_dscritic = "Nao foi possivel realizar a operacao.".
    
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

    RETURN "NOK".
END.

ASSIGN aux_dslinxml = "<SITUACAO><CARTAO><flgcadas>" + 
                      STRING(aux_flgcadas,"SIM/NAO") + 
                      "</flgcadas></CARTAO></SITUACAO>".

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = aux_dslinxml.

RETURN "OK".

/*............................................................................*/

