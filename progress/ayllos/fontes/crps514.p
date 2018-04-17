/* .............................................................................

   Programa: Fontes/crps514.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Agosto/2008                      Ultima atualizacao: 03/01/2017.

   Dados referentes ao programa:

   Frequencia: Diario
   Objetivo  : Aguarda Arquivos do BB e Bancoob e Aguarda finalizacao dos
               processos da Singulares.
               
               Ultimo programa da Cadeia da Compensacao ABBC.
               
   Alteracoes: 09/03/2009 - Acerto na verificacao quando ainda nao havia
                            solicitado o processo (Ze).

               13/04/2010 - Incluido tratamento diferencial quando CECRED e
                            Cooperativas para ABBC (Guilherme/Supero)
                            
               19/05/2010 - Acerto no FIND para HORLIMPROC de GENERI p/ USUARI
                            Acerto no IF hora limite HORLIMPROC(Guilherme).

               18/06/2010 - Correcao no aguardo dos arquivos de Controle no
                            processo da Cecred e Acertos nas Mensagens (Ze).
                            
               09/09/2015 - Retirada verificacao dos arquivos bancoob 
                            SD331188 (Odirlei-AMcom)

               03/01/2017 - Ajustado para apenas efetuar leitura das cooperativas
                            ativas quando for Cecred (Daniel)     

               04/04/2018 - Ajustado o momento da geração do arquivo "Processo_ABBC.Ok."
                            para somente gerar após finalizar a geração do arquivo "ArquivosBB.OK".
                            Necessário a alteração, para evitar a execução dos programas
                            da CENTRAL(CRPS568, resposável pela validação)antes da finalização
                            dos processos nas cooperativas (INC0012100 - Wagner/Sustentação).
............................................................................. */

{ includes/var_batch.i }

DEF STREAM str_1.  /*  Stream para da data da solicitacao do processo  */

DEF BUFFER crabcop FOR crapcop.

DEF VAR aux_nmarquiv AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqui2 AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqui3 AS CHAR                                         NO-UNDO.
DEF VAR aux_narqabbc AS CHAR                                         NO-UNDO.
DEF VAR aux_dtarquiv AS DATE                                         NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                         NO-UNDO.
DEF VAR aux_execabbc AS CHAR                                         NO-UNDO.
DEF VAR aux_lghrexec AS LOG                                          NO-UNDO.
DEF VAR aux_hrlimite AS CHAR                                         NO-UNDO.
DEF VAR aux_flgproce AS LOGICAL                                      NO-UNDO.


ASSIGN glb_cdprogra = "crps514"
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

/* Processo da CECRED verificar se as coop. filiadas  finalizaram o processo */     
IF   glb_cdcooper = 3 THEN 
     DO:
         RUN pi_gera_log (INPUT "Aguardando as cooperativas " + 
                                "finalizarem seus processos ... ").
        
         /* WHILE 1 - Verificar processos das cooperativas */
         DO WHILE TRUE:
           
            ASSIGN aux_flgproce = TRUE.

            FOR EACH crabcop WHERE crabcop.cdcooper <> 3 
			                   AND crabcop.flgativo = TRUE NO-LOCK: /* Somente cooperativas ativas */
                
                ASSIGN aux_nmarquiv = "/usr/coop/" + TRIM(LC(crabcop.dsdircop))
                                      + "/controles/Proc_Diario.Ok"
                       aux_nmarqui2 = "/usr/coop/" + TRIM(LC(crabcop.dsdircop))
                                      + "/proc/dataproc".
    
                IF   SEARCH(aux_nmarquiv) = ?  AND
                     aux_flgproce              THEN
                     aux_flgproce = FALSE.
    
                IF   SEARCH(aux_nmarqui2) <> ?  THEN 
                     DO:
                         INPUT STREAM str_1 FROM VALUE(aux_nmarqui2) NO-ECHO.
    
                         IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
             
                         ASSIGN aux_dtarquiv =
                                      DATE(INT(SUBSTR(aux_setlinha,04,02)),
                                           INT(SUBSTR(aux_setlinha,01,02)),
                                           INT(SUBSTR(aux_setlinha,07,04))).

                         IF   glb_dtmvtolt <> aux_dtarquiv THEN
                              ASSIGN aux_flgproce = FALSE.
                     END.
            END. /* Fim do For Each */
            
            IF   aux_flgproce THEN 
                 DO:
                     RUN pi_gera_log(INPUT "Processo das cooperativas " + 
                                           " finalizado.").
                     LEAVE.
                 END.
            ELSE
                 PAUSE 60 NO-MESSAGE.

         END.  /* Fim do While True */


         RUN pi_gera_log (INPUT "Aguardando arquivos de compensacao ... " +
                                "Sem horario limite configurado").

         /* WHILE 2 - Verificar Arquivos de Controle */

         DO WHILE TRUE:
       
            ASSIGN aux_nmarquiv = "/usr/coop/cecred/controles/ArquivosBB.OK"
                   /* Retirada verificacao bancoob SD331188
                   aux_nmarqui2 = "/usr/coop/cecred/controles/ArqBancoob.ok"*/
                   aux_nmarqui3 = "/usr/coop/cecred/controles/centralizacao.ok".

            IF   SEARCH(aux_nmarquiv) = ?  OR
                 SEARCH(aux_nmarqui3) = ?  THEN
                 PAUSE 60 NO-MESSAGE.
            ELSE
                 DO:
                     RUN pi_gera_log (INPUT "Arquivos de Compensacao ... OK").
                     LEAVE.
                 END.

         END. /* END do WHILE TRUE 2 */

     END.        /** END do IF glb_cdcooper = 3 **/



