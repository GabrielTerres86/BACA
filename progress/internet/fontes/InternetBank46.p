/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank46.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Janeiro/2009                     Ultima atualizacao: 24/05/2010
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Obter dados para gerenciar telefone do titular 
               Modulo "Meu Cadastro"
   
   Alteracoes: 24/05/2010 - Ajustes referente a alteracao nas BO's para tela
                            CONTAS (David).
 
..............................................................................*/
 
CREATE WIDGET-POOL.

{ sistema/generico/includes/b1wgen0070tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/var_ibank.i }

DEF VAR h-b1wgen0070 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_cddopcao AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdrowid AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0070.p PERSISTENT SET h-b1wgen0070.
                
IF  NOT VALID-HANDLE(h-b1wgen0070)  THEN
    DO: 
        ASSIGN xml_dsmsgerr = "<dsmsgerr>Handle invalido para BO b1wgen0070." +
                              "</dsmsgerr>".  
        RETURN "NOK".
    END.

RUN obtem-dados-gerenciar-telefone IN h-b1wgen0070 
                                  (INPUT par_cdcooper,
                                   INPUT 90,             /** PAC      **/
                                   INPUT 900,            /** Caixa    **/
                                   INPUT "996",          /** Operador **/
                                   INPUT "INTERNETBANK", /** Tela     **/
                                   INPUT 3,              /** Origem   **/
                                   INPUT par_nrdconta,
                                   INPUT 1,              /** Titular  **/
                                   INPUT par_cddopcao,
                                   INPUT TO-ROWID(par_nrdrowid),
                                   INPUT TRUE,           /** Logar    **/ 
                                  OUTPUT aux_inpessoa,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-operadoras-celular,
                                  OUTPUT TABLE tt-telefone-cooperado).
                               
DELETE PROCEDURE h-b1wgen0070.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE           
            aux_dscritic = "Nao foi possivel obter dados do telefone.".                   
            
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".    
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<OPERADORAS>".

FOR EACH tt-operadoras-celular NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<OPERADORA><cdopetfn>" +
                        STRING(tt-operadoras-celular.cdopetfn) +
                                   "</cdopetfn><nmopetfn>" +
                                tt-operadoras-celular.nmopetfn +
                                   "</nmopetfn></OPERADORA>".

END. 

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</OPERADORAS>".

FIND FIRST tt-telefone-cooperado NO-LOCK NO-ERROR.

IF  AVAILABLE tt-telefone-cooperado  THEN
    DO:
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<TELEFONE><tptelefo>" +
                        STRING(tt-telefone-cooperado.tptelefo) +
                                       "</tptelefo><nrdddtfc>" +
                        STRING(tt-telefone-cooperado.nrdddtfc) +
                                       "</nrdddtfc><nrtelefo>" +
                        STRING(tt-telefone-cooperado.nrtelefo) +
                                       "</nrtelefo><cdopetfn>" +
                        STRING(tt-telefone-cooperado.cdopetfn) +
                                       "</cdopetfn><cdseqtfc>" +
                        STRING(tt-telefone-cooperado.cdseqtfc) +
                                       "</cdseqtfc></TELEFONE>".
    END.
    
RETURN "OK".

/*............................................................................*/
