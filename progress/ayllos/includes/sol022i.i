/* .............................................................................

   Programa: Includes/sol022i.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                         Ultima Atualizacao: 01/09/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela SOL022.

   Alteracoes: 06/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               01/09/2008 - Alteracao cdempres (Kbase IT).
............................................................................. */

FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                   crapsol.nrsolici = aux_nrsolici   AND
                   crapsol.dtrefere = glb_dtmvtolt   AND
                   crapsol.nrseqsol = tel_nrseqsol   NO-LOCK NO-ERROR NO-WAIT.

IF   AVAILABLE crapsol   THEN
     DO:
         glb_cdcritic = 118.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_sol022.

         tel_nrseqsol = aux_nrseqsol.

         DISPLAY tel_nrseqsol WITH FRAME f_sol022.
         NEXT.
     END.

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   CREATE crapsol.
   ASSIGN crapsol.nrsolici = aux_nrsolici
          crapsol.dtrefere = glb_dtmvtolt
          crapsol.nrseqsol = tel_nrseqsol
          crapsol.insitsol = 1
          crapsol.cdcooper = glb_cdcooper
          tel_cdempres     = 0
          tel_indclass     = 0
          tel_inoqlist     = 0
          tel_nrdevias     = 0.

   DO WHILE TRUE:

      SET tel_cdempres tel_indclass tel_inoqlist tel_nrdevias
          WITH FRAME f_sol022.

      ASSIGN crapsol.cdempres = 11.
             crapsol.dsparame = STRING(tel_cdempres,"99999") + " " +
                                STRING(tel_indclass)         + " " +
                                STRING(tel_inoqlist).

      IF   tel_nrdevias > 0   THEN
           crapsol.nrdevias = tel_nrdevias.
      ELSE
           crapsol.nrdevias = tel_nrviadef.

      LEAVE.
   END.

END. /* Fim da transacao */

RELEASE crapsol.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_sol022 NO-PAUSE.

/* .......................................................................... */

