/* .............................................................................

   Programa: Fontes/sol001c.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Outubro/91                           Ultima atualizacao: 01/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela SOL001.

   Alteracoes: 01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
............................................................................. */

FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                   crapsol.nrsolici = tel_nrsolici   AND
                   crapsol.dtrefere = glb_dtmvtolt   AND
                   crapsol.nrseqsol = tel_nrseqsol   NO-LOCK NO-ERROR NO-WAIT.

IF   AVAILABLE crapsol   THEN
     DISPLAY tel_nrsolici     tel_nrseqsol     crapsol.cdempres
             crapsol.nrdevias crapsol.dsparame
             WITH FRAME f_sol001.
ELSE
     DO:
         glb_cdcritic = 115.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_sol001.

         ASSIGN tel_nrsolici = INTEGER(SUBSTRING(aux_dsacesso,1,3))
                tel_nrseqsol = INTEGER(SUBSTRING(aux_dsacesso,4,2)).

         DISPLAY tel_nrsolici tel_nrseqsol
                 WITH FRAME f_sol001.
         NEXT.
     END.

/* .......................................................................... */

