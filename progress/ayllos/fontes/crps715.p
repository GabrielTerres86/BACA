/* ..........................................................................

   Programa: Fontes/crps715.p  
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Rafael Muniz Monteiro - Mout's
   Data    : Dezembro/2017.                    Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Chamado atraves do shell crps715.sh para criaçao 
               de emprestimo de conta prejuizo.
               
   Alteracoes :

.............................................................................*/   

DEF VAR aux_lsdparam AS CHAR NO-UNDO. 

ASSIGN aux_lsdparam =  (SESSION:PARAMETER).
/*ASSIGN aux_lsdparam = "1;3;8745;5,7;01262017;6901;69;7563239118254;12302016;12;/micros/cecred/odirlei/arq/20170412.log". */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_cdcooper AS INTEGER                                    NO-UNDO.
DEF VAR aux_cdcritic AS INTEGER                                    NO-UNDO.
DEF VAR aux_dscritic AS CHARACTER                                  NO-UNDO.
DEF VAR aux_qtsucess AS INTEGER                                    NO-UNDO.
DEF VAR aux_qtderros AS INTEGER                                    NO-UNDO.
DEF VAR aux_nrctremp AS INTEGER                                    NO-UNDO.
DEF VAR aux_cdagenci AS INTEGER                                    NO-UNDO.
DEF VAR aux_nrdcaixa AS INTEGER                                    NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                       NO-UNDO.
DEF VAR aux_idorigem AS INTEGER                                    NO-UNDO.
DEF VAR aux_nrdconta AS INTEGER                                    NO-UNDO.
DEF VAR aux_idseqttl AS INTEGER                                    NO-UNDO.
DEF VAR aux_vlemprst AS DECI                                       NO-UNDO.
DEF VAR aux_dtdpagto AS DATE                                       NO-UNDO.
DEF VAR aux_cdlcremp AS INTEGER                                    NO-UNDO.
DEF VAR aux_cdfinemp AS INTEGER                                    NO-UNDO.
DEF VAR aux_nrcartao AS DECIMAL                                    NO-UNDO.
DEF VAR aux_dtvencto_ori AS DATE                                   NO-UNDO.
DEF VAR aux_cdadmcrd AS INTEGER                                    NO-UNDO.
DEF VAR aux_nmarqlog AS CHARACTER                                  NO-UNDO.
DEF VAR aux_data     AS CHARACTER                                  NO-UNDO.
DEF VAR aux_transacao AS LOGICAL                                   NO-UNDO.

DEF VAR h-b1wgen0196  AS HANDLE                                    NO-UNDO.

/*************************PRINCIPAL*******************************************/

