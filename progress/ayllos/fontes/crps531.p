/* ............................................................................
   
   Programa: Fontes/crps531.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Setembro/2009.                     Ultima atualizacao: 29/08/2017

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
                            
               29/08/2017 - Conversao Progress >> PLSQL - Andrei - Mouts
                          - Rotina 531_1 sera mantida no TFS apenas para 
                          - caso ocorra algum problema na convertida e 
                          - decida-se retornar versao
                            
............................................................................ */

{ includes/var_batch.i  "NEW" }
{ sistema/generico/includes/var_oracle.i }
             
ASSIGN glb_cdprogra = "crps531"
       glb_cdcritic = 0
       glb_dscritic = ""
      /* Script mqcecred_processa passa como parametro cooperativa '3' */
       glb_cdcooper = INT(SESSION:PARAMETER).

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps531 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,   
    INPUT INT(STRING(glb_flgresta,"1/0")),
    OUTPUT 0,
    OUTPUT 0,                                        
    OUTPUT 0, 
    OUTPUT "").

IF  ERROR-STATUS:ERROR  THEN DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
     END.     
     
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/proc_batch.log").
    RETURN.
     END.

CLOSE STORED-PROCEDURE pc_crps531 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps531.pr_cdcritic WHEN pc_crps531.pr_cdcritic <> ?
       glb_dscritic = pc_crps531.pr_dscritic WHEN pc_crps531.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps531.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps531.pr_infimsol = 1 THEN
                          TRUE
                      ELSE
                          FALSE.
       
IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

        RETURN.
END.

/* .......................................................................... */
