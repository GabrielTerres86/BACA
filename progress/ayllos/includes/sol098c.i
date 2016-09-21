/* .............................................................................

   Programa: Includes/sol098c.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo
   Data    : Marco/05                               Ultima Alteracao:02/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela SOL098.

   Alteracoes: 02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

............................................................................. */

FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                   crapsol.nrsolici = aux_nrsolici   AND
                   crapsol.dtrefere = glb_dtmvtolt   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapsol   THEN
     DO:
         glb_cdcritic = 115.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_sol098.
         NEXT.
     END.

tel_nrdevias = crapsol.nrdevias.

DISPLAY tel_nrdevias WITH FRAME f_sol098.

/* .......................................................................... */
