/* .............................................................................

   Programa: Fontes/sol054.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/94                        Ultima atualizacao: 02/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL054.

   Alteracoes: 25/03/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               05/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
............................................................................ */

{ includes/var_online.i }

DEF        VAR tel_dtmesano AS INT     FORMAT "zzzzz9"               NO-UNDO.
DEF        VAR tel_nrseqsol AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_dssitsol AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR tel_nrdevias  AS INT    FORMAT "z9"                   NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.

DEF        VAR aux_dtdiaref AS INT     FORMAT "99"  INIT 01          NO-UNDO.
DEF        VAR aux_dtmesref AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_dtanoref AS INT     FORMAT "9999"                 NO-UNDO.
DEF        VAR aux_dtgerref AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.


DEF        VAR aux_nrsolici AS INT     FORMAT "zz9" INIT 054         NO-UNDO.
DEF        VAR aux_qtleitur AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.


FORM SKIP(3)
     glb_cddopcao AT 30 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (A,C,E ou I)"
                        VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(1)
     tel_nrseqsol AT 26 LABEL "Sequencia" AUTO-RETURN
                        HELP "Entre com o numero de sequencia da solicitacao."
                        VALIDATE (tel_nrseqsol > 0,"117 - Sequencia errada.")
     SKIP(1)
     tel_dtmesano AT 12 LABEL "Mes e Ano de Referencia" AUTO-RETURN
                        HELP "Entre com o mes e ano de referencia."
     SKIP(1)
     tel_nrdevias AT 31 LABEL "Vias" AUTO-RETURN
                        HELP "Entre com a quantidade de vias a imprimir (1-30)"
                        VALIDATE(tel_nrdevias > 0 AND tel_nrdevias < 31,
                                 "119 - Numero de vias errado")

     SKIP(1)
     tel_dssitsol AT 27 LABEL "Situacao"
     SKIP(4)
     WITH ROW 4 OVERLAY WIDTH 80 TITLE COLOR MESSAGE glb_tldatela
           SIDE-LABELS FRAME f_sol054.

