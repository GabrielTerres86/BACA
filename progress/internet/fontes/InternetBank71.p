
/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank71.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jorge
   Data    : Outubro/2011                        Ultima atualizacao: 17/11/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Manipular mensagens do InternetBank. 
   
   Alteracoes: 14/11/2013 - Retornar qtd de msg nao lidas quando a opcao for
                            leitura das mensagens (David).
                            
               17/11/2016 - M172 Atualizacao Telefone - Gerar log item na
                            leitura das mensagens (Guilherme/SUPERO)
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0116tt.i }
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrdmensg AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_iddopcao AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_iddmensg AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrregist AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nriniseq AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wgen0116 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.

DEF VAR aux_qtdmensg AS INTE                                           NO-UNDO.
DEF VAR aux_qtmsnlid AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_retrerro AS CHAR                                           NO-UNDO.
DEF VAR aux_dsassunt AS CHAR                                           NO-UNDO.
DEF VAR aux_dsasnlid AS CHAR                                           NO-UNDO.

DEF VAR aux_dtdmensg LIKE crapmsg.dtdmensg                             NO-UNDO.
DEF VAR aux_dsdassun LIKE crapmsg.dsdassun                             NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

ASSIGN aux_dstransa = "Acesso ao servico de mensagens. " + 
                      "(iddopcao=" + STRING(par_iddopcao) + ")".

RUN sistema/generico/procedures/b1wgen0116.p PERSISTENT SET h-b1wgen0116.

IF  NOT VALID-HANDLE(h-b1wgen0116)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0116.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RUN proc_geracao_log (INPUT FALSE).

        RETURN "NOK".
    END.

IF  par_iddopcao = 0 THEN
    DO:
        ASSIGN aux_dstransa = "Quantidade Mensagens".
        RUN quantidade-mensagens IN h-b1wgen0116 (INPUT par_cdcooper, 
    	                                          INPUT par_nrdconta,
                                                  INPUT par_idseqttl,
                                                  INPUT par_iddmensg,
                                                  INPUT par_nrregist, 
                                                  INPUT par_nriniseq, 
                                                 OUTPUT aux_retrerro,
                                                 OUTPUT aux_dsassunt,
                                                 OUTPUT aux_qtdmensg).
    END.
ELSE IF par_iddopcao = 1 THEN
    DO:
        ASSIGN aux_dstransa = "Listar Mensagens".
        RUN listar-mensagens IN h-b1wgen0116 (INPUT par_cdcooper, 
	                                          INPUT par_nrdconta,
                                              INPUT par_idseqttl,
                                              INPUT par_iddmensg,
                                              INPUT par_nrregist, 
                                              INPUT par_nriniseq, 
                                             OUTPUT aux_retrerro,
                                             OUTPUT aux_qtmsnlid,
                                             OUTPUT aux_dsasnlid,
                                             OUTPUT TABLE tt-mensagens).
    END.
ELSE IF par_iddopcao = 2 THEN
    DO:
        ASSIGN aux_dstransa = "Ler Mensagem".
        ASSIGN aux_dsdassun = ""
               aux_dtdmensg = ?.

        RUN ler-mensagem  IN h-b1wgen0116 (INPUT par_cdcooper, 
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT par_nrdmensg,
                                          OUTPUT aux_qtmsnlid,
                                          OUTPUT aux_dsasnlid,
                                          OUTPUT TABLE tt-mensagens,
                                          OUTPUT TABLE tt-erro).
        FIND FIRST tt-mensagens
             WHERE tt-mensagens.nrdmensg = par_nrdmensg
           NO-LOCK NO-ERROR.
        ASSIGN aux_dsdassun = tt-mensagens.dsdassun
               aux_dtdmensg = tt-mensagens.dtdmensg.
    END.
ELSE IF par_iddopcao = 3 THEN
    DO:
        ASSIGN aux_dstransa = "Excluir Mensagem".
	    RUN excluir-mensagem in h-b1wgen0116 (INPUT par_cdcooper, 
                                              INPUT par_nrdconta,
                                              INPUT par_nrdmensg,
                                             OUTPUT aux_retrerro).
    END.

