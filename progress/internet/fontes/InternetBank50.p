/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank50.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Janeiro/2009                     Ultima atualizacao: 00/00/0000
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Consultar historico de envio de informativos. 
               Modulo "Informativos".
   
   Alteracoes: 
 
..............................................................................*/
 
CREATE WIDGET-POOL.

{ sistema/generico/includes/b1wgen0037tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/var_ibank.i }

DEF VAR h-b1wgen0037 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_qtinfrec AS INTE                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtiniper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtfimper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_iniconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrregist AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0037.p PERSISTENT SET h-b1wgen0037.
                
IF  NOT VALID-HANDLE(h-b1wgen0037)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0037.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
      
RUN historico-envio-informativos IN h-b1wgen0037 
                                       (INPUT par_cdcooper,
                                        INPUT 90,             /** PAC      **/
                                        INPUT 900,            /** Caixa    **/
                                        INPUT "996",          /** Operador **/
                                        INPUT "INTERNETBANK", /** Tela     **/
                                        INPUT 3,              /** Origem   **/
                                        INPUT par_nrdconta,
                                        INPUT 1,              /** Titular  **/
                                        INPUT par_dtiniper,
                                        INPUT par_dtfimper,
                                        INPUT par_iniconta,
                                        INPUT par_nrregist,
                                        INPUT TRUE,           /** Logar    **/ 
                                       OUTPUT aux_qtinfrec,  
                                       OUTPUT TABLE tt-historico).

DELETE PROCEDURE h-b1wgen0037.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<HISTORICO qtinfrec='" + STRING(aux_qtinfrec) +
                               "'>".
                               
FOR EACH tt-historico NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<ENVIO><dttransa>" +
                                   STRING(tt-historico.dttransa,"99/99/9999") +
                                   "</dttransa><dstransa>" +
                                   tt-historico.dstransa +
                                   "</dstransa><dsperiod>" +
                                   tt-historico.dsperiod +
                                   "</dsperiod><dsdcanal>" +
                                   tt-historico.dsdcanal +
                                   "</dsdcanal><dsendere>" +
                                   tt-historico.dsendere +
                                   "</dsendere></ENVIO>".

END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</HISTORICO>".

RETURN "OK".

/*............................................................................*/
