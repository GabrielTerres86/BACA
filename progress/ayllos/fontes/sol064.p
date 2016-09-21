/* .............................................................................

   Programa: Fontes/sol064.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Agosto/95

   Dados referentes ao programa:                 Ultima Alteracao : 13/12/2013

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL064.

   Alteracoes: 25/03/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               17/01/2000 - Tratar tpdebemp 3 (Deborah).

               05/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_nrseqsol AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrdevias AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dstitulo AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_percentu AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_dtrefere AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdempres AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dsempres AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR tel_dialiber AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_inexecut AS CHAR    FORMAT "x(01)"                NO-UNDO.
DEF        VAR tel_insitsol AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dssitsol AS CHAR    FORMAT "x(15)"                NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrseqsol AS INT                                   NO-UNDO.
DEF        VAR aux_inexecut AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR aux_nrsolici AS INT     FORMAT "z9" INIT 64           NO-UNDO.

DEF        VAR aux_tpintegr AS CHAR    INIT "p"                      NO-UNDO.

FORM SPACE(1)
     WITH ROW 4  OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP (1)
     glb_cddopcao AT  4 LABEL "Opcao           " AUTO-RETURN
                        HELP "Entre com a opcao desejada (A,C,E ou I)"
                        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I",
                                  "014 - Opcao errada.")
     SKIP (1)
     tel_nrseqsol AT  4 LABEL "Sequencia       " AUTO-RETURN
                        HELP "Entre com o numero de sequencia da solicitacao."
                        VALIDATE (tel_nrseqsol > 0,"117 - Sequencia errada.")
     SKIP(1)
     tel_cdempres AT  4 LABEL "Empresa         " AUTO-RETURN
                        HELP "Entre com o codigo da empresa."
                        VALIDATE (CAN-FIND (crapemp WHERE 
                                            crapemp.cdcooper = glb_cdcooper AND
                                            crapemp.cdempres = tel_cdempres),
                                            "040 - Empresa nao cadastrada.")
     tel_dsempres AT 24 NO-LABEL

     SKIP (1)
     tel_dtrefere AT  4 LABEL "Data Referencia " AUTO-RETURN
                        HELP "Entre com a data a que se refere o pagamento."
                        VALIDATE (tel_dtrefere <> ?,"013 - Data errada.")
     SKIP (1)
     tel_dialiber AT  4 LABEL "Dia de Liberacao" AUTO-RETURN
                        HELP "Entre com o dia de liberacao."
                        VALIDATE (tel_dialiber > 00 and tel_dialiber < 32,
                                  "013 - Data errada.")
     SKIP (1)
     tel_inexecut AT  4 LABEL "Integr. Processo" AUTO-RETURN
                        HELP
                        "S p/integrar no processo e N p/integrar durante o dia."
                        VALIDATE (tel_inexecut = "S" OR tel_inexecut = "N",
                                  "024 - Deve ser S ou N.")
     SKIP (1)
     tel_insitsol AT  4 LABEL "Situacao        "
     tel_dssitsol AT 24 NO-LABEL

     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_sol064.

VIEW FRAME f_moldura.

glb_cddopcao = "I".

PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   NEXT-PROMPT tel_nrseqsol WITH FRAME f_sol064.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE  glb_cddopcao tel_nrseqsol WITH FRAME f_sol064.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "SOL064"   THEN
                 DO:
                     HIDE FRAME f_integra.
                     HIDE FRAME f_sol064.
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

   { includes/listaint.i }

   ASSIGN aux_nrseqsol = tel_nrseqsol
          tel_inexecut = "S"
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
                                 CLEAR FRAME f_sol064.
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

               FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper       AND 
                                  crapemp.cdempres = crapsol.cdempres
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE (crapemp) THEN
                    tel_dsempres = " - " + crapemp.nmresemp.
               ELSE
                    tel_dsempres = " - NAO CADASTRADA".

               ASSIGN tel_cdempres = crapsol.cdempres
                      tel_dtrefere =
                      DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                           INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                           INTEGER(SUBSTRING(crapsol.dsparame,7,4)))
                      tel_dialiber =
                          INTEGER(SUBSTRING(crapsol.dsparame,12,2))
                      tel_inexecut = IF
                          (SUBSTRING(crapsol.dsparame,15,1)) = "1" THEN
                           "S" ELSE "N"
                      tel_insitsol = crapsol.insitsol
                      tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                        " - A FAZER"         ELSE
                                        " - PROCESSADA".

               DISPLAY tel_cdempres tel_dsempres tel_dtrefere
                       tel_dialiber tel_inexecut
                       tel_insitsol tel_dssitsol
                       WITH FRAME f_sol064.

               DO WHILE TRUE:

                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.

                  UPDATE  tel_cdempres tel_dtrefere tel_dialiber
                          tel_inexecut WITH FRAME f_sol064.

                  IF   YEAR(tel_dtrefere)  = YEAR(glb_dtmvtolt) - 1   AND
                       MONTH(tel_dtrefere) = 12                       THEN
                       glb_cdcritic = 0.
                  ELSE
                  IF   MONTH(tel_dtrefere) > MONTH(glb_dtmvtolt)       OR
                       MONTH(tel_dtrefere) < (MONTH(glb_dtmvtolt) - 1) THEN
                       DO:
                           glb_cdcritic = 13.
                           NEXT-PROMPT tel_dtrefere WITH FRAME f_sol064.
                           NEXT.
                       END.

                  FIND  crapemp WHERE crapemp.cdcooper = glb_cdcooper   AND 
                                      crapemp.cdempres = tel_cdempres
                                      NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE crapemp THEN
                       DO:
                          glb_cdcritic = 40.
                          NEXT-PROMPT tel_cdempres WITH FRAME f_sol064.
                          NEXT.
                       END.

                  IF   ((crapemp.tpdebemp = 2 OR crapemp.tpdebemp = 3) AND
                         crapemp.inavsemp <> 1) OR
                       ((crapemp.tpdebcot = 2 OR crapemp.tpdebcot = 3) AND
                         crapemp.inavscot <> 1) THEN
                       DO:
                           glb_cdcritic = 316.
                           NEXT-PROMPT tel_cdempres WITH FRAME f_sol064.
                           NEXT.
                       END.

                  IF   (NOT CAN-DO("2,3",STRING(crapemp.tpdebemp,"9"))) AND 
                       (NOT CAN-DO("2,3",STRING(crapemp.tpdebcot,"9"))) THEN
                       DO:
                           glb_cdcritic = 445.
                           NEXT-PROMPT tel_cdempres WITH FRAME f_sol064.
                           NEXT.
                       END.

                  ASSIGN crapsol.cdempres = tel_cdempres
                         aux_inexecut     = IF   tel_inexecut = "S"
                                                 THEN 1 ELSE 2
                         crapsol.dsparame = STRING(tel_dtrefere,"99/99/9999") +
                                            " " + STRING(tel_dialiber,"99")   +
                                            " " + STRING(aux_inexecut,"9").

                  LEAVE.

               END.

            END. /* Fim da transacao */

            RELEASE crapsol.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_sol064 NO-PAUSE.

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
                     CLEAR FRAME f_sol064.
                     tel_nrseqsol = aux_nrseqsol.
                     DISPLAY tel_nrseqsol WITH FRAME f_sol064.
                     glb_cdcritic = 0.
                     NEXT.
                 END.

            FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND 
                               crapemp.cdempres = crapsol.cdempres  
                               NO-LOCK NO-ERROR.

            IF   AVAILABLE (crapemp) THEN
                 tel_dsempres = " - " + crapemp.nmresemp.
            ELSE
                 tel_dsempres = " - NAO CADASTRADA".

            ASSIGN tel_cdempres = crapsol.cdempres
                   tel_dtrefere = DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                                       INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                                INTEGER(SUBSTRING(crapsol.dsparame,7,4)))
                   tel_dialiber = INTEGER(SUBSTRING(crapsol.dsparame,12,2))
                   tel_inexecut = IF (SUBSTRING(crapsol.dsparame,15,1))
                                      = "1" THEN "S" ELSE "N"
                   tel_insitsol = crapsol.insitsol
                   tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                     " - A FAZER"         ELSE
                                     " - PROCESSADA".

           DISPLAY tel_cdempres tel_dsempres tel_dtrefere tel_dialiber
                   tel_inexecut tel_insitsol tel_dssitsol WITH FRAME f_sol064.

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
                                 CLEAR FRAME f_sol064.
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
                        DISPLAY tel_nrseqsol WITH FRAME f_sol064.
                        NEXT.
                    END.

               FIND crapemp WHERE  crapemp.cdcooper = glb_cdcooper      AND 
                                   crapemp.cdempres = crapsol.cdempres
                                   NO-LOCK NO-ERROR.

               IF   AVAILABLE (crapemp) THEN
                    tel_dsempres = " - " + crapemp.nmresemp.
               ELSE
                    tel_dsempres = " - NAO CADASTRADA".

               ASSIGN tel_cdempres = crapsol.cdempres
                      tel_dtrefere =
                               DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                                    INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                                    INTEGER(SUBSTRING(crapsol.dsparame,7,4)))
                      tel_dialiber = INTEGER(SUBSTRING(crapsol.dsparame,12,2))
                      tel_inexecut = IF (SUBSTRING(crapsol.dsparame,15,1))
                                         = "1" THEN "S" ELSE "N"
                      tel_insitsol = crapsol.insitsol
                      tel_dssitsol = IF crapsol.insitsol = 1 THEN
                                          " - A FAZER"
                                     ELSE " - PROCESSADA".

               DISPLAY tel_cdempres tel_dsempres tel_dtrefere tel_dialiber
                       tel_inexecut tel_insitsol tel_dssitsol
                       WITH FRAME f_sol064.

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
               CLEAR FRAME f_sol064 NO-PAUSE.

            END. /* Fim da transacao */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            ASSIGN tel_cdempres = 0
                   tel_dialiber = 0
                   tel_dtrefere = ?
                   tel_inexecut = "S".

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
                     CLEAR FRAME f_sol064.
                     tel_nrseqsol = aux_nrseqsol.
                  /*   DISPLAY tel_nrseqsol WITH FRAME f_sol064. */
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

                  UPDATE tel_cdempres tel_dtrefere tel_dialiber tel_inexecut
                         WITH FRAME f_sol064.

                  IF   YEAR(tel_dtrefere)  = YEAR(glb_dtmvtolt) - 1   AND
                       MONTH(tel_dtrefere) = 12                       THEN
                       glb_cdcritic = 0.
                  ELSE
                  IF   MONTH(tel_dtrefere) > MONTH(glb_dtmvtolt)  OR
                       MONTH(tel_dtrefere) < (MONTH(glb_dtmvtolt) - 1) THEN
                       DO:
                           glb_cdcritic = 13.
                           NEXT-PROMPT tel_dtrefere WITH FRAME f_sol064.
                           NEXT.
                       END.

                  FIND  crapemp WHERE crapemp.cdcooper = glb_cdcooper   AND 
                                      crapemp.cdempres = tel_cdempres
                                      NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE crapemp  THEN
                       DO:
                           glb_cdcritic = 40.
                           NEXT-PROMPT tel_cdempres WITH FRAME f_sol064.
                           NEXT.
                       END.

                  IF   ((crapemp.tpdebemp = 2 OR crapemp.tpdebemp = 3) AND
                         crapemp.inavsemp <> 1) OR
                       ((crapemp.tpdebcot = 2 OR crapemp.tpdebcot = 3) AND
                         crapemp.inavscot <> 1) THEN
                       DO:
                           glb_cdcritic = 316.
                           NEXT-PROMPT tel_cdempres WITH FRAME f_sol064.
                           NEXT.
                       END.

                  IF   (NOT CAN-DO("2,3",STRING(crapemp.tpdebemp,"9"))) AND 
                       (NOT CAN-DO("2,3",STRING(crapemp.tpdebcot,"9"))) THEN
                       DO:
                           glb_cdcritic = 445.
                           NEXT-PROMPT tel_cdempres WITH FRAME f_sol064.
                           NEXT.
                       END.

                  ASSIGN crapsol.cdempres = tel_cdempres
                         aux_inexecut     = IF   tel_inexecut = "S"
                                                 THEN  1 ELSE 2
                         crapsol.dsparame = STRING(tel_dtrefere,"99/99/9999") +
                                            " " + STRING(tel_dialiber,"99") +
                                            " " + STRING(aux_inexecut,"9")
                         crapsol.insitsol = 1
                         crapsol.nrdevias = 1.
                  LEAVE.
                END.

            END. /* Fim da transacao */

            RELEASE crapsol.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_sol064 NO-PAUSE.

        END.
END.
/* .......................................................................... */
