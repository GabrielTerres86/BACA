/* .............................................................................

   Programa: Includes/sol098i.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo
   Data    : Marco/05                           Ultima Atualizacao: 02/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela SOL098.

   Alteracoes: 07/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               02/02/2006 - Unificacao dos Campos - SQLWorks - Fernando.
............................................................................. */

FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND 
                   crapsol.nrsolici = aux_nrsolici  AND
                   crapsol.dtrefere = glb_dtmvtolt  NO-LOCK NO-ERROR NO-WAIT.

IF   AVAILABLE crapsol   THEN
     DO:
         glb_cdcritic = 118.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_sol098.
         NEXT.
     END.

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   CREATE crapsol.
   ASSIGN crapsol.nrsolici = aux_nrsolici
          crapsol.dtrefere = glb_dtmvtolt
          crapsol.nrseqsol = 1
          crapsol.insitsol = 1
          crapsol.cdcooper = glb_cdcooper
          tel_nrdevias     = 0.

   DO WHILE TRUE:

      SET tel_nrdevias WITH FRAME f_sol098.

      ASSIGN crapsol.cdempres = 11.

      IF   tel_nrdevias > 0   THEN
           crapsol.nrdevias = tel_nrdevias.
      ELSE
           crapsol.nrdevias = 1.

      LEAVE.
   END.

END. /* Fim da transacao */

RELEASE crapsol.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_sol098 NO-PAUSE.

/* .......................................................................... */
