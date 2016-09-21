/* .............................................................................

   Programa: Fontes/sol066.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson/Odair
   Data    : Fevereiro/96                       Ultima atualizacao: 05/08/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL066 - Soliticacao de emissao do relatorio
                                       de emprestimos com prestacao variavel.

   Alteracoes: 05/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrdevias AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dssitsol AS CHAR    FORMAT "x(20)"                NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.

DEF        VAR aux_nrsolici AS INT     FORMAT "zz9" INIT 066         NO-UNDO.
DEF        VAR aux_qtleitur AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.


FORM SKIP(5)
     glb_cddopcao AT 30 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (A,C,E ou I)"
                        VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(1)
     tel_cdagenci AT 29 LABEL " PA " AUTO-RETURN
                        HELP "Entre com o PA para emissao."
     SKIP(1)
     tel_nrdevias AT 31 LABEL "Vias" AUTO-RETURN
                        HELP "Entre com a quantidade de vias a imprimir (1-30)"
                        VALIDATE(tel_nrdevias > 0 AND tel_nrdevias < 31,
                                 "119 - Numero de vias errado")

     SKIP(1)
     tel_dssitsol AT 27 LABEL "Situacao"
     SKIP(4)
     WITH ROW 4 OVERLAY WIDTH 80 TITLE COLOR MESSAGE glb_tldatela
           SIDE-LABELS FRAME f_sol066.

ASSIGN glb_cddopcao = "I"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   ASSIGN glb_cdcritic = 0
          tel_dssitsol = ""
          tel_nrdevias = 0
          tel_cdagenci = 0.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_sol066.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "sol066" THEN
                 DO:
                     HIDE FRAME f_sol066.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A"   THEN
        DO:
            DO TRANSACTION ON ERROR UNDO, LEAVE:

               DO aux_qtleitur = 1 TO 5:

                  FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                     crapsol.nrsolici = aux_nrsolici   AND
                                     crapsol.dtrefere = glb_dtmvtolt   AND
                                     crapsol.nrseqsol = 1
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapsol   THEN
                       IF   LOCKED crapsol   THEN
                            DO:
                                glb_cdcritic = 120.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            glb_cdcritic = 115.
                  ELSE
                       DO:
                          glb_cdcritic = 0.
                          IF   crapsol.insitsol <> 1   THEN
                               glb_cdcritic = 150.
                       END.

                  LEAVE.

               END.  /*  Fim do DO .. TO  --  Tenta ler crapsol  */

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        CLEAR FRAME f_sol066 NO-PAUSE.
                        NEXT.
                    END.

               ASSIGN tel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,1,3))
                      tel_nrdevias = crapsol.nrdevias
                      tel_dssitsol = "1 - A FAZER   ".

               DISPLAY tel_cdagenci tel_nrdevias tel_dssitsol
                       WITH FRAME f_sol066.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  IF   glb_cdcritic > 0   THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.

                  UPDATE tel_cdagenci tel_nrdevias WITH FRAME f_sol066.

                  IF   NOT CAN-FIND(crapage WHERE
                                    crapage.cdcooper = glb_cdcooper    AND
                                    crapage.cdagenci = tel_cdagenci)   THEN
                       DO:
                           glb_cdcritic = 15.
                           NEXT.
                       END.

                  ASSIGN crapsol.dsparame = STRING(tel_cdagenci,"999")
                         crapsol.nrdevias = tel_nrdevias.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                    NEXT.

            END. /* Fim da transacao */

            RELEASE crapsol.

            CLEAR FRAME f_sol066 NO-PAUSE.
        END.
   ELSE
   IF   glb_cddopcao = "C"   THEN
        DO:
            FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                               crapsol.nrsolici = aux_nrsolici   AND
                               crapsol.dtrefere = glb_dtmvtolt   AND
                               crapsol.nrseqsol = 1
                               USE-INDEX crapsol1 NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapsol   THEN
                 DO:
                     glb_cdcritic = 115.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_sol066 NO-PAUSE.
                     NEXT.
                 END.

            ASSIGN tel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,1,3))
                   tel_nrdevias = crapsol.nrdevias
                   tel_dssitsol = IF crapsol.insitsol = 1
                                     THEN  "1 - A FAZER"
                                     ELSE  "2 - PROCESSADA".

            DISPLAY tel_cdagenci tel_nrdevias tel_dssitsol WITH FRAME f_sol066.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO TRANSACTION ON ERROR UNDO, LEAVE:

           DO aux_qtleitur = 1 TO 5 :

              FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                 crapsol.nrsolici = aux_nrsolici   AND
                                 crapsol.dtrefere = glb_dtmvtolt   AND
                                 crapsol.nrseqsol = 1
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
                        glb_cdcritic = 115.
              ELSE
                   DO:
                      glb_cdcritic = 0.
                      IF   crapsol.insitsol  <>  1   THEN
                           glb_cdcritic = 150.
                   END.

              LEAVE.

           END.  /*  Fim do DO .. TO  --  Tenta ler crapsol  */

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    CLEAR FRAME f_sol066 NO-PAUSE.
                    NEXT.
                END.

           ASSIGN tel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,1,3))
                  tel_nrdevias = crapsol.nrdevias
                  tel_dssitsol = "1 - A FAZER".

           DISPLAY tel_cdagenci tel_nrdevias tel_dssitsol WITH FRAME f_sol066.

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              ASSIGN aux_confirma = "N"
                     glb_cdcritic = 78.

              RUN fontes/critic.p.
              BELL.
              MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

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

           CLEAR FRAME f_sol066 NO-PAUSE.

        END. /* Fim da transacao */
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            IF   CAN-FIND (crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                         crapsol.nrsolici = aux_nrsolici   AND
                                         crapsol.dtrefere = glb_dtmvtolt   AND
                                         crapsol.nrseqsol = 1
                                         USE-INDEX crapsol1) THEN
                 DO:
                     glb_cdcritic = 118.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_sol066 NO-PAUSE.
                     NEXT.
                 END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               IF   glb_cdcritic > 0   THEN
                    DO:
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0.
                    END.

               UPDATE tel_cdagenci tel_nrdevias WITH FRAME f_sol066.

               IF   NOT CAN-FIND(crapage WHERE
                                 crapage.cdcooper = glb_cdcooper    AND 
                                 crapage.cdagenci = tel_cdagenci)   THEN
                    DO:
                        glb_cdcritic = 15.
                        NEXT.
                    END.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

            DO TRANSACTION ON ERROR UNDO, LEAVE:

               CREATE crapsol.
               ASSIGN crapsol.nrsolici = aux_nrsolici
                      crapsol.dtrefere = glb_dtmvtolt
                      crapsol.nrseqsol = 1
                      crapsol.cdempres = 11
                      crapsol.dsparame = STRING(tel_cdagenci,"999")
                      crapsol.insitsol = 1
                      crapsol.nrdevias = tel_nrdevias
                      crapsol.cdcooper = glb_cdcooper.

            END. /* Fim da transacao */

            RELEASE crapsol.

            CLEAR FRAME f_sol066 NO-PAUSE.

        END.  /* FIM DO DO */

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
