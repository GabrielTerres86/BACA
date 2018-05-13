/*..............................................................................
   Programa: sistema/internet/fontes/InternetBank39.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Abril/2008.                       Ultima atualizacao: 07/03/2017
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Cancelar agendamento de transferencias e pagamentos
   
   Alteracoes: 03/11/2008 - Inclusao widget-pool (martin)
                            
               28/07/2015 - Adição de parâmetro flmobile para indicar que a origem
                            da chamada é do mobile (Dionathan)
 
			         25/04/2016 - Incluido a passagem de novo parametro na rotina
							              cancelar-agendamento
							              (Adriano - M117).
              
               07/03/2017 - Adicionado parametro par_cdtiptra.
                            Adicionado tratamento para agendamentos de recarga de 
                            celular (par_cdtiptra = 11). Projeto 321 (Lombardi)
                            
..............................................................................*/
 
create widget-pool.
 
    
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_oracle.i }
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
DEF  INPUT PARAM par_cdtiptra AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_nrcpfope AS DECI                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

IF par_cdtiptra = 11 THEN
  DO:
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_cancela_agendamento_recarga aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper 
                         ,INPUT par_nrdconta 
                         ,INPUT par_idseqttl
                         ,INPUT 3
                         ,INPUT par_nrdocmto
                         ,OUTPUT 0
                         ,OUTPUT "").
                         

    CLOSE STORED-PROC pc_cancela_agendamento_recarga aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_cancela_agendamento_recarga.pr_dscritic 
                          WHEN pc_cancela_agendamento_recarga.pr_dscritic <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dscritic <> "" THEN 
      DO:
          ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                "</dsmsgerr>".
                                
          RUN proc_geracao_log (INPUT FALSE).
                                
          RETURN "NOK".
      END.
      RUN proc_geracao_log (INPUT TRUE). 
           
      RETURN "OK".
  END.
ELSE
  DO: 
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
                         INPUT "INTERNETBANK", /*Nome da tela*/ 
                                             INPUT par_nrcpfope,
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
