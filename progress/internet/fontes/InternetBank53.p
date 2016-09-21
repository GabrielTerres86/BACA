/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank53.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Janeiro/2009                     Ultima atualizacao: 00/00/0000
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Obtem Dados para Alteracao de Informativo 
   
   Alteracoes: 
 
..............................................................................*/
 
CREATE WIDGET-POOL.

{ sistema/generico/includes/b1wgen0037tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/var_ibank.i }

DEF VAR h-b1wgen0037 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nmrelato AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrdrowid AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0037.p PERSISTENT SET h-b1wgen0037.
                
IF  NOT VALID-HANDLE(h-b1wgen0037)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0037.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
      
RUN obtem-dados-alteracao IN h-b1wgen0037 
                                      (INPUT par_cdcooper,
                                       INPUT 90,             /** PAC      **/
                                       INPUT 900,            /** Caixa    **/
                                       INPUT "996",          /** Operador **/
                                       INPUT "INTERNETBANK", /** Tela     **/
                                       INPUT 3,              /** Origem   **/
                                       INPUT par_nrdconta,
                                       INPUT 1,              /** Titular  **/
                                       INPUT par_nrdrowid,
                                       INPUT TRUE,           /** Logar    **/
                                      OUTPUT aux_nmrelato,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-periodo-envio,
                                      OUTPUT TABLE tt-destino-envio).

DELETE PROCEDURE h-b1wgen0037.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE           
            aux_dscritic = "Nao foi possivel obter dados para informativo.".
                   
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".    
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<INFORMATIVO nmrelato='" + aux_nmrelato + "'>" +
                               "</INFORMATIVO><PERIODOS_ENVIO>".

FOR EACH tt-periodo-envio NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<PERIODO><cdperiod>" +
                                   STRING(tt-periodo-envio.cdperiod) +
                                   "</cdperiod><dsperiod>" +
                                   tt-periodo-envio.dsperiod +
                                   "</dsperiod><selected>" +
                                   tt-periodo-envio.selected +
                                   "</selected></PERIODO>".

END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</PERIODOS_ENVIO><DESTINOS_ENVIO>".

FOR EACH tt-destino-envio NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<DESTINO><cddestin>" +
                                   STRING(tt-destino-envio.cddestin) +
                                   "</cddestin><dsdestin>" +
                                   tt-destino-envio.dsdestin +
                                   "</dsdestin><selected>" +
                                   tt-destino-envio.selected +
                                   "</selected></DESTINO>".

END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</DESTINOS_ENVIO>".

RETURN "OK".

/*............................................................................*/
