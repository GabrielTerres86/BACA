/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank82.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Abril/2013.                       Ultima atualizacao: 
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Validar conta de destino para a transferencia intercooperativa. 
   
   Alteracoes: 

..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }


DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT  PARAM par_cdagectl AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_nrctatrf AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_cdtiptra AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_flgctafa AS LOGI                                           NO-UNDO.
DEF VAR aux_nmtitula AS CHAR                                           NO-UNDO.
DEF VAR aux_nmtitul2 AS CHAR                                           NO-UNDO.
DEF VAR aux_cddbanco AS INTE                                           NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.

RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

IF   NOT VALID-HANDLE(h-b1wgen0015)  THEN
     DO: 
         ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0015."
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                               "</dsmsgerr>".                                                              
         RETURN "NOK".
     END.

RUN valida-conta-destino IN h-b1wgen0015 (INPUT par_cdcooper,
                                          INPUT 90,             /* cdagenci */
                                          INPUT 900,            /* nrdcaixa */
                                          INPUT "996",          /* cdoperad */
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,
                                          INPUT par_cdagectl,
                                          INPUT par_nrctatrf,
                                          INPUT par_dtmvtolt,
                                          INPUT par_cdtiptra,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT aux_flgctafa,
                                         OUTPUT aux_nmtitula,
                                         OUTPUT aux_nmtitul2,
                                         OUTPUT aux_cddbanco).

DELETE PROCEDURE h-b1wgen0015.

IF   RETURN-VALUE <> "OK"   THEN
     DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         ASSIGN aux_dscritic = IF   AVAIL tt-erro   THEN 
                                    tt-erro.dscritic
                               ELSE
                                    "Erro na validacao da conta destino.".
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                               "</dsmsgerr>".                                                                  
         RETURN "NOK".
     END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<flgctafa>" + STRING(aux_flgctafa) + "</flgctafa>". 

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<nmtitula>" + aux_nmtitula + "</nmtitula>". 

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<nmtitul2>" + aux_nmtitul2 + "</nmtitul2>".  

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<cddbanco>" + STRING(aux_cddbanco) + "</cddbanco>".

RETURN "OK".


/*............................................................................*/
