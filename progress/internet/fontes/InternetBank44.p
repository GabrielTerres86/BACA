/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank44.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Janeiro/2009                     Ultima atualizacao: 04/07/2011
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Obter dados para modulo "Meu Cadastro".
   
   Alteracoes: 24/05/2010 - Ajustes referente a alteracao nas BO's para tela
                            CONTAS (David).
                            
               11/01/2011 - Inclusao de novos parametros nas BO's (David).
               
               04/07/2011 - Incluidos novos campos no XML enviado. (Henrique)
 
..............................................................................*/
 
CREATE WIDGET-POOL.

{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/b1wgen0070tt.i }
{ sistema/generico/includes/b1wgen0071tt.i }
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0038 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0070 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0071 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_destpenc AS CHAR                                           NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.
                                         
RUN sistema/generico/procedures/b1wgen0038.p PERSISTENT SET h-b1wgen0038.
                
IF  NOT VALID-HANDLE(h-b1wgen0038)  THEN
    DO:
        RUN elimina-handles.

        ASSIGN xml_dsmsgerr = "<dsmsgerr>Handle invalido para BO b1wgen0038." +
                              "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN sistema/generico/procedures/b1wgen0070.p PERSISTENT SET h-b1wgen0070.
                
IF  NOT VALID-HANDLE(h-b1wgen0070)  THEN
    DO:
        RUN elimina-handles.

        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0070.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN sistema/generico/procedures/b1wgen0071.p PERSISTENT SET h-b1wgen0071.
                
IF  NOT VALID-HANDLE(h-b1wgen0071)  THEN
    DO:
        RUN elimina-handles.

        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0071.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
       
RUN obtem-enderecos-viainternetbank IN h-b1wgen0038 
                                   (INPUT par_cdcooper,
                                    INPUT 90,             /** PAC      **/
                                    INPUT 900,            /** Caixa    **/
                                    INPUT "996",          /** Operador **/
                                    INPUT "INTERNETBANK", /** Tela     **/
                                    INPUT 3,              /** Origem   **/
                                    INPUT par_nrdconta, 
                                    INPUT 1,              /** Titular  **/
                                    INPUT TRUE,           /** Logar    **/  
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-endereco-cooperado).
    
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        RUN retorna-critica.
        RETURN "NOK".    
    END.

RUN obtem-telefone-cooperado IN h-b1wgen0070
                                       (INPUT par_cdcooper,
                                        INPUT 90,             /** PAC      **/
                                        INPUT 900,            /** Caixa    **/
                                        INPUT "996",          /** Operador **/
                                        INPUT "INTERNETBANK", /** Tela     **/
                                        INPUT 3,              /** Origem   **/
                                        INPUT par_nrdconta,
                                        INPUT 1,              /** Titular  **/
                                        INPUT TRUE,           /** Logar    **/  
                                       OUTPUT aux_msgconta,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-telefone-cooperado).
    
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        RUN retorna-critica.
        RETURN "NOK".    
    END.
    
RUN obtem-email-cooperado IN h-b1wgen0071
                                       (INPUT par_cdcooper,
                                        INPUT 90,             /** PAC      **/
                                        INPUT 900,            /** Caixa    **/
                                        INPUT "996",          /** Operador **/
                                        INPUT "INTERNETBANK", /** Tela     **/
                                        INPUT 3,              /** Origem   **/
                                        INPUT par_nrdconta,
                                        INPUT 1,              /** Titular  **/
                                        INPUT TRUE,           /** Logar    **/  
                                       OUTPUT aux_msgconta,
                                       OUTPUT TABLE tt-email-cooperado).
    
RUN elimina-handles.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<ENDERECO>".

FOR EACH tt-endereco-cooperado NO-LOCK:

    ASSIGN aux_destpenc = IF  tt-endereco-cooperado.flgtpenc  THEN
                              "RESIDENCIAL"
                          ELSE
                              "COMERCIAL".
                              
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<" + aux_destpenc + "><dsendere>" + 
                                   tt-endereco-cooperado.dsendere + 
                                   "</dsendere><nrendere>" +
                                   STRING(tt-endereco-cooperado.nrendere) +
                                   "</nrendere><complend>" +
                                   tt-endereco-cooperado.complend +
                                   "</complend><nrcepend>" +
                             STRING(tt-endereco-cooperado.nrcepend,"99999999") +
                                   "</nrcepend><nrcxapst>" +
                                   STRING(tt-endereco-cooperado.nrcxapst) +
                                   "</nrcxapst><nmbairro>" +
                                   tt-endereco-cooperado.nmbairro +
                                   "</nmbairro><nmcidade>" +
                                   tt-endereco-cooperado.nmcidade +
                                   "</nmcidade><cdufende>" +
                                   tt-endereco-cooperado.cdufende +
                                   "</cdufende><cdseqinc>" +
                                   STRING(tt-endereco-cooperado.cdseqinc) +
                                   "</cdseqinc><tpendass>" +
                                   STRING(tt-endereco-cooperado.tpendass) +
                                   "</tpendass><nrdoapto>" + 
                                   STRING(tt-endereco-cooperado.nrdoapto) +
                                   "</nrdoapto><cddbloco>" +
                                   tt-endereco-cooperado.cddbloco +
                                   "</cddbloco></" + aux_destpenc + ">".
                                    

END. /** Fim do FOR EACH tt-endereco-cooperado **/

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</ENDERECO><TELEFONES>".

FOR EACH tt-telefone-cooperado NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<TELEFONE><destptfc>" +
                                   tt-telefone-cooperado.destptfc +
                                   "</destptfc><nrdddtfc>(" +
                                   STRING(tt-telefone-cooperado.nrdddtfc) +
                                   ")</nrdddtfc><nrtelefo>" +
                                   STRING(tt-telefone-cooperado.nrtelefo) +
                                   "</nrtelefo><nmopetfn>" +
                                   tt-telefone-cooperado.nmopetfn +
                                   "</nmopetfn><nrdrowid>" +
                                   STRING(tt-telefone-cooperado.nrdrowid) +
                                   "</nrdrowid></TELEFONE>".

END. /** Fim do FOR EACH tt-telefone-cooperado **/

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</TELEFONES><EMAILS>".

FOR EACH tt-email-cooperado NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<EMAIL><dsdemail>" +
                                   tt-email-cooperado.dsdemail +
                                   "</dsdemail><nrdrowid>" +
                                   STRING(tt-email-cooperado.nrdrowid) +
                                   "</nrdrowid></EMAIL>".

END. /** Fim do FOR EACH tt-email-cooperado **/

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</EMAILS>".

RETURN "OK".

/*............................................................................*/

PROCEDURE elimina-handles:

    IF  VALID-HANDLE(h-b1wgen0038)  THEN
        DELETE PROCEDURE h-b1wgen0038.

    IF  VALID-HANDLE(h-b1wgen0070)  THEN
        DELETE PROCEDURE h-b1wgen0070.

    IF  VALID-HANDLE(h-b1wgen0071)  THEN
        DELETE PROCEDURE h-b1wgen0071.

END PROCEDURE.

PROCEDURE retorna-critica:

    RUN elimina-handles.
        
    FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                
    IF  AVAILABLE tt-erro  THEN
        ASSIGN aux_dscritic = tt-erro.dscritic.
    ELSE           
        ASSIGN aux_dscritic = "Nao foi possivel retornar os dados do titular.".
               
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

END PROCEDURE.

/*............................................................................*/
