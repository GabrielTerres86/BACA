/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank199.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odirlei Busana - AMcom
   Data    : Agosto/2016.                       Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Operar pagamento de tributos.
   
   Alteracoes: 
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0014 AS HANDLE                                           NO-UNDO.

DEF VAR aux_dscritic        AS CHAR                                      NO-UNDO.
DEF VAR aux_dstransa        AS CHAR                                      NO-UNDO.
DEF VAR aux_dsretorn        AS CHAR                                      NO-UNDO.
DEF VAR aux_xml_operacao199 AS LONGCHAR                                  NO-UNDO.
DEF VAR aux_nrdrowid        AS ROWID                                     NO-UNDO.
DEF VAR aux_iteracoes       AS INT                                       NO-UNDO.
DEF VAR aux_posini          AS INT                                       NO-UNDO.
DEF VAR aux_contador        AS INT                                       NO-UNDO.
DEF VAR aux_flmobile        AS INT                                       NO-UNDO.

DEF INPUT  PARAM  par_cdcooper  LIKE crapcop.cdcooper                     NO-UNDO.        
DEF INPUT  PARAM  par_nrdconta  LIKE crapass.nrdconta                     NO-UNDO.        
DEF INPUT  PARAM  par_idseqttl  LIKE crapttl.idseqttl                     NO-UNDO.        
DEF INPUT  PARAM  par_nrcpfope  LIKE crapopi.nrcpfope                     NO-UNDO.        
DEF INPUT  PARAM  par_idorigem  AS INTEGER                                NO-UNDO.        
DEF INPUT  PARAM  par_flmobile  AS LOGICAL                                NO-UNDO.         
DEF INPUT  PARAM  par_idefetiv  AS INTEGER                                NO-UNDO.        
DEF INPUT  PARAM  par_tpdaguia  AS INTEGER                                NO-UNDO.        
DEF INPUT  PARAM  par_tpcaptur  AS INTEGER                                NO-UNDO.        
DEF INPUT  PARAM  par_lindigi1  AS DECIMAL                                NO-UNDO.        
DEF INPUT  PARAM  par_lindigi2  AS DECIMAL                                NO-UNDO.        
DEF INPUT  PARAM  par_lindigi3  AS DECIMAL                                NO-UNDO.        
DEF INPUT  PARAM  par_lindigi4  AS DECIMAL                                NO-UNDO.        
DEF INPUT  PARAM  par_cdbarras  AS CHAR                                   NO-UNDO.        
DEF INPUT  PARAM  par_dsidepag  AS CHAR           	                      NO-UNDO.  
DEF INPUT  PARAM  par_vlrtotal  AS DECIMAL                                NO-UNDO.  
DEF INPUT  PARAM  par_dtapurac  AS DATE                                   NO-UNDO.  
DEF INPUT  PARAM  par_nrcpfcgc  AS CHAR                                   NO-UNDO.  
DEF INPUT  PARAM  par_cdtribut  AS CHAR                                   NO-UNDO.  
DEF INPUT  PARAM  par_dtmvtopg  AS DATE                                   NO-UNDO.  
DEF INPUT  PARAM  par_dtvencto  AS DATE                                   NO-UNDO.  
DEF INPUT  PARAM  par_idagenda  AS INTEGER                                NO-UNDO.
DEF INPUT  PARAM  par_vlapagar  AS DECIMAL                                NO-UNDO.
DEF INPUT  PARAM  par_versaldo  AS INTEGER                                NO-UNDO.
DEF INPUT  PARAM  par_tpleitor  AS INTEGER                                NO-UNDO.
DEF INPUT  PARAM  par_nrrefere  AS DECI                                   NO-UNDO.

DEF OUTPUT PARAM  xml_dsmsgerr  AS CHAR                                   NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

FUNCTION roundUp RETURNS INTEGER ( x as decimal ):
  IF x = TRUNCATE( x, 0 ) THEN
    RETURN INTEGER( x ).
  ELSE
    RETURN INTEGER(TRUNCATE( x, 0 ) + 1 ).
END.

/* Validacao */
IF  par_idefetiv = 0 THEN    
    IF  par_idagenda = 1 THEN
        aux_dstransa = aux_dstransa + 'Valida pagamento '.
    ELSE 
        aux_dstransa = aux_dstransa + 'Valida agendamento de pagamento '.
ELSE /* Efetivaçao */ 
    IF  par_idagenda = 1 THEN
        aux_dstransa = aux_dstransa + 'Pagamento '.
    ELSE 
        aux_dstransa = aux_dstransa + 'Agendamento para pagamento '.

