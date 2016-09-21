/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank51.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Janeiro/2009                     Ultima atualizacao: 00/00/0000
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Listar recebimento de informativos - Modulo "Informativos".
   
   Alteracoes: 
 
..............................................................................*/
 
CREATE WIDGET-POOL.

{ sistema/generico/includes/b1wgen0037tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/var_ibank.i }

DEF VAR h-b1wgen0037 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0037.p PERSISTENT SET h-b1wgen0037.
                
IF  NOT VALID-HANDLE(h-b1wgen0037)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0037.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
      
RUN obtem-lista-recebimento IN h-b1wgen0037 
                                       (INPUT par_cdcooper,
                                        INPUT 90,             /** PAC      **/
                                        INPUT 900,            /** Caixa    **/
                                        INPUT "996",          /** Operador **/
                                        INPUT "INTERNETBANK", /** Tela     **/
                                        INPUT 3,              /** Origem   **/
                                        INPUT par_nrdconta,
                                        INPUT 1,              /** Titular  **/
                                        INPUT TRUE,           /** Logar    **/ 
                                       OUTPUT TABLE tt-erro,  
                                       OUTPUT TABLE tt-informativos).

DELETE PROCEDURE h-b1wgen0037.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE           
            aux_dscritic = "Nao foi possivel obter lista de recebimento.".
                   
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".    
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<RECEBIMENTO>".
                               
FOR EACH tt-informativos NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<INFORMATIVO><cdprogra>" +
                                   STRING(tt-informativos.cdprogra) +
                                   "</cdprogra><cdrelato>" +
                                   STRING(tt-informativos.cdrelato) +
                                   "</cdrelato><nmrelato>" +
                                   tt-informativos.nmrelato +
                                   "</nmrelato><cdfenvio>" +
                                   STRING(tt-informativos.cdfenvio) +
                                   "</cdfenvio><cdperiod>" +
                                   STRING(tt-informativos.cdperiod) +
                                   "</cdperiod><nrdrowid>" +
                                   STRING(tt-informativos.nrdrowid) +
                                   "</nrdrowid><dsrecebe>" +
                                   tt-informativos.dsrecebe +
                                   "</dsrecebe><endcoope>" +
                                   tt-informativos.endcoope +
                                   "</endcoope><cdgrprel>" +
                                   STRING(tt-informativos.cdgrprel) +
                                   "</cdgrprel><grupoinf>" +
                                   tt-informativos.grupoinf +
                                   "</grupoinf><dsfenvio>" +
                                   tt-informativos.dsfenvio +
                                   "</dsfenvio></INFORMATIVO>".

END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</RECEBIMENTO>".

RETURN "OK".

/*............................................................................*/
