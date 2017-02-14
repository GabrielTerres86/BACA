/* .............................................................................

   Programa: Fontes/lanempe.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 23/09/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela lanemp.

   Alteracoes: 21/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               11/04/95 - Alterado para atualizar a data do ultimo pagamento em
                          crapepr.dtultpag quando da exclusao do lancamento
                          (Edson).

               29/01/97 - Alterar a ordem dos campos Contrato Documento (Odair)

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).

             04/07/2001 - Tratamento do prejuizo (Margarete).
             
             25/01/2002 - Nao excluir lote 10001 (Margarete).

             14/05/2002 - Qdo prejuizo criticas de valores lancados (Margarete)
             
             30/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

             13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                          (Sidnei - Precise)
                          
             31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

             06/07/2009 - Nao permitir exclusao de lancamentos para emprestimos 
                          com emissao de boletos (Fernando).
                          
             18/05/2010 - Desativar Rating quando liquidada a operaçao
                          (Gabriel).               
                          
             01/03/2012 - Incluido validacao para o tipo de contrato 1
                          da b1wgen0134.p (Tiago).
                          
             04/02/2015 - Ajuste na exclusao do lote para o contrato em 
                          prejuizo do tipo PP. (Oscar/James)  
                          
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
 
DEF VAR    h-b1wgen0043 AS HANDLE NO-UNDO.
DEF VAR    h-b1wgen0134 AS HANDLE NO-UNDO.

DEF VAR aux_vlrsaldo AS DEC                                         NO-UNDO.
DEF VAR aux_vlrabono AS DEC                                         NO-UNDO.
DEF VAR aux_vlpgsmmo AS DEC                                         NO-UNDO.
DEF VAR aux_sldmulta AS DEC                                         NO-UNDO.
DEF VAR aux_sldjmora AS DEC                                         NO-UNDO.


EXCLUSAO:
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

      UPDATE tel_nrdconta tel_nrdocmto tel_nrctremp WITH FRAME f_lanemp.

      ASSIGN glb_nrcalcul = tel_nrdconta
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
               NEXT.
           END.

      /*  Leitura do dia do pagamento da empresa  */

      FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                         craptab.nmsistem = "CRED"            AND
                         craptab.tptabela = "GENERI"          AND
                         craptab.cdempres = 00                AND
                         craptab.cdacesso = "DIADOPAGTO"      AND
                         craptab.tpregist = aux_cdempres  NO-LOCK NO-ERROR.

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

      tab_dtcalcul = DATE(MONTH(glb_dtmvtolt),tab_diapagto,YEAR(glb_dtmvtolt)).

      DO WHILE TRUE:

         IF   WEEKDAY(tab_dtcalcul) = 1   OR
              WEEKDAY(tab_dtcalcul) = 7   THEN
              DO:
                  tab_dtcalcul = tab_dtcalcul + 1.
                  NEXT.
              END.

         FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                            crapfer.dtferiad = tab_dtcalcul  NO-LOCK NO-ERROR.

         IF   AVAILABLE crapfer   THEN
              DO:
                  tab_dtcalcul = tab_dtcalcul + 1.
                  NEXT.
              END.

         tab_diapagto = DAY(tab_dtcalcul).

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

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
          MESSAGE "Exclusao nao permitida, emprestimo em acordo.".
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
      
      IF   glb_cdcritic <> 0   THEN
           NEXT.
           
      IF   craplot.nrdolote = 10001   THEN
           DO:
               glb_cdcritic = 261.
               NEXT.
           END.
 
      /*** Magui colocado aqui para criticas do prejuizo ****/
      DO  aux_contador = 1 TO 10:

          glb_cdcritic = 0.

          FIND craplem WHERE craplem.cdcooper = glb_cdcooper   AND
                             craplem.dtmvtolt = tel_dtmvtolt   AND
                             craplem.cdagenci = tel_cdagenci   AND
                             craplem.cdbccxlt = tel_cdbccxlt   AND
                             craplem.nrdolote = tel_nrdolote   AND
                             craplem.nrdconta = tel_nrdconta   AND
                             craplem.nrdocmto = tel_nrdocmto   NO-LOCK
                             USE-INDEX craplem1 NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE craplem   THEN
               IF   LOCKED craplem   THEN
                    DO:
                        glb_cdcritic = 114.
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    glb_cdcritic = 90.
          ELSE
               DO:
                   FIND craphis NO-LOCK WHERE 
                                craphis.cdcooper = craplem.cdcooper AND 
                                craphis.cdhistor = craplem.cdhistor NO-ERROR.

                   IF   NOT AVAILABLE craplem   THEN
                        glb_cdcritic = 80.
                   ELSE
                        glb_cdcritic = 0.
               END.

          LEAVE.

      END.  /*  Fim do DO .. TO  */

      IF   glb_cdcritic > 0   THEN
           NEXT.

      ASSIGN tel_cdhistor = craplem.cdhistor
             tel_nrctremp = craplem.nrctremp
             tel_vllanmto = craplem.vllanmto
             tel_nrseqdig = craplem.nrseqdig.


      IF tel_cdhistor <> 382  AND 
         tel_cdhistor <> 383  AND
         tel_cdhistor <> 390  AND
         tel_cdhistor <> 391  THEN
      DO:
      
          RUN sistema/generico/procedures/b1wgen0134.p 
                         PERSISTENT SET h-b1wgen0134.
                    
          RUN valida_empr_tipo1 IN h-b1wgen0134
                                   (INPUT glb_cdcooper,
                                    INPUT tel_cdagenci,
                                    INPUT 0,
                                    INPUT tel_nrdconta,
                                    INPUT tel_nrctremp,
                                   OUTPUT TABLE tt-erro).
    
          DELETE PROCEDURE h-b1wgen0134.
    
          IF  RETURN-VALUE = "OK" THEN
              DO:
                glb_cdcritic = 946.
                /* NEXT-PROMPT tel_nrctremp WITH FRAME f_lanemp. */
                NEXT.
              END.
      END.

      IF   glb_cdcritic = 0   THEN
           DO:
               IF   craplot.tplotmov <> 5   THEN
                    DO:
                        glb_cdcritic = 213.
                        NEXT.
                    END.

               DO WHILE TRUE:

                  FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper   AND
                                     crapepr.nrdconta = tel_nrdconta   AND
                                     crapepr.nrctremp = tel_nrctremp
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

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
             
                IF   tab_inusatab           AND
                    crapepr.inliquid = 0   THEN
                    DO:
                        FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
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
                      aux_inliquid = crapepr.inliquid

                      aux_dtcalcul = ?

                      aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,
                                             YEAR(glb_dtmvtolt)) +
                                             4) - DAY(DATE(MONTH(glb_dtmvtolt),
                                             28,YEAR(glb_dtmvtolt)) + 4)).

               /*** Magui verificar esta critica ***/
               IF   tel_cdhistor <> 382  AND
                    tel_cdhistor <> 383  AND
                    tel_cdhistor <> 390  AND
                    tel_cdhistor <> 391  THEN
                    DO:
                        { includes/lelem.i }
                                   /* Rotina para calculo do saldo devedor */
                    END.

               IF   tel_cdhistor = 382   THEN
                    DO:
                        FIND FIRST crablem WHERE
                                   crablem.cdcooper = glb_cdcooper  AND
                                   crablem.nrdconta = tel_nrdconta  AND
                                   crablem.nrctremp = tel_nrctremp  AND
                                   crablem.cdhistor = 391           
                                   NO-LOCK NO-ERROR.
                                   
                       IF   AVAILABLE crablem   THEN
                            DO:
                                glb_cdcritic = 650.
                                NEXT.
                            END.                 
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

      /*** Magui necessatio aqui tambem porque o lelem.i le o craplem  ******/
      DO  aux_contador = 1 TO 10:

          glb_cdcritic = 0.

          FIND craplem WHERE craplem.cdcooper = glb_cdcooper   AND
                             craplem.dtmvtolt = tel_dtmvtolt   AND
                             craplem.cdagenci = tel_cdagenci   AND
                             craplem.cdbccxlt = tel_cdbccxlt   AND
                             craplem.nrdolote = tel_nrdolote   AND
                             craplem.nrdconta = tel_nrdconta   AND
                             craplem.nrdocmto = tel_nrdocmto   EXCLUSIVE-LOCK
                             USE-INDEX craplem1 NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE craplem   THEN
               IF   LOCKED craplem   THEN
                    DO:
                        glb_cdcritic = 114.
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    glb_cdcritic = 90.
          ELSE
               DO:
                   FIND craphis NO-LOCK WHERE 
                                craphis.cdcooper = craplem.cdcooper AND 
                                craphis.cdhistor = craplem.cdhistor NO-ERROR.

                   IF   NOT AVAILABLE craplem   THEN
                        glb_cdcritic = 80.
                   ELSE
                        glb_cdcritic = 0.
               END.

          LEAVE.

      END.  /*  Fim do DO .. TO  */

      IF   glb_cdcritic > 0   THEN
           NEXT.

      DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
              tel_qtcompln tel_vlcompdb tel_vlcompcr
              tel_qtdifeln tel_vldifedb tel_vldifecr
              tel_cdhistor tel_nrdconta tel_nrctremp
              tel_nrdocmto tel_vllanmto tel_nrseqdig
              WITH FRAME f_lanemp.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         aux_confirma = "N".

         glb_cdcritic = 78.
         RUN fontes/critic.p.
         BELL.
         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         glb_cdcritic = 0.
         LEAVE.

      END.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
           aux_confirma <> "S" THEN
           DO:
               glb_cdcritic = 79.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               NEXT.
           END.

      /******* Magui tratamento do prejuizo 02/07/2001 ***/
      IF   crapepr.inprejuz <> 0    AND
          (tel_cdhistor = 382       OR
           tel_cdhistor = 383       OR
           tel_cdhistor = 390       OR
           tel_cdhistor = 391)       THEN
           DO:
               IF craphis.indebcre = "C"   THEN
                  DO:
                      IF crapepr.tpemprst = 1 AND 
                         CAN-DO("382,383",STRING(tel_cdhistor)) THEN
                         DO:
                             ASSIGN aux_vlrabono = 0
                                    aux_vlpgsmmo = 0
                                    aux_sldmulta = 0
                                    aux_sldjmora = 0
                                    aux_vlrpagos = 0.
            
                             FOR EACH crablem WHERE 
                                     (crablem.cdcooper = glb_cdcooper       AND
                                      crablem.nrdconta = crapepr.nrdconta   AND
                                      crablem.nrctremp = crapepr.nrctremp   AND
                                      crablem.cdhistor = 382)               OR

                                     (crablem.cdcooper = glb_cdcooper       AND
                                      crablem.nrdconta = crapepr.nrdconta   AND
                                      crablem.nrctremp = crapepr.nrctremp   AND
                                      crablem.cdhistor = 383)
                                      NO-LOCK:
                                     
                                 IF crablem.cdhistor = 382 THEN
                                    ASSIGN aux_vlrpagos = aux_vlrpagos +
                                                          crablem.vllanmto.
                                 ELSE
                                 IF crablem.cdhistor = 383 THEN
                                    ASSIGN aux_vlrabono = aux_vlrabono +
                                                          crablem.vllanmto.

                             END. /* END FOR EACH crablem */
            
                             ASSIGN /* Valor a ser desfeito */
                                     aux_vlrsaldo = tel_vllanmto
                                     /* Pago da multa */
                                     aux_sldmulta = crapepr.vlpgmupr
                                     /* Pago do juros de mora */
                                     aux_sldjmora = crapepr.vlpgjmpr
                                     /* Calcular o valor pago do prejuizo original sem multa e juros de mora */   
                                     aux_vlpgsmmo = (aux_vlrpagos + aux_vlrabono) - 
                                                    (aux_sldmulta + aux_sldjmora).
                             
                             /* 1 Desfazer primeiro o valor pago do prejuizo original */
                             IF aux_vlpgsmmo > 0 THEN
                                DO:
                                   IF ((aux_vlpgsmmo - aux_vlrsaldo) <= 0) THEN
                                      ASSIGN crapepr.vlsdprej = crapepr.vlsdprej + aux_vlpgsmmo
                                             aux_vlrsaldo     = aux_vlrsaldo - aux_vlpgsmmo
                                             aux_vlpgsmmo     = 0.
                                   ELSE
                                      ASSIGN crapepr.vlsdprej = crapepr.vlsdprej + aux_vlrsaldo
                                             aux_vlpgsmmo     = aux_vlpgsmmo - aux_vlrsaldo
                                             aux_vlrsaldo     = 0.

                                END. /* END IF aux_vlpgsmmo > 0 THEN */
            
                             /* 2 Desfazer o valor pago de multa */
                             IF aux_vlrsaldo > 0 AND aux_sldmulta > 0 THEN
                                DO:
                                   IF ((aux_sldmulta - aux_vlrsaldo) <= 0) THEN
                                      ASSIGN crapepr.vlpgmupr = crapepr.vlpgmupr - aux_sldmulta
                                             aux_vlrsaldo     = aux_vlrsaldo - aux_sldmulta
                                             aux_sldmulta     = 0.
                                   ELSE     
                                      ASSIGN crapepr.vlpgmupr = crapepr.vlpgmupr - aux_vlrsaldo
                                             aux_sldmulta     = aux_sldmulta - aux_vlrsaldo
                                             aux_vlrsaldo     = 0.
                                END.
            
                             /* 3 Desfazer o valor pago de juros de mora */
                             IF (aux_vlrsaldo > 0) AND (aux_sldjmora > 0) THEN
                                DO:
                                    IF ((aux_sldjmora - aux_vlrsaldo) <= 0) THEN
                                       ASSIGN crapepr.vlpgjmpr = crapepr.vlpgjmpr - aux_sldjmora
                                              aux_vlrsaldo     = aux_vlrsaldo - aux_sldjmora
                                              aux_sldjmora     = 0.
                                    ELSE     
                                       ASSIGN crapepr.vlpgjmpr = crapepr.vlpgjmpr - aux_vlrsaldo
                                              aux_sldjmora     = aux_sldjmora - aux_vlrsaldo
                                              aux_vlrsaldo     = 0.
                                END.

                         END. /* END IF crapepr.tpemprst = 1 */
                      ELSE
                         ASSIGN crapepr.vlsdprej = crapepr.vlsdprej + tel_vllanmto.

                  END. /* END IF craphis.indebcre = "C"   THEN */

               ELSE
                  IF craphis.indebcre = "D"   THEN
                     ASSIGN crapepr.vlsdprej = crapepr.vlsdprej -
                                               tel_vllanmto.
           END. /* END PREJUIZO */
      ELSE  
           DO:                                                   
               IF   tel_cdhistor = 349   THEN 
                    ASSIGN crapepr.vlprejuz = crapepr.vlprejuz - tel_vllanmto
                           crapepr.vlsdprej = crapepr.vlsdprej - tel_vllanmto
                           crapepr.inprejuz = 0
                           crapepr.dtprejuz = ?
                           crapepr.vlsdevat = crapepr.vlsdevat + tel_vllanmto.
               
               IF   craphis.indebcre = "D"   THEN
                    ASSIGN crapepr.inliquid = IF 
                                              (aux_vlsdeved - tel_vllanmto) > 0
                                               THEN 0
                                               ELSE 1.
               ELSE
                    IF   craphis.indebcre = "C"   THEN
                         ASSIGN crapepr.inliquid = IF 
                                        (aux_vlsdeved + tel_vllanmto) > 0
                                              THEN 0
                                              ELSE 1.

               RUN sistema/generico/procedures/b1wgen0043.p
                                    PERSISTENT SET h-b1wgen0043.

               RUN verifica_contrato_rating IN h-b1wgen0043 
                                                (INPUT glb_cdcooper,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT glb_dtmvtopr,
                                                 INPUT crapepr.nrdconta,
                                                 INPUT 90,
                                                 INPUT crapepr.nrctremp,
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
                       
                        IF   AVAIL tt-erro   THEN
                             MESSAGE tt-erro.dscritic.
                       
                        UNDO , NEXT EXCLUSAO.
                    END.                             
           END.              
        
        IF   craphis.indebcre = "D"   THEN
             ASSIGN craplot.vlcompdb = craplot.vlcompdb - tel_vllanmto.
        ELSE
             IF   craphis.indebcre = "C"   THEN
                  ASSIGN craplot.vlcompcr = craplot.vlcompcr - tel_vllanmto.
      
      craplot.qtcompln = craplot.qtcompln - 1.

      ASSIGN tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      DELETE craplem.

      aux_dtultpag = crapepr.dtmvtolt.

      FOR EACH craplem WHERE craplem.cdcooper = glb_cdcooper       AND
                             craplem.nrdconta = crapepr.nrdconta   AND
                             craplem.nrctremp = crapepr.nrctremp   NO-LOCK:

          FIND craphis NO-LOCK WHERE 
                               craphis.cdcooper = craplem.cdcooper AND 
                               craphis.cdhistor = craplem.cdhistor NO-ERROR.

          IF   NOT AVAILABLE craphis   THEN
               NEXT.

          IF   craphis.indebcre = "C"   THEN
               aux_dtultpag = craplem.dtmvtolt.

      END.  /*  Fim do FOR EACH  --  Pesquisa do ultimo pagamento  */

      crapepr.dtultpag = aux_dtultpag.
      
      /* Retorna a situacao para antes de ter pago o 
         prejuizo (Renato Darosci - 16/08/2016) */
      IF crapepr.inprejuz = 1  AND 
         crapepr.vlsdprej > 0  AND 
         crapepr.dtliqprj <> ? THEN
          ASSIGN crapepr.dtliqprj = ?.
          
   END.   /*  Fim da transacao.  */

   RELEASE craplot.
   RELEASE craplem.

   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                STRING(TIME,"HH:MM:SS") + 
                " - EXCLUSAO DE LANCAMENTO" + "'-->'" +
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
            RETURN.                 /* Volta ao lanemp.p */
        END.

   ASSIGN tel_cdhistor = 0  tel_nrdconta = 0  tel_nrctremp = 0
          tel_nrdocmto = 0  tel_vllanmto = 0  tel_nrseqdig = 0.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_cdhistor tel_nrdconta tel_nrctremp
           tel_nrdocmto tel_vllanmto tel_nrseqdig
           WITH FRAME f_lanemp.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */


