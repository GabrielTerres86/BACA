/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank28.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Junho/2007.                       Ultima atualizacao: 23/08/2018
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Obter permissoes de acesso para efetuar pagamentos pela
               Internet.
   
   Alteracoes: 09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).
   
               06/03/2008 - Utilizar include de temp-tables (David).
               
               09/04/2008 - Adaptacao para agendamento de pagamentos (David).
                          - Fone de ctato e hr limite de cancelamento
                            para instrucao de estorno(Guilherme).
   
               03/11/2008 - Inclusao widget-pool (martin)

               25/08/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).
 
               05/10/2011 - Parametro cpf operador na verifica_operacao
                            (Guilherme).
                            
               14/05/2012 - Projeto TED Internet (David).
               
               13/11/2012 - Melhoria Multi Pagamentos (David).
               
               18/04/2013 - Adicionadas tags para campos de hor�rio limite
                            para Pgto./Canc. de Conv. SICREDI (Lucas).
               
               26/01/2014 - Retornar endere�o de email para envio da instru��o
                            de estorno de pagamento SD232206 (Odirlei-AMcom)
                            
               31/03/2015 - #270431 Retornar e-mail e nr do fax do internet 
                            banking (agencia 90), que sao utilizados no 
                            estorno de pagamentos (Carlos)
                            
               20/04/2015 - Inclus�o dos campos de tipo de Transa��o nos limites.
                            (Dionathan)
                            
               28/07/2015 - Adi��o de par�metro flmobile para indicar que a origem
                            da chamada � do mobile (Dionathan)
               
               21/09/2017 - Retornar tag indicando se o convenio pode ser 
			                      cadastrado em debaut (David).
               
               28/03/2018 - Ajuste para que o caixa eletronico possa utilizar o mesmo
                            servico da conta online (PRJ 363 - Rafael Muniz Monteiro)
               
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/b1wgen0016tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0016 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dstrans1 AS CHAR                                           NO-UNDO.
DEF VAR aux_emailest AS CHAR                                           NO-UNDO.
DEF VAR aux_nrtelfax AS CHAR                                           NO-UNDO.
DEF VAR iHandle      AS INTEGER                                        NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_flgconve AS LOGI                                           NO-UNDO.
DEF VAR aux_flgtitul AS LOGI                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF  INPUT PARAM par_flmobile AS LOGI                                  NO-UNDO.

/* Projeto 363 - Novo ATM */
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dsorigem AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmprogra AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dsconsul  AS CHAR NO-UNDO.


ASSIGN aux_dstransa = "Acesso a tela de pagamentos".

RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

