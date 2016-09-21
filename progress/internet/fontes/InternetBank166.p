
/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank166.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Lombardi
   Data    : Marco/2016                        Ultima atualizacao: --/--/----
   
   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Consultar permissoes dos itens do menu Mobile
   
   Alteracoes: 
..............................................................................*/

CREATE WIDGET-POOL.
    
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/b1wnet0002tt.i }
{ sistema/internet/includes/var_ibank.i }

DEF BUFFER bb-itens-menu-mobile FOR tt-itens-menu-mobile.

DEF VAR h-b1wnet0002 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/internet/procedures/b1wnet0002.p PERSISTENT SET h-b1wnet0002.
                
IF  NOT VALID-HANDLE(h-b1wnet0002)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0002.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
       
RUN permissoes-menu-mobile IN h-b1wnet0002 (INPUT par_cdcooper,
                                            INPUT 90,             /** PAC      **/    
                                            INPUT 900,            /** Caixa    **/
                                            INPUT "996",          /** Operador **/
                                            INPUT "INTERNETBANK", /** Tela     **/
                                            INPUT 3,              /** Origem   **/
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_nrcpfope,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-itens-menu-mobile).
                                           
DELETE PROCEDURE h-b1wnet0002.
           
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE           
            aux_dscritic = "Nao foi possivel carregar permissoes do menu.".
                   
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".    
    END.
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = '<MENU>'.
    
FOR EACH tt-itens-menu-mobile NO-LOCK:
                                                   
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '<ITEM>' +
                                     '<CDITEMMN>' + STRING(tt-itens-menu-mobile.cditemmn) + '</CDITEMMN>' +
                                     '<FLCREATE>' + STRING(IF tt-itens-menu-mobile.flcreate THEN 1 ELSE 0) + '</FLCREATE>' +
                                   '</ITEM>'.
    
END. /** Fim do FOR EACH tt-itens-menu-mobile **/

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = '</MENU>'.

RETURN "OK".
                
/*............................................................................*/
