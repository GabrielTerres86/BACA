/* .............................................................................

   Programa: Fontes/crps568.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Abril/2010                       Ultima atualizacao: 10/06/2013.
   
   Dados referentes ao programa:

   Frequencia: Diario
   Objetivo  : Aguarda arquivos da Compe ABBC e aguarda inicio do processo
               da CECRED.
               
               Primeiro programa da Cadeia da Compensacao ABBC.
   
   Alteracoes: 26/05/2010 - Correcao no aguardo dos arquivos de Controle no
                            processo da Cecred (Ze).
                            
               23/06/2010 - Ajustes nas mensagens para o Log e Tratamento
                            para ROC650 (Ze).
                            
               10/08/2010 - Envio de critica em e-mail (Adriano).  
               
               31/08/2010 - Remover arquivos do SERASA 
                            /micros/cecred/serasa/SER_* (Guilherme).
                            
               04/10/2010 - Melhorias no tratamento de aguardo dos arqs. (Ze).
               
               25/07/2012 - Verificação para procurar pelo arq baixado da ABBC se
                            não encontrar arq de controle.
                          - Exclusão do email 'margarete@cecred.coop.br' (Lucas)
               
               10/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).
............................................................................. */

{ includes/var_batch.i }

DEF STREAM str_1.  /*  Stream para da data da solicitacao do processo  */

DEF BUFFER crabcop FOR crapcop.

DEF VAR aux_nmarquiv AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqui2 AS CHAR                                         NO-UNDO.
DEF VAR aux_narqabbc AS CHAR                                         NO-UNDO.
DEF VAR aux_dtarquiv AS DATE                                         NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                         NO-UNDO.
DEF VAR aux_execabbc AS CHAR                                         NO-UNDO.
DEF VAR aux_lghrexec AS LOG                                          NO-UNDO.
DEF VAR aux_hrlimite AS CHAR                                         NO-UNDO.
DEF VAR aux_flgproce AS LOGICAL                                      NO-UNDO.


ASSIGN glb_cdprogra = "crps568"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
IF   NOT AVAILABLE crapcop  THEN 
     DO:
         ASSIGN glb_cdcritic = 651.
         RUN fontes/critic.p.

         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
        
         RETURN.
     END.

/***************************  PARA   CECRED  **********************************/
/* Processo da CECRED verificar se as coop. filiadas o processo da ABBC */

