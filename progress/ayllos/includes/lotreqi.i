/* .............................................................................

   Programa: Includes/lotreqi.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/92.                     Ultima atualizacao: 12/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela LOTREQ.

   Alteracoes: 03/06/96 - Alterado para permitir entrar com uma das quantidades
                          zeradas (Deborah).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               12/11/2004 - Incluido o Cod. do operador - cdoperad - (Evandro).
               
               06/07/2005 - Alimentado campo cdcooper da tabela craptrq (Diego).

               08/12/2005 - Incluir tratamento para conta ITG (Magui).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
............................................................................. */

FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper         AND
                   craptrq.cdagelot = INPUT tel_cdagelot   AND
                   craptrq.tprequis = 0                    AND
                   craptrq.nrdolote = INPUT tel_nrdolote NO-LOCK NO-ERROR.

IF   AVAILABLE craptrq   THEN
     DO:
         glb_cdcritic = 59.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_lotreq NO-PAUSE.
         ASSIGN tel_cdagelot = aux_cdagelot
                tel_nrdolote = aux_nrdolote.

         DISPLAY tel_cdagelot tel_nrdolote WITH FRAME f_lotreq.
         NEXT.
     END.

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   CREATE craptrq.
   ASSIGN craptrq.cdagelot = INPUT tel_cdagelot
          craptrq.nrdolote = INPUT tel_nrdolote
          craptrq.tprequis = 0
          craptrq.cdoperad = glb_cdoperad
          craptrq.cdcooper = glb_cdcooper.
   VALIDATE craptrq.
   DO WHILE TRUE:

      SET  craptrq.qtinforq craptrq.qtinfotl craptrq.qtinfoen
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

glb_nmdatela = "LANREQ".

HIDE FRAME f_lotreq.
RETURN.

/* .......................................................................... */

