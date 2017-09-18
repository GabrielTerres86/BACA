/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank153.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Renato Darosci
   Data    : Setembro/2015                      Ultima atualizacao: 22/06/2016

   Dados referentes ao programa:

   Frequencia: Sempre que houver acesso nas telas do GPS
   Objetivo  : Realizar as transações da tela de Agendamento de GPS
                Tipo Operação => 1 - Consulta dos dados de agendamentos de GPS
                Tipo Operação => 2 - Desativar agendamento
                Tipo Operação => 3 - Efetua pagamento GPS
                Tipo Operação => 4 - Consultar dados da cooperativa quanto ao GPS
                Tipo Operação => 5 - Efetua Agendamento de GPS
                Tipo Operação => 6 - Realizar a chamada da rotina de validação SICREDI
   
   Alteracoes: 30/05/2016 - Tratar aux_dscritic de retorno com "<> ?" na operacao 6
                            (Guilherme/SUPERO)

               22/06/2016 - Ajuste na data passada na operacao 6 (Guilherme/Supero)                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_dsdrowid AS CHAR                                  NO-UNDO.
DEF INPUT PARAM par_tpoperac AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_tpdpagto AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_sftcdbar AS CHAR                                  NO-UNDO.
DEF INPUT PARAM par_cdpagmto AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_dtcompet AS CHAR                                  NO-UNDO.
DEF INPUT PARAM par_dsidenti AS CHAR                                  NO-UNDO.
DEF INPUT PARAM par_vldoinss AS DECI                                  NO-UNDO.
DEF INPUT PARAM par_vloutent AS DECI                                  NO-UNDO.
DEF INPUT PARAM par_vlatmjur AS DECI                                  NO-UNDO.
DEF INPUT PARAM par_vlrtotal AS DECI                                  NO-UNDO.
DEF INPUT PARAM par_dtvencim AS CHAR                                  NO-UNDO.
DEF INPUT PARAM par_idfisjur AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_idleitur AS INTE                                  NO-UNDO.
DEF INPUT PARAM par_dtdiadeb AS CHAR                                  NO-UNDO.
DEF INPUT PARAM par_tpvalida AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM par_dsmsgerr AS CHAR                                 NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_cdcritic AS INT                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                          NO-UNDO.
DEF VAR xml_req      AS LONGCHAR                                      NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                         NO-UNDO.
DEF VAR aux_dtvalida AS DATE                                          NO-UNDO.
DEF VAR h-b1wgen0014 AS HANDLE                                        NO-UNDO.

IF  par_tpoperac = 1 THEN DO: /* Consulta */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    /* GENE0008 */
    RUN STORED-PROCEDURE pc_gps_agmto_consulta aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT 3, /** idorigem */
                          INPUT "996", /* cdoperad */
                          INPUT "INTERNETBANK", /* nmdatela */
                          OUTPUT 0,
                          OUTPUT "",
                          OUTPUT "").

    CLOSE STORED-PROC pc_gps_agmto_consulta aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_gps_agmto_consulta.pr_cdcritic
                            WHEN pc_gps_agmto_consulta.pr_cdcritic <> ?
           aux_dscritic = pc_gps_agmto_consulta.pr_dscritic
                            WHEN pc_gps_agmto_consulta.pr_dscritic <> ?
           xml_req      = pc_gps_agmto_consulta.pr_retxml.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN par_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.

    RETURN "OK".

END.
ELSE IF  par_tpoperac = 2 THEN DO: /* Desativacao */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_gps_agmto_desativar aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT 3, /** idorigem */
                          INPUT "996", /* cdoperad */
                          INPUT "INTERNETBANK", /* nmdatela */
                          INPUT par_dsdrowid,
                          INPUT INT(par_flmobile),
						  INPUT par_nrcpfope,
                          OUTPUT "").

    CLOSE STORED-PROC pc_gps_agmto_desativar aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dscritic = pc_gps_agmto_desativar.pr_dscritic
                            WHEN pc_gps_agmto_desativar.pr_dscritic <> ?.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN par_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
    
    RETURN "OK".

END.
ELSE IF  par_tpoperac = 3 THEN DO: /* Efetua pagamento GPS */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_gps_pagamento aux_handproc = PROC-HANDLE NO-ERROR
                        (INPUT par_cdcooper,
                         INPUT par_nrdconta,
                         INPUT 90,             /* cdagenci */
                         INPUT 900,            /* nrdcaixa */
                         INPUT par_idseqttl,  
                         INPUT par_tpdpagto,
                         INPUT 3,              /* idorigem */
                         INPUT "996",          /* cdoperad -  Internet Banking */
                         INPUT "INTERNETBANK", /* nmdatela */
                         INPUT par_idleitur,   /* indicador de leitura 1-leitora/0-manual */
                         INPUT 1,              /* inproces */
                         INPUT IF LENGTH(par_sftcdbar)=44 THEN par_sftcdbar ELSE "",
                         INPUT IF LENGTH(par_sftcdbar)=48 THEN par_sftcdbar ELSE "",
                         INPUT par_cdpagmto,
                         INPUT par_dtcompet,
                         INPUT par_dsidenti,
                         INPUT par_vldoinss,
                         INPUT par_vloutent,
                         INPUT par_vlatmjur,
                         INPUT par_vlrtotal,
                         INPUT par_dtvencim,
                         INPUT par_idfisjur,
                         INPUT 0, /* NRSEQAGP */
                         INPUT par_nrcpfope,
                         OUTPUT "",
                         OUTPUT 0,
                         OUTPUT "").

    CLOSE STORED-PROC pc_gps_pagamento aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dscritic = pc_gps_pagamento.pr_dscritic
                          WHEN pc_gps_pagamento.pr_dscritic <> ?.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN par_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<dsmsg>Pagamento(s) efetuado(s) com sucesso!</dsmsg>".

    RETURN "OK".