trans_714: 
DO TRANSACTION ON ERROR  UNDO trans_714, LEAVE trans_714
               ON ENDKEY UNDO trans_714, LEAVE trans_714:
  
    ASSIGN aux_transacao = FALSE.
    
    ASSIGN aux_cdcooper = INT (ENTRY( 1,aux_lsdparam,';'))
           aux_cdagenci = INT (ENTRY( 2,aux_lsdparam,';'))
           aux_nrdconta = INT (ENTRY( 3,aux_lsdparam,';'))
           aux_vlemprst = DECI(ENTRY( 4,aux_lsdparam,';'))       
           aux_cdlcremp = INT (ENTRY( 6,aux_lsdparam,';'))
           aux_cdfinemp = INT (ENTRY( 7,aux_lsdparam,';'))
           aux_nrcartao = DECI(ENTRY( 8,aux_lsdparam,';'))       
           aux_cdadmcrd = INT (ENTRY(10,aux_lsdparam,';'))
           aux_nmarqlog = ENTRY(11,aux_lsdparam,';').
    
    /* Tratar data de pagamento */       
    aux_data = ENTRY(5,aux_lsdparam,';').
    aux_dtdpagto = DATE(int(SUBSTRING(aux_data,1,2)),
                        int(SUBSTRING(aux_data,3,2)),
                        int(SUBSTRING(aux_data,5,4))).

    /* Tratar data de vencimento original */
    aux_data = ENTRY(9,aux_lsdparam,';').      
    aux_dtvencto_ori = DATE(int(SUBSTRING(aux_data,1,2)),
                            int(SUBSTRING(aux_data,3,2)),
                            int(SUBSTRING(aux_data,5,4))).
       
    ASSIGN aux_nrdcaixa = 0
           aux_cdoperad = "1"
           aux_nmdatela = "CRPS714"
           aux_idorigem = 7 /* batch */
           aux_idseqttl = 1.
           
           
    FIND FIRST crapdat
         WHERE crapdat.cdcooper = aux_cdcooper
         NO-LOCK no-error.
         
         
    IF NOT VALID-HANDLE(h-b1wgen0196) THEN
       RUN sistema/generico/procedures/b1wgen0196.p 
           PERSISTENT SET h-b1wgen0196.
           

      /* Gerar contrato de cessao de cartao de credito */
      RUN grava_dados IN h-b1wgen0196        
                       (  INPUT  aux_cdcooper /* par_cdcooper INTE */
                         ,INPUT  aux_cdagenci /* par_cdagenci INTE */
                         ,INPUT  aux_nrdcaixa /* par_nrdcaixa INTE */
                         ,INPUT  aux_cdoperad /* par_cdoperad CHAR */
                         ,INPUT  aux_nmdatela /* par_nmdatela CHAR */
                         ,INPUT  aux_idorigem /* par_idorigem INTE */
                         ,INPUT  aux_nrdconta /* par_nrdconta INTE */
                         ,INPUT  aux_idseqttl /* par_idseqttl INTE */
                         ,INPUT  crapdat.dtmvtolt /* par_dtmvtolt DATE */
                         ,INPUT  crapdat.dtmvtopr /* par_dtmvtopr DATE */
                         ,INPUT  aux_vlemprst /* par_vlemprst DECI */
                         ,INPUT  aux_dtdpagto /* par_dtdpagto DATE */
                         ,INPUT  aux_cdlcremp /* par_cdlcremp INTE */
                         ,INPUT  aux_cdfinemp /* par_cdfinemp INTE */
                         ,INPUT  aux_dtvencto_ori /* par_dtvencto_ori DATE */
                        
                        ,OUTPUT  aux_nrctremp
                        ,OUTPUT  TABLE tt-erro).
      DELETE OBJECT h-b1wgen0196.
   
      IF  RETURN-VALUE = "NOK"  THEN
        DO:
            
            FIND FIRST tt-erro NO-LOCK NO-ERROR .
            IF AVAILABLE tt-erro THEN
            DO:
              ASSIGN aux_cdcritic = tt-erro.cdcritic
                     aux_dscritic = tt-erro.dscritic.
            END.          
            
            UNDO, LEAVE trans_714.
        END. 
        
              
      /* Gravar dados de cessao */  
      CREATE tbcrd_cessao_credito.
      ASSIGN tbcrd_cessao_credito.cdcooper = aux_cdcooper 
             tbcrd_cessao_credito.nrdconta = aux_nrdconta
             tbcrd_cessao_credito.nrctremp = aux_nrctremp 
             tbcrd_cessao_credito.nrconta_cartao = aux_nrcartao
             tbcrd_cessao_credito.dtvencto = aux_dtvencto_ori
             tbcrd_cessao_credito.cdadmcrd = aux_cdadmcrd.

     
     ASSIGN aux_transacao = TRUE.
     /*UNDO, LEAVE GRAVAR.*/
    
END. /* Fim transaction */

IF aux_transacao = FALSE THEN
DO:
    
    ASSIGN aux_dscritic = "Nao foi possivel gerar emprestimo de cessao: " + aux_dscritic.
    
    
    UNIX SILENT VALUE("echo " + STRING(today,"99/99/9999") +
              " " +  STRING(TIME,"HH:MM:SS") +
              "' --> 'Conta: " + string(aux_nrdconta) + " - Conta Cartao: " + string(aux_nrcartao) + 
              ": '" + aux_dscritic + "'" +
              " >> " + aux_nmarqlog ).      
    RETURN "NOK". 
END.

   