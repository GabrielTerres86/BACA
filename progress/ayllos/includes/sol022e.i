/* .............................................................................

   Programa: Includes/sol022e.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                        Ultima Alteracao: 01/09/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela SOL022.

   Alteracoes: Unificacao dos Bancos - SQLWorks - Fernando. 

               01/09/2008 - Alteracao cdempres (Kbase IT).

............................................................................. */

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 10:

       FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                          crapsol.nrsolici = aux_nrsolici   AND
                          crapsol.dtrefere = glb_dtmvtolt   AND
                          crapsol.nrseqsol = tel_nrseqsol
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE crapsol   THEN
            IF   LOCKED crapsol   THEN
                 DO:
                     glb_cdcritic = 120.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
           ELSE
                 DO:
                     glb_cdcritic = 115.
                     CLEAR FRAME f_sol022.
                     LEAVE.
                 END.
       ELSE
            DO:
                aux_contador = 0.
                LEAVE.
            END.
   END.

   IF   aux_contador <> 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.

            tel_nrseqsol = aux_nrseqsol.

            DISPLAY tel_nrseqsol WITH FRAME f_sol022.
            NEXT.
        END.

   ASSIGN tel_cdempres = INTEGER(SUBSTRING(crapsol.dsparame,1,5))
          tel_indclass = INTEGER(SUBSTRING(crapsol.dsparame,7,1))
          tel_inoqlist = INTEGER(SUBSTRING(crapsol.dsparame,9,1))
          tel_nrdevias = crapsol.nrdevias.

   DISPLAY tel_cdempres tel_indclass tel_inoqlist tel_nrdevias
           WITH FRAME f_sol022.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.

      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
        aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   DELETE crapsol.
   CLEAR FRAME f_sol022 NO-PAUSE.

END. /* Fim da transacao */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

/* .......................................................................... */

