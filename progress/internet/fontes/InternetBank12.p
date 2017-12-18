/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank12.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao: 05/09/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Carregar extrato da conta corrente.
   
   Alteracoes: 14/08/2008 - Carregar lancamentos futuros no extrato (David).
   
               03/11/2008 - Inclusao widget-pool (martin).
               
               06/10/2009 - Incluir listagem de cheques e depósitos 
                            identificados (David).
                            
               04/08/2010 - Utilizar nova procedure extrato-paginado (David).
               
               04/10/2012 - Tratamento para substituição do 'dshistor' por
                            'dsextrat' (Lucas) [Projeto Tarifas].
                            
               05/09/2014 - Incluir retorno do campo cdhistor na tt-extrato_conta 
                            Chamado: 161899 - (Jonathan - RKAM)
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0003tt.i }

DEF VAR h-b1wgen0001 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0003 AS HANDLE                                         NO-UNDO.

DEF VAR aux_vlstotal AS DECI                                           NO-UNDO.

DEF VAR aux_qtextrat AS INTE                                           NO-UNDO.
DEF VAR aux_qtcheque AS INTE                                           NO-UNDO.
DEF VAR aux_qtdeposi AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_vltotchq AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtiniper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtfimper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_inirgext AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_inirgchq AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_inirgdep AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_qtregpag AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_flglsext AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_flglschq AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_flglsdep AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_flglsfut AS LOGI                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

ASSIGN xml_dsmsgerr = "".

RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT SET h-b1wgen0001.

IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
    ASSIGN xml_dsmsgerr = "<dsmsgerr>Handle invalido para BO b1wgen0001." +
                          "</dsmsgerr>".  

RUN sistema/generico/procedures/b1wgen0003.p PERSISTENT SET h-b1wgen0003.
        
IF  NOT VALID-HANDLE(h-b1wgen0003)  THEN
    ASSIGN xml_dsmsgerr = "<dsmsgerr>Handle invalido para BO b1wgen0003." +
                          "</dsmsgerr>".  

IF  xml_dsmsgerr <> ""  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0001.
        DELETE PROCEDURE h-b1wgen0003.

        RETURN "NOK".
    END.

IF  par_flglsext  THEN
    DO:
        RUN extrato-paginado IN h-b1wgen0001 (INPUT par_cdcooper,
                                              INPUT 90,
                                              INPUT 900,
                                              INPUT "996",
                                              INPUT "INTERNETBANK",
                                              INPUT 3,
                                              INPUT par_nrdconta,
                                              INPUT par_idseqttl,
                                              INPUT par_dtiniper,
                                              INPUT par_dtfimper,
                                              INPUT par_inirgext,
                                              INPUT par_qtregpag,
                                              INPUT TRUE,
                                             OUTPUT aux_qtextrat,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-extrato_conta).
             
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                DELETE PROCEDURE h-b1wgen0001.
                DELETE PROCEDURE h-b1wgen0003.
        
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel carregar o extrato.".
                    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
                RETURN "NOK".
            END.
        
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = '<EXTRATO qtextrat="' + 
                                       STRING(aux_qtextrat) + '">'.
        
        FOR EACH tt-extrato_conta NO-LOCK BREAK BY tt-extrato_conta.dtmvtolt
                                                   BY tt-extrato_conta.nrsequen:
        
            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = "<DADOS><dtmvtolt>" +
                                  (IF  tt-extrato_conta.dtmvtolt <> ?  AND
                                       tt-extrato_conta.nrsequen <> 0  THEN
                                       TRIM(STRING(tt-extrato_conta.dtmvtolt,
                                                   "99/99/9999"))
                                   ELSE
                                       "") + 
                                   "</dtmvtolt><dtliblan>" +
                                   TRIM(tt-extrato_conta.dtliblan) +
                                   "</dtliblan><dsextrat>" + 
                                   TRIM(tt-extrato_conta.dsextrat) + 
                                   "</dsextrat><nrdocmto>" + 
                                   TRIM(STRING(tt-extrato_conta.nrdocmto)) +
                                   "</nrdocmto><vllanmto>" +
                                  (IF  tt-extrato_conta.nrsequen = 0  THEN
                                       ""
                                   ELSE
                                       TRIM(STRING(tt-extrato_conta.vllanmto,
                                                   "zz,zzz,zz9.99-"))) +
                                   "</vllanmto><indebcre>" + 
                                   CAPS(TRIM(tt-extrato_conta.indebcre)) +
                                   "</indebcre><vlsdtota>" +
                                  (IF  LAST-OF(tt-extrato_conta.dtmvtolt)  OR
                                       tt-extrato_conta.nrsequen = 0       THEN
                                       TRIM(STRING(tt-extrato_conta.vlsdtota,
                                                   "zz,zzz,zz9.99-"))
                                   ELSE
                                       "") + 
                                   "</vlsdtota><cdhistor>" +
                                   TRIM(STRING(tt-extrato_conta.cdhistor)) +
                                   "</cdhistor><nrseqlmt>" +
                                   TRIM(STRING(tt-extrato_conta.nrseqlmt)) +
                                   "</nrseqlmt><dsidenti>" +
                                   tt-extrato_conta.dsidenti +
                                   "</dsidenti></DADOS>".
        
        END. /** Fim do FOR EACH tt-extrato_conta **/
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = (IF  NOT par_flglsext  THEN 
                                    '<EXTRATO qtextrat="0">' 
                                ELSE 
                                    '') +
                               '</EXTRATO>'.

