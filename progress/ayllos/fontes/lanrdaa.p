/* .............................................................................

   Programa: Fontes/lanrdaa.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/94.                    Ultima atualizacao: 01/02/2006
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela lanrda.

   Alteracoes: 10/10/95 - Alterado para nao permitir alteracoes de titulos para
                          numeros maiores que 499999 (Odair).

               21/12/96 - Alterado para tratar tpaplica (Odair).

               26/12/96 - Alterado para nao permitir aplicacoes RDCA60 depois
                          do dia 28 e nao exigir mais a taxa (Deborah).

               19/11/97 - Alterado para tratar RDCA 30 DIAS sem rendimento dia-
                          rio (Edson).

               16/02/98 - Alterado para guardar o valor a ser abonado (Deborah).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               09/11/98 - Tratar situacao em prejuizo (Deborah).

               25/01/99 - Tratar abono de IOF (Deborah).
               
               07/06/1999 - Tratar CPMF (Deborah).
                
               24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               05/02/2001 - Aplicaoes apos o dia 28 do mes. (Eduardo).

               26/03/2003 - Incluir tratamento da Concredi (Margarete).
               
               24/10/2003 - Nao atualiza mais incalcul (Margarete).

               20/04/2004 - Tratar modo de impressao do extrato (Margarete).
              
               02/09/2004 - Incluido Flag Conta Investimento(Mirtes).
               
               09/09/2004 - Incluido Flag Debitar Conta Investimento (Evandro).
               
               15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                            de inicio, tab_dtiniabo (Margarete).

               05/09/2005 - Faltava alterar numero da aplicacao no
                            craplap (Margarete).

               16/09/2005 - Quando dinheiro para aplicacao da conta
                            investimento nao tem cpmf (Margarete).
                            
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Andre
............................................................................. */

DEF        VAR tab_vllanmto     AS DECIMAL                           NO-UNDO.
DEF        VAR aux_vlalipmf     AS DECIMAL                           NO-UNDO.
DEF        VAR aux_cfrvipmf     AS DECIMAL                           NO-UNDO.
DEF        VAR aux_cdhislan     AS INTEGER                           NO-UNDO.
DEF        VAR tab_dtiniiof     AS DATE                              NO-UNDO.
DEF        VAR tab_dtfimiof     AS DATE                              NO-UNDO.
DEF        VAR tab_txiofrda     AS DECIMAL FORMAT "zzzzzzzz9,999999" NO-UNDO.

{ includes/var_online.i }

{ includes/var_lanrda.i }

{ includes/var_cpmf.i } 

ASSIGN tel_nrdconta = 0
       tel_nrdocmto = 0
       tel_tpaplica = 0
       tel_flgctain = no 
       tel_flgdebci = no
       tel_vllanmto = 0
       tel_tpemiext = 0
       tel_nrseqdig = 1

       aux_cdhislan = 0.

