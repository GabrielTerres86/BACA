/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank75.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Outubro/2011                        Ultima atualizacao: 13/01/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Validar e efetivar as transacoes pendentes dos operadores de 
               internet
   
   Alteracoes: 13/01/2016 - Alteracoes para o projeto de Assinatura Conjunta
                            Prj. 131 (Jean Michel).
                            
               30/01/2017 - Adicionado o codigo da transacao no xml de resposta
                            (Dionathan).
                            
               12/04/2018 - Inclusao de novos campo para realizaçao 
                            de analise de fraude. 
                            PRJ381 - AntiFraude (Odirlei-AMcom)             
                            
               25/05/2019 - Ajuste na validacao da data de critica
                            PRJ438 - Agilidade de credito (Odirlei)          
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0016tt.i }

DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdoperad AS CHAR        NO-UNDO.
DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_nmdatela AS CHAR        NO-UNDO.
DEFINE INPUT  PARAMETER par_cdditens AS CHAR        NO-UNDO.
/* 0- validacao 1- efetivacao */
DEFINE INPUT  PARAMETER par_indvalid AS INTE        NO-UNDO.
DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_nrcpfope AS DECIMAL     NO-UNDO.
DEFINE INPUT  PARAMETER par_iptransa AS CHAR        NO-UNDO.
DEFINE INPUT  PARAMETER par_flmobile AS LOGI        NO-UNDO.
DEFINE INPUT  PARAMETER par_iddispos AS CHAR        NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wgen0016 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
DEF VAR aux_contarok AS INTE                                           NO-UNDO.
DEF VAR aux_contanok AS INTE                                           NO-UNDO.
DEF VAR aux_dtcritic AS CHAR                                           NO-UNDO.

DEF VAR out_flgaviso AS LOGICAL                                        NO-UNDO.

RUN sistema/generico/procedures/b1wgen0016.p PERSISTENT SET h-b1wgen0016.

IF  NOT VALID-HANDLE(h-b1wgen0016)  THEN
DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0016.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            
    RETURN "NOK".
END.                                                                                 

RUN aprova_trans_pend IN h-b1wgen0016 (INPUT par_cdcooper, 
                                       INPUT par_nrdconta, 
                                       INPUT par_nrdcaixa, 
                                       INPUT par_cdagenci, 
                                       INPUT par_cdoperad, 
                                       INPUT par_dtmvtolt, 
                                       INPUT par_idorigem, 
                                       INPUT par_nmdatela, 
                                       INPUT par_idseqttl, 
                                       INPUT TRUE, /*log*/
                                       INPUT par_cdditens,
                                       INPUT par_indvalid,
                                       INPUT par_nrcpfope,
                                       INPUT par_iptransa,
                                       INPUT par_flmobile,
                                       INPUT par_iddispos,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-criticas_transacoes_oper,
                                      OUTPUT out_flgaviso).

DELETE PROCEDURE h-b1wgen0016.

IF  RETURN-VALUE <> "OK"  THEN
DO:
    FIND LAST tt-erro NO-LOCK NO-ERROR.

    IF AVAIL tt-erro THEN
        ASSIGN aux_dscritic = tt-erro.dscritic.
    ELSE
        ASSIGN aux_dscritic = "Nao foi possivel realizar a operacao.".
    
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

    RETURN "NOK".
END.
/* Efetivacao */
IF  par_indvalid = 1  THEN
DO:
    FOR FIRST tt-criticas_transacoes_oper WHERE tt-criticas_transacoes_oper.flgtrans = TRUE NO-LOCK. END.
	
	IF  AVAIL tt-criticas_transacoes_oper  THEN 
	    DO:	
            ASSIGN aux_dscritic = "Transacoes aprovadas com sucesso.".
			
			IF  out_flgaviso  THEN
				ASSIGN aux_dscritic = aux_dscritic + "\nVerifique as transacoes nao aprovadas.".

			ASSIGN xml_dsmsgerr = "<dsmsgsuc>" + aux_dscritic + "</dsmsgsuc>".
            
            
            IF  NOT out_flgaviso  THEN
                DO:
                    xml_dsmsgerr = xml_dsmsgerr + "<PROTOCOLOS>".
                    
                    FOR EACH tt-criticas_transacoes_oper WHERE  tt-criticas_transacoes_oper.flgtrans = TRUE NO-LOCK:
                        ASSIGN xml_dsmsgerr = xml_dsmsgerr + 
                                              "<dsprotoc>" + tt-criticas_transacoes_oper.dsprotoc + "</dsprotoc>".            
		END.
                    
                    xml_dsmsgerr = xml_dsmsgerr + "</PROTOCOLOS>".
                END.
                        
            
		END.
	ELSE
		DO:
			ASSIGN aux_dscritic = "As transacoes nao foram aprovadas com sucesso.\nVerifique a critica gerada no detalhamento da transacao."
			       xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
				   
			RETURN "NOK".
		END.
      