IF  VALID-HANDLE(h-b1wgen0015)  THEN
    DO:
        RUN verifica_operacao IN h-b1wgen0015 
                                      (INPUT par_cdcooper,
                                       INPUT par_cdagenci, /** PAC   - Projeto 363 - Novo ATM -> estava fixo 90 **/
                                       INPUT par_nrdcaixa, /** CAIXA - Projeto 363 - Novo ATM -> estava fixo 900 **/
                                       INPUT par_nrdconta,
                                       INPUT par_idseqttl,
                                       INPUT par_dtmvtolt,
                                       INPUT 0,          /** AGENDAMENTO   **/
                                       INPUT ?,          /** DATA DEBITO   **/
                                       INPUT 0,          /** VALOR OPER.   **/
                                       INPUT 0,          /** BANCO DESTINO **/
                                       INPUT 0,          /** AGENC.DESTINO **/
                                       INPUT 0,          /** CONTA DESTINO **/
                                       INPUT 0,          /** IND.TRANSACAO **/
                                       INPUT "996",      /** OPERADOR      **/
                                       INPUT 2,          /** PAGAMENTO     **/
                                       INPUT FALSE,      /** VALIDACOES    **/
                                       INPUT par_dsorigem, /** ORIGEM - Projeto 363 - Novo ATM -> estava fixo "INTERNET" **/
                                       INPUT par_nrcpfope, /** CPF OPERADOR  */
                                       INPUT TRUE,       /** VALIDA LIMITES**/
                                      OUTPUT aux_dstrans1,
                                      OUTPUT aux_dscritic,
                                      OUTPUT TABLE tt-limite,
                                      OUTPUT TABLE tt-limites-internet).
    
        DELETE PROCEDURE h-b1wgen0015.
                
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                                      "</dsmsgerr>".
                
                RUN proc_geracao_log (INPUT FALSE).
                
                RETURN "NOK".
            END.
                
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<LIMITE>".
       
        FIND FIRST tt-limite NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-limite  THEN
            DO:
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<hrinipag>" +
                                               tt-limite.hrinipag +
                                               "</hrinipag><hrfimpag>" +
                                               tt-limite.hrfimpag +
                                               "</hrfimpag><idesthor>" +
                                               STRING(tt-limite.idesthor) +
                                               "</idesthor>".
            END.
                                                 
        RUN sistema/generico/procedures/b1wgen0016.p PERSISTENT 
            SET h-b1wgen0016.
        
        IF  VALID-HANDLE(h-b1wgen0016)  THEN
            DO:
                RUN pagamentos_liberados IN h-b1wgen0016 (INPUT par_cdcooper,
                                                         OUTPUT aux_flgconve,
                                                         OUTPUT aux_flgtitul).
                                                          
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<flgconve>" +
                                               STRING(aux_flgconve,"L/B") +
                                               "</flgconve><flgtitul>" +
                                               STRING(aux_flgtitul,"L/B") +
                                               "</flgtitul>".
            
                RUN convenios_aceitos IN h-b1wgen0016 
                                            (INPUT par_cdcooper,
                                            OUTPUT TABLE tt-convenios_aceitos).
                
                DELETE PROCEDURE h-b1wgen0016.
            END.

        FIND FIRST crapage WHERE crapage.cdcooper = par_cdcooper AND
                                 crapage.cdagenci = par_cdagenci  /* Projeto 363 - Novo ATM -> estava fixo  90 */
                                 NO-LOCK NO-ERROR.
        
        IF  AVAILABLE crapage  THEN
            DO:
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<nrtelfax>" +
                                               crapage.nrtelfax +
                                               "</nrtelfax><hrcancel>" +
                                               STRING(crapage.hrcancel,"HH:MM") +
                                               "</hrcancel>".
            END.

        /*** Buscar informa��o do email para estorno de pagamento ***/
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

        /** Consultando e-mail da cooperativa e fax do internet banking (agencia 90) **/
        ASSIGN aux_dsconsul = "SELECT dsdemail, '|', nrtelfax FROM crapage WHERE " + 
                              "cdcooper = " + STRING(par_cdcooper) + " AND " + 
                              "cdagenci = " + STRING(par_cdagenci).	/* Projeto 363 - Novo ATM -> estava fixo 90 */

        RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement iHandle = PROC-HANDLE NO-ERROR(aux_dsconsul).

        FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = iHandle:
            ASSIGN aux_emailest = ENTRY(1, STRING(proc-text), "|")
                   aux_nrtelfax = ENTRY(2, STRING(proc-text), "|").
        END.

        CLOSE STORED-PROCEDURE pc_param_sistema WHERE PROC-HANDLE = aux_handproc.
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<emailest_pag>" + trim(aux_emailest) 
                                       + "</emailest_pag>".

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<nrtelfax_pag>" + trim(aux_nrtelfax) 
                                       + "</nrtelfax_pag>".

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<cdtiptra>" + "2" 
                                       + "</cdtiptra><dstiptra>"
                                       + "PAGAMENTO" + "</dstiptra>".

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "</LIMITE><CONVENIOS_ACEITOS>".

        FOR EACH tt-convenios_aceitos NO-LOCK:
        
            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = "<CONVENIO><nmextcon>" +
                                           tt-convenios_aceitos.nmextcon +
                                           "</nmextcon><nmrescon>" +
                                           tt-convenios_aceitos.nmrescon +
                                           "</nmrescon><cdempcon>" +
                                           STRING(tt-convenios_aceitos.cdempcon,
                                                  "9999") +
                                           "</cdempcon><cdsegmto>" +
                                           STRING(tt-convenios_aceitos.cdsegmto,
                                                  "9") +
                                           "</cdsegmto>" +
                                           "<hhoraini>" + STRING(tt-convenios_aceitos.hhoraini) + "</hhoraini>" +
                                           "<hhorafim>" + STRING(tt-convenios_aceitos.hhorafim) + "</hhorafim>" +
                                           "<hhoracan>" + STRING(tt-convenios_aceitos.hhoracan) + "</hhoracan>" +
                                           "<fldebaut>" + STRING(tt-convenios_aceitos.fldebaut) + "</fldebaut>" +
                                           "<cdhisdeb>" + STRING(tt-convenios_aceitos.cdhisdeb) + "</cdhisdeb>" +
                                           "<dssegmto>" + tt-convenios_aceitos.dssegmto + "</dssegmto>" +
                                           "</CONVENIO>".
        
        END.

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "</CONVENIOS_ACEITOS>".
            
        RUN proc_geracao_log (INPUT TRUE).
    END.
    
/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:
    
    DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.
    
    DEF   VAR       aux_dsorigem AS CHAR                            NO-UNDO.
    
    IF par_flmobile THEN
        ASSIGN aux_dsorigem = "MOBILE".
    ELSE 
        ASSIGN aux_dsorigem = par_nmprogra.
    
    
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT par_dsorigem,  /* Projeto 363 - Novo ATM -> estava fixo "INTERNET" */
                                          INPUT aux_dstransa,
                                          INPUT aux_datdodia,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT par_nmprogra, /* Projeto 363 - Novo ATM -> estava fixo "INTERNETBANK" */
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).
                                          
             RUN gera_log_item IN h-b1wgen0014
                          (INPUT aux_nrdrowid,
                           INPUT "Origem",
                           INPUT "",
                           INPUT aux_dsorigem).
                 
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE.
 
/*............................................................................*/