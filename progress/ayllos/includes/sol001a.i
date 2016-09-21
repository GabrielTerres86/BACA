/* .............................................................................

   Programa: Includes/sol001a.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Outubro/91                          Ultima atualizacao: 01/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela SOL001.

   Alteracoes: 01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
............................................................................. */

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 10:

       FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                          crapsol.nrsolici = tel_nrsolici   AND
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
                     CLEAR FRAME f_sol001.
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

            ASSIGN tel_nrsolici = INTEGER(SUBSTRING(aux_dsacesso,1,3))
                   tel_nrseqsol = INTEGER(SUBSTRING(aux_dsacesso,4,2)).

            DISPLAY tel_nrsolici tel_nrseqsol
                    WITH FRAME f_sol001.
            NEXT.
        END.

   DISPLAY tel_nrsolici     tel_nrseqsol     crapsol.cdempres
           crapsol.nrdevias crapsol.dsparame
           WITH FRAME f_sol001.

   DO WHILE TRUE:

            SET  crapsol.cdempres crapsol.nrdevias
                 crapsol.dsparame WITH FRAME f_sol001.
            crapsol.dsparame = CAPS(crapsol.dsparame).
            LEAVE.
   END.

END. /* Fim da transacao */

RELEASE crapsol.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_sol001 NO-PAUSE.

/* .......................................................................... */