END.
ELSE /* Validacao */
DO:
        
    ASSIGN aux_dslinxml = ""
           aux_dtcritic = "".

    FIND FIRST tt-criticas_transacoes_oper WHERE
               tt-criticas_transacoes_oper.flgtrans  = TRUE AND
               tt-criticas_transacoes_oper.dscritic <> ""   NO-LOCK NO-ERROR.
    
    aux_dslinxml = aux_dslinxml + "<TRANSACOES flginfor='" + 
                  (IF AVAILABLE tt-criticas_transacoes_oper THEN "yes" ELSE "no") +
                   "'><APROVADAS>".

    FOR EACH tt-criticas_transacoes_oper WHERE 
             tt-criticas_transacoes_oper.flgtrans = TRUE NO-LOCK:
        
        IF string(tt-criticas_transacoes_oper.dtcritic) = "Nesta Data" THEN
            DO:
                ASSIGN aux_dtcritic = tt-criticas_transacoes_oper.dtcritic.                         
            END.
        ELSE IF string(tt-criticas_transacoes_oper.dtcritic) = "Mes atual" THEN
            DO:
                ASSIGN aux_dtcritic = tt-criticas_transacoes_oper.dtcritic.                         
            END.
        ELSE IF tt-criticas_transacoes_oper.dtcritic <> ? AND TRIM(tt-criticas_transacoes_oper.dtcritic) <> "" THEN            
            DO:
                ASSIGN aux_dtcritic = STRING(date(tt-criticas_transacoes_oper.dtcritic),"99/99/9999").
            END.
        ELSE
            DO:
                ASSIGN aux_dtcritic = " ".
            END.

        ASSIGN aux_contarok = aux_contarok + 1.
        
        ASSIGN aux_dslinxml = aux_dslinxml + "<TRANSACAO><dtcritic>" +
                              aux_dtcritic + "</dtcritic><vllantra>".

        IF tt-criticas_transacoes_oper.vllantra <> ? THEN 
           ASSIGN aux_dslinxml = aux_dslinxml +  TRIM(STRING(tt-criticas_transacoes_oper.vllantra,"zzz,zzz,zz9.99")).
        ELSE
           ASSIGN aux_dslinxml = aux_dslinxml +  " ".
                              
        ASSIGN aux_dslinxml = aux_dslinxml + "</vllantra><dscedent>" +      
                              tt-criticas_transacoes_oper.dscedent +
                              "</dscedent><dstiptra>" +
                              tt-criticas_transacoes_oper.dstiptra +
                              "</dstiptra><dscritic>" +
                              tt-criticas_transacoes_oper.dscritic +
                              "</dscritic><cdtransa>"+
                              STRING(tt-criticas_transacoes_oper.cdtransa) +
                              "</cdtransa><dtdebito>" +
                              (IF tt-criticas_transacoes_oper.dtcritic = "Nesta Data" OR 
                                  tt-criticas_transacoes_oper.dtcritic = ""           THEN 
                                  STRING(par_dtmvtolt,"99/99/9999")
                               ELSE       
                               IF tt-criticas_transacoes_oper.dtcritic = "Mes atual" THEN
                                  STRING(DATE(MONTH(par_dtmvtolt),1,YEAR(par_dtmvtolt)),"99/99/9999")
                               ELSE
                                  STRING(DATE(tt-criticas_transacoes_oper.dtcritic),"99/99/9999")) +
                              "</dtdebito><dtmvtolt>" +
                              STRING(par_dtmvtolt,"99/99/9999") +
                              "</dtmvtolt><cdtiptra>" +
                              STRING(tt-criticas_transacoes_oper.cdtiptra) +
                              "</cdtiptra></TRANSACAO>".
    END.
                              
    ASSIGN aux_dslinxml = aux_dslinxml + "</APROVADAS><DESAPROVADAS>"
           aux_dtcritic = "".
    
    FOR EACH tt-criticas_transacoes_oper WHERE 
             tt-criticas_transacoes_oper.flgtrans = FALSE NO-LOCK:

        IF  STRING(tt-criticas_transacoes_oper.dtcritic) = "Nesta Data" THEN
            DO:
                ASSIGN aux_dtcritic = tt-criticas_transacoes_oper.dtcritic.                         
            END.
        ELSE 
        IF  STRING(tt-criticas_transacoes_oper.dtcritic) = "Mes atual" THEN
            DO:
                ASSIGN aux_dtcritic = tt-criticas_transacoes_oper.dtcritic.                         
            END.
        ELSE 
        IF  tt-criticas_transacoes_oper.dtcritic <> ? AND tt-criticas_transacoes_oper.dtcritic <> "" THEN            
            DO:
                ASSIGN aux_dtcritic = STRING(DATE(tt-criticas_transacoes_oper.dtcritic),"99/99/9999").
            END.
        ELSE
            DO:
                ASSIGN aux_dtcritic = " ".
            END.
        
        ASSIGN aux_contanok = aux_contanok + 1
               aux_dslinxml = aux_dslinxml + "<TRANSACAO><dtcritic>" +
                              aux_dtcritic + "</dtcritic><vllantra>" +
                              TRIM(STRING(tt-criticas_transacoes_oper.vllantra,
                                          "zzz,zzz,zz9.99")) +
                              "</vllantra><dscedent>" +
                              tt-criticas_transacoes_oper.dscedent +
                              "</dscedent><dstiptra>" +
                              tt-criticas_transacoes_oper.dstiptra +
                              "</dstiptra><dscritic>" +
                              tt-criticas_transacoes_oper.dscritic +
                              "</dscritic><cdtransa>"+
                              STRING(tt-criticas_transacoes_oper.cdtransa) +
                              "</cdtransa><dtdebito>" +
                              (IF tt-criticas_transacoes_oper.dtcritic = "Nesta Data" OR 
                                  tt-criticas_transacoes_oper.dtcritic = ""           THEN 
                                  STRING(par_dtmvtolt,"99/99/9999")
                               ELSE       
                               IF tt-criticas_transacoes_oper.dtcritic = "Mes atual" THEN
                                  STRING(DATE(MONTH(par_dtmvtolt),1,YEAR(par_dtmvtolt)),"99/99/9999")
                               ELSE
                                  STRING(DATE(tt-criticas_transacoes_oper.dtcritic),"99/99/9999")) +
                              "</dtdebito><dtmvtolt>" +
                              STRING(par_dtmvtolt,"99/99/9999") +
                              "</dtmvtolt><cdtiptra>" +
                              STRING(tt-criticas_transacoes_oper.cdtiptra) +
                              "</cdtiptra></TRANSACAO>".
    
    END.
    
    aux_dslinxml = aux_dslinxml + "</DESAPROVADAS></TRANSACOES>".
    
    IF aux_contarok > 0 AND aux_contanok > 0 THEN
        ASSIGN aux_dscritic = "Existem transacoes que nao foram validadas " +
                              "com sucesso. " +
                              "Verifique as criticas na lista de reprovacoes.".
    ELSE IF aux_contarok = 0 THEN
        ASSIGN aux_dscritic = "Nenhuma transacao foi validada com sucesso. " +
                              "Verifique as criticas na lista de reprovacoes.".

    IF aux_dscritic <> "" THEN 
        ASSIGN aux_dslinxml = aux_dslinxml + "<DSMSGAUX>" + aux_dscritic + 
                                             "</DSMSGAUX>".

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = aux_dslinxml.

END.

RETURN "OK".

/*............................................................................*/
