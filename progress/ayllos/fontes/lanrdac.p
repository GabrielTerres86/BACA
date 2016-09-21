/* .............................................................................

   Programa: Fontes/lanrdac.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/94.                    Ultima atualizacao: 01/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela lanrda.

   Alteracoes: 21/11/96 - Alterado para tratar tpaplica (Odair).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
             20/04/2004 - Tratar modo de impressao do extrato (Margarete).

             02/09/2004 - Incluido Flag Conta Investimento(Mirtes).
             
             09/09/2004 - Incluido Flag Debitar Conta Investimento (Evandro).
             
             01/02/2006 - Unificacao dos Bancos - SQLWorks - Andre
............................................................................. */

{ includes/var_online.i }

{ includes/var_lanrda.i }

ASSIGN tel_nrdconta = 0
       tel_nrdocmto = 0
       tel_flgctain = no
       tel_flgdebci = no
       tel_vllanmto = 0
       tel_tpemiext = 0
       tel_nrseqdig = 1.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lanrda.
               CLEAR FRAME f_lanctos ALL NO-PAUSE.
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote
                       WITH FRAME f_lanrda.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_nrdconta tel_nrdocmto WITH FRAME f_lanrda.

      ASSIGN glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0.

      IF   tel_nrdconta = 0   THEN
           LEAVE.

      RUN fontes/digfun.p.

      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper    AND
                         crapass.nrdconta = tel_nrdconta    NO-LOCK NO-ERROR.

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

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   /*   F4 OU FIM   */
        RETURN.  /* Volta pedir a opcao para o operador */

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                      craplot.dtmvtolt = tel_dtmvtolt   AND
                      craplot.cdagenci = tel_cdagenci   AND
                      craplot.cdbccxlt = tel_cdbccxlt   AND
                      craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craplot   THEN
        DO:
            glb_cdcritic = 60.
            NEXT-PROMPT tel_nrdolote WITH FRAME f_lanrda.
        END.

   ELSE
        IF   craplot.tplotmov <> 10   THEN
             glb_cdcritic = 100.

   IF   glb_cdcritic > 0 THEN
        NEXT.

   ASSIGN tel_qtinfoln = craplot.qtinfoln
          tel_qtcompln = craplot.qtcompln
          tel_vlinfodb = craplot.vlinfodb
          tel_vlcompdb = craplot.vlcompdb
          tel_vlinfocr = craplot.vlinfocr
          tel_vlcompcr = craplot.vlcompcr
          tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
          tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
          tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

   IF   tel_nrdconta = 0   THEN
        DO:
            ASSIGN aux_flgerros = FALSE
                   aux_flgretor = FALSE
                   aux_contador = 0.

            /* SUBSTITUICAO DO PUT SCREEN */

            CLEAR FRAME f_lanrda.

            HIDE FRAME f_regant.

            CLEAR FRAME f_lanctos ALL NO-PAUSE.

            /****************/

            DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                    tel_cdbccxlt tel_nrdolote
                    tel_qtinfoln tel_vlinfodb tel_vlinfocr
                    tel_qtcompln tel_vlcompdb tel_vlcompcr
                    tel_qtdifeln tel_vldifedb tel_vldifecr
                    WITH FRAME f_lanrda.

            IF   craplot.qtcompln  = 0 THEN
                 DO:
                    glb_cdcritic = 11.
                    HIDE FRAME f_regant.
                    RETURN.
                 END.

            FOR EACH craplap WHERE craplap.cdcooper = glb_cdcooper   AND
                                   craplap.dtmvtolt = tel_dtmvtolt   AND
                                   craplap.cdagenci = tel_cdagenci   AND
                                   craplap.cdbccxlt = tel_cdbccxlt   AND
                                   craplap.nrdolote = tel_nrdolote   NO-LOCK
                                   USE-INDEX craplap3:

                ASSIGN aux_contador = aux_contador + 1.

                IF   aux_contador = 1   THEN
                     IF   aux_flgretor   THEN
                          DO:
                              PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                              CLEAR FRAME f_lanctos ALL NO-PAUSE.
                          END.
                     ELSE
                          aux_flgretor = TRUE.

                PAUSE (0).

                FIND craprda WHERE craprda.cdcooper = glb_cdcooper          AND
                                   craprda.dtmvtolt = tel_dtmvtolt          AND
                                   craprda.cdagenci = tel_cdagenci          AND
                                   craprda.cdbccxlt = tel_cdbccxlt          AND
                                   craprda.nrdolote = tel_nrdolote          AND
                                   craprda.nrdconta = craplap.nrdconta      AND
                                   craprda.nraplica = INT(craplap.nrdocmto)
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE craprda THEN
                     DO:
                         glb_cdcritic = 518.
                         RUN fontes/critic.p.
                         MESSAGE glb_dscritic.
                         PAUSE.
                         RETURN.
                     END.

                IF  craprda.flgctain = YES THEN
                    ASSIGN aux_flgctain = "S".
                ELSE
                    ASSIGN aux_flgctain = "N".
                    
                DISPLAY craplap.nrdconta craprda.tpaplica
                        aux_flgctain
                        craprda.flgdebci
                        craplap.nrdocmto
                        craplap.vllanmto craprda.tpemiext craplap.nrseqdig
                        WITH FRAME f_lanctos.

                IF   aux_contador = 6   THEN
                     aux_contador = 0.
                ELSE
                     DOWN WITH FRAME f_lanctos.

            END.  /*  Fim do FOR EACH  */

            NEXT.
        END.

   FIND craplap WHERE craplap.cdcooper = glb_cdcooper   AND
                      craplap.dtmvtolt = tel_dtmvtolt   AND
                      craplap.cdagenci = tel_cdagenci   AND
                      craplap.cdbccxlt = tel_cdbccxlt   AND
                      craplap.nrdolote = tel_nrdolote   AND
                      craplap.nrdconta = tel_nrdconta   AND
                      craplap.nrdocmto = tel_nrdocmto   NO-LOCK
                      USE-INDEX craplap1 NO-ERROR.

   IF   NOT AVAILABLE craplap   THEN
        DO:
            glb_cdcritic = 90.
            NEXT.
        END.
                                                         
   FIND craprda WHERE craprda.cdcooper = glb_cdcooper          AND
                      craprda.dtmvtolt = tel_dtmvtolt          AND
                      craprda.cdagenci = tel_cdagenci          AND
                      craprda.cdbccxlt = tel_cdbccxlt          AND
                      craprda.nrdolote = tel_nrdolote          AND
                      craprda.nrdconta = craplap.nrdconta      AND
                      craprda.nraplica = INT(craplap.nrdocmto) NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craprda THEN
        DO:
            glb_cdcritic = 518.
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            PAUSE.
            RETURN.
        END.

   ASSIGN tel_vllanmto = craplap.vllanmto
          tel_nrseqdig = craplap.nrseqdig
          tel_tpaplica = craprda.tpaplica
          tel_flgctain = craprda.flgctain
          tel_flgdebci = craprda.flgdebci
          tel_tpemiext = craprda.tpemiext.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_tpaplica tel_flgctain tel_flgdebci
           tel_vllanmto tel_nrseqdig
           WITH FRAME f_lanrda.

   HIDE FRAME f_lanctos NO-PAUSE.
   HIDE FRAME f_regant  NO-PAUSE.


 END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
