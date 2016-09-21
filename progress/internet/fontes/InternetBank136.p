/*..............................................................................

    Programa: sistema/internet/fontes/InternetBank62.p
    Sistema : Internet - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Dionathan
    Data    : Junho/2015                   Ultima atualizacao: 
  
    Dados referentes ao programa:
  
    Frequencia: Sempre que for chamado (On-Line)
    Objetivo  : Retornar e horarios para transações no mobile
    
    Alteracoes:           
                            
..............................................................................*/
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF TEMP-TABLE tt-limite-trf LIKE tt-limite.
DEF TEMP-TABLE tt-limite-pgt LIKE tt-limite.
DEF TEMP-TABLE tt-limite-ted LIKE tt-limite.

EMPTY TEMP-TABLE tt-limite-trf.
EMPTY TEMP-TABLE tt-limite-pgt.
EMPTY TEMP-TABLE tt-limite-ted.

RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

IF  NOT VALID-HANDLE(h-b1wgen0015)  THEN
DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0015.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            
    RETURN "NOK".
END.

RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                      INPUT 90, /** PAC       **/
                                      INPUT 1,  /** Transferencia **/
                                      INPUT 1,  /*Fixo, pois é igual para ambos*/
                                     OUTPUT aux_dscritic,
                                     OUTPUT TABLE tt-limite-trf).

RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                      INPUT 90, /** PAC       **/
                                      INPUT 2,  /** Pagamento **/
                                      INPUT 1,  /*Fixo, pois é igual para ambos*/
                                     OUTPUT aux_dscritic,
                                     OUTPUT TABLE tt-limite-pgt).

RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                      INPUT 90,  /** PAC       **/
                                      INPUT 4,  /** TED **/
                                      INPUT 1,  /*Fixo, pois é igual para ambos*/
                                     OUTPUT aux_dscritic,
                                     OUTPUT TABLE tt-limite-ted).

DELETE PROCEDURE h-b1wgen0015.

/* Carrega horário de limite para estorno (Pagamento)*/
FOR FIRST crapage FIELDS(hrcancel) WHERE 
          crapage.cdcooper = par_cdcooper AND 
          crapage.cdagenci = 90 NO-LOCK: END.

/* Gera a lista de horários limite*/
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = '<DADOSHORARIOLIMITE>'.

/* Gera o bloco de Horário limite Transferência*/
FIND FIRST tt-limite-trf NO-LOCK NO-ERROR.
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<HORARIOLIMITE>" +
    "<hrinipag>" + TRIM(STRING(tt-limite-trf.hrinipag)) + "</hrinipag>" +
    "<hrfimpag>" + TRIM(STRING(tt-limite-trf.hrfimpag)) + "</hrfimpag>" +
    "<hrlimest></hrlimest>" +
    "<idesthor>" + TRIM(STRING(tt-limite-trf.idesthor)) + "</idesthor>" +
    "<cdtiptra>1</cdtiptra>" +
    "<dstiptra>TRANSFERENCIA</dstiptra>" +
    "</HORARIOLIMITE>".

/* Gera o bloco de Horário limite Pagamento*/
FIND FIRST tt-limite-pgt NO-LOCK NO-ERROR.
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<HORARIOLIMITE>" +
    "<hrinipag>" + TRIM(STRING(tt-limite-pgt.hrinipag)) + "</hrinipag>" +
    "<hrfimpag>" + TRIM(STRING(tt-limite-pgt.hrfimpag)) + "</hrfimpag>" +
    "<hrlimest>" + STRING(crapage.hrcancel,"HH:MM") + "</hrlimest>" +
    "<idesthor>" + TRIM(STRING(tt-limite-pgt.idesthor)) + "</idesthor>" +
    "<cdtiptra>2</cdtiptra>" +
    "<dstiptra>PAGAMENTO</dstiptra>" +
    "</HORARIOLIMITE>".

/* Gera o bloco de Horário limite TED*/
FIND FIRST tt-limite-ted NO-LOCK NO-ERROR.
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<HORARIOLIMITE>" +
    "<hrinipag>" + TRIM(STRING(tt-limite-ted.hrinipag)) + "</hrinipag>" +
    "<hrfimpag>" + TRIM(STRING(tt-limite-ted.hrfimpag)) + "</hrfimpag>" +
    "<hrlimest></hrlimest>" +
    "<idesthor>" + TRIM(STRING(tt-limite-ted.idesthor)) + "</idesthor>" +
    "<cdtiptra>4</cdtiptra>" +
    "<dstiptra>TED</dstiptra>" +
    "</HORARIOLIMITE>".
	
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = '</DADOSHORARIOLIMITE>'.

RETURN "OK".