ALTERACAO:

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper AND
                         crapmfx.dtmvtolt = glb_dtmvtolt AND
                         crapmfx.tpmoefix = 2 
                         USE-INDEX crapmfx1 NO-LOCK NO-ERROR.

          IF   NOT AVAILABLE crapmfx THEN
               DO:
                  glb_cdcritic = 140.
                  RUN fontes/critic.p.
                  MESSAGE glb_dscritic + " UFIR ".
                  glb_cdcritic = 0.
                  BELL.
                  RETURN.
               END.

      IF   glb_dtmvtolt > 01/22/1997 AND glb_dtmvtolt < 01/24/1999 THEN
           ASSIGN aux_cfrvipmf = glb_cfrvipmf
                  aux_vlalipmf = glb_vlalipmf.
      ELSE
           ASSIGN aux_cfrvipmf = 1
                  aux_vlalipmf = 0.

      { includes/cpmf.i } 
      
      /* Tabela do IOF */
      
      FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                         craptab.nmsistem = "CRED"             AND
                         craptab.tptabela = "USUARI"           AND
                         craptab.cdempres = 11                 AND
                         craptab.cdacesso = "CTRIOFRDCA"       AND
                         craptab.tpregist = 1
                         USE-INDEX craptab1 NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE craptab   THEN
           DO:
               glb_cdcritic = 626.
               RUN fontes/critic.p.
               UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                 glb_cdprogra + "' --> '" + glb_dscritic  +
                                 " >> log/proc_batch.log").
               RETURN.
           END.
 
      ASSIGN tab_dtiniiof = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                                 INT(SUBSTRING(craptab.dstextab,1,2)),
                                 INT(SUBSTRING(craptab.dstextab,7,4)))
             tab_dtfimiof = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                                 INT(SUBSTRING(craptab.dstextab,12,2)),
                                 INT(SUBSTRING(craptab.dstextab,18,4)))
             tab_txiofrda = IF   glb_dtmvtolt >= tab_dtiniiof AND
                                 glb_dtmvtolt <= tab_dtfimiof 
                                 THEN DECIMAL(SUBSTR(craptab.dstextab,23,16))
                                 ELSE 0.

      FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                         craptab.nmsistem = "CRED"        AND
                         craptab.tptabela = "USUARI"      AND
                         craptab.cdempres = 11            AND
                         craptab.cdacesso = "VLREFERDCA"  AND
                         craptab.tpregist = 001           NO-LOCK NO-ERROR.

          IF   NOT AVAILABLE craptab THEN
               DO:
                  glb_cdcritic = 596.
                  RUN fontes/critic.p.
                  MESSAGE glb_dscritic.
                  glb_cdcritic = 0.
                  BELL.
                  RETURN.
               END.

      tab_vllanmto = DECIMAL(craptab.dstextab).

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lanrda.
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote
                       WITH FRAME f_lanrda.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      /* SUBSTITUICAO DO PUT SCREEN */
      DISP "" @ tel_tpaplica
           "" @ tel_vllanmto
           WITH FRAME f_lanrda.

      UPDATE tel_nrdconta tel_nrdocmto WITH FRAME f_lanrda.

      ASSIGN glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0.

      RUN fontes/digfun.p.

      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                         crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapass   THEN
           DO:
               glb_cdcritic = 9.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.

      IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
           DO:
               glb_cdcritic = 695.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.

      IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
           DO:
               glb_cdcritic = 95.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.

      IF   crapass.dtelimin <> ?    THEN
           DO:
               glb_cdcritic = 75.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.

      IF   tel_nrdocmto = 0   THEN
           DO:
               glb_cdcritic = 22.
               NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanrda.
               NEXT.
           END.

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
                            craplot.nrdolote = tel_nrdolote
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

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
               IF   craplot.tplotmov <> 10   THEN
                    DO:
                        glb_cdcritic = 100.
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

      DO aux_contador = 1 TO 5:

         FIND craplap WHERE craplap.cdcooper = glb_cdcooper   AND
                            craplap.dtmvtolt = tel_dtmvtolt   AND
                            craplap.cdagenci = tel_cdagenci   AND
                            craplap.cdbccxlt = tel_cdbccxlt   AND
                            craplap.nrdolote = tel_nrdolote   AND
                            craplap.nrdconta = tel_nrdconta   AND
                            craplap.nrdocmto = tel_nrdocmto
                            USE-INDEX craplap1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craplap   THEN
              IF   LOCKED craplap   THEN
                   DO:
                       glb_cdcritic = 114.
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   DO:
                       glb_cdcritic = 90.
                       NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanrda.
                   END.
         ELSE
              glb_cdcritic = 0.

         LEAVE.

      END.  /*  Fim do DO .. TO  */

      IF   glb_cdcritic > 0   THEN
           NEXT.

      DO WHILE TRUE:

         FIND craprda WHERE craprda.cdcooper = glb_cdcooper       AND
                            craprda.dtmvtolt = craplap.dtmvtolt   AND
                            craprda.cdagenci = craplap.cdagenci   AND
                            craprda.cdbccxlt = craplap.cdbccxlt   AND
                            craprda.nrdolote = craplap.nrdolote   AND
                            craprda.nrdconta = craplap.nrdconta   AND
                            craprda.nraplica = INT(craplap.nrdocmto)
                            USE-INDEX craprda1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craprda   THEN
              IF   LOCKED craprda   THEN
                   DO:
                       PAUSE 2 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   glb_cdcritic = 426.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic > 0    THEN
           NEXT.

      ASSIGN tel_vllanmto = craprda.vlaplica
             tel_nrseqdig = craplap.nrseqdig
             tel_tpemiext = craprda.tpemiext
             tel_tpaplica = craprda.tpaplica
             tel_flgctain = craprda.flgctain
             tel_flgdebci = craprda.flgdebci.

      DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
              tel_qtcompln tel_vlcompdb tel_vlcompcr
              tel_qtdifeln tel_vldifedb tel_vldifecr
              tel_tpaplica tel_flgctain tel_flgdebci
              tel_vllanmto tel_tpemiext tel_nrseqdig
              WITH FRAME f_lanrda.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         IF   glb_cdcritic > 0 THEN
              DO:
                  RUN fontes/critic.p.
                  BELL.
                  CLEAR FRAME f_lanrda.
                  CLEAR FRAME f_lanctos ALL NO-PAUSE.
                  DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                          tel_cdbccxlt tel_nrdolote tel_nrdconta
                          tel_nrseqdig WITH FRAME f_lanrda.
                  MESSAGE glb_dscritic.
                  glb_cdcritic = 0.
              END.

         UPDATE tel_tpaplica
                tel_nrdocmto tel_vllanmto tel_tpemiext 
                WITH FRAME f_lanrda

         EDITING:

            READKEY.

            IF   FRAME-FIELD = "tel_vllanmto"   THEN
                 IF   LASTKEY =  KEYCODE(".")   THEN
                      APPLY 44.
                 ELSE
                      APPLY LASTKEY.
            ELSE
                 APPLY LASTKEY.

         END.  /*  Fim do EDITING  */

         /* Rotina nao esta em uso */

         IF   tel_tpaplica = 6  THEN
              DO:
                  glb_cdcritic = 999.
                  NEXT-PROMPT tel_tpaplica WITH FRAME f_lanrda.
                  NEXT.
              END.

         IF   tel_nrdocmto = 0 OR tel_nrdocmto > 499999   THEN
              DO:
                  glb_cdcritic = 425.
                  NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanrda.
                  NEXT.
              END.

         IF   tel_nrdocmto <> craprda.nraplica    THEN
              IF   CAN-FIND(craprda WHERE craprda.cdcooper = glb_cdcooper   AND
                                          craprda.dtmvtolt = tel_dtmvtolt   AND
                                          craprda.cdagenci = tel_cdagenci   AND
                                          craprda.cdbccxlt = tel_cdbccxlt   AND
                                          craprda.nrdolote = tel_nrdolote   AND
                                          craprda.nrdconta = tel_nrdconta   AND
                                          craprda.nraplica = tel_nrdocmto
                                          USE-INDEX craprda1)               OR

                   CAN-FIND(craprda WHERE craprda.cdcooper = glb_cdcooper   AND
                                          craprda.nrdconta = tel_nrdconta   AND
                                          craprda.nraplica = tel_nrdocmto
                                          USE-INDEX craprda2)               OR

                   CAN-FIND(craplap WHERE craplap.cdcooper = glb_cdcooper   AND
                                          craplap.dtmvtolt = tel_dtmvtolt   AND
                                          craplap.cdagenci = tel_cdagenci   AND
                                          craplap.cdbccxlt = tel_cdbccxlt   AND
                                          craplap.nrdolote = tel_nrdolote   AND
                                          craplap.nrdconta = tel_nrdconta   AND
                                          craplap.nrdocmto = tel_nrdocmto
                                          USE-INDEX craplap1)               THEN
                   DO:
                       glb_cdcritic = 92.
                       NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanrda.
                       NEXT.
                   END.

         IF  (tel_tpaplica = 3   AND   tel_vllanmto >= tab_vllanmto)  OR
             (tel_tpaplica = 6   AND   tel_vllanmto <  tab_vllanmto)  THEN
              DO:
                  glb_cdcritic = 269.
                  NEXT-PROMPT tel_vllanmto WITH FRAME f_lanrda.
                  NEXT.
              END.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           NEXT ALTERACAO.  /* Volta pedir a conta para o operador */

      DO WHILE TRUE:

         IF   tel_tpaplica = 3 THEN
              DO:
                  FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper AND
                                     craptrd.dtiniper = glb_dtmvtolt AND
                                     craptrd.tptaxrda = 1            AND
                                     craptrd.incarenc = 0            AND
                                     craptrd.vlfaixas = 0
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE craptrd   THEN
                       IF   LOCKED craptrd   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            glb_cdcritic = 347.
              END.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic > 0   THEN
           NEXT.

      IF   tel_tpaplica = 3 THEN
           aux_dtfimper = craptrd.dtfimper.
      ELSE                                                  /*  Tipos 5 ou 6  */
           DO:
               ASSIGN aux_dtfimper = IF   MONTH(glb_dtmvtolt) = 12 THEN
                                          DATE(1,DAY(glb_dtmvtolt),
                                                 YEAR(glb_dtmvtolt) + 1)
                                     ELSE
                                          DATE(MONTH(glb_dtmvtolt) + 1,
                                               DAY(glb_dtmvtolt),
                                               YEAR(glb_dtmvtolt)) NO-ERROR.

               IF   ERROR-STATUS:ERROR THEN
                    IF   MONTH(glb_dtmvtolt) = 11 THEN  
                         aux_dtfimper = DATE(1, 1, (YEAR(glb_dtmvtolt) + 1)).
                    ELSE
                         IF   MONTH(glb_dtmvtolt) = 12 THEN
                              aux_dtfimper = DATE(2, 1, 
                                                  (YEAR(glb_dtmvtolt) + 1)).
                         ELSE
                              aux_dtfimper = DATE((MONTH(glb_dtmvtolt) + 2),
                                                   1, YEAR(glb_dtmvtolt)).
           
           END.

      IF   tel_tpaplica = 3       AND
           craptrd.txofidia = 0   AND
           craptrd.txprodia = 0   THEN
           DO:
               glb_cdcritic = 427.
               NEXT.
           END.

      IF   tel_tpaplica = 3   THEN
           aux_cdhislan = 113.
      ELSE
      IF   tel_tpaplica = 5   THEN
           aux_cdhislan = 176.
      ELSE
      IF   tel_tpaplica = 6   THEN
           aux_cdhislan = 262.

      ASSIGN craplot.vlcompcr = craplot.vlcompcr - craprda.vlaplica +
                                                   tel_vllanmto

             craplap.vllanmto = tel_vllanmto
             craplap.nrdocmto = tel_nrdocmto
             craplap.cdhistor = aux_cdhislan

             craplap.dtrefere = aux_dtfimper
             craplap.nraplica = tel_nrdocmto

             craprda.nraplica = tel_nrdocmto
             craprda.tpemiext = tel_tpemiext
             craprda.vlaplica = tel_vllanmto
             craprda.vlsdrdca = tel_vllanmto
             craprda.qtaplmfx = tel_vllanmto / crapmfx.vlmoefix
             craprda.vlabcpmf = IF tel_flgdebci THEN
                                   0
                                ELSE   
                                IF tab_indabono = 0 AND
                                   tab_dtiniabo <= craprda.dtmvtolt THEN
                                   TRUNCATE(tel_vllanmto * tab_txcpmfcc,2)
                                ELSE craprda.vlabcpmf
                                
             craprda.vlabdiof = IF tab_indabono = 0 AND
                                   tab_dtiniabo <= craprda.dtmvtolt THEN
                                   TRUNCATE(tel_vllanmto * tab_txiofrda,2)
                                ELSE craprda.vlabdiof
                                
             craprda.tpaplica = tel_tpaplica
             craprda.dtfimper = aux_dtfimper

             tel_qtinfoln = craplot.qtinfoln
             tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb
             tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr
             tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

   END.   /* Fim da transacao */

   RELEASE craplot.
   RELEASE craprda.
   RELEASE craplap.

   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  AND  tel_vldifecr = 0   THEN
        DO:
            glb_nmdatela = "LOTE".
            RETURN.                        /* Volta ao lanctr.p */
        END.

   ASSIGN tel_reganter[6] = tel_reganter[5]  tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3]  tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1].
          
   IF  tel_flgctain = YES THEN
       ASSIGN aux_flgctain = "S".
   ELSE
       ASSIGN aux_flgctain = "N".
       
   IF   tel_flgdebci = YES   THEN
        ASSIGN aux_flgdebci = "S".
   ELSE
        ASSIGN aux_flgdebci = "N".
   
   ASSIGN tel_reganter[1] = STRING(tel_tpaplica,"9")    + "     " +
                            STRING(tel_nrdconta,"zzzz,zzz,9")    + "     " +
                            STRING(tel_nrdocmto,"zzz,zz9")       + "   " +
                            aux_flgctain + "      " +
                            aux_flgdebci + "      " +
                            STRING(tel_vllanmto,"zzz,zzz,zz9.99")
                            + "      " +
                            STRING(tel_tpemiext,"9") + " " +
                            STRING(tel_nrseqdig,"zz,zz9")

          tel_nrdconta = 0
          tel_nrdocmto = 0
          tel_vllanmto = 0
          tel_nrseqdig = tel_nrseqdig + 1.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_nrdconta tel_tpaplica tel_nrdocmto
           tel_vllanmto tel_tpemiext 
           tel_nrseqdig WITH FRAME f_lanrda.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3]
           tel_reganter[4] tel_reganter[5] tel_reganter[6] WITH FRAME f_regant.

END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
