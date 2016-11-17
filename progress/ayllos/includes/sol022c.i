/* .............................................................................

   Programa: Includes/sol022c.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                         Ultima Alteracacao: 01/09/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela SOL022.

   Alteracoes: Unificaco dos Bancos - SQLWorks - Fernando. 
                
               01/09/2008 - Alteracao cdempres (Kbase IT).

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
         CLEAR FRAME f_sol022.

         tel_nrseqsol = aux_nrseqsol.

         DISPLAY tel_nrseqsol WITH FRAME f_sol022.
         NEXT.
     END.

FIND crapemp WHERE 
     crapemp.cdcooper = glb_cdcooper                             AND
     crapemp.cdempres = INTEGER(SUBSTRING(crapsol.dsparame,1,5)) 
     NO-LOCK NO-ERROR.

IF   AVAILABLE (crapemp) THEN
     tel_dsempres = "- " + crapemp.nmresemp.
ELSE
     tel_dsempres = "- NAO CADASTRADA".

ASSIGN tel_cdempres = INTEGER(SUBSTRING(crapsol.dsparame,1,5))
       tel_indclass = INTEGER(SUBSTRING(crapsol.dsparame,7,1))
       tel_inoqlist = INTEGER(SUBSTRING(crapsol.dsparame,9,1))
       tel_nrdevias = crapsol.nrdevias.

DISPLAY tel_cdempres tel_dsempres tel_indclass tel_inoqlist tel_nrdevias
        WITH FRAME f_sol022.

/* .......................................................................... */