/***************************  PARA   SINGULARES  ******************************/


ELSE                  /* glb_cdcooper <> 3 */
     DO:

         /********************************************************************
                            BAIXA DOS ARQUIVOS BB e BANCOOB
          
          BANCOOB o script /usr/local/cecred/bin/DescompactaBancoob.sh aguarda
          ate as 09:00
          
          BB o script /usr/local/cecred/bin/ArquivosBB.sh aguarda ate as 10:00
          
          Para ambos esta fixo no script.

         ********************************************************************/

         
         RUN pi_valida_hora_limite (OUTPUT aux_lghrexec, OUTPUT aux_hrlimite).

         RUN pi_gera_log (INPUT "Aguardando arquivos de compensacao..." +
                                "Horario limite: " + aux_hrlimite).

         DO WHILE TRUE:

            RUN pi_valida_hora_limite (OUTPUT aux_lghrexec, 
                                       OUTPUT aux_hrlimite).
            
            IF   aux_lghrexec THEN 
                 DO:
                     RUN pi_gera_log(INPUT "Horario limite esgotado." +
                                     "Continuando SEM arquivos da Compensacao").
                     LEAVE.
                 END.
            
            ASSIGN aux_nmarquiv = "/usr/coop/" + TRIM(LC(crapcop.dsdircop)) +
                                  "/controles/ArquivosBB.OK".

                   /* Retirada verificacao bancoob SD331188
                   aux_nmarqui2 = "/usr/coop/" + TRIM(LC(crapcop.dsdircop)) +
                                  "/controles/ArqBancoob.ok".*/

            /* Os 2 arquivs devem existir */
            IF   SEARCH(aux_nmarquiv) = ? THEN
                 PAUSE 20 NO-MESSAGE.
            ELSE
                 DO:
                     RUN pi_gera_log(INPUT "Arquivos da Compensacao ... OK"). 
                     LEAVE.
                 END.

         END.  /** FIM do DO WHILE TRUE **/

         ASSIGN aux_narqabbc = "/usr/coop/" + TRIM(LC(crapcop.dsdircop)) +
                               "/controles/Processo_ABBC.Ok".

         /* Cria o arquivo de Controle ABBC */
         OUTPUT TO VALUE(aux_narqabbc).
         PUT UNFORM " ".
         OUTPUT CLOSE.
 
     END.      /** FIM do ELSE DO **/

RUN fontes/fimprg.p.


/* .......................................................................... */


PROCEDURE pi_valida_hora_limite:
/* Verifica se a cooperativa processa ABBC */

   DEF OUTPUT PARAM ret_lghrexec AS LOG                              NO-UNDO.
   DEF OUTPUT PARAM ret_hrlimite AS CHAR                             NO-UNDO.

   DEF VAR          aux_horaexec AS INT                              NO-UNDO.

   /* Verifica se a cooperativa processa ABBC */
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                      craptab.nmsistem = "CRED"           AND
                      craptab.tptabela = "USUARI"         AND
                      craptab.cdempres = 11               AND
                      craptab.cdacesso = "HORLIMPROC" 
                      NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN                   
        ASSIGN aux_horaexec = 26100. /* 07:15h */
   ELSE
        ASSIGN aux_horaexec = INT(craptab.dstextab).

   IF   TIME >= aux_horaexec THEN
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
