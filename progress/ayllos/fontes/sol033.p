/* .............................................................................

   Programa: Fontes/sol033.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/93.                           Ultima atualizacao: 17/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SOL033.

   Alteracao - 09/12/94 - Alterado para colocar a descricao dos lotes tipo
                          10 e 11 (Odair).

               29/06/95 - Alterado para colocar a descricao do tipo de lote 12
                          (Odair).

               25/03/98 - Tratamento para milenio e troca para V8 (Margarete).

               27/10/00 - Alterar nrdolote para 6 posicoes (Margarete/Planner).

               27/01/2005 - Mudado o LABEL do campo "tel_cdagenci" de "Agencia"
                            para "PAC";
                            HELP de "com a agencia" para "com o PAC";
                            VALIDATE de "015 - Agencia nao cadastrada." para
                            "015 - PAC nao cadastrado." (Evandro).

               05/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
              
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               17/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)                            
               
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_cdbccxlt AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_flgclass AS LOGICAL FORMAT "Sequencia/Documento"  NO-UNDO.
DEF        VAR tel_nrseqsol AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_dssitsol AS CHAR    FORMAT "x(20)"                NO-UNDO.

DEF        VAR tel_dslotmov AS CHAR    FORMAT "x(25)"                NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.

DEF        VAR aux_nrsolici AS INT     FORMAT "z9" INIT 33           NO-UNDO.
DEF        VAR aux_tentaler AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_dslotmov AS CHAR    EXTENT 50                     NO-UNDO.

FORM SKIP(1)
     glb_cddopcao AT 22 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (A,C,E ou I)"
                        VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(1)
     tel_nrseqsol AT 18 LABEL "Sequencia" AUTO-RETURN
                        HELP "Entre com o numero de sequencia da solicitacao."
                        VALIDATE (tel_nrseqsol > 0,"117 - Sequencia errada.")
     SKIP(1)
     tel_dtmvtolt AT 15 LABEL "Data do Lote" AUTO-RETURN
                        HELP "Entre com a data do lote."
                        VALIDATE(tel_dtmvtolt <> ?,"013 - Data errada.")
     SKIP(1)
     tel_cdagenci AT 20 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o PA do lote."
                        VALIDATE(CAN-FIND(crapage WHERE
                                          crapage.cdcooper = glb_cdcooper AND
                                          crapage.cdagenci = tel_cdagenci),
                                          "962 - PA nao cadastrado.")
     SKIP(1)
     tel_cdbccxlt AT 16 LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Entre com o banco/caixa do lote."
                        VALIDATE(CAN-FIND(crapbcl WHERE
                                          crapbcl.cdbccxlt = tel_cdbccxlt),
                                          "057 - Banco nao cadastrado.")
     SKIP(1)
     tel_nrdolote AT 13 LABEL "Numero do Lote" AUTO-RETURN
                        HELP "Entre com o numero do lote."
                        VALIDATE(tel_nrdolote >0,"058 - Numero do lote errado.")

     tel_dslotmov AT 40 NO-LABEL
     SKIP(1)
     tel_flgclass AT 14 LABEL "Classificacao" AUTO-RETURN
                        HELP "S - pela sequencia; D - pelo documento."
     SKIP(1)
     tel_dssitsol AT 19 LABEL "Situacao"
     WITH ROW 4 OVERLAY WIDTH 80 TITLE COLOR MESSAGE glb_tldatela
          SIDE-LABELS FRAME f_sol033.

ASSIGN glb_cddopcao = "I"
       glb_cdcritic = 0

       aux_dslotmov[01] = " 1 - Depositos a vista"
       aux_dslotmov[02] = " 2 - Capital"
       aux_dslotmov[03] = " 3 - Planos"
       aux_dslotmov[04] = ""
       aux_dslotmov[05] = ""
       aux_dslotmov[06] = ""
       aux_dslotmov[07] = " 7 - Limites de Credito"
       aux_dslotmov[08] = " 8 - Contratos de Planos"
       aux_dslotmov[09] = " 9 - Aplicacoes Financ."
       aux_dslotmov[10] = "10 - Aplicacoes  RDCA "
       aux_dslotmov[11] = "11 - Resgates  RDCA "
       aux_dslotmov[12] = "12 - Debito em Conta"
       aux_dslotmov[14] = "14 - Poup. Programada".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   ASSIGN glb_cdcritic = 0
          tel_dtmvtolt = glb_dtmvtolt
          tel_cdagenci = 0
          tel_cdbccxlt = 0
          tel_nrdolote = 0
          tel_flgclass = TRUE
          tel_dssitsol = ""
          tel_dslotmov = "".

   NEXT-PROMPT tel_nrseqsol WITH FRAME f_sol033.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao tel_nrseqsol WITH FRAME f_sol033.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "SOL033"   THEN
                 DO:
                     HIDE FRAME f_sol033.
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

               DO aux_tentaler = 1 TO 5:

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
                  IF   crapsol.insitsol <> 1   THEN
                       glb_cdcritic = 150.
                  ELSE
                       glb_cdcritic = 0.

                  LEAVE.

               END.  /*  Fim do DO .. TO  --  Tenta ler crapsol  */

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        CLEAR FRAME f_sol033 NO-PAUSE.
                        NEXT.
                    END.

               ASSIGN tel_dtmvtolt =
                          DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                               INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                               INTEGER(SUBSTRING(crapsol.dsparame,7,4)))

                      tel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,12,3))
                      tel_cdbccxlt = INTEGER(SUBSTRING(crapsol.dsparame,16,3))
                      tel_nrdolote = INTEGER(SUBSTRING(crapsol.dsparame,20,6))

                      tel_flgclass = IF SUBSTRING(crapsol.dsparame,27,1) = "1"
                                        THEN TRUE
                                        ELSE FALSE

                      tel_dssitsol = IF crapsol.insitsol = 1
                                        THEN "1 - A FAZER"
                                        ELSE "2 - PROCESSADA".

               FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                  craplot.dtmvtolt = tel_dtmvtolt   AND
                                  craplot.cdagenci = tel_cdagenci   AND
                                  craplot.cdbccxlt = tel_cdbccxlt   AND
                                  craplot.nrdolote = tel_nrdolote
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE craplot   THEN
                    DO:
                        glb_cdcritic = 60.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.

               tel_dslotmov = aux_dslotmov[craplot.tplotmov].

               DISPLAY tel_dslotmov tel_dssitsol WITH FRAME f_sol033.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_dtmvtolt tel_cdagenci tel_cdbccxlt
                         tel_nrdolote tel_flgclass
                         WITH FRAME f_sol033.

                  IF   NOT CAN-FIND(craplot WHERE
                                    craplot.cdcooper = glb_cdcooper   AND
                                    craplot.dtmvtolt = tel_dtmvtolt   AND
                                    craplot.cdagenci = tel_cdagenci   AND
                                    craplot.cdbccxlt = tel_cdbccxlt   AND
                                    craplot.nrdolote = tel_nrdolote)  THEN
                       DO:
                           glb_cdcritic = 60.
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           NEXT.
                       END.

                  crapsol.dsparame = STRING(tel_dtmvtolt,"99/99/9999") + " " +
                                     STRING(tel_cdagenci,"999")      + " " +
                                     STRING(tel_cdbccxlt,"999")      + " " +
                                     STRING(tel_nrdolote,"999999")   + " " +
                                     IF tel_flgclass THEN "1" ELSE "2".

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                    NEXT.

            END. /* Fim da transacao */

            RELEASE crapsol.

            CLEAR FRAME f_sol033 NO-PAUSE.
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
                     CLEAR FRAME f_sol033 NO-PAUSE.
                     NEXT.
                 END.

            ASSIGN tel_dtmvtolt = DATE(INTEGER(SUBSTR(crapsol.dsparame,4,2)),
                                       INTEGER(SUBSTR(crapsol.dsparame,1,2)),
                                       INTEGER(SUBSTR(crapsol.dsparame,7,4)))

                   tel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,12,3))
                   tel_cdbccxlt = INTEGER(SUBSTRING(crapsol.dsparame,16,3))
                   tel_nrdolote = INTEGER(SUBSTRING(crapsol.dsparame,20,6))

                   tel_flgclass = IF SUBSTRING(crapsol.dsparame,27,1) = "1"
                                     THEN TRUE
                                     ELSE FALSE

                   tel_dssitsol = IF crapsol.insitsol = 1
                                     THEN "1 - A FAZER"
                                     ELSE "2 - PROCESSADA".

            FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                               craplot.dtmvtolt = tel_dtmvtolt   AND
                               craplot.cdagenci = tel_cdagenci   AND
                               craplot.cdbccxlt = tel_cdbccxlt   AND
                               craplot.nrdolote = tel_nrdolote
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craplot   THEN
                 DO:
                     glb_cdcritic = 60.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     NEXT.
                 END.

            tel_dslotmov = aux_dslotmov[craplot.tplotmov].

            DISPLAY tel_dtmvtolt tel_cdagenci tel_cdbccxlt
                    tel_nrdolote tel_dslotmov tel_flgclass
                    tel_dssitsol
                    WITH FRAME f_sol033.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO TRANSACTION ON ERROR UNDO, LEAVE:

           DO aux_tentaler = 1 TO 5:

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
                   glb_cdcritic = 0.

              LEAVE.

           END.  /*  Fim do DO .. TO  --  Tenta ler crapsol  */

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    CLEAR FRAME f_sol033 NO-PAUSE.
                    NEXT.
                END.

           ASSIGN tel_dtmvtolt = DATE(INTEGER(SUBSTR(crapsol.dsparame,4,2)),
                                      INTEGER(SUBSTR(crapsol.dsparame,1,2)),
                                      INTEGER(SUBSTR(crapsol.dsparame,7,4)))

                  tel_cdagenci = INTEGER(SUBSTRING(crapsol.dsparame,12,3))
                  tel_cdbccxlt = INTEGER(SUBSTRING(crapsol.dsparame,16,3))
                  tel_nrdolote = INTEGER(SUBSTRING(crapsol.dsparame,20,6))

                  tel_flgclass = IF SUBSTRING(crapsol.dsparame,27,1) = "1"
                                    THEN TRUE
                                    ELSE FALSE

                  tel_dssitsol = IF crapsol.insitsol = 1
                                    THEN "1 - A FAZER"
                                    ELSE "2 - PROCESSADA".

           FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                              craplot.dtmvtolt = tel_dtmvtolt   AND
                              craplot.cdagenci = tel_cdagenci   AND
                              craplot.cdbccxlt = tel_cdbccxlt   AND
                              craplot.nrdolote = tel_nrdolote
                              NO-LOCK NO-ERROR.

           IF   NOT AVAILABLE craplot   THEN
                DO:
                    glb_cdcritic = 60.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.

           tel_dslotmov = aux_dslotmov[craplot.tplotmov].

           DISPLAY tel_dtmvtolt tel_cdagenci tel_cdbccxlt
                   tel_nrdolote tel_dslotmov tel_flgclass
                   tel_dssitsol
                   WITH FRAME f_sol033.

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

           CLEAR FRAME f_sol033 NO-PAUSE.

        END. /* Fim da transacao */
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                               crapsol.nrsolici = aux_nrsolici   AND
                               crapsol.dtrefere = glb_dtmvtolt   AND
                               crapsol.nrseqsol = tel_nrseqsol
                               USE-INDEX crapsol1 NO-LOCK NO-ERROR NO-WAIT.

            IF   AVAILABLE crapsol   THEN
                 DO:
                     glb_cdcritic = 118.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_sol033 NO-PAUSE.
                     NEXT.
                 END.

            DISPLAY tel_dslotmov tel_dssitsol WITH FRAME f_sol033.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_dtmvtolt tel_cdagenci tel_cdbccxlt
                      tel_nrdolote tel_flgclass
                      WITH FRAME f_sol033.

               IF   NOT CAN-FIND(craplot WHERE
                                 craplot.cdcooper = glb_cdcooper   AND
                                 craplot.dtmvtolt = tel_dtmvtolt   AND
                                 craplot.cdagenci = tel_cdagenci   AND
                                 craplot.cdbccxlt = tel_cdbccxlt   AND
                                 craplot.nrdolote = tel_nrdolote)  THEN
                    DO:
                        glb_cdcritic = 60.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
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
                      crapsol.nrseqsol = tel_nrseqsol
                      crapsol.cdempres = 11
                      crapsol.cdcooper = glb_cdcooper

                      crapsol.dsparame =
                              STRING(tel_dtmvtolt,"99/99/9999") + " " +
                              STRING(tel_cdagenci,"999")      + " " +
                              STRING(tel_cdbccxlt,"999")      + " " +
                              STRING(tel_nrdolote,"999999")     + " " +
                              IF tel_flgclass THEN "1" ELSE "2".

            END. /* Fim da transacao */

            RELEASE crapsol.

            CLEAR FRAME f_sol033 NO-PAUSE.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
