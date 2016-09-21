/* .............................................................................

   Programa: Fontes/lanrdae.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/94.                    Ultima atualizacao: 01/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela lanrda.

   Alteracoes: 21/11/96 - Alterado para tratar tpaplica (Odair)

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
             20/04/2004 - Tratar modo de impressao do extrato (Margarete).

             02/09/2004 - Incluido Flag Conta Investimento(Mirtes).
             
             09/09/2004 - Incluido Flag Debitar Conta Investimento (Evandro).
             
             01/02/2006 - Unificacao dos Bancos - SQLWorks - Andre
............................................................................ */

{ includes/var_online.i }

{ includes/var_lanrda.i }

ASSIGN tel_nrdconta = 0
       tel_nrdocmto = 0
       tel_flgctain = no
       tel_flgdebci = no
       tel_vllanmto = 0
       tel_tpemiext = 0
       tel_nrseqdig = 0
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      /* SUBSTITUICAO DO PUT SCREEN */

      DISP "" @ tel_tpaplica
           "" @ tel_vllanmto
           "" @ tel_tpemiext
           "" @ tel_nrseqdig
           WITH FRAME f_lanrda.

      /*************/

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

      IF   tel_nrdocmto = 0   THEN
           DO:
               glb_cdcritic = 425.
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

      DO aux_contador = 1 TO 10:

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
                   glb_cdcritic = 90.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic > 0    THEN
           NEXT.

      ASSIGN   tel_vllanmto = craprda.vlaplica
               tel_tpemiext = craprda.tpemiext
               tel_nrseqdig = craplap.nrseqdig
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

      ASSIGN craplot.vlcompcr = craplot.vlcompcr - craprda.vlaplica
             craplot.qtcompln = craplot.qtcompln - 1

             tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
             tel_nrseqdig = 0
             tel_nrdconta = 0
             tel_nrdocmto = 0
             tel_tpemiext = 0
             tel_vllanmto = 0
             tel_tpaplica = 0
             tel_flgctain = no
             tel_flgdebci = no.

      DELETE craprda.
      DELETE craplap.

   END.   /* Fim da transacao */

   RELEASE craplot.

   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  AND  tel_vldifecr = 0   THEN
        DO:
            glb_nmdatela = "LOTE".
            RETURN.                        /* Volta ao lanctr.p */
        END.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_nrdconta tel_tpaplica tel_flgctain
           tel_flgdebci tel_nrdocmto
           tel_vllanmto tel_tpemiext tel_nrseqdig     WITH FRAME f_lanrda.


END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