IF  par_tpdaguia = 3 THEN /* FGTS */
    aux_dstransa = aux_dstransa + 'de FGTS.'.
ELSE IF par_tpdaguia = 3 THEN /* DAE */
    
    aux_dstransa = aux_dstransa + 'de DAE.'.
    
IF  par_flmobile THEN        
    ASSIGN aux_flmobile = 1.
ELSE
    ASSIGN aux_flmobile = 0.
    
/* Procedimento do internetbank operacao 199 */
{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_processa_tributos
    aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper               /* pr_cdcooper */
                                       ,INPUT par_nrdconta               /* pr_nrdconta */
                                       ,INPUT par_idseqttl               /* pr_idseqttl */
                                       ,INPUT par_nrcpfope               /* pr_nrcpfope */
                                       ,INPUT par_idorigem               /* pr_idorigem */
                                       ,INPUT aux_flmobile               /* pr_flmobile */
                                       ,INPUT par_idefetiv               /* pr_idefetiv */
                                       ,INPUT par_tpdaguia               /* pr_tpdaguia */
                                       ,INPUT par_tpcaptur               /* pr_tpcaptur */
                                       ,INPUT par_lindigi1               /* pr_lindigi1 */
                                       ,INPUT par_lindigi2               /* pr_lindigi2 */
                                       ,INPUT par_lindigi3               /* pr_lindigi3 */
                                       ,INPUT par_lindigi4               /* pr_lindigi4 */
                                       ,INPUT par_cdbarras               /* pr_cdbarras */
                                       ,INPUT par_nrcpfcgc               /* pr_nrcpfcgc */
                                       ,INPUT par_cdtribut               /* pr_cdtribut */
                                       ,INPUT par_dtvencto               /* pr_dtvencto */
                                       ,INPUT par_dtapurac               /* pr_dtapurac */
                                       ,INPUT par_vlrtotal               /* pr_vlrtotal */
                                       ,INPUT par_nrrefere               /* pr_nrrefere */
                                       ,INPUT par_dsidepag               /* pr_dsidepag */
                                       ,INPUT par_dtmvtopg               /* pr_dtmvtopg */
                                       ,INPUT par_idagenda               /* pr_idagenda */
                                       ,INPUT par_vlapagar               /* pr_vlapagar */
                                       ,INPUT par_versaldo               /* pr_versaldo */
                                       ,INPUT par_tpleitor               /* pr_tpleitor */
                                       ,OUTPUT ""                        /* pr_retxml   */
                                       ,OUTPUT ""                        /* pr_dscritic */
                                       ).
                                                                           

IF  ERROR-STATUS:ERROR  THEN DO:

    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
          
    ASSIGN aux_dscritic = "pc_processa_tributos --> Erro ao executar Stored Procedure: " + aux_msgerora.
      
    ASSIGN xml_dsmsgerr = "<dsmsgerr>Erro inesperado. Nao foi possivel efetuar realizar operacao." + 
                            " Tente novamente ou contacte seu PA" +
                          "</dsmsgerr>".
                        
    RUN proc_geracao_log (INPUT FALSE).
      
    RETURN "NOK".
      
END. 

CLOSE STORED-PROC pc_processa_tributos
		aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}

ASSIGN aux_dscritic        = ""
       aux_xml_operacao199 = ""
       aux_dscritic = pc_processa_tributos.pr_dscritic 
                 WHEN pc_processa_tributos.pr_dscritic <> ?
       aux_xml_operacao199 = pc_processa_tributos.pr_retxml
                        WHEN pc_processa_tributos.pr_retxml <> ?.

/* Verificar se retornou critica */
IF aux_dscritic <> "" THEN
DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                             aux_dscritic +
                          "</dsmsgerr>".

    RETURN "NOK".
END.    
   
/* Atribuir xml de retorno a temptable */ 
IF  aux_xml_operacao199 <> "" THEN
    DO:
        ASSIGN aux_iteracoes = roundUp(LENGTH(aux_xml_operacao199) / 31000)
               aux_posini    = 1.    

        DO  aux_contador = 1 TO aux_iteracoes:
        
            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = SUBSTRING(aux_xml_operacao199, aux_posini, 31000)
                   aux_posini            = aux_posini + 31000.
                   
        END.
    END.

RETURN "OK".
    
/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:
    
  DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.

  RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT SET h-b1wgen0014.
      
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
               
          DELETE PROCEDURE h-b1wgen0014.
      END.
    
END PROCEDURE.
