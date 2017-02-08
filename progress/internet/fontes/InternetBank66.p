/*..............................................................................

    Programa: sistema/internet/fontes/InternetBank66.p
    Sistema : Internet - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jorge
    Data    : Abril/2011                   Ultima atualizacao: 04/02/2016
  
    Dados referentes ao programa:
  
    Frequencia: Sempre que for chamado (On-Line)
    Objetivo  : Comandar Instruções Bancárias para Títulos - Cob. Registrada
    
    Alteracoes: 31/05/2011 - Adicionado verificacao de operacao ao carregar
                             Passado horario de operacao para XML (Jorge).
                        
                22/06/2011 - Adicionado parametro de XML idesthor no retorno de
                            <LIMITE> e verificao caso seja cob. reg. (Jorge).
                            
                14/07/2011 - Retirado duplicidade de codigo da linha 49 - 65
                             (Jorge).
                             
                26/12/2011 - Utilizar data do dia - crapdat.dtmvtocd (Rafael).
                
                10/01/2012 - Incluido rotina de geracao de log. (Rafael)
                
                04/07/2012 - Tratamento do cdoperad "operador" de INTE para CHAR.
                             (Lucas R.)
                             
                25/04/2013 - Adicionado cdocorre 7 e 8, add param de entrada
                             par_vldescto. (Jorge)    
                             
                10/06/2013 - Ajustado log de conceder/cancelar descto. (Rafael)
                
                12/07/2013 - Nao verificar horario de operacao para o comando
                             de instrucoes. O Controle do horário ficará agora 
                             com a b1wgen0088. (Rafael)
                             
                28/08/2013 - Incluso o parametro tt-lat-consolidada nas procedures
                             de instrucao (inst-) e incluso a include b1wgen0010tt.i
                             (Daniel)
                             
                05/11/2013 - Incluso chamada para a procedure efetua-lancamento-tarifas-lat
                             (Daniel)  
                             
                28/04/2015 - Ajustes referente Projeto Cooperativa Emite e Expede 
                             (Daniel/Rafael/Reinert)   

                04/02/2016 - Ajuste Projeto Negativação Serasa (Daniel)   
                13/10/2016 - Inclusao opcao 95 e 96, para Enviar e cancelar
                             SMS de vencimento. PRJ319 - SMS Cobranca (Odirlei-AMcom)
                                 
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0010tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapcob.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrcnvcob LIKE crapcre.nrcnvcob                    NO-UNDO.
DEF  INPUT PARAM par_nrdocmto LIKE craprem.nrdocmto                    NO-UNDO.
DEF  INPUT PARAM par_cdocorre LIKE craprem.cdocorre                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_dtvencto AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_vlabatim AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_cdtpinsc AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_vldescto AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_inavisms AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF VAR h-b1wgen0088 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0090 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO. 
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO. 

/* sistema deve atribuir data do dia vindo da crapdat
   Rafael Cechet - 06/04/2011 */
FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF  AVAILABLE crapdat  THEN
    ASSIGN par_dtmvtolt = crapdat.dtmvtocd.

RUN sistema/generico/procedures/b1wgen0088.p PERSISTENT SET h-b1wgen0088.

IF  NOT VALID-HANDLE(h-b1wgen0088)  THEN
DO:

    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0088.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            
    RETURN "NOK".
END.

IF par_cdocorre = 2 THEN
DO: /* Baixar */
    RUN inst-pedido-baixa IN h-b1wgen0088 (INPUT par_cdcooper,
                                           INPUT par_nrdconta,
                                           INPUT par_nrcnvcob,
                                           INPUT par_nrdocmto,
                                           INPUT par_cdocorre,
                                           INPUT par_dtmvtolt,
                                           INPUT par_cdoperad,
                                           INPUT 0,
                                          OUTPUT xml_dsmsgerr,
                                          INPUT-OUTPUT TABLE tt-lat-consolidada ).

    RUN pi_gera_log (INPUT "Pedido de Baixa").
