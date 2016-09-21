/* .............................................................................

   Programa: Includes/lanautc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/91.                         Ultima atualizacao: 16/03/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela LANAUT.

   Alteracoes: 21/06/95 - Alterado para as novas rotinas da tela (Edson).

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               16/03/2010 - Incluir <F7> para o campo historico (Gabriel).
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
                       tel_nrdconta tel_nrdocmto WITH FRAME f_lanaut.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_cdhistor 
             tel_nrdconta 
             tel_nrdocmto WITH FRAME f_lanaut

      EDITING:

        READKEY.

        IF   FRAME-FIELD = "tel_cdhistor"   THEN
             DO:
                 /* <F7> do historico */
                 IF   LASTKEY = KEYCODE("F7")   THEN
                      DO:
                          RUN fontes/zoom_historicos.p (INPUT glb_cdcooper,
                                                        INPUT TRUE,
                                                        INPUT 0,
                                                        OUTPUT tel_cdhistor).

                          DISPLAY tel_cdhistor 
                                  WITH FRAME f_lanaut.
                      END.
                 ELSE
                      APPLY LASTKEY.
             END.
        ELSE
             APPLY LASTKEY.
      END.
             
      ASSIGN glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0.

      IF   tel_nrdconta = 0  THEN
           LEAVE.

      RUN fontes/digfun.p.
      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
               NEXT.
           END.

      IF   tel_nrdocmto = 0   THEN
           DO:
               glb_cdcritic = 22.
               NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanaut.
               NEXT.
           END.

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                         crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapass   THEN
           DO:
               glb_cdcritic = 9.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        LEAVE.   /* Volta pedir a opcao para o operador */

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                      craplot.dtmvtolt = tel_dtmvtolt   AND
                      craplot.cdagenci = tel_cdagenci   AND
                      craplot.cdbccxlt = tel_cdbccxlt   AND
                      craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craplot   THEN
        glb_cdcritic = 60.
   ELSE
   IF   craplot.tplotmov <> 12   THEN
        glb_cdcritic = 132.

   IF   glb_cdcritic > 0 THEN
        NEXT.

   IF   tel_nrdconta = 0   THEN
        DO:
            ASSIGN aux_flgerros = FALSE
                   aux_flgretor = FALSE
                   aux_regexist = FALSE
                   aux_contador = 0

                   tel_qtinfoln = craplot.qtinfoln
                   tel_qtcompln = craplot.qtcompln
                   tel_vlinfodb = craplot.vlinfodb
                   tel_vlcompdb = craplot.vlcompdb
                   tel_vlinfocr = craplot.vlinfocr
                   tel_vlcompcr = craplot.vlcompcr
                   tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                   tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
                   tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

            /* SUBSTITUICAO AO PUT SCREEN */
            CLEAR FRAME f_lanaut.
            HIDE FRAME f_regant.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            /****/

            DISPLAY glb_cddopcao tel_dtmvtolt
                    tel_cdagenci tel_cdbccxlt tel_nrdolote
                    tel_qtinfoln tel_vlinfodb tel_vlinfocr
                    tel_qtcompln tel_vlcompdb tel_vlcompcr
                    tel_qtdifeln tel_vldifedb tel_vldifecr
                    WITH FRAME f_lanaut.

            /****
            PUT SCREEN ROW 14 COLUMN 3 FILL(" ",74).
            HIDE FRAME f_regant.

            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            ******/
            FOR EACH craplau WHERE craplau.cdcooper = glb_cdcooper   AND
                                   craplau.dtmvtolt = tel_dtmvtolt   AND
                                   craplau.cdagenci = tel_cdagenci   AND
                                   craplau.cdbccxlt = tel_cdbccxlt   AND
                                   craplau.nrdolote = tel_nrdolote   and
                                   craplau.cdhistor >= tel_cdhistor
                                   NO-LOCK USE-INDEX craplau3:

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
                DISPLAY craplau.cdhistor craplau.nrdconta craplau.nrdocmto
                        craplau.vllanaut craplau.cdbccxpg craplau.dtmvtopg
                        craplau.nrseqdig
                        WITH FRAME f_lanctos.

                IF   aux_contador = 6   THEN
                     aux_contador = 0.
                ELSE
                     DOWN WITH FRAME f_lanctos.

            END.  /*  Fim do FOR EACH  */

            IF   NOT aux_regexist   THEN
                 glb_cdcritic = 11.

            IF   glb_cdcritic > 0   THEN
                 NEXT.

            NEXT.
        END.

   FIND craplau WHERE craplau.cdcooper = glb_cdcooper   AND
                      craplau.dtmvtolt = tel_dtmvtolt   AND
                      craplau.cdagenci = tel_cdagenci   AND
                      craplau.cdbccxlt = tel_cdbccxlt   AND
                      craplau.nrdolote = tel_nrdolote   AND
                      craplau.nrdctabb = tel_nrdconta   AND
                      craplau.nrdocmto = tel_nrdocmto
                      USE-INDEX craplau1 NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craplau   THEN
        DO:
            glb_cdcritic = 90.
            NEXT.
        END.

   ASSIGN tel_qtinfoln = craplot.qtinfoln
          tel_qtcompln = craplot.qtcompln
          tel_vlinfodb = craplot.vlinfodb
          tel_vlcompdb = craplot.vlcompdb
          tel_vlinfocr = craplot.vlinfocr
          tel_vlcompcr = craplot.vlcompcr
          tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
          tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
          tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr

          tel_cdhistor = craplau.cdhistor
          tel_vllanaut = craplau.vllanaut
          tel_cdbccxpg = craplau.cdbccxpg
          tel_dtmvtopg = craplau.dtmvtopg
          tel_nrseqdig = craplau.nrseqdig.

   DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
           tel_cdbccxlt tel_nrdolote tel_qtinfoln
           tel_qtcompln tel_qtdifeln tel_vlinfodb
           tel_vlcompdb tel_vldifedb
           tel_cdhistor tel_nrdconta tel_nrdocmto
           tel_vllanaut tel_cdbccxpg tel_dtmvtopg tel_nrseqdig
           WITH FRAME f_lanaut.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

