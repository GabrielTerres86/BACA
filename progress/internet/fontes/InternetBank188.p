/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank188.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Lunelli
   Data    : Agosto/2016.                       Ultima atualizacao: 14/09/2017
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Operar pagamento DARF/DAS.
   
   Alteracoes: 14/09/2017 - Adicionar no campo nrrefere como String (Lucas Ranghetti #756034)
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0014 AS HANDLE                                           NO-UNDO.

DEF VAR aux_dscritic        AS CHAR                                      NO-UNDO.
DEF VAR aux_dstransa        AS CHAR                                      NO-UNDO.
DEF VAR aux_dsretorn        AS CHAR                                      NO-UNDO.
DEF VAR aux_xml_operacao188 AS LONGCHAR                                  NO-UNDO.
DEF VAR aux_nrdrowid        AS ROWID                                     NO-UNDO.
DEF VAR aux_iteracoes       AS INT                                       NO-UNDO.
DEF VAR aux_posini          AS INT                                       NO-UNDO.
DEF VAR aux_contador        AS INT                                       NO-UNDO.
DEF VAR aux_flmobile        AS INT                                       NO-UNDO.

DEF INPUT  PARAM  par_cdcooper  LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT  PARAM  par_nrdconta  LIKE crapass.nrdconta                     NO-UNDO.
DEF INPUT  PARAM  par_idseqttl  LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT  PARAM  par_nrcpfope  LIKE crapopi.nrcpfope                     NO-UNDO.
DEF INPUT  PARAM  par_dtmvtopg  AS DATE                                   NO-UNDO.
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
DEF INPUT  PARAM  par_dsnomfon  AS CHAR                                   NO-UNDO.
DEF INPUT  PARAM  par_dtapurac  AS DATE                                   NO-UNDO.
DEF INPUT  PARAM  par_nrcpfcgc  AS CHAR                                   NO-UNDO.
DEF INPUT  PARAM  par_cdtribut  AS CHAR                                   NO-UNDO.
DEF INPUT  PARAM  par_nrrefere  AS DECI                                   NO-UNDO.
DEF INPUT  PARAM  par_dtvencto  AS DATE                                   NO-UNDO.
DEF INPUT  PARAM  par_vlrprinc  AS DECIMAL                                NO-UNDO.
DEF INPUT  PARAM  par_vlrmulta  AS DECIMAL                                NO-UNDO.
DEF INPUT  PARAM  par_vlrjuros  AS DECIMAL                                NO-UNDO.
DEF INPUT  PARAM  par_vlrecbru  AS DECIMAL                                NO-UNDO.
DEF INPUT  PARAM  par_vlpercen  AS DECIMAL                                NO-UNDO.
DEF INPUT  PARAM  par_idagenda  AS INTEGER                                NO-UNDO.
DEF INPUT  PARAM  par_vlapagar  AS DECIMAL                                NO-UNDO.
DEF INPUT  PARAM  par_versaldo  AS INTEGER                                NO-UNDO.
DEF INPUT  PARAM  par_tpleitor  AS INTEGER                                NO-UNDO.

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

IF  par_tpdaguia = 1 THEN /* DARF */
    aux_dstransa = aux_dstransa + 'de DARF.'.
ELSE /* DAS */
    aux_dstransa = aux_dstransa + 'de DAS.'.
    
IF  par_flmobile THEN        
    ASSIGN aux_flmobile = 1.
ELSE
    ASSIGN aux_flmobile = 0.
    
/* Procedimento do internetbank operacao 188 */
{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_InternetBank188
    aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper
                                       ,INPUT par_nrdconta
                                       ,INPUT par_idseqttl
                                       ,INPUT par_nrcpfope
                                       ,INPUT par_dtmvtopg
                                       ,INPUT par_idorigem
                                       ,INPUT aux_flmobile
                                       ,INPUT par_idefetiv
                                       ,INPUT par_tpdaguia
                                       ,INPUT par_tpcaptur
                                       ,INPUT par_lindigi1
                                       ,INPUT par_lindigi2
                                       ,INPUT par_lindigi3
                                       ,INPUT par_lindigi4
                                       ,INPUT par_cdbarras
                                       ,INPUT par_dsidepag
                                       ,INPUT par_vlrtotal
                                       ,INPUT par_dsnomfon
                                       ,INPUT par_dtapurac
                                       ,INPUT par_nrcpfcgc
                                       ,INPUT par_cdtribut
                                       ,INPUT STRING(par_nrrefere)
                                       ,INPUT par_dtvencto
                                       ,INPUT par_vlrprinc
                                       ,INPUT par_vlrmulta
                                       ,INPUT par_vlrjuros
                                       ,INPUT par_vlrecbru
                                       ,INPUT par_vlpercen
                                       ,INPUT par_idagenda
                                       ,INPUT par_vlapagar
                                       ,INPUT par_versaldo
                                       ,INPUT par_tpleitor
                                      ,OUTPUT ""        /* Retorno XML de critica */
                                      ,OUTPUT ""        /* Retorno XML da operação 188 */
                                      ,OUTPUT "").      /* Retorno de critica (OK ou NOK) */
                                                                           

IF  ERROR-STATUS:ERROR  THEN DO:

    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
          
    ASSIGN aux_dscritic = "pc_InternetBank188 --> Erro ao executar Stored Procedure: " + aux_msgerora.
      
    ASSIGN xml_dsmsgerr = "<dsmsgerr>Erro inesperado. Nao foi possivel efetuar a consulta." + 
                            " Tente novamente ou contacte seu PA" +
                          "</dsmsgerr>".
                        
    RUN proc_geracao_log (INPUT FALSE).
      
    RETURN "NOK".
      
END. 

CLOSE STORED-PROC pc_InternetBank188
		aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}

ASSIGN aux_dsretorn        = ""
       xml_dsmsgerr        = ""
       aux_xml_operacao188 = ""
       aux_dsretorn = pc_InternetBank188.pr_dsretorn 
                 WHEN pc_InternetBank188.pr_dsretorn <> ?
       xml_dsmsgerr = pc_InternetBank188.pr_xml_dsmsgerr 
                 WHEN pc_InternetBank188.pr_xml_dsmsgerr <> ?
       aux_xml_operacao188 = pc_InternetBank188.pr_xml_operacao188
                        WHEN pc_InternetBank188.pr_xml_operacao188 <> ?.

/* Verificar se retornou critica */
IF aux_dsretorn <> "OK" THEN
    RETURN "NOK".
   
/* Atribuir xml de retorno a temptable */ 
IF  aux_xml_operacao188 <> "" THEN
    DO:
        ASSIGN aux_iteracoes = roundUp(LENGTH(aux_xml_operacao188) / 31000)
               aux_posini    = 1.    

        DO  aux_contador = 1 TO aux_iteracoes:
        
            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = SUBSTRING(aux_xml_operacao188, aux_posini, 31000)
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