END.
ELSE IF par_cdocorre = 4 THEN
DO: /* Conceder Abatimento */
    RUN inst-conc-abatimento IN h-b1wgen0088 (INPUT par_cdcooper,
                                              INPUT par_nrdconta,
                                              INPUT par_nrcnvcob,
                                              INPUT par_nrdocmto,
                                              INPUT par_cdocorre,
                                              INPUT par_dtmvtolt,
                                              INPUT par_cdoperad,
                                              INPUT par_vlabatim,
                                              INPUT 0,
                                             OUTPUT xml_dsmsgerr,
                                             INPUT-OUTPUT TABLE tt-lat-consolidada ).

    RUN pi_gera_log (INPUT "Conceder Abatimento").
END.
ELSE IF par_cdocorre = 5 THEN
DO: /* Cancelar Abatimento */
    RUN inst-canc-abatimento IN h-b1wgen0088 (INPUT par_cdcooper,
                                              INPUT par_nrdconta,
                                              INPUT par_nrcnvcob,
                                              INPUT par_nrdocmto,
                                              INPUT par_cdocorre,
                                              INPUT par_dtmvtolt,
                                              INPUT par_cdoperad,
                                              INPUT 0,
                                             OUTPUT xml_dsmsgerr,
                                             INPUT-OUTPUT TABLE tt-lat-consolidada ).

    RUN pi_gera_log (INPUT "Cancelar Abatimento").
END.
ELSE IF par_cdocorre = 6 THEN
DO: /* Alterar Vencimento */
    RUN inst-alt-vencto IN h-b1wgen0088 (INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT par_nrcnvcob,
                                         INPUT par_nrdocmto,
                                         INPUT par_cdocorre,
                                         INPUT par_dtmvtolt,
                                         INPUT par_cdoperad,
                                         INPUT par_dtvencto,
                                         INPUT 0,
                                        OUTPUT xml_dsmsgerr,
                                        INPUT-OUTPUT TABLE tt-lat-consolidada ).

    RUN pi_gera_log (INPUT "Alterar Vencimento").
END.
ELSE IF par_cdocorre = 7 THEN
DO: /* Conceder Desconto */
    RUN inst-conc-desconto IN h-b1wgen0088 (INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_nrcnvcob,
                                            INPUT par_nrdocmto,
                                            INPUT par_cdocorre,
                                            INPUT par_dtmvtolt,
                                            INPUT par_cdoperad,
                                            INPUT par_vldescto,
                                            INPUT 0,
                                           OUTPUT xml_dsmsgerr,
                                           INPUT-OUTPUT TABLE tt-lat-consolidada ).

    RUN pi_gera_log (INPUT "Conceder Desconto").
END.
ELSE IF par_cdocorre = 8 THEN
DO: /* Cancelar Desconto */
    RUN inst-canc-desconto IN h-b1wgen0088 (INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_nrcnvcob,
                                            INPUT par_nrdocmto,
                                            INPUT par_cdocorre,
                                            INPUT par_dtmvtolt,
                                            INPUT par_cdoperad,
                                            INPUT 0,
                                           OUTPUT xml_dsmsgerr,
                                           INPUT-OUTPUT TABLE tt-lat-consolidada ).

    RUN pi_gera_log (INPUT "Cancelar Desconto").
END.
ELSE IF par_cdocorre = 9 THEN
DO: /* Protestar */
    RUN inst-protestar IN h-b1wgen0088 (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrcnvcob,
                                        INPUT par_nrdocmto,
                                        INPUT par_cdocorre,
                                        INPUT par_cdtpinsc,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                        INPUT 0,
                                       OUTPUT xml_dsmsgerr,
                                       INPUT-OUTPUT TABLE tt-lat-consolidada ).

    RUN pi_gera_log (INPUT "Protestar").
