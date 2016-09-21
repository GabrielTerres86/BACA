/* .............................................................................

   Programa: Fontes/lanempc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 30/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela lanemp.

   Alteracoes: 01/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               30/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
............................................................................. */

{ includes/var_online.i }
{ includes/var_lanemp.i }

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lanemp.
               CLEAR FRAME f_lanctos ALL NO-PAUSE.
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote
                       WITH FRAME f_lanemp.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_nrdconta tel_nrdocmto WITH FRAME f_lanemp.

      ASSIGN glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0.

      IF   tel_nrdconta = 0  THEN
           LEAVE.

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

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                         crapass.nrdconta = tel_nrdconta     NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapass   THEN
           DO:
               glb_cdcritic = 9.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanemp.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        RETURN.  /* Volta pedir a opcao para o operador */

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                      craplot.dtmvtolt = tel_dtmvtolt   AND
                      craplot.cdagenci = tel_cdagenci   AND
                      craplot.cdbccxlt = tel_cdbccxlt   AND
                      craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craplot   THEN
        glb_cdcritic = 60.
   ELSE
        IF   craplot.tplotmov <> 5   THEN
             glb_cdcritic = 213.

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
                   aux_regexist = FALSE
                   aux_contador = 0.

            /* SUBSTITUICAO AO PUT SCREEN */

            CLEAR FRAME f_lanemp.

            HIDE FRAME f_regant.

            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            /************/

            DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                    tel_cdbccxlt tel_nrdolote
                    tel_qtinfoln tel_vlinfodb tel_vlinfocr
                    tel_qtcompln tel_vlcompdb tel_vlcompcr
                    tel_qtdifeln tel_vldifedb tel_vldifecr
                    WITH FRAME f_lanemp.

            /**********
            PUT SCREEN ROW 14 COLUMN 6 FILL(" ",70).
            HIDE FRAME f_regant.

            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            ***********/

            FOR EACH craplem WHERE craplem.cdcooper = glb_cdcooper   AND
                                   craplem.dtmvtolt = tel_dtmvtolt   AND
                                   craplem.cdagenci = tel_cdagenci   AND
                                   craplem.cdbccxlt = tel_cdbccxlt   AND
                                   craplem.nrdolote = tel_nrdolote   NO-LOCK
                                   USE-INDEX craplem3:

                ASSIGN aux_regexist = TRUE
                       aux_contador = aux_contador + 1.

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

                DISPLAY craplem.cdhistor craplem.nrdconta
                        craplem.nrctremp craplem.nrdocmto
                        craplem.vllanmto craplem.nrseqdig
                        WITH FRAME f_lanctos.

                IF   aux_contador = 6   THEN
                     aux_contador = 0.
                ELSE
                     DOWN WITH FRAME f_lanctos.

            END.  /*  Fim do FOR EACH  */

            IF   NOT aux_regexist   THEN
                 glb_cdcritic = 11.

            NEXT.
        END.

   FIND craplem WHERE craplem.cdcooper = glb_cdcooper   AND
                      craplem.dtmvtolt = tel_dtmvtolt   AND
                      craplem.cdagenci = tel_cdagenci   AND
                      craplem.cdbccxlt = tel_cdbccxlt   AND
                      craplem.nrdolote = tel_nrdolote   AND
                      craplem.nrdconta = tel_nrdconta   AND
                      craplem.nrdocmto = tel_nrdocmto   NO-LOCK
                      USE-INDEX craplem1 NO-ERROR.

   IF   NOT AVAILABLE craplem   THEN
        DO:
            glb_cdcritic = 90.
            NEXT.
        END.

   ASSIGN tel_cdhistor = craplem.cdhistor
          tel_nrctremp = craplem.nrctremp
          tel_vllanmto = craplem.vllanmto
          tel_nrseqdig = craplem.nrseqdig.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_cdhistor tel_nrdconta tel_nrctremp
           tel_nrdocmto tel_vllanmto tel_nrseqdig
           WITH FRAME f_lanemp.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
