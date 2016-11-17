/* .............................................................................

   Programa: Includes/sol020c.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                        Ultima Atualizacaco: 02/02/2006 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela SOL010.

   Alteracoes: Unificacao dos Bancos - SQLWorks - Fernando.
  
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
         CLEAR FRAME f_sol020.

         tel_nrseqsol = aux_nrseqsol.

         DISPLAY tel_nrseqsol WITH FRAME f_sol020.
         NEXT.
     END.

tel_nrdevias = crapsol.nrdevias.

DISPLAY tel_nrdevias WITH FRAME f_sol020.

/* .......................................................................... */