IF   glb_cdcooper = 3 THEN 
     DO:
         /* Remover arquivos do SERASA /micros/cecred/serasa/SER_* 
            esta sendo removido pois na criacao ja joga no salvar */
         UNIX SILENT VALUE("rm /micros/cecred/serasa/SER_* 2> /dev/null").
         
         RUN pi_gera_log(INPUT "Aguardando as cooperativas " + 
                               " finalizarem o processo da ABBC ... " +
                               "finalizar prog. 546 das coops").

         /* WHILE 1 - Verificar processos ABBC das cooperativas */
         DO WHILE TRUE:

            ASSIGN aux_flgproce = TRUE.

            FOR EACH crabcop WHERE crabcop.cdcooper <> 3 NO-LOCK:
            
                ASSIGN aux_nmarquiv = "/usr/coop/" + TRIM(LC(crabcop.dsdircop))
                                      + "/controles/Processo_ABBC.Ok".
    
                IF   SEARCH(aux_nmarquiv) = ? THEN
                     aux_flgproce = FALSE.
            END.

            IF   aux_flgproce THEN 
                 DO:
                     RUN pi_gera_log (INPUT "Processo ABBC das cooperativas " + 
                                            "finalizado.").
                     LEAVE.
                 END.
            ELSE
                 PAUSE 60 NO-MESSAGE.
                 
         END.  /* FIM do WHILE TRUE 1 */


         RUN pi_executa_abbc (OUTPUT aux_execabbc).
        
         IF   aux_execabbc = "SIM" THEN 
              DO:
                 /*   ARQUIVO FAC ............ Centralizacao Cheques   */
                 
                 RUN pi_valida_hora_limite_abbc (OUTPUT aux_lghrexec, 
                                                 OUTPUT aux_hrlimite).
         
                 RUN pi_gera_log(INPUT "Aguardando arquivo FAC da CECRED - " +
                                       "Centralizacao ABBC... " +
                                       "- Horario limite: " +  aux_hrlimite).
                 RUN pi_gera_log(INPUT "Arquivo esperado: " +
                                      "/usr/coop/cecred/integra/FAC640N9.085").
                 
                 /* WHILE 2 - Verificar arquivo FAC */
         
                 DO WHILE TRUE:
           
                    aux_nmarquiv = "/usr/coop/cecred/controles/ArqfacABBC.ok".

                    /* Se não encontrar arq de controle, procura pelo arq baixado. */
                    aux_nmarqui2 = "/usr/coop/cecred/integra/FAC640N9.085".

                    IF   SEARCH(aux_nmarquiv) = ? AND
                         SEARCH(aux_nmarqui2) = ? THEN
                         DO:
                              RUN pi_valida_hora_limite_abbc (OUTPUT aux_lghrexec, 
                                                             OUTPUT aux_hrlimite).
                                      
                              IF   NOT aux_lghrexec THEN 
                                   DO:
                                       RUN pi_gera_log
                                                  (INPUT "Horario limite esgotado. " +
                                                         "Continuando SEM arquivos de" +
                                                         " FAC da ABBC").
                                      
                                       RUN enviar_email(INPUT "FAC").
                                     
                                       LEAVE.
                                   END.
                              ELSE
                                   PAUSE 20 NO-MESSAGE.
                         END.         
                    ELSE
                         DO:
                             RUN pi_gera_log (INPUT "Arquivo FAC ... OK ").
                             LEAVE.
                         END.
         
                 END. /* FIM do WHILE TRUE 2 */



                 /*   ARQUIVO ROC640 ............ Centralizacao DOC/Tit.   */               
                 RUN pi_valida_hora_limite_abbc (OUTPUT aux_lghrexec, 
                                                 OUTPUT aux_hrlimite).
         
                 RUN pi_gera_log(INPUT "Aguardando arquivo ROC640 da CECRED - "
                                       + "Centralizacao ABBC... " +
                                       "- Horario limite: " +  aux_hrlimite).
                 RUN pi_gera_log(INPUT "Arquivo esperado: " +
                                      "/usr/coop/cecred/integra/ROC640N9.085").
                                       
                 /* WHILE 3 - Verificar arquivo ROC */
                 DO WHILE TRUE:
           
                    aux_nmarquiv = "/usr/coop/cecred/controles/ArqrocABBC.ok".

                    /* Se não encontrar arq de controle, procura pelo arq baixado. */
                    aux_nmarqui2 = "/usr/coop/cecred/integra/ROC640N9.085".
                    
                    IF   SEARCH(aux_nmarquiv) = ? AND
                         SEARCH(aux_nmarqui2) = ? THEN
                         DO:
                             RUN pi_valida_hora_limite_abbc (OUTPUT aux_lghrexec, 
                                                             OUTPUT aux_hrlimite).
                                      
                             IF   NOT aux_lghrexec   THEN 
                                  DO:
                                       RUN pi_gera_log
                                                  (INPUT "Horario limite esgotado. " +
                                                         "Continuando SEM arquivos de" +
                                                         " ROC640 da ABBC").
                                           
                                       RUN enviar_email(INPUT "ROC640").
                                      
                                       LEAVE.
                                  END.
                             ELSE
                                  PAUSE 20 NO-MESSAGE.
                         END.         
                    ELSE
                         DO:
                             RUN pi_gera_log (INPUT "Arquivo ROC640 ... OK").
                             LEAVE.
                         END.
                         
                 END. /* FIM do WHILE TRUE 3 */
                 


                 /*   ARQUIVO ROC650 ......... Centralizacao Tit VLB e SPB   */
                 
                 RUN pi_valida_hora_limite_abbc (OUTPUT aux_lghrexec, 
                                                 OUTPUT aux_hrlimite).
         
                 RUN pi_gera_log(INPUT "Aguardando arquivo ROC650 da CECRED - "
                                       + "Centralizacao ABBC... " +
                                       "- Horario limite: " +  aux_hrlimite).
                 RUN pi_gera_log(INPUT "Arquivo esperado: " +
                                      "/usr/coop/cecred/integra/R650DDMM.085").
                                       
                 /* WHILE 3 - Verificar arquivo ROC */
                 DO WHILE TRUE:
           
                    aux_nmarquiv = "/usr/coop/cecred/controles/Arqroc65ABBC.ok".

                    /* Se não encontrar arq de controle, procura pelo arq baixado. */
                    aux_nmarquiv = "/usr/coop/cecred/integra/R650" + 
                                   STRING(DAY(glb_dtmvtolt),"99") + 
                                   STRING(MONTH(glb_dtmvtolt),"99") + ".085".

                    IF   SEARCH(aux_nmarquiv) = ? AND
                         SEARCH(aux_nmarqui2) = ? THEN
                         DO:
                             RUN pi_valida_hora_limite_abbc (OUTPUT aux_lghrexec, 
                                                             OUTPUT aux_hrlimite).
                                      
                             IF   NOT aux_lghrexec   THEN 
                                  DO:
                                      RUN pi_gera_log
                                                  (INPUT "Horario limite esgotado. " +
                                                         "Continuando SEM arquivos de" +
                                                         " ROC650 da ABBC").
                                 
                                      RUN enviar_email(INPUT "ROC650").
                               
                                      LEAVE.
                                  END.
                             ELSE
                                  PAUSE 20 NO-MESSAGE.
                         END.         
                    ELSE
                         DO:
                             RUN pi_gera_log (INPUT "Arquivo ROC650 ... OK").
                             LEAVE.
                         END.
                         
                 END. /* FIM do WHILE TRUE 3 */

              END. /* Fim aux_execabbc = "SIM" */
      
      END.     /** FIM do IF glb_cdcooper = 3 **/