END.
ELSE IF par_cdocorre = 11 THEN
DO: /* Sustar Protesto */
    RUN inst-sustar-manter IN h-b1wgen0088 (INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_nrcnvcob,
                                            INPUT par_nrdocmto,
                                            INPUT par_cdocorre,
                                            INPUT par_dtmvtolt,
                                            INPUT par_cdoperad,
                                            INPUT 0,
                                           OUTPUT xml_dsmsgerr,
                                           INPUT-OUTPUT TABLE tt-lat-consolidada ).

    RUN pi_gera_log (INPUT "Sustar Protesto").
END.
ELSE IF par_cdocorre = 41 THEN
DO: /* Cancelar Protesto */
    RUN inst-cancel-protesto IN h-b1wgen0088 (INPUT par_cdcooper,
                                              INPUT par_nrdconta,
                                              INPUT par_nrcnvcob,
                                              INPUT par_nrdocmto,
                                              INPUT par_cdocorre,
                                              INPUT par_dtmvtolt,
                                              INPUT par_cdoperad,
                                              INPUT 0,
                                             OUTPUT xml_dsmsgerr,
                                             INPUT-OUTPUT TABLE tt-lat-consolidada ).

    RUN pi_gera_log (INPUT "Cancelar Protesto").
END.
ELSE IF par_cdocorre = 90 THEN  
DO: /* Alt Tipo Emissao CEE */
    RUN inst-alt-tipo-emissao-cee IN h-b1wgen0088 (INPUT par_cdcooper,
                                                   INPUT par_nrdconta,
                                                   INPUT par_nrcnvcob,
                                                   INPUT par_nrdocmto,
                                                   INPUT par_cdocorre,
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_cdoperad,
                                                   INPUT 0,
                                                  OUTPUT xml_dsmsgerr,
                                                  INPUT-OUTPUT TABLE tt-lat-consolidada ).

    RUN pi_gera_log (INPUT "Alterar Tipo Emissao CEE").
END.
ELSE IF par_cdocorre = 93 THEN  
DO: /* Negativar Serasa */

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_negativa_serasa
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_nrcnvcob,
                                 INPUT par_nrdconta,
                                 INPUT par_nrdocmto,
                                 INPUT 0,    /* par_nrremass */
                                 INPUT "996",   /* par_cdoperad */
                                 OUTPUT 0,   /* pr_cdcritic */
                                 OUTPUT ""). /* pr_dscritic */

    CLOSE STORED-PROC pc_negativa_serasa
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""

           aux_cdcritic = pc_negativa_serasa.pr_cdcritic 
                              WHEN pc_negativa_serasa.pr_cdcritic <> ?
           aux_dscritic = pc_negativa_serasa.pr_dscritic
                              WHEN pc_negativa_serasa.pr_dscritic <> ?. 


    IF aux_dscritic <> "" THEN
      ASSIGN xml_dsmsgerr = aux_dscritic.  

    RUN pi_gera_log (INPUT "Negativar Serasa").
END.
ELSE IF par_cdocorre = 94 THEN  
DO: /* Cancelar Negativação */

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_cancelar_neg_serasa
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_nrcnvcob,
                                 INPUT par_nrdconta,
                                 INPUT par_nrdocmto,
                                 INPUT 0,    /* par_nrremass */
                                 INPUT "996",   /* par_cdoperad */
                                 OUTPUT 0,   /* pr_cdcritic */
                                 OUTPUT ""). /* pr_dscritic */

    CLOSE STORED-PROC pc_cancelar_neg_serasa
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""

           aux_cdcritic = pc_cancelar_neg_serasa.pr_cdcritic 
                              WHEN pc_cancelar_neg_serasa.pr_cdcritic <> ?
           aux_dscritic = pc_cancelar_neg_serasa.pr_dscritic
                              WHEN pc_cancelar_neg_serasa.pr_dscritic <> ?. 


    IF aux_dscritic <> "" THEN
      ASSIGN xml_dsmsgerr = aux_dscritic.  

    RUN pi_gera_log (INPUT "Cancelar Negativacao").
