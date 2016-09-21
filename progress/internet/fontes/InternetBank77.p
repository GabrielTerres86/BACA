/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank77.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Janeiro/2012                        Ultima atualizacao: 14/11/2012
   
   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Manutenção das Letras de Segurança cadastradas
   
   Alteracoes: 14/11/2012 - Ajuste letras de seguranca (David).
                            
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
DEFINE INPUT  PARAMETER par_dssennov AS CHAR        NO-UNDO.
DEFINE INPUT  PARAMETER par_dssencon AS CHAR        NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wgen0032 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
DEF VAR aux_flgcadas AS CHAR                                           NO-UNDO.

RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h-b1wgen0032.

IF  NOT VALID-HANDLE(h-b1wgen0032)  THEN
DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0032.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            
    RETURN "NOK".
END.

RUN grava-senha-letras IN h-b1wgen0032 (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nmdatela,
                                        INPUT par_idorigem,
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT par_dtmvtolt,
                                        INPUT par_dssennov,
                                        INPUT par_dssencon,
                                        INPUT TRUE, /*log*/
                                       OUTPUT aux_flgcadas,
                                       OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0032.

ASSIGN aux_dslinxml = "<SITUACAO><CARTAO><flgcadas>" + aux_flgcadas + 
                      "</flgcadas></CARTAO></SITUACAO>".

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = aux_dslinxml.

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
ELSE
DO:
    ASSIGN aux_dscritic = "Operacao realizada com sucesso."
           xml_dsmsgerr = "<dsmsgsuc>" + aux_dscritic + "</dsmsgsuc>".

END.


RETURN "OK".

/*............................................................................*/

