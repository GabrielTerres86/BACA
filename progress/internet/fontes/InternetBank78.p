/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank78.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Abril/2012.                       Ultima atualizacao: 00/00/0000
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Validar acesso a rotina de transferencia.
   
   Alteracoes: 
 
..............................................................................*/
 
CREATE WIDGET-POOL.
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.

DEF VAR aux_flgopspb AS LOGI                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

ASSIGN aux_dstransa = "Acesso a tela de transferencias".

RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.
                
IF  NOT VALID-HANDLE(h-b1wgen0015)  THEN
    DO: 
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0015."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

        RUN proc_geracao_log (INPUT FALSE).
                
        RETURN "NOK".
    END.

RUN verifica-opera-spb IN h-b1wgen0015 (INPUT par_cdcooper,
                                       OUTPUT aux_dscritic,
                                       OUTPUT aux_flgopspb).
    
DELETE PROCEDURE h-b1wgen0015.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                              "</dsmsgerr>".
        
        RUN proc_geracao_log (INPUT FALSE).
        
        RETURN "NOK".
    END.

IF  NOT aux_flgopspb  THEN
    DO:
        ASSIGN aux_dscritic = "Cooperativa nao esta operando no SPB.".

        RUN proc_geracao_log (INPUT FALSE).

        ASSIGN aux_dscritic = "".
    END.
                
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<ACESSO><flgopspb>" +
                               STRING(aux_flgopspb,"SIM/NAO") +
                               "</flgopspb></ACESSO>".

RETURN "OK".
            
/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:

    DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT "INTERNET",
                                          INPUT aux_dstransa,
                                          INPUT aux_datdodia,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                         OUTPUT aux_nrdrowid).
                                                            
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE. 

/*............................................................................*/
