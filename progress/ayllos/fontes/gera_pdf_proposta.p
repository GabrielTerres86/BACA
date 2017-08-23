/* ..........................................................................

   Programa: Fontes/crps_pdf_proposta.p  
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcos Martini - Supero
   Data    : Junho/2017.                    Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Chamado atraves do shell para gerar o PDF da Proposta em Progress.
               
   Alteracoes : 
   
.............................................................................*/
   

DEF VAR aux_lsdparam AS CHAR NO-UNDO. 

ASSIGN aux_lsdparam =  (SESSION:PARAMETER). 

/*ASSIGN aux_lsdparam = "1;1;1;ATENDA;1;9;818380;04112017;04122017;"
                    + "836524;teste.user;/micros/cecred/marcos/proposta.pdf".
*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }


/* Para recebimento dos parametros */
DEF  VAR  aux_cdcooper AS INTE                           NO-UNDO.
DEF  VAR  aux_cdagenci AS INTE                           NO-UNDO. 
DEF  VAR  aux_nrdcaixa AS INTE                           NO-UNDO. 
DEF  VAR  aux_nmdatela AS CHAR                           NO-UNDO.
DEF  VAR  aux_cdoperad AS CHAR                           NO-UNDO.    
DEF  VAR  aux_idorigem AS INTE                           NO-UNDO.
DEF  VAR  aux_nrdconta AS INTE                           NO-UNDO.  
DEF  VAR  aux_dtmvtolt AS DATE                           NO-UNDO.
DEF  VAR  aux_dtmvtopr AS DATE                           NO-UNDO.
DEF  VAR  aux_nrctremp AS INTE                           NO-UNDO.
DEF  VAR  aux_dsiduser AS CHAR                           NO-UNDO.
DEF  VAR  aux_nmarqpdf AS CHAR                           NO-UNDO.

/* Variaveis locais */
DEF VAR aux_nmarqpd2          AS CHAR                           NO-UNDO.
DEF VAR aux_cdcritic          AS INTE                           NO-UNDO.    
DEF VAR aux_dscritic          AS CHAR                           NO-UNDO.              
DEF VAR aux_datatext          AS CHAR                           NO-UNDO.              
        
DEF VAR h-b1wgen0195  AS HANDLE                                    NO-UNDO.

/*************************PRINCIPAL*******************************************/

/* Separar os parametros recebidos  */
ASSIGN aux_cdcooper = INT (ENTRY( 1,aux_lsdparam,';'))
       aux_cdagenci = INT (ENTRY( 2,aux_lsdparam,';'))
       aux_nrdcaixa = INT (ENTRY( 3,aux_lsdparam,';'))
       aux_nmdatela =     (ENTRY( 4,aux_lsdparam,';'))
       aux_cdoperad =     (ENTRY( 5,aux_lsdparam,';'))
       aux_idorigem = INT (ENTRY( 6,aux_lsdparam,';'))
       aux_nrdconta = INT (ENTRY( 7,aux_lsdparam,';'))
       aux_nrctremp = INT (ENTRY(10,aux_lsdparam,';'))
       aux_dsiduser =     (ENTRY(11,aux_lsdparam,';'))
       aux_nmarqpdf =     (ENTRY(12,aux_lsdparam,';'))

/* Tratar datas atual e proxima */       
aux_datatext = ENTRY(8,aux_lsdparam,';').
aux_dtmvtolt = DATE(int(SUBSTRING(aux_datatext,1,2)),
                    int(SUBSTRING(aux_datatext,3,2)),
                    int(SUBSTRING(aux_datatext,5,4))).
aux_datatext = ENTRY(9,aux_lsdparam,';').
aux_dtmvtopr = DATE(int(SUBSTRING(aux_datatext,1,2)),
                    int(SUBSTRING(aux_datatext,3,2)),
                    int(SUBSTRING(aux_datatext,5,4))).
                                        
/* Instanciar BO para chamada */
IF NOT VALID-HANDLE(h-b1wgen0195) THEN
   RUN sistema/generico/procedures/b1wgen0195.p 
       PERSISTENT SET h-b1wgen0195.
       

/* Gerar contrato de cessao de cartao de credito */
RUN gerar_proposta_pdf 
    IN h-b1wgen0195(INPUT aux_cdcooper
                   ,INPUT aux_cdagenci 
                   ,INPUT aux_nrdcaixa 
                   ,INPUT aux_nmdatela
                   ,INPUT aux_cdoperad    
                   ,INPUT aux_idorigem
                   ,INPUT aux_nrdconta  
                   ,INPUT aux_dtmvtolt
                   ,INPUT aux_dtmvtopr
                   ,INPUT aux_nrctremp
                   ,INPUT aux_dsiduser                                       
                   ,OUTPUT aux_nmarqpd2
                   ,OUTPUT aux_cdcritic
                   ,OUTPUT aux_dscritic).

DELETE OBJECT h-b1wgen0195.
   
IF  RETURN-VALUE = "NOK" OR aux_cdcritic > 0 
OR  aux_dscritic <> "" OR aux_nmarqpd2 = ""  THEN
  DO:
    
      /* Caso nao voltou PDF e nao tem critica */
      IF aux_nmarqpd2 = "" AND aux_dscritic = ""  THEN
      DO:      
            /* Gerar critica */
        aux_dscritic = "Nao foi possivel gerar impressao da proposta " + 
                       "para envio a Esteira.".
      END.
           
    /* Gerar LOG */  
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                        " - " + aux_nmdatela + "' --> '"  +
                        " Coop " + STRING(aux_cdcooper,"zzzz9") + 
                        " Conta " + STRING(aux_nrdconta,"zzzzzzzzz9") + 
                        " Proposta " + STRING(aux_nrctremp,"zzzzz9") +
                        " Erro na geracao da proposta --> " +
                        " - " + aux_dscritic + 
                        " >> log/proc_batch.log").        
          
    /* Retornar */
    RETURN "NOK".
  
  END. 
  
/* Mover o arquivo recebido para o seu novo nome */
UNIX SILENT VALUE("mv " + aux_nmarqpd2 + " " + aux_nmarqpdf  + " 2>/dev/null").
        
/* Retornar */
RETURN "OK". 
