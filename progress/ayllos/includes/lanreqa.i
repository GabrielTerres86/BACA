/* .............................................................................

   Programa: Includes/lanreqa.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Fevereiro/92.                       Ultima atualizacao: 10/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela LANREQ.

   Alteracoes: 20/02/95 - Alterado para tratar inpessoa 3 (Deborah).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
             06/07/2005 - Alimentado campo cdcooper da tabela crapreq (Diego).
             
             11/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).

             01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
             
             06/09/2011 - Incluido a chamada para a procedure alerta_fraude
                          (Adriano).
                          
             13/03/2013 - Colocado a chamada da procedure alerta_fraude
                          para o inicio do programa (Adriano). 
                          
            10/12/2013 - Alteracao referente a integracao Progress X 
                         Dataserver Oracle 
                         Inclusao do VALIDATE ( André Euzébio / SUPERO)                           
                         
            08/03/2018 - Comentados Ifs que verificam se tipo de conta e igual a 1 ou 2 
                         e igual a 3 e 4 para retornar a critica 26. PRJ366 (Lombardi).
............................................................................. */

DO WHILE TRUE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      SET tel_nrdconta 
          tel_nrinichq 
          WITH FRAME f_lanreq.

      ASSIGN aux_cddopcao = glb_cddopcao
             aux_nrdconta = tel_nrdconta
             aux_nrinichq = tel_nrinichq
             aux_nrdolote = tel_nrdolote
             glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0.

      RUN fontes/digfun.p.
      
      IF NOT glb_stsnrcal THEN
         DO: 
             ASSIGN glb_cdcritic = 8.
             NEXT-PROMPT tel_nrdconta WITH FRAME f_lanreq.

         END.
      ELSE
         IF tel_nrinichq = 0   THEN
            ASSIGN aux_nrinital = 0.
         ELSE
            DO:
                ASSIGN glb_nrcalcul = tel_nrinichq.

                RUN fontes/digfun.p.

                IF NOT glb_stsnrcal   THEN
                   DO: 
                       ASSIGN glb_cdcritic = 8.
                       NEXT-PROMPT tel_nrinichq WITH FRAME f_lanreq.

                   END.
                ELSE
                   DO:
                       ASSIGN glb_nrcalcul = tel_nrinichq.

                       RUN fontes/numtal.p.

                       ASSIGN aux_nrinital = glb_nrtalchq.

                       IF glb_nrposchq <> 1   THEN
                          DO:
                              ASSIGN glb_cdcritic = 69.
                              NEXT-PROMPT tel_nrinichq
                                          WITH FRAME f_lanreq.
                          END.
                       ELSE
                          DO:
                              FIND crapass WHERE
                                   crapass.cdcooper = glb_cdcooper AND 
                                   crapass.nrdconta = tel_nrdconta
                                   NO-LOCK NO-ERROR NO-WAIT.

                              IF NOT AVAILABLE crapass   THEN
                                 DO:
                                     ASSIGN glb_cdcritic = 9.
                                     NEXT-PROMPT tel_nrdconta
                                                 WITH FRAME f_lanreq.

                                 END.

                          END.

                   END.

            END.

      IF glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             CLEAR FRAME f_lanreq.

             ASSIGN tel_nrdconta = aux_nrdconta
                    tel_nrinichq = aux_nrinichq
                    tel_nrdolote = aux_nrdolote.

             MESSAGE glb_dscritic.
             DISPLAY glb_cddopcao 
                     tel_nrdolote 
                     tel_nrdconta 
                     tel_nrinichq
                     WITH FRAME f_lanreq.

             NEXT.

         END.

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                         crapass.nrdconta = tel_nrdconta
                         NO-LOCK NO-ERROR.

      IF AVAIL crapass  THEN
         DO:
            IF NOT VALID-HANDLE(h-b1wgen0110) THEN   
               RUN sistema/generico/procedures/b1wgen0110.p 
                   PERSISTENT SET h-b1wgen0110.
            
            /*Monta a mensagem da operacao para envio no e-mail*/
            ASSIGN aux_dsoperac = "Tentativa de alterar a "             +
                                  "solicitacao de taloes de "           +
                                  "cheque na conta "                    +
                                  STRING(crapass.nrdconta,"zzzz,zzz,9") +
                                  " - CPF/CNPJ "                        +
                                 (IF crapass.inpessoa = 1 THEN
                                     STRING((STRING(crapass.nrcpfcgc,
                                            "99999999999")),
                                            "xxx.xxx.xxx-xx")
                                  ELSE
                                     STRING((STRING(crapass.nrcpfcgc,
                                             "99999999999999")),
                                             "xx.xxx.xxx/xxxx-xx")).


            /*Verifica se o associado esta no cadastro restritivo. Se 
              estiver, sera enviado um e-mail informando a situacao*/
            RUN alerta_fraude IN h-b1wgen0110(INPUT glb_cdcooper,
                                              INPUT glb_cdagenci,
                                              INPUT 0, /*nrdcaixa*/
                                              INPUT glb_cdoperad,
                                              INPUT glb_nmdatela,
                                              INPUT glb_dtmvtolt,
                                              INPUT 1, /*ayllos*/
                                              INPUT crapass.nrcpfcgc,
                                              INPUT crapass.nrdconta,
                                              INPUT 1, /*idseqttl*/
                                              INPUT TRUE, /*Bloqueia operacao*/
                                              INPUT 21, /*cdoperac*/
                                              INPUT aux_dsoperac ,
                                              OUTPUT TABLE tt-erro).

            IF VALID-HANDLE(h-b1wgen0110) THEN    
               DELETE PROCEDURE h-b1wgen0110.
            
            IF RETURN-VALUE <> "OK"  THEN
               DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                  IF AVAIL tt-erro  THEN
                     DO:
                         MESSAGE tt-erro.dscritic.
                         PAUSE(2) NO-MESSAGE.
                         NEXT.
            
                     END.
                  ELSE
                     DO:
                         MESSAGE "Nao foi possivel verificar o " +
                                 "cadastro restritivo." .
                         PAUSE(2) NO-MESSAGE.
                         NEXT.
                         
                     END.
            
               END.
            
         END.

      LEAVE.

   END.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
      LEAVE.   /* Volta pedir a opcao para o operador */

   DO TRANSACTION:

      ASSIGN glb_cdcritic = 0.
      
      DO WHILE TRUE:

         FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper  AND
                            craptrq.tprequis = 1             AND
                            craptrq.nrdolote = tel_nrdolote
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF NOT AVAILABLE craptrq   THEN
            IF LOCKED craptrq   THEN
               DO:
                   PAUSE 1 NO-MESSAGE.
                   NEXT.
               END.
            ELSE
               DO: 
                   ASSIGN glb_cdcritic = 63.
                   LEAVE.

               END.

         LEAVE.

      END.

      IF glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             CLEAR FRAME f_lanreq.
             ASSIGN tel_nrdconta = aux_nrdconta
                    tel_nrinichq = aux_nrinichq
                    tel_nrdolote = aux_nrdolote.

             MESSAGE glb_dscritic.
             DISPLAY glb_cddopcao 
                     tel_nrdolote 
                     tel_nrdconta 
                     tel_nrinichq
                     WITH FRAME f_lanreq.

             NEXT.

         END.

      DO WHILE TRUE:

         FIND crapreq WHERE crapreq.cdcooper = glb_cdcooper   AND
                            crapreq.dtmvtolt = glb_dtmvtolt   AND
                            crapreq.tprequis = 1              AND
                            crapreq.nrdolote = tel_nrdolote   AND
                            crapreq.nrdconta = tel_nrdconta   AND
                            crapreq.nrinichq = tel_nrinichq
                            USE-INDEX crapreq1 
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF NOT AVAILABLE crapreq   THEN
            IF LOCKED crapreq   THEN
               DO:
                   PAUSE 1 NO-MESSAGE.
                   NEXT.
               END.
            ELSE
               DO:
                   ASSIGN glb_cdcritic = 066.
                   LEAVE.

               END.
         LEAVE.

      END.

      IF glb_cdcritic = 0   THEN
         IF crapreq.insitreq <> 1 THEN
            ASSIGN glb_cdcritic = 113.

      IF glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             CLEAR FRAME f_lanreq.
             ASSIGN tel_nrdconta = aux_nrdconta
                    tel_nrinichq = aux_nrinichq
                    tel_nrdolote = aux_nrdolote.

             MESSAGE glb_dscritic.
             DISPLAY glb_cddopcao 
                     tel_nrdolote 
                     tel_nrdconta 
                     tel_nrinichq
                     WITH FRAME f_lanreq.

             NEXT.

         END.

      ASSIGN tel_qtinforq = craptrq.qtinforq
             tel_qtinfotl = craptrq.qtinfotl
             tel_qtinfoen = craptrq.qtinfoen
             tel_qtcomprq = craptrq.qtcomprq
             tel_qtcomptl = craptrq.qtcomptl
             tel_qtcompen = craptrq.qtcompen
             tel_qtdiferq = tel_qtcomprq - tel_qtinforq
             tel_qtdifetl = tel_qtcomptl - tel_qtinfotl
             tel_qtdifeen = tel_qtcompen - tel_qtinfoen
             tel_qtreqtal = crapreq.qtreqtal
             tel_nrfinchq = crapreq.nrfinchq
             tel_nrseqdig = crapreq.nrseqdig.

      DISPLAY tel_qtinforq tel_qtcomprq tel_qtdiferq
              tel_qtinfotl tel_qtcomptl tel_qtdifetl
              tel_qtinfoen tel_qtcompen tel_qtdifeen
              tel_qtreqtal tel_nrfinchq tel_nrseqdig
              WITH FRAME f_lanreq.

      ASSIGN glb_cdcritic = 0
             aux_nrfintal = 0.

      IF crapreq.nrfinchq > 0 THEN
         DO:
             ASSIGN glb_nrcalcul = crapreq.nrfinchq
                    aux_nrfintal = glb_nrtalchq.

             DO aux_nrcheque = tel_nrinichq TO tel_nrfinchq BY 1:

                DO WHILE TRUE:

                   ASSIGN aux_flgerros = FALSE.

                   FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper   AND
                                      crapfdc.nrdconta = tel_nrdconta   AND
                                      crapfdc.nrcheque = INT(SUBSTR(STRING(                                                                 aux_nrcheque,
                                                             "9999999"),1,6))
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF NOT AVAILABLE crapfdc   THEN
                      IF LOCKED crapfdc   THEN
                         DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                         END.
                      ELSE
                         DO:
                             ASSIGN glb_cdcritic = 108.
                             LEAVE.

                         END.

                   LEAVE.

                END.

                IF glb_cdcritic = 0   THEN
                   IF crapfdc.dtretchq = ? THEN
                      ASSIGN glb_cdcritic = 109.

                IF glb_cdcritic > 0 THEN
                   DO:
                       RUN fontes/critic.p.
                       BELL.
                       CLEAR FRAME f_lanreq.
                       ASSIGN tel_nrdconta = aux_nrdconta
                              tel_nrinichq = aux_nrinichq
                              tel_nrdolote = aux_nrdolote.

                       MESSAGE glb_dscritic.

                       DISPLAY glb_cddopcao 
                               tel_nrdolote
                               tel_nrdconta 
                               tel_nrinichq
                               WITH FRAME f_lanreq.

                       LEAVE.

                   END.

                ASSIGN crapfdc.dtretchq = ?.

             END.  /* Fim do DO ... TO ... */

             IF glb_cdcritic > 0   THEN
                UNDO, NEXT.

         END.

      DELETE crapreq.

      ASSIGN craptrq.qtcomprq = craptrq.qtcomprq - 1
             craptrq.qtcomptl = craptrq.qtcomptl - tel_qtreqtal
             craptrq.qtcompen = craptrq.qtcompen - (IF aux_nrinital = 0  AND
                                                       aux_nrfintal = 0
                                                       THEN 0
                                                       ELSE (aux_nrfintal + 1) -
                                                             aux_nrinital)

             tel_qtcomprq = craptrq.qtcomprq
             tel_qtcomptl = craptrq.qtcomptl
             tel_qtcompen = craptrq.qtcompen.

      DO WHILE TRUE:

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            SET tel_nrdconta 
                tel_qtreqtal 
                tel_nrinichq 
                tel_nrfinchq
                WITH FRAME f_lanreq.

            ASSIGN aux_nrdconta = tel_nrdconta
                   aux_nrinichq = tel_nrinichq
                   aux_nrfinchq = tel_nrfinchq
                   aux_qtreqtal = tel_qtreqtal
                   aux_nrseqdig = tel_nrseqdig
                   aux_nrdolote = tel_nrdolote
                   glb_nrcalcul = tel_nrdconta
                   glb_cdcritic = 0.

            RUN fontes/digfun.p.

            IF NOT glb_stsnrcal THEN
               DO:
                   ASSIGN glb_cdcritic = 008.
                   NEXT-PROMPT tel_nrdconta WITH FRAME f_lanreq.

               END.
            ELSE
               DO: 
                   FIND FIRST crapass WHERE crapass.nrdconta = tel_nrdconta
                                            NO-LOCK NO-ERROR NO-WAIT.

                   IF NOT AVAILABLE crapass   THEN
                      DO: 
                          ASSIGN glb_cdcritic = 009.
                          NEXT-PROMPT tel_nrdconta WITH FRAME f_lanreq.

                      END.
                   ELSE
                      DO:
                          /*
                          IF  crapass.inpessoa = 1   AND
                             (crapass.cdtipcta = 1   OR
                              crapass.cdtipcta = 2)  AND
                              tel_qtreqtal > 2       THEN
                              DO:
                                  ASSIGN glb_cdcritic = 26.
                                  NEXT-PROMPT tel_qtreqtal
                                              WITH FRAME f_lanreq.
                              END.
                          ELSE
                          IF  crapass.inpessoa = 1  AND
                             (crapass.cdtipcta = 3  OR
                              crapass.cdtipcta = 4) AND
                              tel_qtreqtal > 4      THEN
                              DO:
                                  ASSIGN glb_cdcritic = 26.
                                  NEXT-PROMPT tel_qtreqtal
                                              WITH FRAME f_lanreq.
                              END.
                          ELSE         
                          IF   (crapass.inpessoa = 2   OR
                                crapass.inpessoa = 3)  AND
                               tel_qtreqtal > 20   THEN
                               DO:
                                   glb_cdcritic = 26.
                                   NEXT-PROMPT tel_qtreqtal
                                               WITH FRAME f_lanreq.
                               END.
                          ELSE         */
                          IF (tel_nrinichq  = 0   AND
                              tel_nrfinchq <> 0)  OR
                             (tel_nrinichq <> 0   AND
                              tel_nrfinchq  = 0)  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 129.
                                  NEXT-PROMPT tel_nrinichq
                                              WITH FRAME f_lanreq.
                              END.

                          IF tel_nrinichq = 0   AND
                             tel_nrfinchq = 0   THEN
                             DO:
                                 ASSIGN aux_nrinital = 0
                                        aux_nrfintal = 0.

                                 IF tel_qtreqtal = 0   THEN
                                    DO:
                                        ASSIGN glb_cdcritic = 26.
                                        NEXT-PROMPT tel_qtreqtal
                                                    WITH FRAME f_lanreq.
                                    END.
                             END.

                          IF glb_cdcritic = 0 AND tel_nrfinchq > 0 THEN
                             DO:
                                 ASSIGN glb_nrcalcul = tel_nrfinchq.

                                 RUN fontes/digfun.p.

                                 IF NOT glb_stsnrcal THEN
                                    DO:
                                        ASSIGN glb_cdcritic = 008.
                                        NEXT-PROMPT tel_nrfinchq
                                                    WITH FRAME f_lanreq.
                                     END.
                                  ELSE
                                     DO:
                                         ASSIGN glb_nrcalcul = tel_nrfinchq.

                                         RUN fontes/numtal.p.

                                         ASSIGN aux_nrfintal = glb_nrtalchq.

                                         IF glb_nrposchq <> 20 THEN
                                            DO:
                                                ASSIGN glb_cdcritic = 070.
                                                NEXT-PROMPT tel_nrfinchq
                                                           WITH FRAME f_lanreq.
                                            END.

                                     END.
                             END.

                          IF glb_cdcritic = 0 AND tel_nrinichq > 0 THEN
                             DO:
                                 glb_nrcalcul = tel_nrinichq.
                                 RUN fontes/digfun.p.
                                 IF   NOT glb_stsnrcal THEN
                                      DO:
                                          glb_cdcritic = 008.
                                          NEXT-PROMPT tel_nrinichq
                                                      WITH FRAME f_lanreq.
                                      END.
                                 ELSE
                                      DO:
                                          glb_nrcalcul = tel_nrinichq.
                                          RUN fontes/numtal.p.
                                          aux_nrinital = glb_nrtalchq.
                                          IF   glb_nrposchq <> 1 THEN
                                               DO:
                                                   glb_cdcritic = 069.
                                                 NEXT-PROMPT tel_nrinichq
                                                      WITH FRAME f_lanreq.

                                               END.

                                      END.

                             END.

                          IF glb_cdcritic = 0 THEN
                             DO:
                                 FIND crapreq WHERE
                                      crapreq.cdcooper = glb_cdcooper AND
                                      crapreq.dtmvtolt = glb_dtmvtolt AND
                                      crapreq.tprequis = 1            AND
                                      crapreq.nrdconta = tel_nrdconta AND
                                      crapreq.nrinichq = tel_nrinichq
                                      USE-INDEX crapreq2 NO-LOCK NO-ERROR.

                                 IF AVAILABLE crapreq THEN
                                    IF crapreq.insitreq = 6   THEN
                                       DO:
                                           ASSIGN glb_cdcritic = 350.
                                           NEXT-PROMPT tel_nrdconta
                                                  WITH FRAME f_lanreq.
                                       END.
                                    ELSE
                                       DO:
                                           ASSIGN glb_cdcritic = 068.
                                           NEXT-PROMPT tel_nrdconta
                                                  WITH FRAME f_lanreq.
                                       END.
                                 ELSE
                                    IF aux_nrfintal < aux_nrinital THEN
                                       DO:
                                           ASSIGN glb_cdcritic = 129.
                                           NEXT-PROMPT tel_nrinichq
                                                   WITH FRAME f_lanreq.

                                       END.

                             END.

                      END.   

               END.

               IF glb_cdcritic > 0 THEN
                  DO:
                      RUN fontes/critic.p.
                      BELL.
                      CLEAR FRAME f_lanreq.
                      ASSIGN tel_nrdconta = aux_nrdconta
                             tel_nrinichq = aux_nrinichq
                             tel_nrfinchq = aux_nrfinchq
                             tel_qtreqtal = aux_qtreqtal
                             tel_nrseqdig = aux_nrseqdig
                             tel_nrdolote = aux_nrdolote.

                      MESSAGE glb_dscritic.

                      DISPLAY glb_cddopcao 
                              tel_nrdolote
                              tel_nrdconta 
                              tel_qtreqtal
                              tel_nrinichq 
                              tel_nrfinchq 
                              tel_nrseqdig
                              WITH FRAME f_lanreq.

                      NEXT.

                  END.

               ASSIGN aux_flgerros = FALSE.

             LEAVE.

         END.

         IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
            DO:
               ASSIGN aux_flgerros = TRUE.
               UNDO, LEAVE.   /* Volta pedir a opcao para o operador */

            END.

         DO WHILE TRUE:

            ASSIGN aux_flgerros = FALSE.

            FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper AND
                               craptrq.tprequis = 1            AND
                               craptrq.nrdolote = tel_nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF NOT AVAILABLE craptrq   THEN
               IF LOCKED craptrq  THEN
                  DO:
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
               ELSE
                  DO:
                      ASSIGN glb_cdcritic = 063
                             aux_flgerros = TRUE.
                      LEAVE.
                  END.

            LEAVE.

         END.  /* Fim do DO WHILE */

         IF aux_flgerros   THEN
            DO:
                RUN fontes/critic.p.
                BELL.
                CLEAR FRAME f_lanreq.

                ASSIGN tel_nrdconta = aux_nrdconta
                       tel_nrinichq = aux_nrinichq
                       tel_nrfinchq = aux_nrfinchq
                       tel_qtreqtal = aux_qtreqtal
                       tel_nrseqdig = aux_nrseqdig
                       tel_nrdolote = aux_nrdolote.

                MESSAGE glb_dscritic.

                DISPLAY glb_cddopcao 
                        tel_nrdolote 
                        tel_nrdconta 
                        tel_qtreqtal
                        tel_nrinichq 
                        tel_nrfinchq 
                        tel_nrseqdig
                        WITH FRAME f_lanreq.

                NEXT-PROMPT tel_nrdconta WITH FRAME f_lanreq.
                UNDO, NEXT.

            END.

         ASSIGN tel_nrseqdig = craptrq.nrseqdig + 1.

         IF tel_nrinichq > 0 AND tel_nrfinchq > 0 THEN
            DO:
                DO aux_nrcheque = tel_nrinichq TO tel_nrfinchq BY 1:

                   DO WHILE TRUE:

                      ASSIGN aux_flgerros = FALSE.

                      FIND crapfdc WHERE 
                           crapfdc.cdcooper = glb_cdcooper   AND
                           crapfdc.nrdconta = tel_nrdconta   AND
                           crapfdc.nrcheque = INT(SUBSTR(STRING(aux_nrcheque,
                                                             "9999999"),1,6))
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crapfdc   THEN
                         IF LOCKED crapfdc   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                         ELSE
                            DO:
                                ASSIGN glb_cdcritic = 108
                                       aux_flgerros = TRUE.
                                LEAVE.

                            END.

                      LEAVE.

                   END.        /* Fim do DO WHILE */

                   IF NOT aux_flgerros   THEN
                      IF crapfdc.dtretchq <> ? THEN
                         ASSIGN glb_cdcritic = 112
                                aux_flgerros = TRUE.

                   IF glb_cdcritic > 0 THEN
                      DO:
                          RUN fontes/critic.p.
                          BELL.
                          CLEAR FRAME f_lanreq.
                          ASSIGN tel_nrdconta = aux_nrdconta
                                 tel_nrinichq = aux_nrinichq
                                 tel_nrfinchq = aux_nrfinchq
                                 tel_qtreqtal = aux_qtreqtal
                                 tel_nrseqdig = aux_nrseqdig
                                 tel_nrdolote = aux_nrdolote.

                          MESSAGE glb_dscritic.

                          DISPLAY glb_cddopcao
                                  tel_nrdolote 
                                  tel_nrdconta
                                  tel_qtreqtal 
                                  tel_nrinichq 
                                  tel_nrfinchq
                                  tel_nrseqdig
                                  WITH FRAME f_lanreq.

                          NEXT-PROMPT tel_nrinichq WITH FRAME f_lanreq.
                          UNDO, LEAVE.

                      END.

                   ASSIGN crapfdc.dtretchq = glb_dtmvtolt.

                END.  /* Fim do DO ... TO ... */

            END.

         IF aux_flgerros THEN
            UNDO, NEXT.

         CREATE crapreq.

         ASSIGN crapreq.nrdconta = tel_nrdconta
                crapreq.nrdolote = tel_nrdolote
                crapreq.cdagenci = crapass.cdagenci
                crapreq.nrinichq = tel_nrinichq
                crapreq.insitreq = 1
                crapreq.nrfinchq = tel_nrfinchq
                crapreq.qtreqtal = tel_qtreqtal
                crapreq.nrseqdig = tel_nrseqdig
                crapreq.dtmvtolt = glb_dtmvtolt
                crapreq.cdcooper = glb_cdcooper
                crapreq.cdoperad = glb_cdoperad
                crapreq.dtpedido = glb_dtmvtolt

                craptrq.qtcomprq = craptrq.qtcomprq + 1
                craptrq.qtcomptl = craptrq.qtcomptl + tel_qtreqtal
                craptrq.qtcompen = craptrq.qtcompen + (IF aux_nrinital = 0  AND
                                                          aux_nrfintal = 0
                                                       THEN 0
                                                       ELSE (aux_nrfintal + 1) -
                                                             aux_nrinital)
                craptrq.nrseqdig = tel_nrseqdig

                tel_qtinforq = craptrq.qtinforq
                tel_qtcomprq = craptrq.qtcomprq
                tel_qtinfotl = craptrq.qtinfotl
                tel_qtcomptl = craptrq.qtcomptl
                tel_qtcompen = craptrq.qtcompen

                tel_qtdiferq = tel_qtcomprq - tel_qtinforq
                tel_qtdifetl = tel_qtcomptl - tel_qtinfotl
                tel_qtdifeen = tel_qtcompen - tel_qtinfoen.
         VALIDATE crapreq. 
         LEAVE.
            
      END.

   END.   /*  Fim da transacao  */

   
   IF aux_flgerros   THEN
      UNDO, NEXT.

   IF tel_qtdiferq = 0  AND  tel_qtdifetl = 0   AND  tel_qtdifeen = 0   THEN
      DO:
          ASSIGN glb_nmdatela = "LOTREQ".
          HIDE FRAME f_lanreq.
          HIDE FRAME f_regant.
          HIDE FRAME f_lanctos.
          HIDE FRAME f_moldura.
          RETURN.

      END.
   
   ASSIGN tel_reganter[6] = tel_reganter[5]
          tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3]
          tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1]
          tel_reganter[1] = STRING(tel_nrdconta,"zzzz,zzz,9") + "        "  +
                            STRING(tel_qtreqtal,"z9")         + "       "   +
                            STRING(tel_nrinichq,"zzz,zzz,9")  + "  "        +
                            STRING(tel_nrfinchq,"zzz,zzz,9")  + "   "       +
                            STRING(tel_nrseqdig,"zz,zz9").

   ASSIGN tel_nrdconta = 0
          tel_qtreqtal = 0
          tel_nrinichq = 0
          tel_nrfinchq = 0
          tel_nrseqdig = tel_nrseqdig + 1.

   DISPLAY tel_nrdolote tel_qtinforq tel_qtcomprq
           tel_qtdiferq tel_qtinfotl tel_qtcomptl
           tel_qtdifetl tel_qtinfoen tel_qtcompen
           tel_qtdifeen tel_nrdconta tel_qtreqtal
           tel_nrinichq tel_nrfinchq tel_nrseqdig
           WITH FRAME f_lanreq.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3]
           tel_reganter[4] tel_reganter[5] tel_reganter[6]
           WITH FRAME f_regant.

END.
/* .......................................................................... */


