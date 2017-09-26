/* .............................................................................

   Programa: Fontes/proces.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Junho/2004.                     Ultima atualizacao: 15/08/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela PROCES.

   Alteracoes:  09/03/2005 - Se mesmo operador utilizando tela, nao criticar
                             uso(Mirtes)
                            
               14/03/2005 - Se tela em uso por outro operador, solicitar
                            liberacao coordenador(pedesenha.p)(Mirtes)

               05/07/2005 - Alimentado campo cdcooper da tabela craptab (Diego).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando 

               13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada
                            do programa fontes/pedesenha.p - SQLWorks - 
                            Fernando.
                            
               12/09/2006 - Excluida opcao "TAB" (Diego).             
               
               05/10/2006 - Corrigido para utilizar o F2 (Evandro).

               19/04/2007 - Alterado para gerar log "log/proces.log" (Elton).
               
               17/03/2010 - Move os arquivos do diretorio "compbb" para o 
                            diretorio "compbbnproc" e remove arquivos do 
                            diretorio "controles" quando o processo for 
                            solicitado (Elton).
                            
               16/09/2010 - Incluido parametro glb_cdcooper na chamada da 
                            procedure limpa_arquivos_proces (Elton).
                            
               21/12/2011 - Corrigido warnings (Tiago).             
               
               01/02/2017 - Ajustes para consultar dados da tela PROCES de todas as cooperativas
                            (Lucas Ranghetti #491624)
                           
               15/08/2017 - Exibir a quantidade de pendencias quando solicitar o processo
                            (Lucas Ranghetti #665982)
............................................................................. */

{ includes/var_online.i }

{ includes/var_proces.i "NEW" }

DEF  VAR aut_flgsenha AS LOGICAL                              NO-UNDO.
DEF  VAR aut_cdoperad AS CHAR                                 NO-UNDO.
DEF  VAR h-b1wgen9998 AS HANDLE                               NO-UNDO.  

ASSIGN cmd[1] = "1. Consultar as pendencias ref. " +
                 STRING(glb_dtmvtolt,"99/99/9999") + "."
       cmd[2] = "2. Solicitar o processo ref. " +
                 STRING(glb_dtmvtolt,"99/99/9999") + "."
       cmd[3] = "3. Cancelar o processo ja solicitado."
       cmd[4] = "4. Consultar as pendencias de todas cooperativas ref. " +
                 STRING(glb_dtmvtolt,"99/99/9999") + ".".

  
DISPLAY cmd WITH ROW 4 FRAME f-cmd.

COLOR DISPLAY MESSAGES cmd[choice] WITH FRAME f-cmd.


glb_cddopcao = "C".
glb_cdcritic = 0.

