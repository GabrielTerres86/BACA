/* .............................................................................

   Programa: Fontes/moedasc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                         Ultima atualizacao:31/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela MOEDAS.

   Alteracao : 31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
............................................................................. */

FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper   AND
                   crapmfx.dtmvtolt = tel_dtmvtolt   AND
                   crapmfx.tpmoefix = tel_tpmoefix
                   NO-LOCK NO-ERROR.

IF   AVAILABLE crapmfx   THEN
     DO:
         tel_vlmoefix = crapmfx.vlmoefix.
         DISPLAY tel_vlmoefix WITH FRAME f_moedas.
     END.
ELSE
     DO:
         glb_cdcritic = 211.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_moedas.
         NEXT.
     END.

/* .......................................................................... */

