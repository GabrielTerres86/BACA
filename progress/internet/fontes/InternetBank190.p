/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank190.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Fevereiro/2018                      Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Detalhar cheque depositado.

   Alteracoes: 

..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0001tt.i }

DEF VAR h-b1wgen0001 AS HANDLE                                         NO-UNDO.

DEF VAR aux_vlrtotal AS DECI                                           NO-UNDO.

DEF VAR aux_qtcheque AS INTE                                           NO-UNDO.

DEF INPUT  PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtocd                    NO-UNDO.
DEF INPUT  PARAM par_nrdocmto LIKE craplcm.nrdocmto                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT SET h-b1wgen0001.

IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
    ASSIGN xml_dsmsgerr = "<dsmsgerr>Handle invalido para BO b1wgen0001." +
                          "</dsmsgerr>".  

IF  xml_dsmsgerr <> ""  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0001.

        RETURN "NOK".
    END.

RUN obtem-cheques-deposito IN h-b1wgen0001 
                          (INPUT par_cdcooper,
                           INPUT 90,
                           INPUT 900,
                           INPUT "996",
                           INPUT "INTERNETBANK",
                           INPUT 3,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT par_dtmvtolt,
                           INPUT par_dtmvtolt,
                           INPUT TRUE,
                           INPUT 1,
                           INPUT 999999,
                           INPUT FALSE,
                          OUTPUT aux_qtcheque,
                          OUTPUT TABLE tt-extrato_cheque).                         

FOR EACH tt-extrato_cheque NO-LOCK:

    IF  tt-extrato_cheque.nrdocmto <> par_nrdocmto  THEN
        NEXT.

    IF  tt-extrato_cheque.vltotchq <> 0  THEN
        ASSIGN aux_vlrtotal = tt-extrato_cheque.vltotchq.
     
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<cheque><dtmvtolt>" +
                                   tt-extrato_cheque.dtmvtolt +
                                   "</dtmvtolt><nrdocmto>" +
                              TRIM(STRING(tt-extrato_cheque.nrdocmto,
                                          "zzz,zzz,zz9")) +
                                   "</nrdocmto><cdbanchq>" + 
                                   STRING(tt-extrato_cheque.cdbanchq,
                                          "999") + 
                                   "</cdbanchq><cdagechq>" + 
                                   STRING(tt-extrato_cheque.cdagechq,
                                          "9999") +
                                   "</cdagechq><nrctachq>" +
                              TRIM(STRING(tt-extrato_cheque.nrctachq,
                                          "zzzz,zzz,zzz,9")) +
                                   "</nrctachq><nrcheque>" + 
                              TRIM(STRING(tt-extrato_cheque.nrcheque,
                                          "zzz,zz9")) +
                                   "." +
                                   STRING(tt-extrato_cheque.nrddigc3) + 
                                   "</nrcheque><vlcheque>" +
                              TRIM(STRING(tt-extrato_cheque.vlcheque,
                                          "zzz,zzz,zz9.99")) + 
                                   "</vlcheque></cheque>".

END. /** Fim do FOR EACH tt-extrato_cheque **/

IF  NOT TEMP-TABLE xml_operacao:HAS-RECORDS  THEN        
    DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>Cheques nao encontrados." +
                              "</dsmsgerr>".
                              
        RETURN "NOK".
    END.

FOR FIRST xml_operacao EXCLUSIVE-LOCK:
    ASSIGN xml_operacao.dslinxml = '<cheques vlrtotal="' + TRIM(STRING(aux_vlrtotal,"zzz,zzz,zzz,zz9.99")) + '">' + xml_operacao.dslinxml.
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = '</cheques>'.
                               
DELETE PROCEDURE h-b1wgen0001.                               
    
RETURN "OK".

/*............................................................................*/


