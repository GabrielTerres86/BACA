/* ............................................................................
   
   Programa: Fontes/crps531.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Setembro/2009.                     Ultima atualizacao: 04/07/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Integrar mensagens(TED/TEC) recebidas via SPB.
   
   Observacoes: O script /usr/local/cecred/bin/mqcecred_recebe.pl baixa as 
                mensagens da fila de mensageria do MQ para o diretorio 
                /usr/coop/cecred/integra. Em seguida eh executado o script
                /usr/local/cecred/bin/mqcecred_processa.pl que faz chamada do
                CRPS531 para processar as mensagens. O programa identifica e 
                processa(em paralelo) cada mensagem na sua cooperativa de 
                destino. 
                Este procedimento esta configurado na CRON para rodar a cada
                5 minutos.   
                
   Alteracoes: 20/05/2010 - Criticar Numero de Conta Credito maior que 9
                            digitos;
                          - Efetuadas correcoes no LOG (Diego).
                          
               02/06/2010 - Desconsiderar zeros a esquerda na validacao do
                            numero da conta Credito (Diego).
                            
               14/06/2010 - Receber novas mensagens: STR0005R2, STR0007R2
                            PAG0106R2, PAG0107R2; 
                          - Logar "Mensagem nao prevista" somente na CECRED;
                          - Gerar mensagem de devolucao(STR0010/PAG0111)
                            partindo da CECRED, quando codigo da agencia for
                            inexistente; 
                          - Tratar mensagens Rejeitadas pela Cabine (Diego).

               04/08/2010 - Buscar descricao dos motivos de devolucao da 
                            craptab.cdacesso = "CDERROSSPB" (Diego).
                            
               27/08/2010 - Buscar motivos de devolução na TAB046 
                          - Acerto no format do campo "Conta Dest" ref. log de
                            mensagens RECEBIDA OK (Diego).  
                                             
               01/12/2010 - Permitir o recebimento das mensagens: STR0018 e 
                            STR0019 
                          - Mostrar no LOG de rejeitadas o codigo da mensagem
                            original (Diego).
                            
               15/02/2011 - Modificacoes no layout do STR0018, STR0019 e
                            PAG0101 (Gabriel).
                            
               29/07/2011 - Validar ambas as contas quando for conta 
                            conjunta. Especificar na TAG 'Hist' a descricao
                            da critica quando codigo do erro igual a 2 
                            (Gabriel).              
                            
               02/12/2011 - Rodar programa em paralelo; 
                          - Processar todas as mensagens disponibilizadas em 
                            um diretorio unico  (Gabriel)             
                            
               20/05/2014 - Transferido criacao do registro de lote do 531_1
                            para ca. Cria o registro de lote para todas as
                            cooperativas e no 531_1 apenas le o registro e
                            atualiza (Problemas com chave duplicada no Oracle;
                            em virtude do 531_1 rodar em paralelo).
                            (Chamado 158826) - (Fabricio)

               04/07/2017 - Adicionar o ID paralelo na mensagem de log
                            (Douglas - Chamado 524133)
............................................................................ */

{ includes/var_batch.i  "NEW" }
{ sistema/generico/includes/b1wgen0046tt.i } 

DEF STREAM str_1.
DEF STREAM str_mp.      /*  Stream para monitoramento do programas paralelos  */


DEF VAR aux_idparale  AS INT                                          NO-UNDO.
DEF VAR aux_dspidprg  AS CHAR                                         NO-UNDO.
                                                                      
DEF VAR aux_nmarquiv  AS CHAR                                         NO-UNDO.
DEF VAR aux_contador  AS INT                                          NO-UNDO.
DEF VAR aux_arqdelog  AS CHAR                                         NO-UNDO.                                                                      

DEF VAR b1wgen0046    AS HANDLE                                       NO-UNDO.
DEF VAR h_paralelo    AS HANDLE                                       NO-UNDO.

DEF VAR aux_contlock AS INTE                                          NO-UNDO.

DEF BUFFER crabcop FOR crapcop.
DEF BUFFER crabdat FOR crapdat.
                                                                      

DEFINE TEMP-TABLE crawarq                                             NO-UNDO
       FIELD nrsequen AS INTEGER
       FIELD nmarquiv AS CHAR
       INDEX crawarq1 AS PRIMARY
             nrsequen nmarquiv.
             
ASSIGN glb_cdprogra = "crps531"
      /* Script mqcecred_processa passa como parametro cooperativa '3' */
       glb_cdcooper = INT(SESSION:PARAMETER).

/* Busca dados da cooperativa */
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         ASSIGN glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.     
     
/* Busca data do sistema */ 
FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

IF   NOT AVAIL crapdat THEN 
     DO:
         ASSIGN glb_cdcritic = 1.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

/* Setar variavel de ambiente MONPROC para executar em paralelo */
UNIX SILENT VALUE("export MONPROC=SIM").

