/* .........................................................................

   Programa: Fontes/crps002.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91.                        Ultima atualizacao: 09/06/2008

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001 (batch - atualizacao).
               Liberar diariamente os depositos bloqueados para o dia seguinte.

   Alteracoes: 22/04/1998 - Tratamento para milenio e troca para V8 (Margarete).
               
               28/08/2003 - Incluir numero da conta na critica quando valor do
                            saldo bloqueado for negativo (Junior). 
                            
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder      
               
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               19/10/2009 - Alteracao Codigo Historico (Kbase). 
                      
............................................................................ */

{ includes/var_batch.i }

DEF        VAR aux_vlsdbloq AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR aux_vlsdblpr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR aux_vlsdblfp AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.

DEF        VAR aux_inhistor AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_cdhistor AS INT     FORMAT "9999"                 NO-UNDO.
DEF        VAR aux_nrdconta AS INT     FORMAT "zzzz,zz9,9"           NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.

glb_cdprogra = "crps002".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

IF   glb_dtmvtolt = 02/01/1995 THEN
     DO:
         RUN fontes/fimprg.p.
         RETURN.
     END.

aux_flgfirst = TRUE.

FOR EACH crapdpb WHERE crapdpb.cdcooper = glb_cdcooper  AND
                       crapdpb.dtliblan = glb_dtmvtolt  AND
                       crapdpb.nrdconta > glb_nrctares  AND
                       crapdpb.inlibera = 1
                       USE-INDEX crapdpb3 NO-LOCK:

    IF   crapdpb.cdhistor <> aux_cdhistor   THEN
         DO:
             FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND
                                craphis.cdhistor = crapdpb.cdhistor
                                NO-LOCK NO-ERROR.
             
             IF   NOT AVAILABLE craphis   THEN
                  DO:
                      glb_cdcritic = 80.
                      RUN fontes/critic.p.
                      UNIX SILENT
                           VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '" +
                                  glb_dscritic +
                                  " >> log/proc_batch.log").
                      UNDO, RETURN.
                  END.

             ASSIGN aux_cdhistor = craphis.cdhistor
                    aux_inhistor = craphis.inhistor.
         END.

    IF   crapdpb.nrdconta <> aux_nrdconta   THEN
         DO:
             FIND craptrf WHERE craptrf.cdcooper = glb_cdcooper      AND
                                craptrf.nrdconta = crapdpb.nrdconta 
                                NO-LOCK NO-ERROR.

             IF   AVAILABLE craptrf THEN
                  IF   craptrf.tptransa = 1   AND   craptrf.insittrs = 2   THEN
                       NEXT.

             IF   aux_flgfirst   THEN
                  ASSIGN aux_nrdconta = crapdpb.nrdconta
                         aux_flgfirst = FALSE.
             ELSE
                  TRANS_1:

                  DO TRANSACTION:

                     DO WHILE TRUE:

                        FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper  AND
                                           crapsld.nrdconta = aux_nrdconta
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF   NOT AVAILABLE crapsld   THEN
                             IF   LOCKED crapsld   THEN
                                  DO:
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                             ELSE
                                  DO:
                                      glb_cdcritic = 10.
                                      RUN fontes/critic.p.
                                      UNIX SILENT
                                      VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                              " - " + glb_cdprogra + "' --> '" +
                                              glb_dscritic +
                                              " >> log/proc_batch.log").
                                      RETURN.
                                  END.

                        LEAVE.

                     END.  /*  Fim do DO WHILE TRUE  */

                     ASSIGN crapsld.vlsdbloq = crapsld.vlsdbloq - aux_vlsdbloq
                            crapsld.vlsdblpr = crapsld.vlsdblpr - aux_vlsdblpr
                            crapsld.vlsdblfp = crapsld.vlsdblfp - aux_vlsdblfp
                            crapsld.vlsddisp = crapsld.vlsddisp + aux_vlsdbloq
                                                                + aux_vlsdblpr
                                                                + aux_vlsdblfp

                            aux_vlsdbloq = 0
                            aux_vlsdblpr = 0
                            aux_vlsdblfp = 0.

                     IF   crapsld.vlsdbloq < 0   OR
                          crapsld.vlsdblpr < 0   OR
                          crapsld.vlsdblfp < 0   THEN
                          DO:
                              glb_cdcritic = 136.
                              RUN fontes/critic.p.
                              UNIX SILENT
                                   VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '" +
                                          glb_dscritic + " CONTA: " +
                                          STRING(aux_nrdconta,"zzzz,zz9,9") +
                                          " >> log/proc_batch.log").
                          END.

                     DO WHILE TRUE:

                        FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND
                                           crapres.cdprogra = glb_cdprogra
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF   NOT AVAILABLE crapres   THEN
                             IF   LOCKED crapres   THEN
                                  DO:
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                             ELSE
                                  DO:
                                      glb_cdcritic = 151.
                                      RUN fontes/critic.p.
                                      UNIX SILENT
                                      VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             glb_dscritic +
                                             " >> log/proc_batch.log").
                                      UNDO TRANS_1, RETURN.
                                  END.

                        LEAVE.

                     END.  /*  Fim do DO WHILE TRUE  */

                     ASSIGN crapres.nrdconta = crapsld.nrdconta
                            aux_nrdconta     = crapdpb.nrdconta.

                  END.  /* Fim da transacao */
         END.

    IF   aux_inhistor = 3   THEN
         aux_vlsdbloq = aux_vlsdbloq + crapdpb.vllanmto.
    ELSE
         IF   aux_inhistor = 4   THEN
              aux_vlsdblpr = aux_vlsdblpr + crapdpb.vllanmto.
         ELSE
              IF   aux_inhistor = 5   THEN
                   aux_vlsdblfp = aux_vlsdblfp + crapdpb.vllanmto.
              ELSE
                   DO:
                       glb_cdcritic = 83.
                       RUN fontes/critic.p.
                       UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '" +
                                          glb_dscritic +
                                          " >> log/proc_batch.log").
                       UNDO, RETURN.
                   END.

