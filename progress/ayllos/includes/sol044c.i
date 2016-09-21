/* .............................................................................

   Programa: Includes/sol044c.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94                     Ultima Atualizacacao: 02/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela SOL044.

   Alteracoes: 02/02/2006 - Unificacao dos bancos - SLQWorks - Fernando.

............................................................................. */

FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                   crapsol.nrsolici = aux_nrsolici   AND
                   crapsol.dtrefere = glb_dtmvtolt   AND
                   crapsol.nrseqsol = tel_nrseqsol   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapsol   THEN
     DO:
         glb_cdcritic = 115.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_sol044.

         tel_nrseqsol = aux_nrseqsol.

         DISPLAY tel_nrseqsol WITH FRAME f_sol044.
         NEXT.
     END.

ASSIGN tel_tprelato = INTEGER(SUBSTRING(crapsol.dsparame,1,1))
       tel_nrdevias = crapsol.nrdevias.

DISPLAY tel_tprelato tel_nrdevias WITH FRAME f_sol044.

/* .......................................................................... */