/* Mover arquivo de log do dia anterior para o /salvar */
INPUT THROUGH VALUE("ls /usr/coop/" + crapcop.dsdircop + 
                    "/log/crps531_*.log 2>/dev/null") NO-ECHO.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IMPORT UNFORMATTED aux_arqdelog.

   IF  DATE(INTE(SUBSTR(aux_arqdelog,32,2)),
            INTE(SUBSTR(aux_arqdelog,30,2)),
            INTE(SUBSTR(aux_arqdelog,34,4))) < crapdat.dtmvtolt  THEN
       UNIX SILENT VALUE ("mv " + aux_arqdelog + " /usr/coop/" + 
                          crapcop.dsdircop + "/salvar 2>/dev/null").

END.

/* As mensagens estarao no diretorio /usr/coop/cecred/integra e 
   o script ira executar com a variavel de ambiente CECRED */ 

ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop +
                      "/integra/msgr_cecred_*.xml"  
       aux_contador = 0.
                      

INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
                   NO-ECHO.
                   
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   IMPORT STREAM str_1 UNFORMATTED aux_nmarquiv.

   ASSIGN aux_contador = aux_contador + 1.
   
   CREATE crawarq.
   ASSIGN crawarq.nrsequen = aux_contador
          crawarq.nmarquiv = aux_nmarquiv.
          
END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.

/* Cria registro de lote (para todas as singulares) que sera lido e atualizado
   pelo 531_1. */
FOR EACH crabcop NO-LOCK:

    FIND FIRST crabdat WHERE crabdat.cdcooper = crabcop.cdcooper
         NO-LOCK NO-ERROR.

    IF NOT AVAIL crabdat THEN
    DO:
        ASSIGN glb_cdcritic = 1.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/proc_batch.log").
        QUIT.
    END.

    DO aux_contlock = 1 TO 10:

        FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper  AND
                           craplot.dtmvtolt = crabdat.dtmvtolt  AND
                           craplot.cdagenci = 1                 AND
                           craplot.cdbccxlt = crabcop.cdbcoctl  AND
                           craplot.nrdolote = 10115
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
             
        IF NOT AVAIL craplot THEN
            IF LOCKED craplot THEN
            DO:
                PAUSE 1 NO-MESSAGE.
                NEXT.
            END.
            ELSE
            DO:
                CREATE craplot.
                ASSIGN craplot.cdcooper = crabcop.cdcooper
                       craplot.dtmvtolt = crabdat.dtmvtolt
                       craplot.cdagenci = 1
                       craplot.cdbccxlt = crabcop.cdbcoctl
                       craplot.nrdolote = 10115
                       craplot.tplotmov = 1.

                VALIDATE craplot.
            END.
                 
        LEAVE.
    END.

    IF NOT AVAIL craplot THEN
    DO:
        ASSIGN glb_dscritic = "Tabela CRAPLOT esta em uso.".

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/proc_batch.log").
        QUIT.
    END.
END.

RUN sistema/generico/procedures/bo_paralelo.p PERSISTENT SET h_paralelo.

RUN gera_ID IN h_paralelo (OUTPUT aux_idparale).
    
FOR EACH crawarq NO-LOCK BY crawarq.nrsequen:

    /* cadastra programa paralelo */
    RUN ativa_paralelo IN h_paralelo (INPUT aux_idparale,
                                      INPUT crawarq.nrsequen).
                                      
    /* faz a chamada do programa em paralelo passando o
       ID,  o numero sequencial e o nome da mensagem */
    
    INPUT STREAM str_mp THROUGH VALUE
                     ("cecred_mbpro" +
                      " -pf arquivos/PROC_cron.pf " +
                      "-p fontes/crps531_1.p " +
                      "-param '" +
                      STRING(aux_idparale)     + "," + 
                      STRING(crawarq.nrsequen) + "," + 
                      crawarq.nmarquiv + "'") NO-ECHO.
                      
    SET STREAM str_mp aux_dspidprg FORMAT "x(30)" WITH FRAME f_monproc1.
    INPUT STREAM str_mp CLOSE.                    

    UNIX SILENT VALUE("echo " + 
                      STRING(TODAY,"99/99/9999") + " - " +
                      STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '" +
                      "Inicio da Execucao Paralela - PID: " + aux_dspidprg +
                      " - " + STRING(aux_idparale) +
                      " Seq.: " + STRING(crawarq.nrsequen,"zzzz9") +
                      " Mensagem: " + crawarq.nmarquiv + 
                      " >> /usr/coop/" + crapcop.dsdircop + "/log/crps531_" + 
                      STRING(crapdat.dtmvtolt,"99999999") + ".log").

    /* Mantem 10 programas executando em paralelo */
    RUN aguarda_paralelos IN h_paralelo (INPUT aux_idparale,
                                         INPUT 10).  
                                           
                                              
END.

/* Aguarda a finalizacao de todos os paralelos */
RUN aguarda_paralelos IN h_paralelo (INPUT aux_idparale,
                                     INPUT 0).    

DELETE PROCEDURE h_paralelo.

/* .......................................................................... */
