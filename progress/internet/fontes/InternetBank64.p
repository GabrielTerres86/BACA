

/*..............................................................................

    Programa: sistema/internet/fontes/InternetBank64.p
    Sistema : Internet - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jorge
    Data    : Abril/2011                   Ultima atualizacao: 00/00/0000
  
    Dados referentes ao programa:
  
    Frequencia: Sempre que for chamado (On-Line)
    Objetivo  : Adesão de sacado eletronico (DDA)
    
    Alteracoes: 
                            
					25/10/2017 -  Ajustado para especificar adesão de DDA pelo Mobile
								  PRJ356.4 - DDA (Ricardo Linhares)
							
..............................................................................*/

CREATE WIDGET-POOL.    

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0078tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0078 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_idorigem AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_flmobile AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.

IF  NOT VALID-HANDLE(h-b1wgen0078)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0078.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN aderir-sacado IN h-b1wgen0078 (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_dtmvtolt,
                                   INPUT TRUE,
								   INPUT par_flmobile,
                                  OUTPUT TABLE tt-erro).
DELETE PROCEDURE h-b1wgen0078.

IF  RETURN-VALUE = "NOK"  THEN
DO:
    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-erro  THEN
        ASSIGN aux_dscritic = tt-erro.dscritic.
    ELSE
        ASSIGN aux_dscritic = "Falha na requisicao.".

    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

    RETURN "NOK".
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<ADESAO_DDA>" + 
                                    "<status>OK</status>" + 
                                "</ADESAO_DDA>".
RETURN "OK".

/*............................................................................*/


