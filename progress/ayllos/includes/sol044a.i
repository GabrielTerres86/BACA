/* .............................................................................

   Programa: Includes/sol044a.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94                       Ultima Atualizacao: 02/02/2006
     
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela SOL044.

   Alteracoes: 02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
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
                     CLEAR FRAME f_sol044.
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

            DISPLAY tel_nrseqsol WITH FRAME f_sol044.
            NEXT.
        END.

   ASSIGN tel_tprelato = INTEGER(SUBSTRING(crapsol.dsparame,1,1))
          tel_nrdevias = crapsol.nrdevias.

   DISPLAY tel_tprelato tel_nrdevias
           WITH FRAME f_sol044.

   DO WHILE TRUE:

      SET  tel_tprelato tel_nrdevias
           WITH FRAME f_sol044.

      crapsol.dsparame = STRING(tel_tprelato).

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

CLEAR FRAME f_sol044 NO-PAUSE.

/* .......................................................................... */
