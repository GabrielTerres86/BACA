/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank49.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Janeiro/2009                     Ultima atualizacao: 11/01/2011
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Alterar/Excluir/Incluir telefone do titular 
               Modulo "Meu Cadastro"
   
   Alteracoes: 24/05/2010 - Ajustes referente a alteracao nas BO's para tela
                            CONTAS (David).
                            
               11/01/2011 - Inclusao de novos parametros nas BO's (David).   
               
               22/01/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
			                Transferencia entre PAs (Heitor - RKAM)
 
..............................................................................*/
 
CREATE WIDGET-POOL.

{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0070 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_msgatcad AS CHAR                                           NO-UNDO.
DEF VAR aux_chavealt AS CHAR                                           NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                           NO-UNDO.

DEF VAR aux_tpatlcad AS INTE                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_cddopcao AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdrowid AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_tptelefo AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdddtfc AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrtelefo AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_cdopetfn AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

RUN sistema/generico/procedures/b1wgen0070.p PERSISTENT SET h-b1wgen0070.
                
IF  NOT VALID-HANDLE(h-b1wgen0070)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0070.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
      
RUN validar-telefone IN h-b1wgen0070 (INPUT par_cdcooper,
                                      INPUT 90,             /** PAC      **/
                                      INPUT 900,            /** Caixa    **/
                                      INPUT "996",          /** Operador **/
                                      INPUT "INTERNETBANK", /** Tela     **/
                                      INPUT 3,              /** Origem   **/
                                      INPUT par_nrdconta,
                                      INPUT 1,              /** Titular  **/
                                      INPUT par_cddopcao,
                                      INPUT TO-ROWID(par_nrdrowid),
                                      INPUT par_tptelefo,
                                      INPUT par_nrdddtfc,
                                      INPUT par_nrtelefo,
                                      INPUT 0,              /** Ramal    **/
                                      INPUT "",             /** Setor    **/
                                      INPUT "",             /** Contato  **/
                                      INPUT par_cdopetfn,
                                      INPUT TRUE,
                                      INPUT 0,     /** Conta replicadora **/
                                     OUTPUT TABLE tt-erro).

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0070.

        FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE           
            aux_dscritic = "Nao foi possivel concluir a operacao.".
                   
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".    
    END.

RUN gerenciar-telefone IN h-b1wgen0070 (INPUT par_cdcooper,
                                        INPUT 90,             /** PAC           **/
                                        INPUT 900,            /** Caixa         **/
                                        INPUT "996",          /** Operador      **/
                                        INPUT "INTERNETBANK", /** Tela          **/
                                        INPUT 3,              /** Origem        **/
                                        INPUT par_nrdconta,                    
                                        INPUT 1,              /** Titular       **/
                                        INPUT par_cddopcao,
                                        INPUT par_dtmvtolt,
                                        INPUT TO-ROWID(par_nrdrowid),
                                        INPUT par_tptelefo,
                                        INPUT par_nrdddtfc,
                                        INPUT par_nrtelefo,
                                        INPUT 0,              /** Ramal         **/
                                        INPUT "",             /** Setor         **/
                                        INPUT "",             /** Contato       **/
                                        INPUT par_cdopetfn,
                                        INPUT "I",            /** Sis.Alteracao **/
                                        INPUT TRUE,           /** Logar         **/
                                        INPUT 1,              /** Situacao      **/
                                        INPUT 1,              /** Origem        **/
                                       OUTPUT aux_tpatlcad,
                                       OUTPUT aux_msgatcad,
                                       OUTPUT aux_chavealt,
                                       OUTPUT aux_msgrvcad,
                                       OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0070.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE           
            aux_dscritic = "Nao foi possivel concluir a operacao.".
                   
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".    
    END.

RETURN "OK".

/*............................................................................*/

