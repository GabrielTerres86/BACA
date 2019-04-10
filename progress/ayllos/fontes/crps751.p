/* ..........................................................................

   Programa: Fontes/crps751.p  
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Rafael Faria - Supero
   Data    : Agosto/2018.                    Ultima atualizacao: 09/04/2019

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Chamado atraves do shell crps751.sh para criaçao 
               de emprestimo de cessao.
               
   Alteracoes : P437 - Consignado - Incluido os parametros ( par_dtvencto, par_vlpreemp  par_vlrdoiof) na chamada da rotina calcular_emprestimos

.............................................................................*/   

DEF VAR aux_lsdparam AS CHAR NO-UNDO. 

ASSIGN aux_lsdparam =  (SESSION:PARAMETER).
/*meu program*//*ASSIGN aux_lsdparam = "1;31;1;AUTOCDC;AUTOCDC;7;03/08/18;06/08/18;2652846;1;1124333;/usr/coop/sistema/equipe/faria/20180803temp.log".*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_cdcooper AS INTEGER                             NO-UNDO.
DEF VAR aux_cdagenci AS INTEGER                             NO-UNDO.
DEF VAR aux_nrdcaixa AS INTEGER                             NO-UNDO.
DEF VAR aux_cdoperad AS CHARACTER                           NO-UNDO.
DEF VAR aux_nmdatela AS CHARACTER                           NO-UNDO.
DEF VAR aux_idorigem AS INTEGER                             NO-UNDO.
DEF VAR aux_dtmvtolt AS DATE                                NO-UNDO.
DEF VAR aux_dtmvtopr AS DATE                                NO-UNDO.
DEF VAR aux_nrdconta AS INTEGER                             NO-UNDO.
DEF VAR aux_idseqttl AS INTEGER                             NO-UNDO.
DEF VAR aux_nrctremp AS INTEGER                             NO-UNDO.

DEF VAR aux_cdcritic AS INTEGER                             NO-UNDO.
DEF VAR aux_dscritic AS CHARACTER                           NO-UNDO.
DEF VAR aux_nmarqlog AS CHARACTER                           NO-UNDO.

DEF VAR aux_dtvencto AS DATE                                NO-UNDO.
DEF VAR aux_vlpreemp AS DECI                                NO-UNDO.
DEF VAR aux_vlrdoiof AS DECI                                NO-UNDO.

DEF VAR aux_transacao AS LOGICAL                            NO-UNDO.

DEF VAR h-b1wgen0002  AS HANDLE                             NO-UNDO.

/*************************PRINCIPAL*******************************************/

trans_751: 
DO TRANSACTION ON ERROR  UNDO trans_751, LEAVE trans_751
               ON ENDKEY UNDO trans_751, LEAVE trans_751:

    ASSIGN aux_transacao = FALSE.

    ASSIGN aux_cdcooper = INT (ENTRY( 1,aux_lsdparam,';'))
           aux_cdagenci = INT (ENTRY( 2,aux_lsdparam,';'))
           aux_nrdcaixa = INT (ENTRY( 3,aux_lsdparam,';'))
           aux_cdoperad = ENTRY( 4,aux_lsdparam,';')
           aux_nmdatela = ENTRY( 5,aux_lsdparam,';')
           aux_idorigem = INT (ENTRY( 6,aux_lsdparam,';'))
           aux_dtmvtolt = DATE (ENTRY( 7,aux_lsdparam,';'))
           aux_dtmvtopr = DATE (ENTRY( 8,aux_lsdparam,';'))
           aux_nrdconta = INT (ENTRY( 9,aux_lsdparam,';'))
           aux_idseqttl = INT (ENTRY( 10,aux_lsdparam,';'))
           aux_nrctremp = INT (ENTRY( 11,aux_lsdparam,';'))
           aux_nmarqlog = ENTRY(12,aux_lsdparam,';').

    ASSIGN aux_nrdcaixa = 0
           aux_cdoperad = "1"
           aux_nmdatela = "CRPS751"
           aux_idorigem = 7 /* batch */
           aux_idseqttl = 1
		   aux_dtvencto = ?
		   aux_vlpreemp = ?
		   aux_vlrdoiof = ?.
		   
      
      IF NOT VALID-HANDLE(h-b1wgen0002) THEN
       RUN sistema/generico/procedures/b1wgen0002.p 
           PERSISTENT SET h-b1wgen0002.

       RUN recalcular_emprestimo IN h-b1wgen0002 (INPUT aux_cdcooper /*par_cdcooper*/
                                                 ,INPUT aux_cdagenci /*par_cdagenci*/
                                                 ,INPUT aux_nrdcaixa /*par_nrdcaixa*/
                                                 ,INPUT aux_cdoperad /*par_cdoperad*/
                                                 ,INPUT aux_nmdatela /*par_nmdatela*/
                                                 ,INPUT aux_idorigem /*par_idorigem*/
                                                 ,INPUT aux_dtmvtolt /*par_dtmvtolt*/
                                                 ,INPUT aux_dtmvtopr /*par_dtmvtopr*/
                                                 ,INPUT aux_nrdconta /*par_nrdconta*/
                                                 ,INPUT aux_idseqttl /*par_idseqttl*/
                                                 ,INPUT aux_nrctremp /*par_nrctremp*/
												 ,INPUT aux_dtvencto /*par_dtvencto*/
												 ,INPUT aux_vlpreemp /*par_vlpreemp*/
												 ,INPUT aux_vlrdoiof /*par_vlrdoiof*/
                                                 ,OUTPUT TABLE tt-erro
                                                 ,OUTPUT TABLE tt-msg-confirma).
       DELETE OBJECT h-b1wgen0002.
      
      IF  RETURN-VALUE = "NOK"  THEN
        DO:
            
            MESSAGE "CRPS751 - Erro".
            FIND FIRST tt-erro NO-LOCK NO-ERROR .
            IF AVAILABLE tt-erro THEN
            DO:
              ASSIGN aux_cdcritic = tt-erro.cdcritic
                     aux_dscritic = tt-erro.dscritic.
            END.          
            
            UNDO, LEAVE trans_751.
        END.

     ASSIGN aux_transacao = TRUE.
     /*UNDO, LEAVE GRAVAR.*/

END. /* Fim transaction */

IF aux_transacao = FALSE THEN
DO:
    
    ASSIGN aux_dscritic = "Nao foi possivel gerar atualizar data: " + aux_dscritic.
    
    
    UNIX SILENT VALUE("echo " + STRING(today,"99/99/9999") +
              " " +  STRING(TIME,"HH:MM:SS") +
              "' --> 'Cooperativa: " + string(aux_cdcooper) + 
              "' --> 'Conta: " + string(aux_nrdconta) + " - Contrato: " + string(aux_nrctremp) + 
              "' --> 'Movimento: " + string(aux_dtmvtolt) + " - Proxima: " + string(aux_dtmvtopr) + 
              ": '" + aux_dscritic + "'" +
              " >> " + aux_nmarqlog ).      
    RETURN "NOK". 
END.

   