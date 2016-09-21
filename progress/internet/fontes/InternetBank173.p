/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank173.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Luneli
   Data    : Maio/2016                        Ultima atualizacao:
   
   Dados referentes ao programa: Oferta DEBAUT Sicredi [PROJ320]
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Operaçoes de SMS (DEBAUT)
      
   Alteracoes: 
..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }
{ sistema/generico/includes/b1wgen0092tt.i }

DEF INPUT  PARAM par_cdcooper  LIKE crapcop.cdcooper                   NO-UNDO.
DEF INPUT  PARAM par_nrdconta  LIKE crapass.nrdconta                   NO-UNDO.
DEF INPUT  PARAM par_idseqttl  AS INTE                                 NO-UNDO.
DEF INPUT  PARAM par_cddopcao  AS CHAR                                 NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt  AS DATE                                 NO-UNDO.
DEF INPUT  PARAM par_flgacsms  AS CHAR                                 NO-UNDO.
DEF INPUT  PARAM par_nrdddtfc  AS DECI                                 NO-UNDO.
DEF INPUT  PARAM par_nrtelefo  AS DECI                                 NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEFINE VARIABLE h-b1wgen0092  AS HANDLE                                NO-UNDO.
DEFINE VARIABLE aux_dsmsgsms  AS CHAR                                  NO-UNDO.

IF  NOT VALID-HANDLE(h-b1wgen0092) THEN
    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

RUN sms-cooperado-debaut IN h-b1wgen0092 (INPUT par_cdcooper,
                                          INPUT 90,              /* par_cdagenci */
                                          INPUT 900,             /* par_nrdcaixa */
                                          INPUT "996",           /* par_cdoperad */
                                          INPUT "INTERNETBANK",  /* par_nmdatela */
                                          INPUT 3,               /* par_idorigem */
                                          INPUT par_cddopcao,    /* par_cddopcao */
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,    /* par_idseqttl */
                                          INPUT IF par_cddopcao <> "C" THEN TRUE ELSE FALSE,
                                          INPUT par_dtmvtolt,
                                          INPUT IF par_flgacsms = "yes" THEN TRUE ELSE FALSE,
                                          INPUT-OUTPUT par_nrdddtfc,
                                          INPUT-OUTPUT par_nrtelefo,
                                                OUTPUT aux_dsmsgsms,
                                         OUTPUT TABLE tt-erro).
DELETE PROCEDURE h-b1wgen0092.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-erro  THEN
            ASSIGN xml_dsmsgerr = "<dsmsgerr>" + tt-erro.dscritic + "</dsmsgerr>".            
        ELSE
            ASSIGN xml_dsmsgerr = "<dsmsgerr>Problemas ao obter telefone para envio de SMS.</dsmsgerr>".

        RETURN "NOK".
    END.
    
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<SMS>"
       xml_operacao.dslinxml = xml_operacao.dslinxml + "<flgsusms>OK</flgsusms>"
       xml_operacao.dslinxml = xml_operacao.dslinxml + "<dsmsgsms>" + aux_dsmsgsms + "</dsmsgsms>"
       xml_operacao.dslinxml = xml_operacao.dslinxml + "<nrdddtfc>" + STRING(par_nrdddtfc) + "</nrdddtfc>"
       xml_operacao.dslinxml = xml_operacao.dslinxml + "<nrtelefo>" + STRING(par_nrtelefo) + "</nrtelefo>"
       xml_operacao.dslinxml = xml_operacao.dslinxml + "</SMS>".

RETURN "OK".