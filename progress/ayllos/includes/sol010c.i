/* .............................................................................

   Programa: Includes/sol010c.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                         Ultima atualizacao: 01/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela SOL010.

   Alteracoes: 01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
............................................................................. */

FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper      AND
                   crapsol.nrsolici = aux_nrsolici      AND
                   crapsol.dtrefere = glb_dtmvtolt      AND
                   crapsol.nrseqsol = tel_nrseqsol      NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapsol   THEN
     DO:
         glb_cdcritic = 115.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_sol010.

         tel_nrseqsol = aux_nrseqsol.

         DISPLAY tel_nrseqsol WITH FRAME f_sol010.
         NEXT.
     END.

ASSIGN tel_tprelato = INTEGER(SUBSTRING(crapsol.dsparame,1,1))
       tel_indclass = INTEGER(SUBSTRING(crapsol.dsparame,2,1))
       tel_inoqlist = INTEGER(SUBSTRING(crapsol.dsparame,3,1))
       tel_nrdevias = crapsol.nrdevias.

DISPLAY tel_tprelato tel_indclass tel_inoqlist tel_nrdevias
        WITH FRAME f_sol010.

/* .......................................................................... */

