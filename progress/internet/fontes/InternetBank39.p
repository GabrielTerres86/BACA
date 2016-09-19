/*..............................................................................
   Programa: sistema/internet/fontes/InternetBank39.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Abril/2008.                       Ultima atualizacao:   /  /
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Cancelar agendamento de transferencias e pagamentos
   
   Alteracoes: 03/11/2008 - Inclusao widget-pool (martin)
                            
               28/07/2015 - Adição de parâmetro flmobile para indicar que a origem
                            da chamada é do mobile (Dionathan)
 
..............................................................................*/
 
create widget-pool.
 
    
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/var_ibank.i }
DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0016 AS HANDLE                                         NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtage LIKE craplau.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_nrdocmto LIKE craplau.nrdocmto                    NO-UNDO.
DEF  INPUT PARAM par_flmobile AS LOGI                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
RUN sistema/generico/procedures/b1wgen0016.p PERSISTENT SET h-b1wgen0016.
IF  VALID-HANDLE(h-b1wgen0016)  THEN
    DO:
        RUN cancelar-agendamento IN h-b1wgen0016 
                                        (INPUT par_cdcooper,
                                         INPUT 90,          /** PAC      **/
                                         INPUT 900,         /** CAIXA    **/
                                         INPUT "996",       /** OPERADOR **/
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT par_dtmvtolt,
                                         INPUT "INTERNET",  /** ORIGEM   **/
                                         INPUT par_dtmvtage,
                                         INPUT par_nrdocmto,
                                        OUTPUT aux_dstransa,
                                        OUTPUT aux_dscritic).
        DELETE PROCEDURE h-b1wgen0016.
        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".
                                      
                RUN proc_geracao_log (INPUT FALSE).
                                      
                RETURN "NOK".
            END.
        RUN proc_geracao_log (INPUT TRUE). 
             
        RETURN "OK".
    END.
    
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
            
            RUN gera_log_item IN h-b1wgen0014
                         (INPUT aux_nrdrowid,
                          INPUT "Origem",
                          INPUT "",
                          INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).
                          
            RUN gera_log_item IN h-b1wgen0014 
                                      (INPUT aux_nrdrowid,
                                       INPUT "Data de Registro",
                                       INPUT "",
                                       INPUT STRING(par_dtmvtage,
                                                    "99/99/9999")).
            RUN gera_log_item IN h-b1wgen0014 
                                      (INPUT aux_nrdrowid,
                                       INPUT "Numero do Documento",
                                       INPUT "",
                                       INPUT TRIM(STRING(par_nrdocmto,
                                                          "zzz,zzz,zzz"))).
            
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE.
/*............................................................................*/