IF  par_flglschq  THEN
    DO:
        RUN obtem-cheques-deposito IN h-b1wgen0001 
                                  (INPUT par_cdcooper,
                                   INPUT 90,
                                   INPUT 900,
                                   INPUT "996",
                                   INPUT "INTERNETBANK",
                                   INPUT 3,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_dtiniper,
                                   INPUT par_dtfimper,
                                   INPUT TRUE,
                                   INPUT par_inirgchq,
                                   INPUT par_qtregpag,
                                   INPUT FALSE,
                                  OUTPUT aux_qtcheque,
                                  OUTPUT TABLE tt-extrato_cheque).

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = '<CHEQUES qtcheque="' + 
                                       STRING(aux_qtcheque) + '">'.

        FOR EACH tt-extrato_cheque NO-LOCK:

            IF  tt-extrato_cheque.vltotchq = 0  THEN
                aux_vltotchq = "".
            ELSE
                aux_vltotchq = TRIM(STRING(tt-extrato_cheque.vltotchq,
                                           "zzz,zzz,zz9.99")).
             
            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = "<DADOS><dtmvtolt>" +
                                           tt-extrato_cheque.dtmvtolt +
                                           "</dtmvtolt><nrdocmto>" +
                                      TRIM(STRING(tt-extrato_cheque.nrdocmto,
                                                  "zzz,zzz,zz9")) +
                                           "</nrdocmto><cdbanchq>" + 
                                           STRING(tt-extrato_cheque.cdbanchq,
                                                  "999") + 
                                           "</cdbanchq><cdagechq>" + 
                                           STRING(tt-extrato_cheque.cdagechq,
                                                  "9999") +
                                           "</cdagechq><nrctachq>" +
                                      TRIM(STRING(tt-extrato_cheque.nrctachq,
                                                  "zzzz,zzz,zzz,9")) +
                                           "</nrctachq><nrcheque>" + 
                                      TRIM(STRING(tt-extrato_cheque.nrcheque,
                                                  "zzz,zz9")) +
                                           "." +
                                           STRING(tt-extrato_cheque.nrddigc3) + 
                                           "</nrcheque><vlcheque>" +
                                      TRIM(STRING(tt-extrato_cheque.vlcheque,
                                                  "zzz,zzz,zz9.99")) + 
                                           "</vlcheque><vltotchq>" +
                                           aux_vltotchq + 
                                           "</vltotchq></DADOS>".
        
        END. /** Fim do FOR EACH tt-extrato_cheque **/
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = (IF  NOT par_flglschq  THEN 
                                    '<CHEQUES qtcheque="0">' 
                                ELSE 
                                    '') +
                               '</CHEQUES>'.

