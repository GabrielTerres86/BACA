/* .............................................................................

   Programa: Fontes/lanaut.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson                       Ultima atualizacao: 24/01/2006
   Data    : Outubro/91.

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANAUT - Lancamentos automaticos

   Alteracoes: 12/08/96 - Alterado para tratar historico com debito na folha
                          de pagamento (Edson).

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               21/09/2001 - Incluir opcao R (Margarete).
               
               24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
............................................................................. */

{ includes/var_online.i }

{ includes/var_lanaut.i }

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "I"
       tel_cdhistor = 0
       tel_nrdconta = 0
       tel_nrdocmto = 0
       tel_vllanaut = 0
       tel_cdbccxpg = 0
       tel_dtmvtopg = ?
       tel_dtmvtolt = glb_dtmvtolt

       glb_cdcritic = 0

       aux_flgretor = FALSE

       aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                       DAY(DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4))

       aux_dtmvtolt = aux_dtultdia.

       DO WHILE TRUE:

          aux_dtmvtolt = aux_dtmvtolt + 1.

          IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt))) OR
              CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND   
                                     crapfer.dtferiad = aux_dtmvtolt) THEN
              NEXT.

          LEAVE.

       END.  /* DO WHILE TRUE */

IF   glb_nmtelant = "LOTE"   THEN
     ASSIGN tel_cdagenci = glb_cdagenci
            tel_cdbccxlt = glb_cdbccxlt
            tel_nrdolote = glb_nrdolote.

PAUSE(0).

DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_cdbccxlt tel_nrdolote
        WITH FRAME f_lanaut.

CLEAR FRAME f_regant NO-PAUSE.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   ASSIGN tel_dtmvtolt = glb_dtmvtolt.
   DISPLAY tel_dtmvtolt WITH FRAME f_lanaut.
   PAUSE(0).
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   NOT aux_flgretor   THEN
           IF   tel_cdagenci <> 0   AND
                tel_cdbccxlt <> 0   AND
                tel_nrdolote <> 0   THEN
                LEAVE.

      UPDATE glb_cddopcao WITH FRAME f_lanaut.

      IF   aux_cddopcao <> glb_cddopcao   THEN
           DO:
               { includes/acesso.i }
               aux_cddopcao = glb_cddopcao.
           END.
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         IF   glb_cddopcao = "R"   THEN
              DO:
                  UPDATE tel_dtmvtolt WITH FRAME f_lanaut.

                  IF   tel_dtmvtolt >= glb_dtmvtolt  OR
                       tel_dtmvtolt  = ?             THEN
                       DO:
                           ASSIGN glb_cdcritic = 13.
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                           NEXT.
                       END.
              END.
     
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE tel_cdagenci WITH FRAME f_lanaut.
      
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_cdbccxlt WITH FRAME f_lanaut.

               IF   glb_cddopcao = "R"   AND
                    tel_cdbccxlt <> 911  THEN
                    DO:
                        ASSIGN glb_cdcritic = 132.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic "Deve ser 911.".
                        glb_cdcritic = 0.
                        NEXT.
                    END.
         
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                  UPDATE tel_nrdolote WITH FRAME f_lanaut.

                  LEAVE.
               
               END.  /*  Fim do DO WHILE TRUE  */
            
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN 
                    NEXT.
 
               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */
       
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.
      
            LEAVE.
      
         END.  /*  Fim do DO WHILE TRUE  */
      
         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
              IF   glb_cddopcao <> "R"   THEN
                   LEAVE.
              ELSE
                   NEXT.

         LEAVE.

      END.  /*   Fim do DO WHILE TRUE  */

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           NEXT.

      LEAVE.
      
   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "LANAUT"   THEN
                 DO:
                     HIDE FRAME f_lanaut.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   ASSIGN aux_cdagenci = tel_cdagenci
          aux_cdbccxlt = tel_cdbccxlt
          aux_nrdolote = tel_nrdolote
          aux_flgretor = TRUE.

   IF   glb_cddopcao = "A" THEN
        DO:
            { includes/lanauta.i }
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            { includes/lanautc.i }
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            { includes/lanaute.i }
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            { includes/lanauti.i }
        END.
   ELSE
   IF   glb_cddopcao = "R"   THEN
        DO:
            { includes/lanautr.i } 
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

