/* .............................................................................

   Programa: Fontes/fimprg.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Novembro/91.                        Ultima atualizacao: 07/02/2012

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado por outro programa.
   Objetivo  : Fazer os procedimentos de finalizacao dos programas batch.
               Deve ser enviado para esta rotina o campo glb_cdprogra.

   Alteracoes: 21/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
   
               07/02/2012 - Utilizar variavel glb_flgresta para criar a
                            tabela de restart (David).

............................................................................. */

{ includes/var_batch.i }

TRANS_1:

DO TRANSACTION ON ERROR UNDO TRANS_1, LEAVE TRANS_1:

   glb_cdcritic = 0.

   DO WHILE TRUE:

      FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE crapdat   THEN
           IF   LOCKED crapdat   THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                DO:
                    glb_cdcritic = 1.
                    LEAVE TRANS_1.
                END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   DO WHILE TRUE:

      FIND crapprg WHERE crapprg.cdcooper = glb_cdcooper AND
                         crapprg.cdprogra = glb_cdprogra 
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE crapprg   THEN
           IF   LOCKED crapprg   THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                DO:
                    glb_cdcritic = 145.
                    LEAVE TRANS_1.
                END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   glb_infimsol = TRUE THEN
        DO:
            DO WHILE TRUE:

               FIND FIRST crapsol WHERE crapsol.cdcooper = glb_cdcooper     AND
                                        crapsol.nrsolici = crapprg.nrsolici
                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF   NOT AVAILABLE crapsol  THEN
                    IF   LOCKED crapsol   THEN
                         DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                         END.
                    ELSE
                         DO:
                             glb_cdcritic = 115.
                             LEAVE TRANS_1.
                         END.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            ASSIGN crapsol.insitsol = 2
                   glb_infimsol     = FALSE.
        END.

   ASSIGN crapprg.inctrprg = 2
          crapdat.cdprgant = glb_cdprogra.

   IF   glb_flgresta   THEN
        DO:
            DO WHILE TRUE:
           
               FIND crapres WHERE crapres.cdcooper = glb_cdcooper AND
                                  crapres.cdprogra = glb_cdprogra
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
           
               IF   NOT AVAILABLE crapres   THEN
                    IF   LOCKED crapres   THEN
                         DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                         END.
                    ELSE
                         DO:
                             glb_cdcritic = 151.
                             UNDO TRANS_1, LEAVE TRANS_1.
                         END.
           
               LEAVE.
           
            END.  /*  Fim do DO WHILE TRUE  */
           
            DELETE crapres.
        END.

   glb_stprogra = TRUE.

END.  /*  Fim da TRANSACAO  */

IF   glb_cdcritic > 0   THEN
     DO:
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " >> log/proc_batch.log").
     END.

/* .......................................................................... */