END.
ELSE IF par_cdocorre = 95 THEN  
DO: /* Aviso Vencimento por SMS */

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_inst_envio_sms
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,        /* pr_cdcooper */
                                 INPUT par_nrdconta,        /* pr_nrdconta */
                                 INPUT par_nrcnvcob,        /* pr_nrcnvcob */
                                 INPUT par_nrdocmto,        /* pr_nrdocmto */
                                 INPUT par_dtmvtolt,        /* pr_dtmvtolt */
                                 INPUT "996",               /* pr_cdoperad */
                                 INPUT par_inavisms,        /* pr_inavisms */
                                 INPUT 0,                   /* pr_nrcelsac */
                                 INPUT 0,                   /* pr_nrremass */   
                                 OUTPUT 0,                  /* pr_cdcritic */
                                 OUTPUT "").                /* pr_dscritic */

    CLOSE STORED-PROC pc_inst_envio_sms
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""

           aux_cdcritic = pc_inst_envio_sms.pr_cdcritic 
                              WHEN pc_inst_envio_sms.pr_cdcritic <> ?
           aux_dscritic = pc_inst_envio_sms.pr_dscritic
                              WHEN pc_inst_envio_sms.pr_dscritic <> ?. 


    IF aux_dscritic <> "" THEN
      ASSIGN xml_dsmsgerr = aux_dscritic.  

    RUN pi_gera_log (INPUT "Aviso Vencimento por SMS").
END.

ELSE IF par_cdocorre = 96 THEN  
DO: /* Cancelamento de Aviso Vencimento por SMS */

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_inst_canc_sms
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,        /* pr_cdcooper */
                                 INPUT par_nrdconta,        /* pr_nrdconta */
                                 INPUT par_nrcnvcob,        /* pr_nrcnvcob */
                                 INPUT par_nrdocmto,        /* pr_nrdocmto */
                                 INPUT par_dtmvtolt,        /* pr_dtmvtolt */
                                 INPUT "996",               /* pr_cdoperad */
                                 INPUT 0,                   /* pr_nrremass */   
                                 OUTPUT 0,                  /* pr_cdcritic */
                                 OUTPUT "").                /* pr_dscritic */

    CLOSE STORED-PROC pc_inst_canc_sms
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""

           aux_cdcritic = pc_inst_canc_sms.pr_cdcritic 
                              WHEN pc_inst_canc_sms.pr_cdcritic <> ?
           aux_dscritic = pc_inst_canc_sms.pr_dscritic
                              WHEN pc_inst_canc_sms.pr_dscritic <> ?. 


    IF aux_dscritic <> "" THEN
      ASSIGN xml_dsmsgerr = aux_dscritic.  

    RUN pi_gera_log (INPUT "Cancelamento de aviso por SMS").
END.

DELETE PROCEDURE h-b1wgen0088.

IF  xml_dsmsgerr <> ""  THEN
    DO:                                                             
        ASSIGN  aux_dscritic = xml_dsmsgerr
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

        RETURN "NOK".
    END.

/* Inicio - Rotina para cobranca tarifa */

IF  NOT VALID-HANDLE(h-b1wgen0090) THEN
    RUN sistema/generico/procedures/b1wgen0090.p PERSISTENT SET h-b1wgen0090.

RUN efetua-lancamento-tarifas-lat IN h-b1wgen0090(INPUT par_cdcooper,
                                                  INPUT par_dtmvtolt,
                                                  INPUT-OUTPUT TABLE tt-lat-consolidada ).
IF  VALID-HANDLE(h-b1wgen0090) THEN
    DELETE PROCEDURE h-b1wgen0090.

/* Fim - Rotina para cobranca tarifa */
           
RETURN "OK".

PROCEDURE pi_gera_log:
    DEF INPUT PARAM par_dscritic AS CHAR                NO-UNDO.

    DEF VAR aux_nrdrowid AS ROWID                       NO-UNDO.

    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT "996",
                        INPUT "Convenio: " + 
                              STRING(par_nrcnvcob, "9999999") + 
                              " - Doc: " + 
                              STRING(par_nrdocmto, "999999999"),
                        INPUT "INTERNET",
                        INPUT par_dscritic,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT "INTERNETBANK",
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    RETURN "OK".
END.
/*............................................................................*/
