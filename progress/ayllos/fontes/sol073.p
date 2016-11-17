/* .............................................................................

   Programa: Fontes/sol073.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Junho/97

   Dados referentes ao programa:                 Ultima Alteracao : 17/01/2014

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL073.

   Alteracoes: 05/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)              
                            
               17/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado."
                          - Alterado format da variavel tel_cdagenci para "zz9".
                           (Reinert)                            
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_nrseqsol AS INT   FORMAT "zz9"                    NO-UNDO.
DEF        VAR tel_cdagenci AS INT   FORMAT "zz9"                    NO-UNDO.
DEF        VAR tel_dsagenci AS CHAR  FORMAT "x(20)"                  NO-UNDO.

DEF        VAR aux_confirma AS CHAR  FORMAT "!(1)"                   NO-UNDO.

DEF        VAR aux_contador AS INT   FORMAT "z9"                     NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_nrsolici AS INT   FORMAT "z9" INIT 73             NO-UNDO.

DEF        VAR tel_dtrefini AS DATE  FORMAT "99/99/9999"             NO-UNDO.
DEF        VAR tel_dtreffim AS DATE  FORMAT "99/99/9999"             NO-UNDO.

FORM SPACE(1)
     WITH ROW 4  OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP (3)
     glb_cddopcao AT  24 LABEL "Opcao " AUTO-RETURN
                        HELP "Entre com a opcao desejada (A,C,E ou I)"
                        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I",
                                  "014 - Opcao errada.")
     SKIP (1)
     tel_nrseqsol AT  20 LABEL "Sequencia " AUTO-RETURN
                        HELP "Entre com o numero de sequencia da solicitacao."
                        VALIDATE (tel_nrseqsol > 0,"117 - Sequencia errada.")
     SKIP(1)
     tel_cdagenci AT  27 LABEL "PA " AUTO-RETURN
                        HELP "Entre com o codigo do PA"
                        VALIDATE (CAN-FIND (crapage WHERE 
                                            crapage.cdcooper = glb_cdcooper AND
                                            crapage.cdagenci = tel_cdagenci),
                                            "962 - PA nao cadastrado.")
     tel_dsagenci AT 34 NO-LABEL

     SKIP (1)
     tel_dtrefini AT  4 LABEL "Data Inicio das Admissoes " AUTO-RETURN
                        HELP "Entre com a data a de inicio das admissoes."

     SKIP (1)
     tel_dtreffim AT  7 LABEL "Data Fim das Admissoes " AUTO-RETURN
                        HELP "Entre com a data ."
     SKIP (1)
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_sol073.

VIEW FRAME f_moldura.

glb_cddopcao = "I".

PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   NEXT-PROMPT tel_nrseqsol WITH FRAME f_sol073.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE  glb_cddopcao tel_nrseqsol WITH FRAME f_sol073.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "SOL073"   THEN
                 DO:
                     HIDE FRAME f_sol073.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <>  glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao =  glb_cddopcao.
        END.

   ASSIGN aux_nrseqsol = tel_nrseqsol
          glb_cdcritic = 0.

   IF   glb_cddopcao = "A" THEN
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
                                 glb_cdcritic = 120.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                         ELSE
                             DO:
                                 glb_cdcritic = 115.
                                 CLEAR FRAME f_sol073.
                                 LEAVE.
                             END.
                   ELSE
                        DO:
                            aux_contador = 0.
                            LEAVE.
                        END.
               END.

               IF   aux_contador = 0 THEN
                    IF   crapsol.insitsol <> 1 THEN
                         ASSIGN glb_cdcritic = 150
                                aux_contador = 1.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        tel_nrseqsol = aux_nrseqsol.
                        NEXT.
                    END.

               FIND crapage WHERE crapage.cdcooper = glb_cdcooper       AND
                                  crapage.cdagenci = crapsol.cdempres   
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE (crapage) THEN
                    tel_dsagenci = " - " + crapage.nmresage.
               ELSE
                    tel_dsagenci = " - NAO CADASTRADA".

               ASSIGN tel_cdagenci = crapsol.cdempres
                      tel_dtrefini = DATE(INTEGER(SUBSTR(crapsol.dsparame,4,2)),
                                          INTEGER(SUBSTR(crapsol.dsparame,1,2)),
                                          INTEGER(SUBSTR(crapsol.dsparame,7,4)))
                     tel_dtreffim = DATE(INTEGER(SUBSTR(crapsol.dsparame,15,2)),
                                       INTEGER(SUBSTR(crapsol.dsparame,12,2)),
                                       INTEGER(SUBSTR(crapsol.dsparame,18,4))).

               DISPLAY tel_cdagenci tel_dsagenci tel_dtrefini tel_dtreffim
                       WITH FRAME f_sol073.

               DO WHILE TRUE:

                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.

                  UPDATE tel_cdagenci tel_dtrefini tel_dtreffim
                         WITH FRAME f_sol073.

                  IF   tel_dtrefini > glb_dtmvtolt OR
                       tel_dtrefini > tel_dtreffim THEN
                       DO:
                           glb_cdcritic = 13.
                           NEXT-PROMPT tel_dtrefini WITH FRAME f_sol073.
                           NEXT.
                       END.

                  ASSIGN crapsol.cdempres = tel_cdagenci
                         crapsol.dsparame = STRING(tel_dtrefini,"99/99/9999") +
                                            " " +
                                            STRING(tel_dtreffim,"99/99/9999").
                  LEAVE.

               END.

            END. /* Fim da transacao */

            RELEASE crapsol.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_sol073 NO-PAUSE.

        END.
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                               crapsol.nrsolici = aux_nrsolici   AND
                               crapsol.dtrefere = glb_dtmvtolt   AND
                               crapsol.nrseqsol = tel_nrseqsol
                               USE-INDEX crapsol1 NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapsol   THEN
                 DO:
                     glb_cdcritic = 115.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_sol073.
                     tel_nrseqsol = aux_nrseqsol.
                     DISPLAY tel_nrseqsol WITH FRAME f_sol073.
                     glb_cdcritic = 0.
                     NEXT.
                 END.

            FIND crapage WHERE crapage.cdcooper = glb_cdcooper      AND 
                               crapage.cdagenci = crapsol.cdempres  
                               NO-LOCK NO-ERROR.

            IF   AVAILABLE (crapage) THEN
                 tel_dsagenci = " - " + crapage.nmresage.
            ELSE
                 tel_dsagenci = " - NAO CADASTRADA".

            ASSIGN tel_cdagenci = crapsol.cdempres
                   tel_dtrefini = DATE(INTEGER(SUBSTR(crapsol.dsparame,4,2)),
                                       INTEGER(SUBSTR(crapsol.dsparame,1,2)),
                                       INTEGER(SUBSTR(crapsol.dsparame,7,4)))
                   tel_dtreffim = DATE(INTEGER(SUBSTR(crapsol.dsparame,15,2)),
                                       INTEGER(SUBSTR(crapsol.dsparame,12,2)),
                                       INTEGER(SUBSTR(crapsol.dsparame,18,4))).

            DISPLAY tel_cdagenci tel_dsagenci tel_dtrefini tel_dtreffim
                    WITH FRAME f_sol073.

        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO  aux_contador = 1 TO 10:

                   FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                      crapsol.nrsolici = aux_nrsolici   AND
                                      crapsol.dtrefere = glb_dtmvtolt   AND
                                      crapsol.nrseqsol = tel_nrseqsol
                                      USE-INDEX crapsol1
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
                                 CLEAR FRAME f_sol073.
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
                        DISPLAY tel_nrseqsol WITH FRAME f_sol073.
                        NEXT.
                    END.

               FIND crapage WHERE crapage.cdcooper = glb_cdcooper       AND
                                  crapage.cdagenci = crapsol.cdempres   
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE (crapage) THEN
                    tel_dsagenci = " - " + crapage.nmresage.
               ELSE
                    tel_dsagenci = " - NAO CADASTRADA".

               ASSIGN tel_cdagenci = crapsol.cdempres
                      tel_dtrefini = DATE(INTEGER(SUBSTR(crapsol.dsparame,4,2)),
                                          INTEGER(SUBSTR(crapsol.dsparame,1,2)),
                                          INTEGER(SUBSTR(crapsol.dsparame,7,4)))
                     tel_dtreffim = DATE(INTEGER(SUBSTR(crapsol.dsparame,15,2)),
                                         INTEGER(SUBSTR(crapsol.dsparame,12,2)),
                                        INTEGER(SUBSTR(crapsol.dsparame,18,4))).

               DISPLAY tel_cdagenci tel_dsagenci tel_dtrefini tel_dtreffim
                       WITH FRAME f_sol073.

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
               CLEAR FRAME f_sol073 NO-PAUSE.

            END. /* Fim da transacao */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            ASSIGN tel_cdagenci = 0.

            FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                               crapsol.nrsolici = aux_nrsolici   AND
                               crapsol.dtrefere = glb_dtmvtolt   AND
                               crapsol.nrseqsol = tel_nrseqsol
                               USE-INDEX crapsol1 NO-LOCK NO-ERROR NO-WAIT.

            IF   AVAILABLE crapsol   THEN
                 DO:
                     ASSIGN glb_cdcritic = 118.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_sol073.
                     tel_nrseqsol = aux_nrseqsol.
                  /*   DISPLAY tel_nrseqsol WITH FRAME f_sol073. */
                     NEXT.
                 END.

            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               CREATE crapsol.
               ASSIGN crapsol.nrsolici = aux_nrsolici
                      crapsol.dtrefere = glb_dtmvtolt
                      crapsol.nrseqsol = tel_nrseqsol
                      crapsol.cdcooper = glb_cdcooper.
               VALIDATE crapsol.

               DO WHILE TRUE:

                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.

                  UPDATE tel_cdagenci tel_dtrefini tel_dtreffim
                         WITH FRAME f_sol073.

                  IF   tel_dtrefini > glb_dtmvtolt OR
                       tel_dtrefini > tel_dtreffim THEN
                       DO:
                           glb_cdcritic = 13.
                           NEXT-PROMPT tel_dtrefini WITH FRAME f_sol073.
                           NEXT.
                       END.

                  ASSIGN crapsol.cdempres = tel_cdagenci
                         crapsol.dsparame = STRING(tel_dtrefini,"99/99/9999") +
                                            " " +
                                            STRING(tel_dtreffim,"99/99/9999")
                         crapsol.insitsol = 1
                         crapsol.nrdevias = 1.
                  LEAVE.
                END.

            END. /* Fim da transacao */

            RELEASE crapsol.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_sol073 NO-PAUSE.

        END.
END.
/* .......................................................................... */


