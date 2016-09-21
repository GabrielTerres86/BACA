/* .............................................................................
   Programa: Includes/rmative.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Junho/2006

   Dados referentes ao programa:      Ultima Alteracao:   /  /    

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela BANCOS.
   
   Alteracao : 

............................................................................. */

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 10:
       
       FIND gnrativ WHERE gnrativ.cdrmativ = tel_cdrmativ
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE gnrativ   THEN
            IF   LOCKED gnrativ   THEN
                 DO:
                     glb_cdcritic = 77.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
           ELSE
                 DO:
                     glb_cdcritic = 878.
                     CLEAR FRAME f_ramos.
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
            MESSAGE glb_dscritic.
            DISPLAY tel_cdrmativ WITH FRAME f_ramos.
            NEXT.
        END.

   RUN pesq_setor_economico.

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

   DELETE gnrativ.
   CLEAR FRAME f_ramos NO-PAUSE.

END. /* Fim da transacao */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

/* .......................................................................... */
