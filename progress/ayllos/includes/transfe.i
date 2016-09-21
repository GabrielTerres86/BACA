/* .............................................................................

   Programa: Includes/transfe.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Outubro/91                     Ultima Atualizacacao:02/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela TRANSF.

   Alteracoes: 02/06/2000 - Alterar prompt-for por update (Odair)
    
               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
............................................................................. */

ASSIGN tel_nrdconta = 0   tel_nmprimtl = ""
       tel_nrsconta = 0   tel_nrmatric = 0
       tel_tptransa = 0   tel_dstransa = ""
       tel_sttransa = "".

DO WHILE TRUE:

   REPEAT ON ENDKEY UNDO, LEAVE:

          UPDATE tel_nrdconta tel_nrsconta
                     tel_tptransa WITH FRAME f_transf.
          LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        LEAVE.

   glb_nrcalcul = tel_nrdconta.

   RUN fontes/digfun.p.
   IF   NOT glb_stsnrcal THEN
        DO:
            glb_cdcritic = 8.
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_transf NO-PAUSE.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.
            NEXT.
        END.

   glb_nrcalcul = tel_nrsconta.
   RUN fontes/digfun.p.
   IF   NOT glb_stsnrcal THEN
        DO:
            glb_cdcritic = 8.
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_transf NO-PAUSE.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrsconta WITH FRAME f_transf.
            NEXT.
        END.

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                      crapass.nrdconta = tel_nrdconta
                      NO-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE crapass   THEN
        DO:
            glb_cdcritic = 009.
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_transf NO-PAUSE.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.
            NEXT.
        END.

   ASSIGN tel_nmprimtl = crapass.nmprimtl
          tel_nrmatric = crapass.nrmatric.

   DO TRANSACTION:

      DO  aux_contador = 1 TO 10:

          FIND craptrf WHERE craptrf.cdcooper = glb_cdcooper AND 
                             craptrf.nrdconta = tel_nrdconta AND
                             craptrf.tptransa = tel_tptransa AND
                             craptrf.nrsconta = tel_nrsconta
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE craptrf THEN
               IF   LOCKED craptrf   THEN
                    DO:
                        glb_cdcritic = 126.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 124.
                        CLEAR FRAME f_transf.
                        LEAVE.
                    END.
          ELSE
               DO:
                   aux_contador = 0.
                   LEAVE.
               END.
      END.

      IF   aux_contador <> 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_transf NO-PAUSE.
               MESSAGE glb_dscritic.
               NEXT.
           END.

      IF   NOT CAN-DO("1,3",STRING(craptrf.insittrs))   THEN
           DO:
               glb_cdcritic = 051.
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_transf NO-PAUSE.
               MESSAGE glb_dscritic.
               NEXT.
           END.

      ASSIGN tel_nrsconta = craptrf.nrsconta
             tel_tptransa = craptrf.tptransa
             tel_dstransa = IF craptrf.tptransa = 1
                               THEN " - TRANSFERENCIA"
                               ELSE " - DUPLICACAO"

             tel_sttransa = IF craptrf.insittrs = 1
                               THEN "A FAZER"
                               ELSE "NAO PROCESSADA".

      DISPLAY glb_cddopcao tel_nrdconta tel_nmprimtl
              tel_nrsconta tel_nrmatric tel_tptransa
              tel_dstransa tel_sttransa WITH FRAME f_transf.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         ASSIGN aux_confirma = "N"
                glb_cdcritic = 78.

         RUN fontes/critic.p.
         BELL.
         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         LEAVE.

      END.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
           aux_confirma <> "S" THEN
           DO:
               glb_cdcritic = 79.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               NEXT.
           END.

      DELETE craptrf.

   END.   /* Fim da transacao */

   CLEAR FRAME f_transf NO-PAUSE.
   LEAVE.

END.

/* .......................................................................... */
