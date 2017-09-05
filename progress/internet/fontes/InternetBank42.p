/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank42.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Novembro/2008                     Ultima atualizacao: 00/00/0000
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Carregar operadores da conta e itens do menu do InternetBank.
   
   Alteracoes: 
 
..............................................................................*/
 
CREATE WIDGET-POOL.
    
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/b1wnet0002tt.i }
{ sistema/internet/includes/var_ibank.i }

DEF BUFFER bb-itens-menu FOR tt-itens-menu.

DEF VAR h-b1wnet0002 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/internet/procedures/b1wnet0002.p PERSISTENT SET h-b1wnet0002.
                
IF  NOT VALID-HANDLE(h-b1wnet0002)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0002.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
       
RUN obtem-operadores IN h-b1wnet0002 (INPUT par_cdcooper,
                                      INPUT 90,             /** PAC      **/
                                      INPUT 900,            /** Caixa    **/
                                      INPUT "996",          /** Operador **/
                                      INPUT "INTERNETBANK", /** Tela     **/
                                      INPUT 3,              /** Origem   **/
                                      INPUT par_nrdconta,
                                      INPUT 1,              /** Titular  **/
                                      INPUT FALSE,          /** Logar    **/  
                                     OUTPUT TABLE tt-operadores).
    
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<OPERADORES>".

FOR EACH tt-operadores NO-LOCK BY tt-operadores.nmoperad:
            
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<OPERADOR><nmoperad>" +
                                   tt-operadores.nmoperad +
                                   "</nmoperad><nrcpfope>" +
                                   STRING(tt-operadores.nrcpfope,
                                          "99999999999") +
                                   "</nrcpfope><dsdcargo>" +
                                   tt-operadores.dsdcargo +
                                   "</dsdcargo><flgsitop>" +
                                   TRIM(STRING(tt-operadores.flgsitop,
                                               "yes/no")) +
                                   "</flgsitop><dsdemail>" +
                                   tt-operadores.dsdemail +
                                   "</dsdemail><vllbolet>" +
								   TRIM(STRING(tt-operadores.vllbolet,
                                               "zzz,zzz,zz9.99-")) +
								   "</vllbolet><vllimtrf>" +
								   TRIM(STRING(tt-operadores.vllimtrf,
                                               "zzz,zzz,zz9.99-")) +
								   "</vllimtrf><vllimted>" +
								   TRIM(STRING(tt-operadores.vllimted,
                                               "zzz,zzz,zz9.99-")) +
								   "</vllimted><vllimvrb>" +
								   TRIM(STRING(tt-operadores.vllimvrb,
                                               "zzz,zzz,zz9.99-")) +
								   "</vllimvrb><vllimflp>" +
								   TRIM(STRING(tt-operadores.vllimflp,
                                               "zzz,zzz,zz9.99-")) +
								   "</vllimflp><PERMISSOES>". 
                                      
    RUN cria-tags-itens-menu (INPUT tt-operadores.nrcpfope).
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
        
    CREATE xml_operacao.                                      
    ASSIGN xml_operacao.dslinxml = "</PERMISSOES></OPERADOR>".

END. /** Fim do FOR EACH tt-operadores **/

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</OPERADORES><ITENS_MENU>".

RUN cria-tags-itens-menu (INPUT 0).
    
IF  RETURN-VALUE = "NOK"  THEN
    RETURN "NOK".
    
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</ITENS_MENU>".

DELETE PROCEDURE h-b1wnet0002.

RETURN "OK".


/*........................... PROCEDURES INTERNAS ............................*/


PROCEDURE cria-tags-itens-menu:

    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.

    RUN permissoes-menu IN h-b1wnet0002 (INPUT par_cdcooper,
                                         INPUT 90,             /** PAC      **/
                                         INPUT 900,            /** Caixa    **/
                                         INPUT "996",          /** Operador **/
                                         INPUT "INTERNETBANK", /** Tela     **/
                                         INPUT 3,              /** Origem   **/
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT par_nrcpfope,
                                         INPUT "",           /** URL        **/
                                         INPUT TRUE,         /** Tela Oper. **/
                                         INPUT TRUE,         /** Logar      **/
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-itens-menu).
                                                    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wnet0002.
            
            FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE           
                aux_dscritic = "Nao foi possivel carregar permissoes do menu.".
                   
            xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
            RETURN "NOK".    
        END.
        
    FOR EACH tt-itens-menu WHERE tt-itens-menu.cdsubitm = 0 NO-LOCK 
                                 BY tt-itens-menu.nrorditm:
                                                   
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = '<ITEM cditemmn="' +
                                       STRING(tt-itens-menu.cditemmn) +
                                       '" cdsubitm="' +
                                       STRING(tt-itens-menu.cdsubitm) +
                                       '" nmdoitem="' + 
                                       tt-itens-menu.nmdoitem +
                                       '" dsurlace="' + 
                                       tt-itens-menu.dsurlace + '">'.
                                     
        FOR EACH bb-itens-menu WHERE 
                 bb-itens-menu.cditemmn = tt-itens-menu.cditemmn AND
                 bb-itens-menu.cdsubitm > 0                      NO-LOCK
                 BY bb-itens-menu.nrorditm:

            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = '<SUB_ITEM cditemmn="' +
                                           STRING(bb-itens-menu.cditemmn) +
                                           '" cdsubitm="' +
                                           STRING(bb-itens-menu.cdsubitm) +
                                           '" nmdoitem="' +
                                           bb-itens-menu.nmdoitem +
                                           '" dsurlace="' + 
                                           bb-itens-menu.dsurlace + '">' +
                                           '</SUB_ITEM>'.

        END. /** Fim do FOR EACH bb-itens-menu **/

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = '</ITEM>'.
    
    END. /** Fim do FOR EACH tt-itens-menu **/

    RETURN "OK".
        
END PROCEDURE.


/*............................................................................*/
