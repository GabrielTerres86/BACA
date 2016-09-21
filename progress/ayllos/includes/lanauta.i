/* .............................................................................

   Programa: Includes/lanauta.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/91.                         Ultima atualizacao: 13/05/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela LANAUT.

   Alteracoes: 21/06/95 - Alterado para as novas rotinas da tela (Edson).

               18/07/95 - Alterado para nao permitir data superior a 30 dias
                          (Deborah).

               12/08/96 - Alterado para tratar historico com debito na folha
                          de pagamento (Edson).

               27/08/96 - Alterado para gerar o aviso (historicos com debito
                          ha folha) na data do aviso de emprestimo (Deborah).

               17/07/97 - Tratar avs.dtmvtolt dependendo emp.tpconven (Odair)

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               20/08/2001 - Tratar onze posicoes no numero do documento (Edson).

               18/12/2003 - Alterado para NAO permitir data de pagamento para
                            o dia 31/12 de qualquer ano (Edson).

               24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
               
               01/09/2008 - Alteracao cdempres (Kbase IT) - Eduardo Silva.
               
               23/11/2009 - Alteracao Codigo Historico (Kbase).
............................................................................. */

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lanaut.
               DISPLAY glb_cddopcao tel_dtmvtolt
                       tel_cdagenci tel_cdbccxlt tel_nrdolote
                       tel_nrdconta tel_nrdocmto tel_cdhistor tel_cdbccxpg
                       tel_dtmvtopg WITH FRAME f_lanaut.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_nrdconta tel_nrdocmto WITH FRAME f_lanaut.

      ASSIGN glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0.

      RUN fontes/digfun.p.
      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
               NEXT.
           END.

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                         crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

      IF  AVAILABLE crapass  THEN
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
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
               NEXT.
           END.

         /* FIND crapemp OF crapass NO-LOCK NO-ERROR. */
          FIND crapemp WHERE  crapemp.cdcooper = glb_cdcooper AND
                              crapemp.cdempres = aux_cdempres
                              NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapemp   THEN
           DO:
               glb_cdcritic = 40.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
               NEXT.
           END.

      IF   tel_nrdocmto = 0   THEN
           DO:
               glb_cdcritic = 22.
               NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanaut.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        LEAVE.   /* Volta pedir a opcao para o operador */

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
         ELSE
         IF   craplot.tplotmov <> 12   THEN
              glb_cdcritic = 132.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic > 0 THEN
           NEXT.

      ASSIGN tel_qtinfoln = craplot.qtinfoln
             tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb
             tel_vlinfocr = craplot.vlinfocr
             tel_vlcompdb = craplot.vlcompdb
             tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      DO aux_contador = 1 TO 10:

         FIND craplau WHERE craplau.cdcooper = glb_cdcooper   AND
                            craplau.dtmvtolt = tel_dtmvtolt   AND
                            craplau.cdagenci = tel_cdagenci   AND
                            craplau.cdbccxlt = tel_cdbccxlt   AND
                            craplau.nrdolote = tel_nrdolote   AND
                            craplau.nrdctabb = tel_nrdconta   AND
                            craplau.nrdocmto = tel_nrdocmto
                            USE-INDEX craplau1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craplau   THEN
              IF   LOCKED craplau   THEN
                   DO:
                       glb_cdcritic = 114.
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   glb_cdcritic = 90.
         ELSE
              glb_cdcritic = 0.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic > 0 THEN
           NEXT.

      ASSIGN aux_vllanaut = craplau.vllanaut
             aux_cdbccxpg = craplau.cdbccxpg
             aux_dtmvtopg = craplau.dtmvtopg
             tel_cdhistor = craplau.cdhistor
             tel_vllanaut = craplau.vllanaut
             tel_cdbccxpg = craplau.cdbccxpg
             tel_dtmvtopg = craplau.dtmvtopg
             tel_nrseqdig = craplau.nrseqdig.

      DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
              tel_qtcompln tel_vlcompdb tel_vlcompcr
              tel_qtdifeln tel_vldifedb tel_vldifecr
              tel_cdhistor tel_vllanaut tel_cdbccxpg
              tel_dtmvtopg tel_nrseqdig
              WITH FRAME f_lanaut.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         UPDATE tel_vllanaut tel_dtmvtopg tel_cdbccxpg WITH FRAME f_lanaut

         EDITING:

             READKEY.
             IF   FRAME-FIELD = "tel_vllanaut"   THEN
                  IF   LASTKEY =  KEYCODE(".")   THEN
                       APPLY 44.
                  ELSE
                       APPLY LASTKEY.
             ELSE
                  APPLY LASTKEY.

         END.  /*  Fim do EDITING  */

         FIND craphis NO-LOCK WHERE
                               craphis.cdcooper = craplau.cdcooper AND 
                               craphis.cdhistor = craplau.cdhistor NO-ERROR.

         IF   NOT AVAILABLE craphis   THEN
              DO:
                  glb_cdcritic = 93.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  NEXT-PROMPT tel_cdhistor WITH FRAME f_lanaut.
                  glb_cdcritic = 0.
                  NEXT.
              END.

         IF   tel_dtmvtopg > (glb_dtmvtolt + 30)   OR
             (craphis.indebfol = 1   AND   tel_dtmvtopg <> aux_dtultdia)  THEN
              DO:
                  glb_cdcritic = 013.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  NEXT-PROMPT tel_dtmvtopg WITH FRAME f_lanaut.
                  glb_cdcritic = 0.
                  NEXT.
              END.

         /*  Nao permite data de pagamento para 31/12  */

         IF   MONTH(tel_dtmvtopg) = 12   AND
              DAY(tel_dtmvtopg)   = 31   THEN
              DO:
                  glb_cdcritic = 013.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  NEXT-PROMPT tel_dtmvtopg WITH FRAME f_lanaut.
                  glb_cdcritic = 0.
                  NEXT.
              END.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           LEAVE.   /* Volta pedir a opcao para o operador */

      IF   craphis.inavisar = 1   THEN
           DO:
               DO WHILE TRUE:

                  IF   craphis.indebfol = 1   THEN
                       FIND crapavs WHERE
                            crapavs.cdcooper = glb_cdcooper       AND
                            crapavs.dtmvtolt = (IF  crapemp.tpconven = 1
                                                    THEN crapemp.dtavsemp
                                                    ELSE aux_dtmvtolt) AND
                            crapavs.cdempres = aux_cdempres       AND
                            crapavs.cdagenci = crapass.cdagenci   AND
                            crapavs.cdsecext = crapass.cdsecext   AND
                            crapavs.nrdconta = craplau.nrdconta   AND
                            crapavs.dtdebito = ?                  AND
                            crapavs.cdhistor = craplau.cdhistor   AND
                            crapavs.nrdocmto = craplau.nrdocmto
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                  ELSE
                       FIND crapavs WHERE
                            crapavs.cdcooper = glb_cdcooper       AND
                            crapavs.dtmvtolt = craplau.dtmvtolt   AND
                            crapavs.cdempres = 0                  AND
                            crapavs.cdagenci = crapass.cdagenci   AND
                            crapavs.cdsecext = crapass.cdsecext   AND
                            crapavs.nrdconta = craplau.nrdconta   AND
                            crapavs.dtdebito = craplau.dtmvtopg   AND
                            crapavs.cdhistor = craplau.cdhistor   AND
                            crapavs.nrdocmto = craplau.nrdocmto
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapavs   THEN
                       IF   LOCKED crapavs   THEN
                            DO:
                                PAUSE 2 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            glb_cdcritic = 448.
                  ELSE
                  IF   craphis.indebfol = 1    THEN
                       crapavs.vllanmto = tel_vllanaut.
                  ELSE
                       ASSIGN crapavs.vllanmto = tel_vllanaut
                              crapavs.dtdebito = tel_dtmvtopg.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   glb_cdcritic > 0   THEN
                    NEXT.
           END.

      IF   craphis.indebcre = "D"   THEN
           craplot.vlcompdb = craplot.vlcompdb - aux_vllanaut + tel_vllanaut.
      ELSE
      IF   craphis.indebcre = "C"   THEN
           craplot.vlcompcr = craplot.vlcompcr - aux_vllanaut + tel_vllanaut.

      ASSIGN craplau.vllanaut = tel_vllanaut
             craplau.cdbccxpg = tel_cdbccxpg
             craplau.dtmvtopg = tel_dtmvtopg

             tel_qtinfoln = craplot.qtinfoln
             tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb
             tel_vlinfocr = craplot.vlinfocr
             tel_vlcompdb = craplot.vlcompdb
             tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlcompcr.

   END.   /* Fim da transacao */

   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0   THEN
        DO:
            HIDE FRAME f_lanaut.
            HIDE FRAME f_regant.
            HIDE FRAME f_lanctos.
            HIDE FRAME f_moldura.
            glb_nmdatela = "LOTE".
            RETURN.
        END.

   ASSIGN tel_reganter[6] = tel_reganter[5]
          tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3]
          tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1]

          tel_reganter[1] = STRING(tel_cdhistor,"zzz9")               + "  " +
                            STRING(tel_nrdconta,"zzzz,zzz,9")         + " " +
                            STRING(tel_nrdocmto,"zz,zzz,zzz,zzz,zz9") + " " +
                            STRING(tel_vllanaut,"zzz,zzz,zzz,zz9.99") + "  " +
                            STRING(tel_dtmvtopg,"99/99/9999")         + "  " +
                            STRING(tel_cdbccxpg,"zz9")                + " " +
                            STRING(tel_nrseqdig,"zz,zz9")

          tel_cdhistor = 0
          tel_nrdconta = 0
          tel_nrdocmto = 0
          tel_vllanaut = 0
          tel_cdbccxpg = 0
          tel_dtmvtopg = ?
          tel_nrseqdig = craplot.nrseqdig + 1.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_cdhistor tel_nrdconta tel_nrdocmto
           tel_vllanaut tel_cdbccxpg tel_dtmvtopg
           tel_nrseqdig
           WITH FRAME f_lanaut.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3]
           tel_reganter[4] tel_reganter[5] tel_reganter[6]
           WITH FRAME f_regant.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