/***************************  PARA   SINGULARES  ******************************/


ELSE                  /* glb_cdcooper <> 3 */
     DO:
         /* Processamento ABBC */
         DO  WHILE TRUE:
         
             RUN pi_executa_abbc (OUTPUT aux_execabbc).
        
             IF   aux_execabbc = "NAO" THEN 
                  DO:
                      RUN pi_gera_log (INPUT "Cooperativa NAO Processa " +
                                         "arquivos da Compensacao ABBC.").
                      LEAVE.
                  END.

             RUN pi_valida_hora_limite_abbc (OUTPUT aux_lghrexec, 
                                             OUTPUT aux_hrlimite).
         
             RUN pi_gera_log(INPUT "Aguardando arquivos Compe SR ABBC... " +
                                   "Horario limite: " +  aux_hrlimite).

             /* WHILE 1 - Verificar arquivo Compensacao ABBC */
             DO  WHILE TRUE:

                 ASSIGN aux_nmarquiv = "/usr/coop/" + 
                                       TRIM(LC(crapcop.dsdircop)) +
                                       "/controles/ArqCompABBC.ok".
                 
                 IF   SEARCH(aux_nmarquiv) = ? THEN
                      DO:
                          RUN pi_valida_hora_limite_abbc 
                                        (OUTPUT aux_lghrexec, 
                                         OUTPUT aux_hrlimite).

                          IF   NOT aux_lghrexec   THEN 
                               DO:
                                   RUN pi_gera_log
                                       (INPUT "Horario limite esgotado. " +
                                              "Continuando SEM arquivos da" +
                                              " Compe SR ABBC").

                                   RUN enviar_email
                                       (INPUT "Compe SR - 085*2.zip").
                                   
                                   LEAVE.
                               END.
                          ELSE
                               PAUSE 20 NO-MESSAGE.
                      END.
                 ELSE
                      DO:
                          RUN pi_gera_log 
                              (INPUT "Arquivo Compe SR ABBC ... OK").
                          LEAVE.
                      END.
                                    
             END.  /* Fim do While True 1 */

             RUN pi_valida_hora_limite_abbc (OUTPUT aux_lghrexec, 
                                             OUTPUT aux_hrlimite).
         
             RUN pi_gera_log (INPUT "Aguardando arquivos Conciliacao ABBC... " +
                                    "Horario limite: " +  aux_hrlimite).
         
             /* WHILE 2 - Verificar arquivo Conciliacao ABBC */
             DO  WHILE TRUE:

                 ASSIGN aux_nmarquiv = "/usr/coop/" + 
                                       TRIM(LC(crapcop.dsdircop)) +
                                       "/controles/ArqConcABBC.ok".

                 
                 IF   SEARCH(aux_nmarquiv) = ? THEN
                      DO:
                          RUN pi_valida_hora_limite_abbc (OUTPUT aux_lghrexec, 
                                                 OUTPUT aux_hrlimite).

                          IF   NOT aux_lghrexec  THEN 
                               DO:
                                   RUN pi_gera_log
                                       (INPUT "Horario limite esgotado. " +
                                              "Continuando SEM arquivos de " +
                                             "Conciliacao da ABBC").

                                   RUN enviar_email
                                       (INPUT "Conciliacao - 085*1.zip").

                                   LEAVE.
                               END.
                          ELSE
                               PAUSE 20 NO-MESSAGE.
                      END.
                 ELSE
                      DO:
                          RUN pi_gera_log 
                              (INPUT "Arquivo Conciliacao ABBC ... OK ").
                          LEAVE.
                      END.   
                      
             END.  /* Fim do While True - CONCILIACAO */

             LEAVE.
         
         END. /* Fim do While True de processamento da ABBC */

     END.  /** FIM do ELSE DO **/

