/* .............................................................................

   Programa: Fontes/lanempa.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 23/09/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela lanemp.

   Alteracoes: 21/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               12/08/94 - Alterado para atualizar o inliquid na alteracao do
                          valor (Edson).

               06/03/95 - Alterado para atualizar craplem, atualizando txjurepr
                          dtpagemp (Odair).

               11/04/95 - Alterado para nao permitir a alteracao do codigo de
                          historico e o numero do contrato (Edson).

               11/06/96 - Alterado para alimentar o valor da prestacao no
                          craplem quando houver pagamento (Edson).

               29/01/97 - Alterar a ordem dos campos Documento Contrato (Odair)

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).

             02/07/2001 - Tratamento do prejuizo (Margarete). 

             24/01/2002 - Nao permitir alterar lote 10001 (Margarete).

             14/05/2002 - Qdo prejuizo criticas de valores lancados (Margarete)
             
             30/01/2006 - Unificacao dos bancos - SQLWorks - Andre

             13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                          (Sidnei - Precise)
                          
             31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

             06/07/2009 - Nao permitir alteracao de lancamentos para empresti- 
                          mos com emissao de boletos (Fernando).
                          
             23/11/2009 - Alteracao Codigo Historico (Kbase).             
             
             29/12/2009 - Bloquear Hist. 382, 383, 390 e 391 quando emprestimo
                          nao estiver em prejuizo (David).
                          
             17/05/2010 - Desativar Rating quando liquidado o emprestimo
                          (Gabriel).             

             14/09/2011 - Tratamento historico 277. Numero do documento deve 
                          ser igual ao numero do contrato de emprestimo (Irlan)
                          
             01/03/2012 - Adicionado criticas para novo tipo de contrato e
                          novo historico da b1wgen0134.p (Tiago).
                          
             03/11/2014 - Incluso tratamento para Transferencia Prejuizo 
                          novos contratos (Daniel/Oscar).
            
             26/01/2015 - Alterado o formato do campo nrctremp para 8 
                          caracters (Kelvin - 233714)

             16/03/2015 - Alterado o formato do campo nrdocmto para 10
                          posicoes. (Jaison/Gielow - SD: 263692)
                          
             18/03/2015 - (Chamado 260201) - Inclusao de um log para lancamentos 
                          manuais na craplem (Tiago Castro - RKAM).
               
             16/08/2016 - Controlar o preenchimento da data de pagamento do prejuízo,
                          no momento da liquidaçao do mesmo. (Renato Darosci - M176)
                          
             23/09/2016 - Inclusao da verificacao de contrato de acordo (Jean Michel).
             
............................................................................. */

{ includes/var_online.i }
{ includes/var_lanemp.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/var_internet.i }

DEF BUFFER crablem FOR craplem.
DEF VAR h-b1wgen0134         AS HANDLE            NO-UNDO.