DELETE PROCEDURE h-b1wgen0116.

IF  aux_retrerro <> "" THEN
    DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_retrerro + "</dsmsgerr>".  
                
        RUN proc_geracao_log (INPUT FALSE).

        RETURN "NOK".    
    END.

IF  par_iddopcao = 0 THEN
    DO:
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = 
               "<qtdmensg>" + STRING(aux_qtdmensg) + "</qtdmensg>" +
               "<dsassunt>" + aux_dsassunt + "</dsassunt>".
    END.
ELSE IF  par_iddopcao = 1 OR par_iddopcao = 2 THEN
    DO:
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel carregar a mensagem.".
                    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
                RUN proc_geracao_log (INPUT FALSE).

                RETURN "NOK".
            END.
    
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<mensagens>".
                
        FOR EACH tt-mensagens NO-LOCK:
        
            ASSIGN xml_operacao.dslinxml = 
                   xml_operacao.dslinxml + "<mensagem>" +
                   "<cdcooper>" + STRING(tt-mensagens.cdcooper) + "</cdcooper>" +
                   "<nrdconta>" + STRING(tt-mensagens.nrdconta) + "</nrdconta>" +
                   "<idseqttl>" + STRING(tt-mensagens.idseqttl) + "</idseqttl>" +
                   "<nrdmensg>" + STRING(tt-mensagens.nrdmensg) + "</nrdmensg>" +
                   "<cdprogra>" + STRING(tt-mensagens.cdprogra) + "</cdprogra>" +
                   "<dtdmensg>" + (IF  tt-mensagens.dtdmensg = ?  THEN " "
                                   ELSE STRING(tt-mensagens.dtdmensg,
                                                 "99/99/9999")) + "</dtdmensg>" +
                   "<hrdmensg>" + STRING(tt-mensagens.hrdmensg,"HH:MM:SS") +
                                                                  "</hrdmensg>" +
                   "<dsdremet>" + tt-mensagens.dsdremet + "</dsdremet>" +
                   "<dsdassun>" + tt-mensagens.dsdassun + "</dsdassun>" +
                   "<dsdmensg>" + tt-mensagens.dsdmensg + "</dsdmensg>" +
                   "<flgleitu>" + STRING(tt-mensagens.flgleitu) + "</flgleitu>" +
                   "<dtdleitu>" + (IF  tt-mensagens.dtdleitu = ?  THEN " "
                                   ELSE STRING(tt-mensagens.dtdleitu,
                                                 "99/99/9999")) + "</dtdleitu>" +
                   "<hrdleitu>" + STRING(tt-mensagens.hrdleitu,"HH:MM:SS") +
                                                                  "</hrdleitu>" +
                   "<inpriori>" + STRING(tt-mensagens.inpriori) + "</inpriori>" +
                   "<flgexclu>" + STRING(tt-mensagens.flgexclu) + "</flgexclu>" +
                   "<qtdresul>" + STRING(tt-mensagens.qtdresul) + "</qtdresul>" +
                   "</mensagem>".
                        
        END. /** Fim do FOR EACH tt-mensagens **/
        
        ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "</mensagens>".

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<Nao_Lidas><qtmsnlid>" +
                                       STRING(aux_qtmsnlid) +
                                       "</qtmsnlid><dsasnlid>" +
                                       aux_dsasnlid +
                                       "</dsasnlid></Nao_Lidas>".
    END.
    
    IF  par_iddopcao <> 0 THEN
        RUN proc_geracao_log (INPUT TRUE).

RETURN "OK".


/*............................. PROCEDURES ..................................*/

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
                                                            
        /** Se for Leitura de Msg, gera log do item */
        IF  par_iddopcao = 2 THEN DO:

            RUN gera_log_item IN h-b1wgen0014
                          (INPUT aux_nrdrowid,
                           INPUT "Assunto",
                           INPUT "",
                           INPUT aux_dsdassun).

            RUN gera_log_item IN h-b1wgen0014
                          (INPUT aux_nrdrowid,
                           INPUT "Data Mensagem",
                           INPUT "",
                           INPUT aux_dtdmensg).

        END.

            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE.