RUN fontes/fimprg.p.


/* .......................................................................... */

PROCEDURE pi_executa_abbc:
/* Verifica se a cooperativa processa ABBC */

    DEF OUTPUT PARAM ret_execabbc AS CHAR                             NO-UNDO.

    /* Verifica se a cooperativa processa ABBC */
     
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "EXECUTAABBC"  AND
                       craptab.tpregist = 0             
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab  THEN
         ASSIGN ret_execabbc = "NAO".
    ELSE
         ASSIGN ret_execabbc = craptab.dstextab.

END PROCEDURE.


PROCEDURE pi_valida_hora_limite_abbc:
/* Verifica horario limite para aguardar Arquivos ABBC */

   DEF OUTPUT PARAM ret_lghrexec AS LOG                              NO-UNDO.
   DEF OUTPUT PARAM ret_hrlimite AS CHAR                             NO-UNDO.

   DEF VAR          aux_horaexec AS INT                              NO-UNDO.

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                      craptab.nmsistem = "CRED"           AND
                      craptab.tptabela = "GENERI"         AND
                      craptab.cdempres = 0                AND
                      craptab.cdacesso = "HORLIMABBC"     AND
                      craptab.tpregist = 0
                      NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN                   
        ASSIGN aux_horaexec = 14700. /* 04:05h */
   ELSE
        ASSIGN aux_horaexec = INT(craptab.dstextab).

   IF   aux_horaexec >= TIME THEN
        ret_lghrexec = TRUE. /* superior a hora cadastrada */
   ELSE
        ret_lghrexec = FALSE.

   ret_hrlimite = STRING(aux_horaexec,"hh:mm:ss").

END PROCEDURE.


PROCEDURE pi_gera_log:

     DEF INPUT PARAM par_mensglog    AS CHAR                           NO-UNDO.

     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                       glb_cdprogra + "' --> '" + par_mensglog +
                       " >> " + "/usr/coop/" + TRIM(LC(crapcop.dsdircop)) +
                       "/log/proc_batch.log").

END PROCEDURE.

/* .......................................................................... */


PROCEDURE enviar_email:                           

    DEF INPUT PARAM aux_dscritic AS CHAR         NO-UNDO.

    DEF         VAR h-b1wgen0011 AS HANDLE       NO-UNDO.
    DEF         VAR aux_conteudo AS CHAR         NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0011.p 
        PERSISTENT SET h-b1wgen0011.

    IF  NOT VALID-HANDLE (h-b1wgen0011)  THEN
        DO:
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                              glb_cdprogra + "' --> '" + 
                              "Handle invalido para h-b1wgen0011." + 
                              " >> log/proc_batch.log").
            RETURN.          
        END.

    ASSIGN aux_conteudo = 
           "ARQUIVO DA ABBC\n\n" +
           "ATENCAO!!\n\n Voce esta recebendo este e-mail pois o programa " +
           glb_cdprogra + " acusou critica QUE NAO RECEBEU O ARQUIVO de " +
           STRING(aux_dscritic) + " da ABBC. \n\nCOOPERATIVA: " +
           STRING(crapcop.cdcooper) + " - " + crapcop.nmrescop + 
           ".\nData: " + STRING(glb_dtmvtolt,"99/99/9999") +
           "\nHora: " + STRING(TIME,"HH:MM:SS").

    RUN enviar_email_completo IN h-b1wgen0011
                (INPUT crapcop.cdcooper,
                 INPUT "crps568",
                 INPUT "CECRED<cecred@cecred.coop.br>",
                 INPUT "cpd@cecred.coop.br," +
                       "eduardo@cecred.coop.br," +
                       "mirtes@cecred.coop.br",
                 INPUT "Processo da Cooperativa " +
                       STRING(crapcop.cdcooper) + " - ABBC - " + 
                       "Nao Recebeu Arquivo: " + STRING(aux_dscritic),
                 INPUT "",
                 INPUT "",
                 INPUT aux_conteudo,
                 INPUT FALSE).

    DELETE PROCEDURE h-b1wgen0011.

END PROCEDURE.

/*............................................................................*/
