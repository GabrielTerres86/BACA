/* .............................................................................

   Programa: Fontes/sol001i.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Outubro/91                        Ultima Atualizacao: 12/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela SOL001.

   Alteracoes: 06/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
............................................................................. */

FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper    AND
                   crapsol.nrsolici = tel_nrsolici    AND
                   crapsol.dtrefere = glb_dtmvtolt    AND
                   crapsol.nrseqsol = tel_nrseqsol    NO-LOCK NO-ERROR NO-WAIT.

IF   AVAILABLE crapsol   THEN
     DO:
         glb_cdcritic = 118.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_sol001.

         ASSIGN tel_nrsolici = INTEGER(SUBSTRING(aux_dsacesso,1,3))
                tel_nrseqsol = INTEGER(SUBSTRING(aux_dsacesso,4,2)).

         DISPLAY glb_cddopcao tel_nrsolici tel_nrseqsol
                 WITH FRAME f_sol001.
         NEXT.
     END.

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   CREATE crapsol.

   ASSIGN crapsol.nrsolici = tel_nrsolici
          crapsol.dtrefere = glb_dtmvtolt
          crapsol.nrseqsol = tel_nrseqsol
          crapsol.cdcooper = glb_cdcooper.
   VALIDATE crapsol.

   DO WHILE TRUE:

      SET     crapsol.cdempres crapsol.nrdevias crapsol.dsparame
              WITH FRAME f_sol001.
      crapsol.dsparame = CAPS(crapsol.dsparame).
      LEAVE.
   END.

END. /* Fim da transacao */

RELEASE crapsol.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_sol001 NO-PAUSE.

/* .......................................................................... */

