/* ............................................................................

   Programa: siscaixa/web/InternetBank30.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Agosto/2007.                       Ultima atualizacao: 18/04/2013
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Listar convenios para pagamento na Internet.
   
   Alteracoes: 09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).
   
               10/03/2008 - Utilizar include var_ibank.i (David).
   
               03/11/2008 - Inclusao widget-pool (martin)
               
               08/03/2013 - Utilizar include b1wgen0016tt.i (David).
               
               18/04/2013 - Alimentadas tags com campos de horário limite
                            para Pgto./Canc. de Conv. SICREDI (Lucas).
                            
               28/07/2015 - Adição de parâmetro flmobile para indicar que a origem
                            da chamada é do mobile (Dionathan)
               
 ............................................................................ */
 
CREATE WIDGET-POOL.
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0016tt.i }

DEF VAR h-b1wgen0016 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0014 AS HANDLE                                      NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta                 NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                 NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                 NO-UNDO.
DEF INPUT  PARAM par_flmobile AS LOGI                               NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                               NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao30.

ASSIGN aux_dstransa = "Convenios aceitos para pagamento na internet".

RUN sistema/generico/procedures/b1wgen0016.p PERSISTENT SET h-b1wgen0016.

IF  VALID-HANDLE(h-b1wgen0016)  THEN
    DO: 
        RUN convenios_aceitos IN h-b1wgen0016 
                              (INPUT par_cdcooper,
                              OUTPUT TABLE tt-convenios_aceitos).

        DELETE PROCEDURE h-b1wgen0016.
        
        FIND FIRST tt-convenios_aceitos NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE tt-convenios_aceitos  THEN
            DO:
                ASSIGN aux_dscritic = "Nao existem convenios para pagamento " +
                                      "na internet."
                       xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".
                                      
                RUN proc_geracao_log (INPUT FALSE).
                                      
                RETURN "NOK".
            END.
            
        FOR EACH tt-convenios_aceitos NO-LOCK:
        
            CREATE xml_operacao30.
            ASSIGN xml_operacao30.dscabini = "<CONVENIO>"
                   xml_operacao30.nmextcon = "<nmextcon>" +
                                             tt-convenios_aceitos.nmextcon +
                                             "</nmextcon>"

                   xml_operacao30.hhoraini = "<hhoraini>" +
                                             tt-convenios_aceitos.hhoraini +
                                             "</hhoraini>"

                   xml_operacao30.hhorafim = "<hhorafim>" +
                                             tt-convenios_aceitos.hhorafim +
                                             "</hhorafim>"

                   xml_operacao30.hhoracan = "<hhoracan>" +
                                             tt-convenios_aceitos.hhoracan +
                                             "</hhoracan>"

                   xml_operacao30.dscabfim = "</CONVENIO>".
        END.
        
        RUN proc_geracao_log (INPUT TRUE). 
             
        RETURN "OK".
    END.

/* ............................... PROCEDURES ............................... */

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
                                          INPUT TODAY,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).
                                          
             RUN gera_log_item IN h-b1wgen0014
                          (INPUT aux_nrdrowid,
                           INPUT "Origem",
                           INPUT "",
                           INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).
                                           
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE.