ASSIGN glb_cddopcao = "I"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   ASSIGN glb_cdcritic = 0
          tel_dssitsol = ""
          tel_nrdevias = 0
          tel_dtmesano = 0.

   NEXT-PROMPT tel_nrseqsol WITH FRAME f_sol054.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao tel_nrseqsol WITH FRAME f_sol054.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "SOL054" THEN
                 DO:
                     HIDE FRAME f_sol054.
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
                        CLEAR FRAME f_sol054 NO-PAUSE.
                        NEXT.
                    END.

               ASSIGN tel_nrdevias = crapsol.nrdevias
                      tel_dtmesano = INTEGER(SUBSTRING(crapsol.dsparame,1,6))
                      tel_dssitsol = "1 - A FAZER   ".

               DISPLAY tel_dtmesano tel_nrdevias tel_dssitsol
                       WITH FRAME f_sol054.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  IF   glb_cdcritic > 0   THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.

                  UPDATE tel_dtmesano tel_nrdevias WITH FRAME f_sol054.

                  ASSIGN aux_dtmesref = INTEGER(SUBSTR(STRING(tel_dtmesano,
                                                       "999999"),1,2))
                         aux_dtanoref = INTEGER(SUBSTRING(STRING(tel_dtmesano,
                                                    "999999"),3,4)).

                  IF   (aux_dtmesref = 0  OR  aux_dtmesref > 12)       OR
                       (aux_dtanoref < 1993)                           OR
                       (aux_dtanoref = 1993  AND  aux_dtmesref < 11)   OR
                       (aux_dtanoref  > YEAR(glb_dtmvtolt))            THEN
                       DO:
                          glb_cdcritic = 13.
                          NEXT.
                       END.

                  ASSIGN aux_dtgerref = DATE(aux_dtmesref,aux_dtdiaref,
                                             aux_dtanoref)
                         aux_dtmvtolt = ((DATE(MONTH(glb_dtmvtolt),28,
                                          YEAR(glb_dtmvtolt)) + 4) -
                                          DAY(DATE(MONTH(glb_dtmvtolt),28,
                                          YEAR(glb_dtmvtolt)) + 4)).

                  IF   aux_dtgerref > aux_dtmvtolt   THEN
                       DO:
                          glb_cdcritic = 13.
                          NEXT.
                       END.

                  ASSIGN crapsol.nrdevias = tel_nrdevias
                         crapsol.dsparame = STRING(tel_dtmesano,"999999").

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                    NEXT.

            END. /* Fim da transacao */

            RELEASE crapsol.

            tel_nrseqsol = 0.

            CLEAR FRAME f_sol054 NO-PAUSE.
        END.
   ELSE
   IF   glb_cddopcao = "C"   THEN
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
                     CLEAR FRAME f_sol054 NO-PAUSE.
                     NEXT.
                 END.

            ASSIGN tel_dtmesano = INTEGER(SUBSTRING(crapsol.dsparame,1,6))
                   tel_nrdevias = crapsol.nrdevias
                   tel_dssitsol = IF crapsol.insitsol = 1
                                     THEN  "1 - A FAZER"
                                     ELSE  "2 - PROCESSADA".

            DISPLAY tel_dtmesano tel_nrdevias tel_dssitsol WITH FRAME f_sol054.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO TRANSACTION ON ERROR UNDO, LEAVE:

           DO aux_qtleitur = 1 TO 5 :

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
                    CLEAR FRAME f_sol054 NO-PAUSE.
                    NEXT.
                END.

           ASSIGN  tel_dtmesano = INTEGER(SUBSTRING(crapsol.dsparame,1,6))
                   tel_nrdevias = crapsol.nrdevias
                   tel_dssitsol = "1 - A FAZER".

           DISPLAY tel_dtmesano tel_nrdevias tel_dssitsol WITH FRAME f_sol054.

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

           tel_nrseqsol = 0.

           CLEAR FRAME f_sol054 NO-PAUSE.

        END. /* Fim da transacao */

   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            IF   CAN-FIND (crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                         crapsol.nrsolici = aux_nrsolici   AND
                                         crapsol.dtrefere = glb_dtmvtolt   AND
                                         crapsol.nrseqsol = tel_nrseqsol
                                         USE-INDEX crapsol1) THEN
                 DO:
                     glb_cdcritic = 118.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_sol054 NO-PAUSE.
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

               UPDATE tel_dtmesano tel_nrdevias   WITH FRAME f_sol054.

               ASSIGN aux_dtmesref = INTEGER(SUBSTR(STRING(tel_dtmesano,
                                                    "999999"),1,2))
                      aux_dtanoref = INTEGER(SUBSTRING(STRING(tel_dtmesano,
                                                    "999999"),3,4)).

               IF   (aux_dtmesref = 0  OR  aux_dtmesref > 12)       OR
                    (aux_dtanoref < 1993)                           OR
                    (aux_dtanoref = 1993  AND  aux_dtmesref < 11)   OR
                    (aux_dtanoref > YEAR(glb_dtmvtolt) )            THEN

                    DO:
                       glb_cdcritic = 13.
                       NEXT.
                    END.

               ASSIGN aux_dtgerref = DATE(aux_dtmesref,aux_dtdiaref,
                                          aux_dtanoref)
                      aux_dtmvtolt = ((DATE(MONTH(glb_dtmvtolt),28,
                                      YEAR(glb_dtmvtolt)) + 4) -
                                      DAY(DATE(MONTH(glb_dtmvtolt),28,
                                      YEAR(glb_dtmvtolt)) + 4)).

               IF   aux_dtgerref > aux_dtmvtolt   THEN
                    DO:
                       glb_cdcritic = 13.
                       NEXT.
                    END.
               ELSE
                   LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

            DO TRANSACTION ON ERROR UNDO, LEAVE:

               CREATE crapsol.
               ASSIGN crapsol.nrsolici = aux_nrsolici
                      crapsol.dtrefere = glb_dtmvtolt
                      crapsol.nrseqsol = tel_nrseqsol
                      crapsol.cdempres = 11
                      crapsol.dsparame = STRING(tel_dtmesano,"999999")
                      crapsol.insitsol = 1
                      crapsol.nrdevias = tel_nrdevias
                      crapsol.cdcooper = glb_cdcooper.

            END. /* Fim da transacao */

            RELEASE crapsol.

            tel_nrseqsol = 0.

            CLEAR FRAME f_sol054 NO-PAUSE.

        END.  /* FIM DO DO */

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
