/* .............................................................................

   Programa: Includes/lanrqea.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Agosto/2000.                    Ultima atualizacao: 18/05/2017
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela LANRQE.

   Alteracoes: 17/04/2001 - Permitir no max 500 bloquetos (Deborah).

               15/07/2003 - Substituido o Nro de conta fixo do Banco do Brasil,
                            pela variavel aux_lsconta3, setada no 
                            lanrqe.p (Julio).

               04/10/2004 - Alteracao da quantidade maxima de taloes para
                            formulario continuo (Julio).
                            
               03/10/2005 - Incluir o Continuo ITG (Ze).             
                
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.  
               
               14/02/2006 - Alterado para ler folhas ao inves de taloes para o
                            "Formulario Continuo" (Evandro).
               
               03/04/2007 - Corrigida a critica para contas BANCOOB (Evandro).

               24/04/2008 - Para tipo de requisicao 5, permitir 500 folhas para
                            pessoa JURIDICA e 20 para FISICA (Evandro).

               12/05/2008 - Controle nas alteracoes dos formularios continuos
                            (Gabriel).

               03/07/2008 - Nao permite mais de 400 folhas para o mesmo pedido
                            de formularios continuos, verificar todas as
                            requisicoes pendentes (Evandro).
               
               03/07/2009 - No pedido de formularios continuos, considerar
                            apenas requisicoes com cdcritic = 0 (Fernando).
                            
               15/10/2009 - Adaptacoes projeto IF CECRED (Guilherme).
                            
               01/12/2009 - Limitar a 200 chq avulso para PJ (Guilherme).
               
               01/03/2010 - Tratar formulario continuo(req 5) apenas para 
                            IF CECRED (Guilherme).
                            
               30/04/2010 - Bloquear a opcao para emissão de taloes TB.
                            (2-Folhas TB) (Guilherme).
       
               10/06/2010 - Coope tem que estar operando com ABBC para
                            podes solicitar taloes tipo 3 (Magui).
                            
               06/06/2011 - Gravado glb_cdoperad no crapreq.cdoperad
                            (Adriano).             
                            
               06/09/2011 - Incluido a chamada para a procedure alerta_fraude
                            (Adriano).
                            
               14/03/2013 - Colocado a chamada da procedure alerta_fraude no
                            inicio do programa e retirado tratamento
                            de contas BB "aux_lsconta3" (Adriano).             
                  
               14/03/2017 - Aumentar para 1500 folhas por requisição no formulario  
                            3, conforme solicitado no chamado 627236. (Kelvin)
                  
               18/05/2017 - Retirar glb_cddopcao do form f_lanrqe (Lucas Ranghetti #646559)
                  
               21/03/2018 - Substituida verificacao "cdtipcta = 8,9,10,11" pela consulta 
                            se o produto de folhas de cheque está liberado para o tipo 
                            de conta. PRJ366 (Lombardi).
............................................................................ */