ALTERACAO:

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lanemp.
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote WITH FRAME f_lanemp.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_nrdconta tel_nrdocmto WITH FRAME f_lanemp.

      ASSIGN glb_nrcalcul = tel_nrdconta
             aux_nrdconta = tel_nrdconta
             glb_cdcritic = 0.

      RUN fontes/digfun.p.
      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanemp.
               NEXT.
           END.

      IF   tel_nrdocmto = 0   THEN
           DO:
               glb_cdcritic = 22.
               NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanemp.
               NEXT.
           END.

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper    AND
                         crapass.nrdconta = tel_nrdconta    NO-LOCK NO-ERROR.

      IF   AVAILABLE crapass   THEN
           DO:
               IF   crapass.inpessoa = 1   THEN 
                    DO:
                        FIND crapttl WHERE 
                             crapttl.cdcooper = glb_cdcooper       AND
                             crapttl.nrdconta = crapass.nrdconta   AND
                             crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
                       
                        IF   AVAIL crapttl  THEN
                             ASSIGN aux_cdempres = crapttl.cdempres.
                    END.
               ELSE
                    DO:
                        FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                           crapjur.nrdconta = crapass.nrdconta
                                           NO-LOCK NO-ERROR.
                
                        IF   AVAIL crapjur  THEN
                             ASSIGN aux_cdempres = crapjur.cdempres.
                    END.
           END.

      IF   NOT AVAILABLE crapass   THEN
           DO:
               glb_cdcritic = 9.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanemp.
           END.

      /* Verifica se ha contratos de acordo */
            
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
      
      RUN STORED-PROCEDURE pc_verifica_acordo_ativo
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper
                                            ,INPUT tel_nrdconta
                                            ,INPUT tel_nrctremp
                                            ,0
                                            ,0
                                            ,"").

      CLOSE STORED-PROC pc_verifica_acordo_ativo
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

      ASSIGN glb_cdcritic = 0
             glb_dscritic = ""
             glb_cdcritic = pc_verifica_acordo_ativo.pr_cdcritic WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
             glb_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
             aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo).
      
      IF glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0.
            NEXT.
        END.
      ELSE IF glb_dscritic <> ? AND glb_dscritic <> "" THEN
        DO:
          MESSAGE glb_dscritic.
          ASSIGN glb_cdcritic = 0.
          NEXT.
        END.
        
      IF aux_flgativo = 1 THEN
        DO:
          MESSAGE "Alteracao nao permitida, emprestimo em acordo.".
          PAUSE 3 NO-MESSAGE.
          NEXT.
        END.            
      
      /* Fim verifica se ha contratos de acordo */
      
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        RETURN.  /* Volta pedir a opcao para o operador */

   DO TRANSACTION:

      DO WHILE TRUE:

         FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                            craplot.dtmvtolt = tel_dtmvtolt   AND
                            craplot.cdagenci = tel_cdagenci   AND
                            craplot.cdbccxlt = tel_cdbccxlt   AND
                            craplot.nrdolote = tel_nrdolote   EXCLUSIVE-LOCK
                            NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craplot   THEN
              IF   LOCKED craplot   THEN
                   DO:
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   glb_cdcritic = 60.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic = 0   THEN
           DO:
               IF   craplot.tplotmov <> 5   THEN
                    DO:
                        glb_cdcritic = 213.
                        NEXT.
                    END.
               IF   craplot.nrdolote = 10001   THEN
                    DO:
                        glb_cdcritic = 261.
                        NEXT.
                    END.
           END.
      ELSE
           NEXT.

      ASSIGN tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      DO  aux_contador = 1 TO 10:

          FIND crablem WHERE crablem.cdcooper = glb_cdcooper   AND
                             crablem.dtmvtolt = tel_dtmvtolt   AND
                             crablem.cdagenci = tel_cdagenci   AND
                             crablem.cdbccxlt = tel_cdbccxlt   AND
                             crablem.nrdolote = tel_nrdolote   AND
                             crablem.nrdconta = tel_nrdconta   AND
                             crablem.nrdocmto = tel_nrdocmto   EXCLUSIVE-LOCK
                             USE-INDEX craplem1 NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE crablem   THEN
               IF   LOCKED crablem   THEN
                    DO:
                        glb_cdcritic = 114.
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    glb_cdcritic = 90.
          ELSE
               glb_cdcritic = 0.

          LEAVE.
      END.

      IF   glb_cdcritic > 0   THEN
           NEXT.

      FIND craphis NO-LOCK WHERE craphis.cdcooper = crablem.cdcooper AND 
                                 craphis.cdhistor = crablem.cdhistor NO-ERROR.

      IF   NOT AVAILABLE craphis   THEN
           DO:
               glb_cdcritic = 83.
               NEXT.
           END.

      ASSIGN aux_cdhistor = craphis.cdhistor
             aux_inhistor = craphis.inhistor
             aux_indebcre = craphis.indebcre.

      ASSIGN tel_cdhistor = crablem.cdhistor
             tel_nrctremp = crablem.nrctremp
             tel_vllanmto = crablem.vllanmto
             tel_nrseqdig = crablem.nrseqdig

             aux_vllanmto = tel_vllanmto.

      DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
              tel_qtcompln tel_vlcompdb tel_vlcompcr
              tel_qtdifeln tel_vldifedb tel_vldifecr
              tel_cdhistor tel_nrdconta tel_nrctremp
              tel_nrdocmto tel_vllanmto tel_nrseqdig
              WITH FRAME f_lanemp.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         IF   glb_cdcritic > 0 THEN
              DO:
                  RUN fontes/critic.p.
                  BELL.
                  CLEAR FRAME f_lanemp.
                  DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                          tel_qtinfoln tel_vlinfodb tel_vlinfocr
                          tel_qtcompln tel_vlcompdb tel_vlcompcr
                          tel_qtdifeln tel_vldifedb tel_vldifecr
                          tel_cdbccxlt tel_nrdolote tel_cdhistor tel_nrdconta
                          tel_nrdocmto tel_nrctremp tel_vllanmto tel_nrseqdig
                          WITH FRAME f_lanemp.
                  MESSAGE glb_dscritic.
                  glb_cdcritic = 0.
              END.

         UPDATE tel_nrdocmto tel_vllanmto WITH FRAME f_lanemp

         EDITING:

            READKEY.
            IF   FRAME-FIELD = "tel_vllanmto"   THEN
                 IF   LASTKEY =  KEYCODE(".")   THEN
                      APPLY 44.
                 ELSE
                      APPLY LASTKEY.
            ELSE
                 APPLY LASTKEY.

         END.

         FIND craphis WHERE craphis.cdhistor = tel_cdhistor AND 
                            craphis.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craphis   THEN
              DO:
                  glb_cdcritic = 93.
                  NEXT-PROMPT tel_cdhistor WITH FRAME f_lanemp.
                  NEXT.
              END.



         IF   craphis.tplotmov <> 5   THEN
              DO:
                  glb_cdcritic = 94.
                  NEXT-PROMPT tel_cdhistor WITH FRAME f_lanemp.
                  NEXT.
              END.


         IF   tel_nrdocmto = 0   THEN
              DO:
                  glb_cdcritic = 22.
                  NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanemp.
                  NEXT.
              END.

         IF   tel_cdhistor = 277 THEN
              IF   tel_nrdocmto <> tel_nrctremp THEN
                   DO: 
                       MESSAGE "Num. documento deve ser igual ao Num. do contrato de emprestimo".
                       glb_cdcritic = 0.
                       NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanemp.
                       NEXT.
                   END.

         IF   tel_nrdocmto <> crablem.nrdocmto   THEN
              DO:
                  IF   CAN-FIND(craplem WHERE 
                                craplem.cdcooper = glb_cdcooper  AND
                                craplem.dtmvtolt = tel_dtmvtolt  AND
                                craplem.cdagenci = tel_cdagenci  AND
                                craplem.cdbccxlt = tel_cdbccxlt  AND
                                craplem.nrdolote = tel_nrdolote  AND
                                craplem.nrdconta = tel_nrdconta  AND
                                craplem.nrdocmto = tel_nrdocmto 
                                USE-INDEX craplem1)   THEN
                       DO:
                           glb_cdcritic = 92.
                           NEXT.
                       END.
              END.

         /*  Leitura do dia do pagamento da empresa  */

         FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                            craptab.nmsistem = "CRED"            AND
                            craptab.tptabela = "GENERI"          AND
                            craptab.cdempres = 00                AND
                            craptab.cdacesso = "DIADOPAGTO"      AND
                            craptab.tpregist = aux_cdempres 
                            NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craptab   THEN
              DO:
                  glb_cdcritic = 55.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic "DIA DO PAGTO DA EMPRESA" 
                          aux_cdempres.
                  glb_cdcritic = 0.
                  NEXT.
              END.

         IF   CAN-DO("1,3,4",STRING(crapass.cdtipsfx))   THEN
              tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,4,2)).
         ELSE
              tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,7,2)).

         /*  Verifica se a data do pagamento da empresa cai num dia util  */

         tab_dtcalcul = DATE(MONTH(glb_dtmvtolt),tab_diapagto,
                              YEAR(glb_dtmvtolt)).

         DO WHILE TRUE:

            IF   WEEKDAY(tab_dtcalcul) = 1   OR
                 WEEKDAY(tab_dtcalcul) = 7   THEN
                 DO:
                     tab_dtcalcul = tab_dtcalcul + 1.
                     NEXT.
                 END.

            FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper AND
                               crapfer.dtferiad = tab_dtcalcul NO-LOCK NO-ERROR.

            IF   AVAILABLE crapfer   THEN
                 DO:
                     tab_dtcalcul = tab_dtcalcul + 1.
                     NEXT.
                 END.

            tab_diapagto = DAY(tab_dtcalcul).

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

         DO WHILE TRUE:

            FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper   AND
                               crapepr.nrdconta = tel_nrdconta   AND
                               crapepr.nrctremp = tel_nrctremp   EXCLUSIVE-LOCK
                               NO-ERROR NO-WAIT.

            IF   NOT AVAILABLE crapepr   THEN
                 IF   LOCKED crapepr   THEN
                      DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          glb_cdcritic = 356.
                          NEXT-PROMPT tel_nrctremp WITH FRAME f_lanemp.
                      END.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

         IF   glb_cdcritic > 0   THEN
              NEXT.
         
         /* Guardar o valor de saldo de prejuizo (Renato Darosci - 16/08/2016) */ 
         ASSIGN ant_vlsdprej = crapepr.vlsdprej.         
         
         RUN sistema/generico/procedures/b1wgen0134.p 
                              PERSISTENT SET h-b1wgen0134.

         IF tel_cdhistor <> 382 AND 
            tel_cdhistor <> 383 AND
            tel_cdhistor <> 390 AND
            tel_cdhistor <> 391 THEN
         DO:
    
             
             RUN valida_empr_tipo1 IN h-b1wgen0134 
                                     (INPUT glb_cdcooper,
                                      INPUT tel_cdagenci,
                                      INPUT 0,
                                      INPUT tel_nrdconta,
                                      INPUT tel_nrctremp,
                                      OUTPUT TABLE tt-erro).
            
             IF  RETURN-VALUE = "OK" THEN
                 DO:
                    glb_cdcritic = 946.
                    DELETE PROCEDURE h-b1wgen0134.
                    NEXT.
                 END.
         
         END.

         RUN valida_historico IN h-b1wgen0134 (INPUT tel_cdhistor).

         IF  RETURN-VALUE = "OK" THEN
             DO:
                glb_cdcritic = 650.
                DELETE PROCEDURE h-b1wgen0134.
                NEXT.
             END.      

         DELETE PROCEDURE h-b1wgen0134.

         IF   tab_inusatab           AND
              crapepr.inliquid = 0   THEN
              DO:
                  FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper     AND
                                     craplcr.cdlcremp = crapepr.cdlcremp
                                     NO-LOCK NO-ERROR.
                  

                  IF   NOT AVAILABLE craplcr   THEN
                       DO:
                           glb_cdcritic = 363.
                           NEXT.
                       END.
                  ELSE
                       aux_txdjuros = craplcr.txdiaria.
              END.
         ELSE
              aux_txdjuros = crapepr.txjuremp.

         ASSIGN aux_nrdconta = crapepr.nrdconta
                aux_nrctremp = crapepr.nrctremp
                aux_vlsdeved = crapepr.vlsdeved
                aux_vljuracu = crapepr.vljuracu
                aux_dtultpag = crapepr.dtultpag

                aux_dtcalcul = ?

                aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,
                                       YEAR(glb_dtmvtolt)) + 4) -
                                        DAY(DATE(MONTH(glb_dtmvtolt),28,
                                            YEAR(glb_dtmvtolt)) + 4)).

          IF  tel_cdhistor <> 349   AND 
              tel_cdhistor <> 382   AND
              tel_cdhistor <> 390   AND
              tel_cdhistor <> 391   AND
              tel_cdhistor <> 383   THEN 
              DO:
                  { includes/lelem.i } /*  Rotina para calc. do sld. devedor  */
              END.
             
         IF   aux_vlsdeved <= 0   AND
              crapepr.inprejuz = 0 AND
              craphis.indebcre = "C"  THEN
              DO:
                  glb_cdcritic = 358.
                  NEXT-PROMPT tel_nrctremp WITH FRAME f_lanemp.
                  NEXT.
              END.

         IF   crapepr.inprejuz = 0   THEN
              DO:
                  IF   tel_cdhistor = 382   OR
                       tel_cdhistor = 383   OR
                       tel_cdhistor = 390   OR
                       tel_cdhistor = 391   THEN
                       DO:
                           glb_cdcritic = 93.
                           NEXT-PROMPT tel_cdhistor WITH FRAME f_lanemp.
                           NEXT.
                       END.
              END.
         ELSE
              DO:
                  IF   tel_cdhistor = 382   OR
                       tel_cdhistor = 391   THEN
                       DO:
                           glb_cdcritic = 323.
                           NEXT-PROMPT tel_cdhistor WITH FRAME f_lanemp.
                           NEXT.
                       END.    

                  IF    tel_cdhistor = 383
                  AND   tel_vllanmto > (crapepr.vlsdprej + crablem.vllanmto)
                  AND   ((crapepr.vlttmupr - crapepr.vlpgmupr) +
                         (crapepr.vlttjmpr - crapepr.vlpgjmpr)) > 0 THEN   
                        DO:
                            glb_cdcritic = 269.
                            NEXT-PROMPT tel_vllanmto WITH FRAME f_lanemp.
                            NEXT.
                        END.    
              END.
              
         IF   tel_cdhistor = 349   AND
              tel_vllanmto <> crablem.vllanmto   THEN   
              DO:
                  glb_cdcritic = 269.
                  NEXT-PROMPT tel_vllanmto WITH FRAME f_lanemp.
                  NEXT.
              END.   

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           UNDO, NEXT ALTERACAO.  /* Volta pedir a conta para o operador */

      /******* Magui tratamento do prejuizo 02/07/2001 ***/
      IF   crapepr.inprejuz <> 0   AND 
          (tel_cdhistor = 390    OR
           tel_cdhistor = 383) THEN
           DO:
               IF   aux_indebcre = "D"   THEN
                    ASSIGN crapepr.vlsdprej = crapepr.vlsdprej -
                                                      aux_vllanmto.
               ELSE                                       
                    IF   aux_indebcre = "C"   THEN
                         ASSIGN crapepr.vlsdprej = crapepr.vlsdprej +
                                                           aux_vllanmto.
           END.
      ELSE  
           IF   tel_cdhistor <> 349   THEN
                DO:
                    IF   aux_indebcre = "D"   THEN
                         ASSIGN aux_vlsdeved     = aux_vlsdeved - aux_vllanmto
                                crapepr.inliquid = IF aux_vlsdeved > 0 THEN 0 
                                                      ELSE 1.
                    ELSE
                         IF   aux_indebcre = "C"   THEN
                              ASSIGN aux_vlsdeved     = aux_vlsdeved +
                                                            aux_vllanmto
                                     crapepr.inliquid = IF aux_vlsdeved > 0 
                                                        THEN 0 ELSE 1.
                        
                    RUN verifica_contrato_rating (INPUT crapepr.cdcooper,
                                                  INPUT crapepr.nrdconta,
                                                  INPUT crapepr.nrctremp).

                    IF   RETURN-VALUE <> "OK"   THEN
                         UNDO, NEXT ALTERACAO.

                END.
           
      IF   aux_indebcre = "D"   THEN
           ASSIGN craplot.vlcompdb = craplot.vlcompdb - aux_vllanmto.
      ELSE
           IF   aux_indebcre = "C"   THEN
                ASSIGN craplot.vlcompcr = craplot.vlcompcr - aux_vllanmto.
                           
      ASSIGN aux_cdhistor = craphis.cdhistor
             aux_inhistor = craphis.inhistor
             aux_indebcre = craphis.indebcre

             crablem.cdhistor = tel_cdhistor
             crablem.nrctremp = tel_nrctremp
             crablem.nrdocmto = tel_nrdocmto
             crablem.vllanmto = tel_vllanmto
             crablem.txjurepr = aux_txdjuros
             crablem.dtpagemp = tab_dtcalcul

             crablem.vlpreemp = crapepr.vlpreemp.

      IF   crapepr.inprejuz <> 0   AND
          (tel_cdhistor = 390   OR
           tel_cdhistor = 383)   THEN
           DO:
               IF   aux_indebcre = "D"   THEN
                    ASSIGN crapepr.vlsdprej = crapepr.vlsdprej +
                                                      tel_vllanmto.
               ELSE                                       
                    IF   aux_indebcre = "C"   THEN
                         ASSIGN crapepr.vlsdprej = crapepr.vlsdprej -
                                                           tel_vllanmto.
           END.
      ELSE        
           IF   tel_cdhistor <> 349   THEN
                DO:
                    IF   aux_indebcre = "D"   THEN
                         ASSIGN crapepr.inliquid = 
                                        IF (aux_vlsdeved + tel_vllanmto) > 0
                                        THEN 0
                                        ELSE 1.
                    ELSE
                         IF   aux_indebcre = "C"   THEN
                              ASSIGN crapepr.dtultpag = tel_dtmvtolt
                                     crapepr.txjuremp = aux_txdjuros
                                     crapepr.inliquid =
                                           IF (aux_vlsdeved - tel_vllanmto) > 0
                                               THEN 0
                                           ELSE 1.

                    RUN verifica_contrato_rating (INPUT crapepr.cdcooper,
                                                  INPUT crapepr.nrdconta,
                                                  INPUT crapepr.nrctremp).

                    IF   RETURN-VALUE <> "OK"   THEN
                         UNDO, NEXT ALTERACAO.

                END.
           
      /* Verificacao para atualizar a data do saldo do prejuizo apenas quando 
         foi pago neste momento, evitando que a data seja alterada novamente 
         a cada atualizacao da tela (Renato Darosci - 16/08/2016) */
      IF crapepr.inprejuz = 1 THEN 
        DO:
            IF ant_vlsdprej > 0 AND crapepr.vlsdprej = 0 THEN
                ASSIGN crapepr.dtliqprj = glb_dtmvtolt.
            ELSE
                ASSIGN crapepr.dtliqprj = ?.
        END.
          
      IF   aux_indebcre = "D"   THEN
           ASSIGN craplot.vlcompdb = craplot.vlcompdb + tel_vllanmto.
      ELSE
           IF   aux_indebcre = "C"   THEN
                ASSIGN craplot.vlcompcr = craplot.vlcompcr + tel_vllanmto.
                          
      ASSIGN tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

   END.   /*  Fim da transacao.  */

   RELEASE craplot.
   RELEASE crablem.
   
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                STRING(TIME,"HH:MM:SS") + 
                " - ALTERACAO DE LANCAMENTO" + "'-->'" +
                " Operador: " + glb_cdoperad +
                " Hst: " + STRING(tel_cdhistor) +
                " Conta: " + TRIM(STRING(tel_nrdconta,
                                         "zz,zzz,zzz,z")) + 
                " Doc: " + STRING(tel_nrdocmto) +
                " Valor: " + TRIM(STRING(tel_vllanmto,
                                         "zzzzzz,zzz,zz9.99")) +
                " Lote: " + TRIM(STRING(tel_nrdolote,"zzz,zz9")) + 
                " PA: " + STRING(tel_cdagenci,"999") + 
                " Banco/Caixa: " + STRING(tel_cdbccxlt,"999") + 
                " >> log/lanemp.log").

   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  AND  tel_vldifecr = 0   THEN
        DO:
            glb_nmdatela = "LOTE".
            RETURN.                        /* Volta ao lanemp.p */
        END.

   ASSIGN tel_reganter[6] = tel_reganter[5]  tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3]  tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1]

          tel_reganter[1] = STRING(tel_cdhistor,"zzz9")               + "  "  +
                            STRING(tel_nrdconta,"zzzz,zzz,9")         + "   " +
                            STRING(tel_nrdocmto,"z,zzz,zzz,zz9")         + "  " +
                            STRING(tel_nrctremp,"zz,zzz,zz9")          + "   " +
                            STRING(tel_vllanmto,"zzz,zzz,zzz,zz9.99") + "   " +
                            STRING(tel_nrseqdig,"zz,zz9").

   ASSIGN tel_cdhistor = 0  tel_nrdconta = 0  tel_nrctremp = 0
          tel_nrdocmto = 0  tel_vllanmto = 0  tel_nrseqdig = tel_nrseqdig + 1.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_cdhistor tel_nrdconta tel_nrctremp
           tel_nrdocmto tel_vllanmto tel_nrseqdig
           WITH FRAME f_lanemp.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3]
           tel_reganter[4] tel_reganter[5] tel_reganter[6]
           WITH FRAME f_regant.

END.  /*  Fim do DO WHILE TRUE  */



PROCEDURE verifica_contrato_rating:

    DEF INPUT PARAM par_cdcooper AS INTE              NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE              NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE              NO-UNDO.
                                                      
    DEF VAR h-b1wgen0043         AS HANDLE            NO-UNDO.
            
    RUN sistema/generico/procedures/b1wgen0043.p 
                         PERSISTENT SET h-b1wgen0043.

    /* Verifica se tem que desativar/ativar Rating */
    RUN verifica_contrato_rating IN h-b1wgen0043 
                                        (INPUT par_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_dtmvtolt,
                                         INPUT glb_dtmvtopr,
                                         INPUT par_nrdconta,
                                         INPUT 90, /* Emprestimo */
                                         INPUT par_nrctremp,
                                         INPUT 1,
                                         INPUT 1,
                                         INPUT glb_nmdatela,
                                         INPUT glb_inproces,
                                         INPUT FALSE,
                                         OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0043.

    IF   RETURN-VALUE <> "OK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   AVAIL tt-erro  THEN
                  MESSAGE tt-erro.dscritic.
                 
             RETURN "NOK".    
         END.

    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */


