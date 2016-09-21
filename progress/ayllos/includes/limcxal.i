/* .............................................................................

   Programa: Includes/limcxal.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Abril/2004                          Ultima atualizacao: 27/01/2006
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela LIMCXA.

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

............................................................................. */

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 10:

       FIND crapope WHERE crapope.cdcooper = glb_cdcooper   AND
                          crapope.cdoperad = tel_cdoperad
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE crapope   THEN
            IF   LOCKED crapope   THEN
                 DO:
                     glb_cdcritic = 67.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 67.
                     CLEAR FRAME f_limcxa.
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
            DISPLAY tel_cdoperad WITH FRAME f_limcxa.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   ASSIGN tel_nmoperad = crapope.nmoperad
          tel_vlpagchq = crapope.vlpagchq.

   DISPLAY tel_nmoperad tel_vlpagchq WITH FRAME f_limcxa.

   DO WHILE TRUE:

            SET tel_vlpagchq WITH FRAME f_limcxa.
            ASSIGN crapope.vlpagchq = tel_vlpagchq.
            LEAVE.

   END.

END. /* Fim da transacao */

RELEASE crapope.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_limcxa NO-PAUSE.

/* .......................................................................... */

