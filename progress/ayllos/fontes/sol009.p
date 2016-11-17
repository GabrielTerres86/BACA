/* .............................................................................

   Programa: Fontes/sol009.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/92                            Ultima Atualizacao: 01/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL009.
   
   Alteracoes: 05/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_nrseqsol AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrdevias AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dstitulo AS CHAR    FORMAT "x(40)"                NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_nrsolici AS INT     FORMAT "z9" INIT 9            NO-UNDO.

FORM SKIP (4)
     glb_cddopcao AT 15 LABEL "Opcao         " AUTO-RETURN
                        HELP "Entre com a opcao desejada (A,C,E ou I)"
                        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I",
                                  "014 - Opcao errada.")
     SKIP (2)
     tel_nrseqsol AT 15 LABEL "Sequencia     " AUTO-RETURN
                        HELP "Entre com o numero de sequencia da solicitacao."
                        VALIDATE (tel_nrseqsol > 0,"117 - Sequencia errada.")

     SKIP (2)
     tel_nrdevias AT 15 LABEL "Numero de vias" AUTO-RETURN
                        HELP "Entre com o numero de vias desejadas."
                        VALIDATE (tel_nrdevias > 0,
                                  "119 - Numero de vias errado.")
     SKIP (5)

     WITH ROW 4 COLUMN 1 OVERLAY TITLE COLOR MESSAGE tel_dstitulo
          SIDE-LABELS NO-ATTR-SPACE WIDTH 80 FRAME f_sol009.

glb_cddopcao = "I".

FIND craprel WHERE craprel.cdcooper = glb_cdcooper   AND
                   craprel.cdrelato = 17 NO-LOCK     NO-ERROR.

IF   NOT AVAILABLE craprel   THEN
     ASSIGN tel_dstitulo = FILL("*",40).
ELSE
     ASSIGN tel_dstitulo = " " + craprel.nmrelato + " ".

RELEASE craprel.

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao WITH FRAME f_sol009.
        NEXT-PROMPT tel_nrseqsol WITH FRAME f_sol009.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           PROMPT-FOR glb_cddopcao tel_nrseqsol WITH FRAME f_sol009.
           LEAVE.                                     

        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "SOL009"   THEN
                      DO:
                          HIDE FRAME f_sol009.
                          RETURN.
                      END.
                 ELSE
                      NEXT.
             END.

        IF   aux_cddopcao <> INPUT glb_cddopcao THEN
             DO:
                 { includes/acesso.i }
                 aux_cddopcao = INPUT glb_cddopcao.
             END.

        ASSIGN tel_nrseqsol = INPUT tel_nrseqsol
               aux_nrseqsol = INPUT tel_nrseqsol
               glb_cddopcao = INPUT glb_cddopcao.

        IF   INPUT glb_cddopcao = "A" THEN
             DO:
                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    DO  aux_contador = 1 TO 10:

                        FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND                                            crapsol.nrsolici = aux_nrsolici   AND
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
                                      CLEAR FRAME f_sol009.
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

                             DISPLAY tel_nrseqsol WITH FRAME f_sol009.
                             NEXT.
                         END.

                    ASSIGN tel_nrdevias = crapsol.nrdevias.

                    DISPLAY tel_nrdevias WITH FRAME f_sol009.

                    DO WHILE TRUE:

                       SET  tel_nrdevias WITH FRAME f_sol009.

                       ASSIGN crapsol.nrdevias = tel_nrdevias.

                       LEAVE.

                    END.

                 END. /* Fim da transacao */

                 RELEASE crapsol.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                      NEXT.

                 CLEAR FRAME f_sol009 NO-PAUSE.

             END.
        ELSE
        IF   INPUT glb_cddopcao = "C" THEN
             DO:
               
                 FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                                    crapsol.nrsolici = aux_nrsolici   AND
                                    crapsol.dtrefere = glb_dtmvtolt   AND
                                    crapsol.nrseqsol = tel_nrseqsol
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crapsol   THEN
                      DO:
                          ASSIGN glb_cdcritic = 115.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          CLEAR FRAME f_sol009.
                          ASSIGN tel_nrseqsol = aux_nrseqsol.
                          DISPLAY tel_nrseqsol WITH FRAME f_sol009.
                          NEXT.
                      END.

                 ASSIGN tel_nrdevias = crapsol.nrdevias.

                 DISPLAY tel_nrdevias WITH FRAME f_sol009.
             END.
        ELSE
        IF   INPUT glb_cddopcao = "E"   THEN
             DO:
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
                                      ASSIGN glb_cdcritic = 120.
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                             ELSE
                                  DO:
                                      ASSIGN glb_cdcritic = 115.
                                      CLEAR FRAME f_sol009.
                                      LEAVE.
                                  END.
                        ELSE
                             DO:
                                 ASSIGN aux_contador = 0.
                                 LEAVE.
                             END.
                    END.

                    IF   aux_contador <> 0   THEN
                         DO:
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             ASSIGN tel_nrseqsol = aux_nrseqsol.
                             DISPLAY tel_nrseqsol WITH FRAME f_sol009.
                             NEXT.
                         END.

                    ASSIGN tel_nrdevias = crapsol.nrdevias.

                    DISPLAY tel_nrdevias WITH FRAME f_sol009.

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
                             ASSIGN glb_cdcritic = 79.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             NEXT.
                         END.

                    DELETE crapsol.
                    CLEAR FRAME f_sol009 NO-PAUSE.

                 END. /* Fim da transacao */

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                      NEXT.
             END.
        ELSE
        IF   INPUT glb_cddopcao = "I"   THEN
             DO:

                 FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                                    crapsol.nrsolici = aux_nrsolici   AND
                                    crapsol.dtrefere = glb_dtmvtolt   AND
                                    crapsol.nrseqsol = tel_nrseqsol
                                    NO-LOCK NO-ERROR NO-WAIT.

                 IF   AVAILABLE crapsol   THEN
                      DO:
                          ASSIGN glb_cdcritic = 118.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          CLEAR FRAME f_sol009.
                          ASSIGN tel_nrseqsol = aux_nrseqsol.
                          DISPLAY tel_nrseqsol WITH FRAME f_sol009.
                          NEXT.
                      END.

                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    CREATE crapsol.

                    ASSIGN crapsol.nrsolici = aux_nrsolici
                           crapsol.dtrefere = glb_dtmvtolt
                           crapsol.nrseqsol = tel_nrseqsol
                           crapsol.insitsol = 1
                           crapsol.cdcooper = glb_cdcooper
                           tel_nrdevias     = 0.

                    DO WHILE TRUE:

                       SET tel_nrdevias WITH FRAME f_sol009.

                       ASSIGN crapsol.cdempres = 11
                              crapsol.nrdevias = tel_nrdevias.
                       LEAVE.
                    END.

                 END. /* Fim da transacao */

                 RELEASE crapsol.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                      NEXT.

                 CLEAR FRAME f_sol009 NO-PAUSE.

             END.
END.
/* .......................................................................... */