END.   /* Fim do FOR EACH */

IF   aux_nrdconta <> 0   THEN
     TRANS1:

     DO TRANSACTION:

        DO WHILE TRUE:

           FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper   AND
                              crapsld.nrdconta = aux_nrdconta
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE crapsld   THEN
                IF   LOCKED crapsld   THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         glb_cdcritic = 10.
                         RUN fontes/critic.p.
                         UNIX SILENT
                              VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                     " - " + glb_cdprogra + "' --> '" +
                                     glb_dscritic +
                                     " >> log/proc_batch.log").
                         RETURN.
                     END.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        ASSIGN crapsld.vlsdbloq = crapsld.vlsdbloq - aux_vlsdbloq
               crapsld.vlsdblpr = crapsld.vlsdblpr - aux_vlsdblpr
               crapsld.vlsdblfp = crapsld.vlsdblfp - aux_vlsdblfp
               crapsld.vlsddisp = crapsld.vlsddisp + aux_vlsdbloq
                                                   + aux_vlsdblpr
                                                   + aux_vlsdblfp

               aux_vlsdbloq = 0
               aux_vlsdblpr = 0
               aux_vlsdblfp = 0.

        IF   crapsld.vlsdbloq < 0   OR
             crapsld.vlsdblpr < 0   OR
             crapsld.vlsdblfp < 0   THEN
             DO:
                 glb_cdcritic = 136.
                 RUN fontes/critic.p.
                 UNIX SILENT
                      VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                             " - " + glb_cdprogra + "' --> '" +
                             glb_dscritic + " CONTA: " + 
                             STRING(aux_nrdconta,"zzzz,zz9,9") +
                             " >> log/proc_batch.log").
             END.

        DO WHILE TRUE:

           FIND crapres WHERE crapres.cdcooper = glb_cdcooper   AND
                              crapres.cdprogra = glb_cdprogra
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE crapres   THEN
                IF   LOCKED crapres   THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         glb_cdcritic = 151.
                         RUN fontes/critic.p.
                         UNIX SILENT
                              VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                     " - " + glb_cdprogra + "' --> '" +
                                     glb_dscritic +
                                     " >> log/proc_batch.log").
                         UNDO TRANS1, RETURN.
                     END.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        ASSIGN crapres.nrdconta = crapsld.nrdconta.

     END.  /* Fim da transacao */

glb_cdcritic = 0.

RUN fontes/fimprg.p.

/* .......................................................................... */