END.
ELSE IF  par_tpoperac = 4 THEN DO: /* Consultar dados da cooperativa quanto ao GPS */
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_gps_cooperativa aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          OUTPUT "",
                          OUTPUT "").

    CLOSE STORED-PROC pc_gps_cooperativa aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dscritic = pc_gps_cooperativa.pr_dscritic
                            WHEN pc_gps_cooperativa.pr_dscritic <> ?
           xml_req      = pc_gps_cooperativa.pr_retxml.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN par_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.

    RETURN "OK".

END.
ELSE IF  par_tpoperac = 5 THEN DO: /* Efetua Agendamento de GPS */
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_gps_agmto_novo aux_handproc = PROC-HANDLE NO-ERROR
                        (INPUT par_cdcooper,
                         INPUT par_nrdconta,
                         INPUT par_tpdpagto,
                         INPUT 90,
                         INPUT 900,
                         INPUT par_idseqttl,   /* par_idseqttl */
                         INPUT 3,              /* par_idorigem */
                         INPUT "996",
                         INPUT "INTERNETBANK", /* nmdatela */
                         INPUT par_idleitur,    /* leitura 1-leitora / 0-manual */
                         INPUT IF LENGTH(par_sftcdbar)=44 THEN par_sftcdbar ELSE "",
                         INPUT IF LENGTH(par_sftcdbar)=48 THEN par_sftcdbar ELSE "",
                         INPUT par_cdpagmto,
                         INPUT par_dtcompet,
                         INPUT par_dsidenti,
                         INPUT par_vldoinss,
                         INPUT par_vloutent,
                         INPUT par_vlatmjur,
                         INPUT par_vlrtotal,
                         INPUT par_dtvencim,
                         INPUT par_idfisjur,
                         INPUT par_dtdiadeb,
                         INPUT par_nrcpfope,
                         OUTPUT "",
                         OUTPUT 0,
                         OUTPUT "").

    CLOSE STORED-PROC pc_gps_agmto_novo aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dscritic = pc_gps_agmto_novo.pr_dscritic
                          WHEN pc_gps_agmto_novo.pr_dscritic <> ?.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN par_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<dsmsg>Agendamento(s) efetuado(s) com sucesso!</dsmsg>".
    RETURN "OK".

END.
ELSE IF  par_tpoperac = 6 THEN DO:
     
    /* Realizar a chamada da rotina de validação SICREDI */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    

    IF par_tpvalida = "V" THEN
        ASSIGN aux_dtvalida = DATE(par_dtvencim).
    ELSE
        ASSIGN aux_dtvalida = DATE(par_dtdiadeb).


    RUN STORED-PROCEDURE pc_gps_validar_sicredi aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT 90, 
                          INPUT "900", 
                          INPUT 3, 
                          INPUT par_dtmvtolt, 
                          INPUT "INTERNETBAN2", 
                          INPUT "996", 
                          INPUT 1,
                          INPUT par_idleitur,   /* indicador de leitura 1-leitora/0-manual */
                          INPUT STRING(par_cdpagmto), 
                          INPUT par_dsidenti, 
                          /*INPUT DATE(par_dtvencim),*/
                          INPUT DATE(aux_dtvalida),
                          INPUT IF LENGTH(par_sftcdbar)=44 THEN par_sftcdbar ELSE "",
                          INPUT IF LENGTH(par_sftcdbar)=48 THEN par_sftcdbar ELSE "",
                          INPUT par_dtcompet,
                          INPUT par_vldoinss / 100,
                          INPUT par_vloutent / 100,
                          INPUT par_vlatmjur / 100,
                          INPUT par_vlrtotal / 100, 
                          INPUT par_idseqttl, 
                          INPUT par_tpdpagto, 
                          INPUT par_nrdconta, 
                          INPUT par_idfisjur, 
                          INPUT par_tpvalida, /* A-Agendar / P-Pagar / V-Validar Pagamento */
                          INPUT 0, /* NRSEQAGP */
                          INPUT par_nrcpfope,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT 0,
                          OUTPUT 0,
                          OUTPUT "",
                          OUTPUT "").

    CLOSE STORED-PROC pc_gps_validar_sicredi aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dscritic = pc_gps_validar_sicredi.pr_dscritic.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dscritic <> ""
	AND aux_dscritic <> ? THEN DO:
        RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
            SET h-b1wgen0014.
            
        IF  VALID-HANDLE(h-b1wgen0014)  THEN DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT "INTERNET",
                                          INPUT "Validar GPS",
                                          INPUT TODAY,
                                          INPUT NO, /*SUCESSO/YES - ERRO/NO*/
                                          INPUT TIME,
                                          INPUT 1, 
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).
            DELETE PROCEDURE h-b1wgen0014.
        END.

        IF aux_dscritic MATCHES('*LPX-00229*') THEN
           ASSIGN aux_dscritic = 'Falha na execucao do metodo de Validar GPS! (Erro no serviço)'.

        ASSIGN par_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.


    IF  VALID-HANDLE(h-b1wgen0014)  THEN DO:
        RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                      INPUT "996",
                                      INPUT "",
                                      INPUT "INTERNET",
                                      INPUT "Validar GPS",
                                      INPUT TODAY,
                                      INPUT YES, /*SUCESSO/YES - ERRO/NO*/
                                      INPUT TIME,
                                      INPUT 1,
                                      INPUT "INTERNETBANK",
                                      INPUT par_nrdconta,
                                      OUTPUT aux_nrdrowid).
        DELETE PROCEDURE h-b1wgen0014.
    END.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.

    RETURN "OK".

END.




/*............................................................................*/


