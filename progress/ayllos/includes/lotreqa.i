/* .............................................................................

   Programa: Includes/lotreqa.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/92.                     Ultima atualizacao: 30/01/2006
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela lotreq.

   Alteracoes: 03/06/96 - Alterado para permitir entrar com uma das quantidades
                          zeradas (Deborah).

               02/04/98 - Tratamento para milenio e troca para V8 (Magui).

               16/11/2004 - Exibir o nome do operador (Evandro).

               08/12/2005 - Incluir tratamento para conta ITG (Magui) 

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
............................................................................. */

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 10:

       FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper         AND
                          craptrq.cdagelot = INPUT tel_cdagelot   AND
                          craptrq.tprequis = 0                    AND
                          craptrq.nrdolote = INPUT tel_nrdolote
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE  craptrq   THEN
            IF   LOCKED craptrq   THEN
                 DO:
                     glb_cdcritic = 84.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 60.
                     CLEAR FRAME f_lotreq NO-PAUSE.
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

            ASSIGN tel_cdagelot = aux_cdagelot
                   tel_nrdolote = aux_nrdolote.

            DISPLAY tel_cdagelot tel_nrdolote WITH FRAME f_lotreq.
            NEXT.
        END.

   ASSIGN tel_qtdiferq = craptrq.qtcomprq - craptrq.qtinforq
          tel_qtdifetl = craptrq.qtcomptl - craptrq.qtinfotl
          tel_qtdifeen = craptrq.qtcompen - craptrq.qtinfoen.

   FIND crapope WHERE crapope.cdcooper = glb_cdcooper     AND
                      crapope.cdoperad = craptrq.cdoperad NO-LOCK NO-ERROR.

   IF   AVAILABLE crapope   THEN
        tel_nmoperad = crapope.nmoperad.

   DISPLAY craptrq.qtinforq craptrq.qtcomprq tel_qtdiferq
           craptrq.qtinfotl craptrq.qtcomptl tel_qtdifetl
           craptrq.qtinfoen craptrq.qtcompen tel_qtdifeen
           tel_nmoperad     WITH FRAME f_lotreq.

   DO WHILE TRUE:

      SET craptrq.qtinforq craptrq.qtinfotl craptrq.qtinfoen
          WITH FRAME f_lotreq.

      IF   INPUT craptrq.qtinforq = 0   AND
           INPUT craptrq.qtinfotl = 0   THEN
           DO:
               glb_cdcritic = 26.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               NEXT-PROMPT craptrq.qtinforq WITH FRAME f_lotreq.
               NEXT.
           END.

      LEAVE.

   END.

END.   /* Fim da transacao */

RELEASE craptrq.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_lotreq NO-PAUSE.

/* .......................................................................... */