DO WHILE TRUE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      SET tel_nrdctabb 
          tel_tprequis 
          WITH FRAME f_lanrqe.

      ASSIGN aux_nrdconta = tel_nrdctabb
             aux_tprequis = tel_tprequis
             glb_nrcalcul = tel_nrdctabb
             glb_cdcritic = 0.

      RUN fontes/digfun.p.

      IF NOT glb_stsnrcal THEN
         DO:
             ASSIGN glb_cdcritic = 8.
             NEXT-PROMPT tel_nrdctabb WITH FRAME f_lanrqe.
         END.
      ELSE
      DO:
         FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                            crapass.nrdconta = tel_nrdctabb
                            NO-LOCK NO-ERROR.

         IF NOT AVAILABLE crapass   THEN
            DO:
                ASSIGN glb_cdcritic = 9.
                NEXT-PROMPT tel_nrdctabb WITH FRAME f_lanrqe.
            END.
         
      END.
           
      IF glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             CLEAR FRAME f_lanrqe.
             ASSIGN tel_nrdctabb = aux_nrdconta
                    tel_tprequis = aux_tprequis.

             MESSAGE glb_dscritic.
             DISPLAY tel_nrdctabb 
                     tel_tprequis
                     WITH FRAME f_lanrqe.
             NEXT.

         END.


      IF NOT VALID-HANDLE(h-b1wgen0110) THEN
         RUN sistema/generico/procedures/b1wgen0110.p 
             PERSISTENT SET h-b1wgen0110.

      /*Monta a mensagem da operacao para envio no e-mail*/
      ASSIGN aux_dsoperac = "Tentativa de alterar "                     + 
                            "requisicoes especiais na conta "           + 
                            STRING(crapass.nrdconta,"zzzz,zzz,9")       +
                           (IF crapass.inpessoa = 1 THEN
                               STRING((STRING(crapass.nrcpfcgc,
                                       "99999999999")),"xxx.xxx.xxx-xx")
                            ELSE
                               STRING((STRING(crapass.nrcpfcgc,
                                       "99999999999999")),
                                       "xx.xxx.xxx/xxxx-xx")).
      
      /*Verifica se o associado esta no cadastro restritivo. Se estiver,
        sera enviado um e-mail informando a situacao*/
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
                                        INPUT 23, /*cdoperac*/
                                        INPUT aux_dsoperac,
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
                           "cadastro restritivo.".
                   PAUSE(2) NO-MESSAGE.
                   NEXT.
         
               END.
         
         END.

      LEAVE.

   END.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
      RETURN.   /* Volta pedir a opcao para o operador */

   DO TRANSACTION:

      ASSIGN glb_cdcritic = 0.

      DO WHILE TRUE:

         FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper AND
                            craptrq.tprequis = 9            AND
                            craptrq.nrdolote = 99 
                            NO-LOCK NO-ERROR NO-WAIT.

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
             CLEAR FRAME f_lanrqe.
             ASSIGN tel_nrdctabb = aux_nrdconta
                    tel_tprequis = aux_tprequis.

             MESSAGE glb_dscritic.
             DISPLAY tel_nrdctabb 
                     tel_tprequis
                     WITH FRAME f_lanrqe.
             NEXT.

         END.

      DO WHILE TRUE:

         FIND crapreq WHERE crapreq.cdcooper = glb_cdcooper   AND
                            crapreq.dtmvtolt = glb_dtmvtolt   AND
                            crapreq.tprequis = tel_tprequis   AND
                            crapreq.nrdolote = 99             AND
                            crapreq.nrdconta = tel_nrdctabb   AND
                            crapreq.nrinichq = 0
                            USE-INDEX crapreq1 NO-LOCK NO-ERROR NO-WAIT.

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
             CLEAR FRAME f_lanrqe.
             ASSIGN tel_nrdctabb = aux_nrdconta
                    tel_tprequis = aux_tprequis.

             MESSAGE glb_dscritic.
             DISPLAY tel_nrdctabb 
                     tel_tprequis
                     WITH FRAME f_lanrqe.
             NEXT.

         END.
           
      ASSIGN tel_qtinforq = craptrq.qtinforq
             tel_qtinfotl = craptrq.qtinfotl
             tel_qtcomprq = craptrq.qtcomprq
             tel_qtcomptl = craptrq.qtcomptl
             tel_qtreqtal = crapreq.qtreqtal
             tel_nrseqdig = crapreq.nrseqdig.

      DISPLAY tel_qtinforq 
              tel_qtcomprq 
              tel_qtinfotl 
              tel_qtcomptl 
              tel_qtreqtal 
              tel_nrseqdig
              WITH FRAME f_lanrqe.

      ASSIGN glb_cdcritic = 0
             aux_nrfintal = 0
             glb_dscritic = "".
     
      DO WHILE TRUE:

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
            SET tel_qtreqtal  
                WITH FRAME f_lanrqe.
            
            /* Nao solicitar taloes tipo 2 */
            IF tel_tprequis = 2  THEN
               ASSIGN glb_dscritic = "Tipo de requisicao 2-Folhas TB " + 
                                     "desabilitada.".
            ELSE
            IF tel_qtreqtal = 0                         OR
              (tel_tprequis = 2 AND tel_qtreqtal > 20)  OR
              (tel_tprequis     = 5  AND
               tel_qtreqtal     > 20 AND
               crapass.inpessoa = 1)                    OR
              (tel_tprequis     = 5   AND
               tel_qtreqtal     > 200 AND
               crapass.inpessoa = 2)                    OR
              (tel_tprequis = 8 AND tel_qtreqtal > 500) THEN
               ASSIGN glb_cdcritic = 26.
            ELSE
            IF (tel_tprequis = 2 OR tel_tprequis = 5) AND 
               (tel_qtreqtal MODULO 4) > 0            THEN
                ASSIGN glb_cdcritic = 859.
            ELSE
            IF tel_tprequis = 3   THEN
               DO:
                   IF crapass.inpessoa <> 2   THEN
                      ASSIGN glb_cdcritic = 331.
                   ELSE
                      DO:
                         
                         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                         
                         RUN STORED-PROCEDURE pc_permite_produto_tipo
                         aux_handproc = PROC-HANDLE NO-ERROR (INPUT 38,               /* Codigo do produto */
                                                              INPUT crapass.cdtipcta, /* Tipo de conta */
                                                              INPUT crapass.cdcooper, /* Cooperativa */
                                                              INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                             OUTPUT "",   /* Possui produto */
                                                             OUTPUT 0,   /* Codigo da crítica */
                                                             OUTPUT "").  /* Descriçao da crítica */
                         
                         CLOSE STORED-PROC pc_permite_produto_tipo
                               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                         
                         ASSIGN aux_possuipr = ""
                                aux_cdcritic = 0
                                aux_dscritic = ""
                                aux_possuipr = pc_permite_produto_tipo.pr_possuipr 
                                               WHEN pc_permite_produto_tipo.pr_possuipr <> ?
                                aux_cdcritic = pc_permite_produto_tipo.pr_cdcritic 
                                               WHEN pc_permite_produto_tipo.pr_cdcritic <> ?
                                aux_dscritic = pc_permite_produto_tipo.pr_dscritic
                                               WHEN pc_permite_produto_tipo.pr_dscritic <> ?.
                         
                         IF aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
                              DO:
                                 ASSIGN glb_cdcritic = aux_cdcritic
                                        glb_dscritic = aux_dscritic.
                              END.

                         IF aux_possuipr = "N" THEN 
                            ASSIGN glb_cdcritic = 17.
                      END.
                   /*** Magui fora em 14/06/2010 enquanto nao houver emissao
                        de cheques com a nossa IF
                   ELSE
                   DO:
                      IF  aux_flopabbc   THEN
                          DO:
                              IF  crapcop.cdbcoctl = 0  THEN
                                  glb_dscritic = 
                                      "Nao ha cadastro de IF CECRED " +
                                      "na tela CADCOP.".
                              ELSE
                              IF  crapass.cdbcochq <> crapcop.cdbcoctl  THEN
                                  glb_dscritic = 
                                      "Banco para emissao de cheques " +
                                      "da conta deve ser IF CECRED " + 
                                      STRING(crapcop.cdbcoctl,"999") + ".".
                          END.
                   END.
                   ****************/
                   
                   IF tel_qtreqtal MODULO 20 > 0   OR
                      tel_qtreqtal < 100           OR
                      tel_qtreqtal > 1500          THEN
                      ASSIGN glb_cdcritic = 26.
                   ELSE
                   IF crapass.cdsitcpf <> 1   THEN
                      ASSIGN glb_cdcritic = 737.
                   ELSE
                      DO:
                          /* CCF */
                          FIND LAST crapneg WHERE
                                    crapneg.cdcooper  = glb_cdcooper     AND
                                    crapneg.nrdconta  = crapass.nrdconta AND
                                    crapneg.cdhisest  = 1                AND
                                    crapneg.dtfimest  = ?                AND
                                    crapneg.dtiniest <= 
                                   (glb_dtmvtolt - 10)                   AND
                                   (crapneg.cdobserv  = 12               OR
                                    crapneg.cdobserv  = 13)
                                    NO-LOCK NO-ERROR.
                      
                          IF AVAILABLE crapneg   THEN
                             ASSIGN glb_cdcritic = 720.
                          ELSE
                             DO:
                                 /* Nao permite mais de 400 folhas para o
                                    mesmo pedido, verifica todas as
                                    requisicoes pendentes */
                                 ASSIGN aux_contador = 0.

                                 FOR EACH crabreq WHERE
                                          crabreq.cdcooper = 
                                                  crapass.cdcooper    AND
                                          crabreq.nrdconta = 
                                                  crapass.nrdconta    AND
                                          /* FORM.CONT */
                                          crabreq.tprequis = 3        AND
                                          /* Nao Atend */
                                          crabreq.insitreq <> 2       AND
                                          crabreq.cdcritic = 0        AND
                                          ROWID(crabreq)   <>
                                                  ROWID(crapreq)
                                          NO-LOCK:

                                     ASSIGN aux_contador = aux_contador +
                                                           crabreq.qtreqtal.
                                 END.
                             
                                 IF aux_contador + tel_qtreqtal > 1500   THEN
                                    DO:
                                        MESSAGE "Limite por pedido"
                                                "excedido.".
                                        NEXT.
                                    END.

                             END.

                      END.

               END.
               
            IF glb_cdcritic > 0   OR
               glb_dscritic <> "" THEN
               DO:
                   IF glb_dscritic = ""  THEN
                      RUN fontes/critic.p.
                   BELL.
                   CLEAR FRAME f_lanrqe.
                   ASSIGN tel_nrdctabb = aux_nrdconta
                          tel_tprequis = aux_tprequis
                          tel_qtreqtal = aux_qtreqtal
                          tel_nrseqdig = aux_nrseqdig
                          glb_cdcritic = 0.
                    
                   IF glb_cdcritic = 737   THEN
                      CASE crapass.cdsitcpf:
                              
                           WHEN 0 THEN MESSAGE glb_dscritic "s/consulta.".
                           WHEN 2 THEN MESSAGE glb_dscritic "pendente.".
                           WHEN 3 THEN MESSAGE glb_dscritic "cancelado.".
                           WHEN 4 THEN MESSAGE glb_dscritic "irregular.".
                           WHEN 5 THEN MESSAGE glb_dscritic "suspenso.".
                     
                      END CASE.

                   ELSE
                      MESSAGE glb_dscritic.

                   DISPLAY tel_nrdctabb 
                           tel_tprequis 
                           tel_qtreqtal 
                           tel_nrseqdig
                           WITH FRAME f_lanrqe.
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
                               craptrq.tprequis = 9            AND
                               craptrq.nrdolote = 99
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
            
            FIND crapreq WHERE crapreq.cdcooper = glb_cdcooper   AND
                               crapreq.dtmvtolt = glb_dtmvtolt   AND
                               crapreq.tprequis = tel_tprequis   AND
                               crapreq.nrdolote = 99             AND
                               crapreq.nrdconta = tel_nrdctabb   AND
                               crapreq.nrinichq = 0
                               USE-INDEX crapreq1 EXCLUSIVE-LOCK 
                               NO-ERROR NO-WAIT.

            IF NOT AVAILABLE crapreq   THEN
               IF LOCKED crapreq   THEN
                  DO:
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
               ELSE
                  DO:
                      ASSIGN glb_cdcritic = 066.
                             aux_flgerros = TRUE.
                      LEAVE.
                  END.

            LEAVE.

         END. /* DO WHILE TRUE */

         IF aux_flgerros   THEN
            DO:
                RUN fontes/critic.p.
                BELL.
                CLEAR FRAME f_lanrqe.

                ASSIGN tel_nrdctabb = aux_nrdconta
                       tel_tprequis = aux_tprequis
                       tel_qtreqtal = aux_qtreqtal
                       tel_nrseqdig = aux_nrseqdig.

                MESSAGE glb_dscritic.

                DISPLAY tel_nrdctabb 
                        tel_tprequis 
                        tel_qtreqtal 
                        tel_nrseqdig
                        WITH FRAME f_lanrqe.

                NEXT-PROMPT tel_nrdctabb WITH FRAME f_lanrqe.
                UNDO, NEXT.

            END.

          /* primeiro retirar a quantidade a ser alterada do controle de lote */
         ASSIGN craptrq.qtcomprq = craptrq.qtcomprq - 1
                craptrq.qtinforq = craptrq.qtinforq - 1
                craptrq.qtcomptl = craptrq.qtcomptl - crapreq.qtreqtal
                craptrq.qtinfotl = craptrq.qtinfotl - crapreq.qtreqtal.
         
         /* agora altera-se os registros com os novos dados */
         ASSIGN crapreq.qtreqtal = tel_qtreqtal
                crapreq.cdoperad = glb_cdoperad
                craptrq.qtcomprq = craptrq.qtcomprq + 1
                craptrq.qtinforq = craptrq.qtinforq + 1
                craptrq.qtcomptl = craptrq.qtcomptl + crapreq.qtreqtal
                craptrq.qtinfotl = craptrq.qtinfotl + crapreq.qtreqtal
                craptrq.qtcompen = 0
                craptrq.qtinfoen = 0 
                tel_qtinforq = craptrq.qtinforq
                tel_qtcomprq = craptrq.qtcomprq
                tel_qtinfotl = craptrq.qtinfotl
                tel_qtcomptl = craptrq.qtcomptl.

         LEAVE.

      END.

   END.   /*  Fim da transacao  */
   
   IF aux_flgerros   THEN
      UNDO, NEXT.
   
   ASSIGN tel_reganter[6] = tel_reganter[5]
          tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3]
          tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1]
          tel_reganter[1] =
              STRING(tel_nrdctabb,"zzzz,zzz,9") + "        "      +
              STRING(tel_tprequis,"9")          + "            "  +
              STRING(tel_qtreqtal,"zzz9")         + "     "       +
              STRING(tel_nrseqdig,"zz,zz9")
          
          tel_nrdctabb = 0
          tel_tprequis = 0
          tel_qtreqtal = 0
          tel_nrseqdig = 0.

   DISPLAY tel_qtinforq 
           tel_qtcomprq
           tel_qtinfotl 
           tel_qtcomptl
           tel_nrdctabb 
           tel_qtreqtal 
           tel_nrseqdig
           WITH FRAME f_lanrqe.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] 
           tel_reganter[2] 
           tel_reganter[3]
           tel_reganter[4] 
           tel_reganter[5] 
           tel_reganter[6]
           WITH FRAME f_regant.

END.

/* .......................................................................... */