IF  par_flglsdep  THEN
    DO:
        RUN obtem-depositos-identificados IN h-b1wgen0001 
                                         (INPUT par_cdcooper,
                                          INPUT 90,
                                          INPUT 900,
                                          INPUT "996",
                                          INPUT "INTERNETBANK",
                                          INPUT 3,
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,
                                          INPUT par_dtiniper,
                                          INPUT par_dtfimper,
                                          INPUT TRUE,
                                          INPUT par_inirgdep,
                                          INPUT par_qtregpag,
                                          INPUT FALSE,
                                         OUTPUT aux_qtdeposi,
                                         OUTPUT TABLE tt-dep-identificado,
                                         OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                DELETE PROCEDURE h-b1wgen0001.
                DELETE PROCEDURE h-b1wgen0003.
        
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel carregar o extrato.".
                    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
                RETURN "NOK".
            END.

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = '<DEPOSITOS qtdeposi="' + 
                                       STRING(aux_qtdeposi) + '">'.

        FOR EACH tt-dep-identificado NO-LOCK:
             
            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = "<DADOS><dtmvtolt>" +
                                           STRING(tt-dep-identificado.dtmvtolt,
                                                  "99/99/9999") +
                                           "</dtmvtolt><dshistor>" +
                                           tt-dep-identificado.dshistor +
                                           "</dshistor><nrdocmto>" + 
                                           tt-dep-identificado.nrdocmto +
                                           "</nrdocmto><indebcre>" + 
                                           tt-dep-identificado.indebcre +                                          
                                           "</indebcre><vllanmto>" +
                                      TRIM(STRING(tt-dep-identificado.vllanmto,
                                                  "zzz,zzz,zzz,zz9.99-")) +
                                           "</vllanmto><dsidenti>" + 
                                           SUBSTR(tt-dep-identificado.dsidenti,
                                                  1,30) +
                                           "</dsidenti></DADOS>".
        
        END. /** Fim do FOR EACH tt-dep-identificado **/
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = (IF  NOT par_flglsdep  THEN 
                                    '<DEPOSITOS qtdeposi="0">' 
                                ELSE '') +
                                "</DEPOSITOS><FUTUROS>".

IF  par_flglsfut  THEN /** Lista lancamentos futuros **/
    DO:
        RUN consulta-lancamento IN h-b1wgen0003
                               (INPUT par_cdcooper,
                                INPUT 90,         
                                INPUT 900,        
                                INPUT "996",      
                                INPUT par_nrdconta,
                                INPUT 3,          
                                INPUT par_idseqttl,
                                INPUT "INTERNETBANK",
                                INPUT FALSE,      
                               OUTPUT TABLE tt-totais-futuros,
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-lancamento_futuro).
                                        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                DELETE PROCEDURE h-b1wgen0001.
                DELETE PROCEDURE h-b1wgen0003.

                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel consultar os " +
                                   "lancamentos futuros.".
    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + 
                               "</dsmsgerr>".  

                RETURN "NOK".
            END.                        

        FOR EACH tt-lancamento_futuro NO-LOCK BY tt-lancamento_futuro.dtmvtolt:

            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = "<DADOS><dtmvtolt>" +
                           (IF  tt-lancamento_futuro.dtmvtolt = 01/01/1099  THEN 
                                "FOLHA" 
                            ELSE 
                                STRING(tt-lancamento_futuro.dtmvtolt,
                                       "99/99/9999")) + 
                                           "</dtmvtolt><dshistor>" + 
                                           tt-lancamento_futuro.dshistor +
                                           "</dshistor><nrdocmto>" +
                                    STRING(tt-lancamento_futuro.nrdocmto) +
                                           "</nrdocmto><indebcre>" + 
                                           tt-lancamento_futuro.indebcre +
                                           "</indebcre><vllanmto>" +
                               TRIM(STRING(tt-lancamento_futuro.vllanmto,
                                           "zzz,zzz,zz9.99-")) +
                                           "</vllanmto></DADOS>".

        END. /** Fim do FOR EACH tt-lancamento_futuro **/
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</FUTUROS>".

DELETE PROCEDURE h-b1wgen0001.
DELETE PROCEDURE h-b1wgen0003.

RETURN "OK".

/*............................................................................*/