GETCHOICE:
REPEAT:

        RUN fontes/inicia.p.

        IF   RETRY    THEN
             DO:
                 DISPLAY cmd WITH FRAME f-cmd.
                 COLOR DISPLAY MESSAGES cmd[choice] WITH FRAME f-cmd.
             END.

        IF   lastchoice NE choice   THEN
             DO:
                 COLOR DISPLAY NORMAL cmd[lastchoice] WITH FRAME f-cmd.
                 lastchoice = choice.
                 COLOR DISPLAY MESSAGES cmd[choice] WITH FRAME f-cmd.
             END.

        READKEY.

        HIDE MESSAGE NO-PAUSE.
        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
             DO:
                 COLOR DISPLAY NORMAL cmd[choice] WITH FRAME f-cmd.
                 RUN fontes/novatela.p.
                 IF   glb_nmdatela <> "PROCES"   THEN
                      DO:
                          HIDE FRAME f-cmd NO-PAUSE.
                          RETURN.
                      END.
                 ELSE
                      DO:
                          COLOR DISPLAY MESSAGES cmd[choice] WITH FRAME f-cmd.
                          NEXT.
                      END.
             END.
        ELSE
             IF   (LASTKEY = KEYCODE("UP")      OR
                   LASTKEY = KEYCODE("LEFT"))   THEN
                  DO:
                      choice = choice - 1.
                      IF   choice = 0   THEN
                           choice = cmdcount.
                           NEXT GETCHOICE.
                  END.
             ELSE
                  IF   (LASTKEY = KEYCODE("DOWN")   OR
                        LASTKEY = KEYCODE("RIGHT")  OR
                        LASTKEY = KEYCODE(" "))   THEN
                       DO:
                           choice = choice + 1.
                           IF   choice GT cmdcount   THEN
                                choice = 1.
                           NEXT GETCHOICE.
                       END.
                  ELSE
                       IF   KEYFUNCTION(LASTKEY) = "HOME"   THEN
                            DO:
                                choice = 1.
                                NEXT GETCHOICE.
                            END.
                       ELSE
                            IF   INDEX(cmdlist,KEYLABEL(LASTKEY)) GT 0   THEN
                                 DO:
                                     choice = INDEX(cmdlist,KEYLABEL(LASTKEY)).
                                     qgo    = TRUE.
                                 END.

        IF   LASTKEY = KEYCODE("RETURN")   OR
             KEYFUNCTION(LASTKEY) = "GO"   OR qgo   THEN
             DO:
                 IF   lastchoice NE choice   THEN
                      DO:
                          COLOR DISPLAY NORMAL cmd[lastchoice] WITH FRAME f-cmd.
                          lastchoice = choice.
                          COLOR DISPLAY MESSAGES cmd[choice] WITH FRAME f-cmd.
                      END.

                 IF   aux_cddopcao <> glb_cddopcao   THEN
                      DO:
                          { includes/acesso.i }
                          aux_cddopcao = glb_cddopcao.
                      END.

                 /*---- Controle de 1 operador utilizando  tela --*/           
                            
                 FIND FIRST crapcop WHERE crapcop.cdcooper = glb_cdcooper
                                          NO-LOCK NO-ERROR.
                                          
                 IF  NOT AVAIL crapcop  THEN 
                     DO:
                        glb_cdcritic = 1.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic "--> SISTEMA CANCELADO!".
                        PAUSE MESSAGE
                       "Tecle <entra> para voltar `a tela de identificacao!".
                        BELL.
                        QUIT.
                     END.

                 IF   choice <> 1 AND 
                      choice <> 4 THEN
                      DO:                     
                          FIND craptab WHERE             
                               craptab.cdcooper = glb_cdcooper      AND
                               craptab.nmsistem = "CRED"            AND
                               craptab.tptabela = "GENERI"          AND
                               craptab.cdempres = crapcop.cdcooper  AND     
                               craptab.cdacesso = "PROCES"          AND
                               craptab.tpregist = 1 NO-LOCK NO-ERROR.
         
                          IF   NOT AVAIL craptab   THEN 
                               DO:
                                    CREATE craptab.
                                    ASSIGN craptab.nmsistem = "CRED"            
                                           craptab.tptabela = "GENERI"          
                                           craptab.cdempres = crapcop.cdcooper
                                           craptab.cdacesso = "PROCES"          
                                           craptab.tpregist = 1
                                           craptab.cdcooper = glb_cdcooper.
                                    RELEASE craptab.       
                               END.
                 
                          DO   WHILE TRUE:

                               FIND craptab WHERE             
                                    craptab.cdcooper = glb_cdcooper     AND
                                    craptab.nmsistem = "CRED"           AND
                                    craptab.tptabela = "GENERI"         AND
                                    craptab.cdempres = crapcop.cdcooper AND    
                                    craptab.cdacesso = "PROCES"         AND
                                    craptab.tpregist = 1 NO-LOCK NO-ERROR.
                                    
                              IF  NOT AVAIL craptab THEN 
                                  DO:
                                     MESSAGE 
                       "Controle nao cad.(Avise Inform) Processo Cancelado!".
                                     PAUSE MESSAGE
                       "Tecle <entra> para voltar `a tela de identificacao!".
                                     BELL.
                                     LEAVE.
                                  END.

                              IF  craptab.dstextab       <> " "   AND
                                  TRIM(craptab.dstextab) <> glb_cdoperad THEN
                                  DO:
                   
                                     MESSAGE
                                  "Processo sendo utilizado pelo Operador " +
                                  TRIM(SUBSTR(craptab.dstextab,1,20)).
                                     PAUSE MESSAGE
                                  "Peca liberacao Coordenador ou Aguarde....".
                    
                                     RUN fontes/pedesenha.p
                                                (INPUT glb_cdcooper,
                                                 INPUT 2, 
                                                 OUTPUT aut_flgsenha,
                                                 OUTPUT aut_cdoperad).
                                                                              
                                     IF   aut_flgsenha    THEN
                                          LEAVE.
                
                                     NEXT.
                    
                                  END.

                              LEAVE.
                          END.
            
                          FIND craptab WHERE 
                               craptab.cdcooper = glb_cdcooper       AND
                               craptab.nmsistem = "CRED"             AND 
                               craptab.tptabela = "GENERI"           AND
                               craptab.cdempres = crapcop.cdcooper   AND       
                               craptab.cdacesso = "PROCES"           AND
                               craptab.tpregist = 1  
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                               
                          IF   AVAIL craptab   THEN     
                               DO:
                                   ASSIGN craptab.dstextab = glb_cdoperad.
                                   RELEASE craptab.
                               END.
                      END.         
                 
                 IF  choice = 1 OR 
                     choice = 4 THEN
                      DO:  
                          IF  choice = 4 AND glb_cdcooper <> 3 THEN
                              MESSAGE "Opcao disponivel somente para CECRED.".
                          ELSE
                          RUN fontes/criticas_proces.p. /* Verifica processo */
                      END.
                 ELSE
                 IF  choice = 2 THEN DO:       
                     FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper
                                              NO-LOCK NO-ERROR.
                     IF   AVAILABLE crapdat   THEN
                          DO:
                              IF   crapdat.inproces <> 1   THEN
                                   DO:
                                       ASSIGN glb_cdcritic = 138.
                                       RUN fontes/critic.p.
                                       BELL.
                                       MESSAGE glb_dscritic
                                               "--> SISTEMA CANCELADO!".
                                       PAUSE MESSAGE
                       "Tecle <entra> para voltar `a tela de identificacao!".
                                       BELL.
                                       UNDO.
                                   END.
                          END.   
                     RUN fontes/criticas_proces.p. /* Verifica processo */
                            
                     UNIX SILENT 
                              VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")
                                    + " " +
                                    STRING(TIME,"HH:MM:SS") + "' --> '"  +
                                    " Operador " + glb_cdoperad +
                                    " solicitou'  'o processo, obtendo " +
                                    STRING(aux_nrsequen) + " criticas."  +
                                    " >> log/proces.log").
                                                     
                     IF  aux_nrsequen = 0 THEN
                         DO:
                            RUN fontes/proces1.p.
                            IF  glb_cdcritic <> 0 THEN
                                DO:
                                   RUN fontes/critic.p.
                                   BELL.
                                   MESSAGE
                                   glb_dscritic "--> SISTEMA CANCELADO!".
                                   PAUSE MESSAGE
                        "Tecle <entra> para voltar `a tela de identificacao!".
                                   BELL.
                                   QUIT.
                                END.
                            /** Move arquivos dos diretorios controles e compbb **/                        
                             
                            RUN sistema/generico/procedures/b1wgen9998.p 
                                       PERSISTEN SET h-b1wgen9998.
                                 
                            RUN limpa_arquivos_proces IN h-b1wgen9998 
                                                        (INPUT glb_cdcooper,
                                                         INPUT glb_cdprogra,
                                                         INPUT glb_dtmvtolt).
                            DELETE PROCEDURE h-b1wgen9998.

                            MESSAGE "Processo solicitado!!".
                         END.
                     ELSE /* aux_nrsequen <> 0 */
                         DO: 
                             DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                 ASSIGN aux_confirma = "N"
                                        glb_dscritic = "Existem " + STRING(aux_nrsequen) + 
                                                       " criticas pendentes. Confirma operacao?".

                                 MESSAGE COLOR NORMAL glb_dscritic
                                 UPDATE aux_confirma.
                                 ASSIGN glb_cdcritic = 0.

                                 LEAVE.

                             END. /* Fim do DO WHILE TRUE */

                             IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                                 aux_confirma <> "S" THEN
                                 DO:
                                     ASSIGN glb_cdcritic = 79.
                                     RUN fontes/critic.p.
                                     BELL.
                                     MESSAGE glb_dscritic "--> SISTEMA CANCELADO!".
                                     PAUSE MESSAGE "Tecle <entra> para voltar `a tela de identificacao!".
                                     BELL.
                                     UNDO.
                                 END.
                                
                             RUN fontes/proces1.p.

                             IF  glb_cdcritic <> 0 THEN
                                 DO:
                                     RUN fontes/critic.p.
                                     BELL.
                                     MESSAGE glb_dscritic "--> SISTEMA CANCELADO!".
                                     PAUSE MESSAGE "Tecle <entra> para voltar `a tela de identificacao!".
                                     BELL.
                                     QUIT.
                                 END.
                                 
                             /** Move arquivos dos diretorios controles e compbb **/ 
                             RUN sistema/generico/procedures/b1wgen9998.p
                                 PERSISTENT SET h-b1wgen9998.

                             RUN limpa_arquivos_proces IN h-b1wgen9998
                                                      (INPUT glb_cdcooper,
                                                       INPUT glb_cdprogra,
                                                       INPUT glb_dtmvtolt).
                             DELETE PROCEDURE h-b1wgen9998.
                                 
                             MESSAGE "Processo solicitado!!".
                         END. /* aux_nrsequen <> 0 */
                 END.
                 ELSE
                     DO:  
                          FIND FIRST crapdat WHERE 
                                     crapdat.cdcooper = glb_cdcooper 
                                     NO-LOCK NO-ERROR.
                                     
                          IF   AVAILABLE crapdat   THEN
                               DO:
                                   IF   crapdat.inproces <> 2   THEN
                                   DO:
                                       ASSIGN glb_cdcritic = 141.
                                       RUN fontes/critic.p.
                                       BELL.
                                       MESSAGE glb_dscritic
                                               "--> SISTEMA CANCELADO!".
                                       PAUSE MESSAGE
                       "Tecle <entra> para voltar `a tela de identificacao!".
                                       BELL.
                                       UNDO.
                                   END.
                               END.
                           
                          RUN fontes/proces2.p.  /* Cancela o processo */
                                                                  
                     UNIX SILENT 
                              VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")
                                    + " " +
                                    STRING(TIME,"HH:MM:SS") + "' --> '"  +
                                    " Operador " + glb_cdoperad +
                                    " cancelou '  'o processo. " +
                                    " >> log/proces.log").
                                                                          END.
                 IF   choice <> 1 AND
                      choice <> 4 THEN
                      DO:
                          FIND craptab WHERE 
                               craptab.cdcooper = glb_cdcooper       AND 
                               craptab.nmsistem = "CRED"             AND       
                               craptab.tptabela = "GENERI"           AND
                               craptab.cdempres = crapcop.cdcooper   AND       
                               craptab.cdacesso = "PROCES"           AND
                               craptab.tpregist = 1  
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                          IF   AVAIL craptab   THEN      
                               DO:
                                   ASSIGN craptab.dstextab = " ".
                                   RELEASE craptab.
                               END.
                      END.

                 IF   glb_cdcritic > 0    THEN
                      DO:
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          glb_cdcritic = 0.
                      END.

                 VIEW FRAME f-cmd.
                 qgo = FALSE.
                 NEXT GETCHOICE.
             END.
        ELSE
        IF   KEYFUNCTION(LASTKEY) = "HELP"   THEN
             APPLY "HELP".
        ELSE
             DO:
                 BELL.
                 MESSAGE "Escolha invalida, tente novamente!".
             END.

END.  /* GETCHOICE */
     
/* .......................................................................... */


