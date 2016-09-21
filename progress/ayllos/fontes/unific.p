/* .............................................................................

   Programa: Fontes/unific.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/95.                     Ultima atualizacao: 05/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela UNIFIC -- Unificacao das aplicacoes RDCA.

   Alteracoes: 07/03/96 - Alterado para reduzir codigo para nao exceder 63k.

               04/10/96 - Alterado para reduzir codigo .r (Odair).

               27/11/96 - Tratar RDCAII (Odair).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
             03/01/2005 - Incluir var_faixas_ir (Margarete).  

             05/07/2005 - Alimentado campo cdcooper da tabela crapuni (Diego).
             
             03/02/2006 - Unificacao dos bancos - SQLWorks - Eder

             28/11/2006 - Colocacao do USE-INDEX na craprda (Evandro).
             
             05/12/2013 - Alteracao referente a integracao Progress X 
                          Dataserver Oracle 
                          Inclusao do VALIDATE ( André Euzébio / SUPERO) 
............................................................................. */

{ includes/var_online.i }
{ includes/var_faixas_ir.i "NEW"} 

DEF      VAR choice       AS INT     INIT 1                          NO-UNDO.
DEF      VAR cmdcount     AS INT     INIT 56                         NO-UNDO.
DEF      VAR lastchoice   AS INT     INIT 1                          NO-UNDO.

DEF      VAR ultimo       AS INT                                     NO-UNDO.
DEF      VAR ant          AS INT                                     NO-UNDO.

DEF      VAR tel_nrapl    AS INT     FORMAT "zzz,zzz" EXTENT 56      NO-UNDO.

DEF      VAR tel_flgap    AS LOGICAL FORMAT "*/ " EXTENT 56          NO-UNDO.

DEF      VAR tel_nrdconta AS INT     FORMAT "zzz,zzz,9"              NO-UNDO.
DEF      VAR tel_nrapluni AS INT     FORMAT "zzz,zz9"                NO-UNDO.
DEF      VAR tel_dtapluni AS DATE    FORMAT "99/99/9999"             NO-UNDO.
DEF      VAR tel_vlsdesti AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"    NO-UNDO.

DEF      VAR ant_flgaplic AS LOGICAL                                 NO-UNDO.

DEF      VAR rda_nraplica AS INT     EXTENT 56                       NO-UNDO.

DEF      VAR aux_flgaplic AS LOGICAL                                 NO-UNDO.
DEF      VAR aux_flgalter AS LOGICAL                                 NO-UNDO.

DEF      VAR aux_cddopcao AS CHAR                                    NO-UNDO.
DEF      VAR aux_confirma AS CHAR    FORMAT "!"                      NO-UNDO.

DEF      VAR aux_stimeout AS INT                                     NO-UNDO.
DEF      VAR aux_nrctatos AS INT                                     NO-UNDO.
DEF      VAR aux_qtunific AS INT                                     NO-UNDO.

DEF TEMP-TABLE crawrda                                               NO-UNDO
           FIELD nraplica AS INT
           FIELD dtmvtolt AS DATE
           FIELD vlaplica AS DECIMAL
           FIELD vlsdrdca AS DECIMAL
           FIELD flgaplic AS LOGICAL.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao     AT 03 LABEL "Opcao" AUTO-RETURN
                            HELP "Entre com a opcao desejada (C ou U)."
                            VALIDATE(CAN-DO("C,U",glb_cddopcao),
                                     "014 - Opcao errada.")

     tel_nrdconta     AT 13 LABEL "Conta/dv" AUTO-RETURN
                            HELP "Entre com o numero da conta do associado."
     crapass.nmprimtl AT 33 NO-LABEL FORMAT "x(42)"
     SKIP (1)
     tel_nrapluni     AT 03 LABEL "Unificacao"
                     HELP "Entre com o numero da unificacao ou F7 para listar."

     tel_dtapluni     AT 25 LABEL "Data"
     tel_vlsdesti     AT 42 LABEL "Saldo Estimado"
     SKIP(1)
     "Grade de Aplicacoes" AT 31
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_unific.

FORM tel_nrapl[01] AT 01    tel_flgap[01] AT 08
     tel_nrapl[02] AT 10    tel_flgap[02] AT 17
     tel_nrapl[03] AT 19    tel_flgap[03] AT 26
     tel_nrapl[04] AT 28    tel_flgap[04] AT 35
     tel_nrapl[05] AT 37    tel_flgap[05] AT 44
     tel_nrapl[06] AT 46    tel_flgap[06] AT 53
     tel_nrapl[07] AT 55    tel_flgap[07] AT 62
     tel_nrapl[08] AT 64    tel_flgap[08] AT 71
     SKIP
     tel_nrapl[09] AT 01    tel_flgap[09] AT 08
     tel_nrapl[10] AT 10    tel_flgap[10] AT 17
     tel_nrapl[11] AT 19    tel_flgap[11] AT 26
     tel_nrapl[12] AT 28    tel_flgap[12] AT 35
     tel_nrapl[13] AT 37    tel_flgap[13] AT 44
     tel_nrapl[14] AT 46    tel_flgap[14] AT 53
     tel_nrapl[15] AT 55    tel_flgap[15] AT 62
     tel_nrapl[16] AT 64    tel_flgap[16] AT 71
     SKIP
     tel_nrapl[17] AT 01    tel_flgap[17] AT 08
     tel_nrapl[18] AT 10    tel_flgap[18] AT 17
     tel_nrapl[19] AT 19    tel_flgap[19] AT 26
     tel_nrapl[20] AT 28    tel_flgap[20] AT 35
     tel_nrapl[21] AT 37    tel_flgap[21] AT 44
     tel_nrapl[22] AT 46    tel_flgap[22] AT 53
     tel_nrapl[23] AT 55    tel_flgap[23] AT 62
     tel_nrapl[24] AT 64    tel_flgap[24] AT 71
     SKIP
     tel_nrapl[25] AT 01    tel_flgap[25] AT 08
     tel_nrapl[26] AT 10    tel_flgap[26] AT 17
     tel_nrapl[27] AT 19    tel_flgap[27] AT 26
     tel_nrapl[28] AT 28    tel_flgap[28] AT 35
     tel_nrapl[29] AT 37    tel_flgap[29] AT 44
     tel_nrapl[30] AT 46    tel_flgap[30] AT 53
     tel_nrapl[31] AT 55    tel_flgap[31] AT 62
     tel_nrapl[32] AT 64    tel_flgap[32] AT 71
     SKIP
     tel_nrapl[33] AT 01    tel_flgap[33] AT 08
     tel_nrapl[34] AT 10    tel_flgap[34] AT 17
     tel_nrapl[35] AT 19    tel_flgap[35] AT 26
     tel_nrapl[36] AT 28    tel_flgap[36] AT 35
     tel_nrapl[37] AT 37    tel_flgap[37] AT 44
     tel_nrapl[38] AT 46    tel_flgap[38] AT 53
     tel_nrapl[39] AT 55    tel_flgap[39] AT 62
     tel_nrapl[40] AT 64    tel_flgap[40] AT 71
     SKIP
     tel_nrapl[41] AT 01    tel_flgap[41] AT 08
     tel_nrapl[42] AT 10    tel_flgap[42] AT 17
     tel_nrapl[43] AT 19    tel_flgap[43] AT 26
     tel_nrapl[44] AT 28    tel_flgap[44] AT 35
     tel_nrapl[45] AT 37    tel_flgap[45] AT 44
     tel_nrapl[46] AT 46    tel_flgap[46] AT 53
     tel_nrapl[47] AT 55    tel_flgap[47] AT 62
     tel_nrapl[48] AT 64    tel_flgap[48] AT 71
     SKIP
     tel_nrapl[49] AT 01    tel_flgap[49] AT 08
     tel_nrapl[50] AT 10    tel_flgap[50] AT 17
     tel_nrapl[51] AT 19    tel_flgap[51] AT 26
     tel_nrapl[52] AT 28    tel_flgap[52] AT 35
     tel_nrapl[53] AT 37    tel_flgap[53] AT 44
     tel_nrapl[54] AT 46    tel_flgap[54] AT 53
     tel_nrapl[55] AT 55    tel_flgap[55] AT 62
     tel_nrapl[56] AT 64    tel_flgap[56] AT 71 /*
     SKIP
     tel_nrapl[57] AT 01    tel_flgap[57] AT 08
     tel_nrapl[58] AT 10    tel_flgap[58] AT 17
     tel_nrapl[59] AT 19    tel_flgap[59] AT 26
     tel_nrapl[60] AT 28    tel_flgap[60] AT 35
     tel_nrapl[61] AT 37    tel_flgap[61] AT 44
     tel_nrapl[62] AT 46    tel_flgap[62] AT 53
     tel_nrapl[63] AT 55    tel_flgap[63] AT 62
     tel_nrapl[64] AT 64    tel_flgap[64] AT 71
     SKIP
     tel_nrapl[65] AT 01    tel_flgap[65] AT 08
     tel_nrapl[66] AT 10    tel_flgap[66] AT 17
     tel_nrapl[67] AT 19    tel_flgap[67] AT 26
     tel_nrapl[68] AT 28    tel_flgap[68] AT 35
     tel_nrapl[69] AT 37    tel_flgap[69] AT 44
     tel_nrapl[70] AT 46    tel_flgap[70] AT 53
     tel_nrapl[71] AT 55    tel_flgap[71] AT 62
     tel_nrapl[72] AT 64    tel_flgap[72] AT 71   */
     WITH ROW 12 COLUMN 5 OVERLAY NO-LABELS NO-BOX FRAME f_aplicacoes.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

VIEW FRAME f_moldura.

PAUSE 0.

TRANS_1:

DO WHILE TRUE:

   RUN fontes/inicia.p.

   NEXT-PROMPT tel_nrdconta WITH FRAME f_unific.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_unific NO-PAUSE.
               CLEAR FRAME f_aplicacoes NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao tel_nrdconta WITH FRAME f_unific.

      glb_nrcalcul = tel_nrdconta.

      RUN fontes/digfun.p.

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                         crapass.nrdconta = tel_nrdconta  NO-LOCK NO-ERROR.

      IF   NOT glb_stsnrcal OR  NOT AVAILABLE crapass   THEN
           DO:
               glb_cdcritic = IF NOT glb_stsnrcal
                                 THEN 8
                                 ELSE 9.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_unific.
               NEXT.
           END.

      IF   aux_cddopcao <> glb_cddopcao   THEN
           DO:
               { includes/acesso.i}
               aux_cddopcao = glb_cddopcao.
           END.

      DISPLAY crapass.nmprimtl WITH FRAME f_unific.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "UNIFIC"   THEN
                 DO:
                     HIDE FRAME f_aplicacoes.
                     HIDE FRAME f_unific.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   glb_cddopcao = "U"  THEN
        DO:
            ASSIGN tel_dtapluni = glb_dtmvtolt
                   tel_nrapluni = 0
                   tel_vlsdesti = 0.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        CLEAR FRAME f_aplicacoes NO-PAUSE.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.

               UPDATE tel_nrapluni WITH FRAME f_unific

               EDITING:

                  READKEY.

                  IF   LASTKEY = KEYCODE("F7")   THEN
                       DO:
                           RUN fontes/listauni.p (INPUT tel_nrdconta,
                                                  OUTPUT tel_nrapluni).

                           IF   glb_cdcritic > 0   THEN
                                DO:
                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    glb_cdcritic = 0.
                                END.

                           DISPLAY tel_nrapluni WITH FRAME f_unific.
                       END.

                  APPLY LASTKEY.

               END.  /*  Fim do EDITING  */
               /*
               FOR EACH crawrda:

                   DELETE crawrda.

               END.  /*  Fim do FOR EACH  */
               */
               
               EMPTY TEMP-TABLE crawrda.

               ASSIGN choice       = 0
                      tel_nrapl    = 0
                      tel_vlsdesti = 0
                      aux_qtunific = 0
                      tel_flgap    = FALSE
                      aux_flgaplic = FALSE
                      aux_flgalter = FALSE.

               HIDE MESSAGE NO-PAUSE.

               DISPLAY tel_vlsdesti  WITH FRAME f_unific.

               TRANS_1:

               FOR EACH craprda WHERE craprda.cdcooper  = glb_cdcooper   AND
                                      craprda.nrdconta  = tel_nrdconta   AND
                                      craprda.insaqtot  = 0              AND
                                      craprda.tpaplica  = 3              AND
                                     (craprda.inaniver  = 1              OR
                                     (craprda.inaniver  = 0              AND
                                      craprda.dtfimper <= glb_dtmvtolt)) 
                                      USE-INDEX craprda2
                                      EXCLUSIVE-LOCK ON ERROR UNDO, LEAVE:

                   FIND crapuni WHERE crapuni.cdcooper = glb_cdcooper       AND
                                      crapuni.dtmvtolt = glb_dtmvtolt       AND
                                      crapuni.nrdconta = craprda.nrdconta   AND
                                      crapuni.nraplica = craprda.nraplica
                                      USE-INDEX crapuni3 NO-LOCK NO-ERROR.

                   IF   AVAILABLE crapuni   THEN
                        IF   tel_nrapluni = 0   THEN
                             NEXT.
                        ELSE
                        IF   crapuni.nruniapl = tel_nrapluni   THEN
                             aux_flgaplic = TRUE.
                        ELSE
                             NEXT.
                   ELSE
                        aux_flgaplic = FALSE.

                   { includes/aplicacao.i }

                   IF   dup_vlsdrdca    <= 0   OR
                        craptrd.txofidia = 0   THEN
                        NEXT.

                   CREATE crawrda.
                   ASSIGN crawrda.nraplica = craprda.nraplica
                          crawrda.dtmvtolt = craprda.dtmvtolt
                          crawrda.vlaplica = craprda.vlaplica
                          crawrda.vlsdrdca = dup_vlsdrdca
                          crawrda.flgaplic = aux_flgaplic.
                   choice = choice + 1.

                   IF   choice > cmdcount   THEN
                        LEAVE.

                   ASSIGN tel_nrapl[choice] = craprda.nraplica
                          tel_flgap[choice] = aux_flgaplic.

                   IF   aux_flgaplic   THEN
                        ASSIGN tel_vlsdesti = tel_vlsdesti + dup_vlsdrdca
                               aux_qtunific = aux_qtunific + 1.

               END.  /*  Fim do FOR EACH  */

               IF   choice <= 1   THEN
                    DO:
                        glb_cdcritic = 463.
                        NEXT.
                    END.

               IF   tel_nrapluni = 0   THEN
                    DO:
                        aux_flgalter = TRUE.

                        DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE.

                           FIND FIRST crapmat WHERE 
                                      crapmat.cdcooper = glb_cdcooper
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                           IF   NOT AVAILABLE crapmat   THEN
                                IF   LOCKED crapmat   THEN
                                     NEXT.
                                ELSE
                                     glb_cdcritic = 194.
                           ELSE
                                ASSIGN crapmat.nruniapl = crapmat.nruniapl + 1
                                       tel_nrapluni     = crapmat.nruniapl.

                           LEAVE.

                        END.  /*  Fim do DO WHILE TRUE e da transacao  */

                        RELEASE crapmat.

                        IF   glb_cdcritic > 0   THEN
                             NEXT.

                        DISPLAY tel_nrapluni tel_dtapluni WITH FRAME f_unific.
                    END.
               ELSE
                    DO:
                        FIND FIRST crapuni WHERE
                                   crapuni.cdcooper = glb_cdcooper   AND
                                   crapuni.nrdconta = tel_nrdconta   AND
                                   crapuni.dtmvtolt = glb_dtmvtolt   AND
                                   crapuni.nruniapl = tel_nrapluni
                                   NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE crapuni   THEN
                             DO:
                                 glb_cdcritic = 465.
                                 NEXT.
                             END.
                    END.

               DISPLAY tel_vlsdesti WITH FRAME f_unific.

               DISPLAY tel_nrapl tel_flgap WITH FRAME f_aplicacoes.

               ASSIGN ultimo = choice
                      choice = 1.

               COLOR DISPLAY MESSAGES tel_nrapl[choice] WITH FRAME f_aplicacoes.

               GETCHOICE:
               REPEAT:

                 IF   RETRY    THEN
                      DO:
                          DISPLAY tel_nrapl WITH FRAME f_aplicacoes.
                          COLOR DISPLAY MESSAGES tel_nrapl[choice]
                                        WITH FRAME f_aplicacoes.
                      END.

                 IF   lastchoice NE choice   THEN
                      DO:
                          COLOR DISPLAY NORMAL tel_nrapl[lastchoice]
                                        WITH FRAME f_aplicacoes.
                          lastchoice = choice.
                          COLOR DISPLAY MESSAGES tel_nrapl[choice]
                                        WITH FRAME f_aplicacoes.
                      END.

                 IF   tel_nrapl[choice] > 0   THEN
                      DO:
                          FIND FIRST crawrda WHERE
                                     crawrda.nraplica = tel_nrapl[choice].

                          HIDE MESSAGE NO-PAUSE.
                          MESSAGE COLOR NORMAL
                                "Aplicado em:"
                                crawrda.dtmvtolt
                                " Valor aplicado:"
                                STRING(crawrda.vlaplica,"zzzzz,zz9.99")
                                " Saldo Atual:"
                                STRING(crawrda.vlsdrdca,"zzzzz,zz9.99-").
                      END.

                 READKEY.

                 HIDE MESSAGE NO-PAUSE.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                      LEAVE.
                 ELSE
                 IF   LASTKEY = KEYCODE("UP")   THEN
                      DO:
                          ASSIGN ant = choice
                                 choice = choice - 8.

                          IF   choice <= 0   THEN
                               choice = choice + cmdcount.

                          IF   tel_nrapl[choice] = 0   THEN
                               choice = ant.

                          NEXT GETCHOICE.
                      END.
                 ELSE
                 IF   LASTKEY = KEYCODE("LEFT")   THEN
                      DO:
                          choice = IF   choice = 1 THEN cmdcount
                                   ELSE choice - 1.

                          IF   tel_nrapl[choice] = 0   THEN
                               choice = ultimo.

                          NEXT GETCHOICE.
                      END.
                 ELSE
                 IF   LASTKEY = KEYCODE("RIGHT")   OR
                      LASTKEY = KEYCODE(" ")      THEN
                      DO:
                          choice = IF   choice = cmdcount THEN 1
                                   ELSE choice + 1.

                          IF   tel_nrapl[choice] = 0   THEN
                               choice = 1.

                          NEXT GETCHOICE.
                      END.
                 ELSE
                 IF   LASTKEY = KEYCODE("DOWN")   THEN
                      DO:
                          ASSIGN ant = choice
                                 choice = choice + 8.

                          IF   choice GT cmdcount   THEN
                               choice = choice - cmdcount.

                          IF   tel_nrapl[choice] = 0   THEN
                               choice = ant.

                          NEXT GETCHOICE.
                      END.
                 ELSE
                 IF   KEYFUNCTION(LASTKEY) = "HOME"   THEN
                      DO:
                          choice = 1.
                          NEXT GETCHOICE.
                      END.

                 IF   LASTKEY = KEYCODE("RETURN")   OR
                      KEYFUNCTION(LASTKEY) = "GO"   THEN
                      DO:
                          IF   tel_nrapl[choice] > 0   then
                               DO:
                                   ASSIGN ant_flgaplic = tel_flgap[choice]
                                          aux_flgalter = TRUE.

                                   IF   tel_flgap[choice]    THEN
                                        tel_flgap[choice] = FALSE.
                                   ELSE
                                        tel_flgap[choice] = TRUE.

                                   IF   ant_flgaplic <> tel_flgap[choice]   THEN
                                        DO:
                                            IF   ant_flgaplic   THEN
                                                 ASSIGN
                                                   tel_vlsdesti = tel_vlsdesti -
                                                              crawrda.vlsdrdca
                                                   aux_qtunific = aux_qtunific -
                                                                  1.
                                            ELSE
                                                 ASSIGN
                                                   tel_vlsdesti = tel_vlsdesti +
                                                              crawrda.vlsdrdca
                                                   aux_qtunific = aux_qtunific +
                                                                  1.

                                            DISPLAY tel_vlsdesti
                                                    WITH FRAME f_unific.
                                        END.

                                   DISPLAY tel_flgap[choice]
                                           WITH FRAME f_aplicacoes.
                               END.

                          NEXT GETCHOICE.
                      END.
                 ELSE
                      BELL.

               END.  /* GETCHOICE e do REPEAT  */

               IF   aux_flgalter   THEN
                    DO:
                        IF   aux_qtunific > 1   THEN
                             DO:
                                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                    ASSIGN aux_confirma = "N"
                                           glb_cdcritic = 78.

                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE COLOR NORMAL glb_dscritic
                                                         UPDATE aux_confirma.
                                    LEAVE.

                                 END.  /*  Fim do DO WHILE TRUE  */

                                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                                      aux_confirma <> "S"   THEN
                                      DO:
                                          glb_cdcritic = 79.
                                          RUN fontes/critic.p.
                                          BELL.
                                          MESSAGE glb_dscritic.
                                          ASSIGN glb_cdcritic = 0
                                                 tel_vlsdesti = 0.
                                          DISPLAY tel_vlsdesti
                                                  WITH FRAME f_unific.
                                          CLEAR FRAME f_aplicacoes NO-PAUSE.
                                          NEXT.
                                      END.
                             END.
                        ELSE
                             tel_flgap = FALSE.

                        glb_cdcritic = 0.

                        HIDE MESSAGE NO-PAUSE.

                        DO choice = 1 TO cmdcount:

                           IF   tel_nrapl[choice] = 0    THEN
                                LEAVE.

                           DO WHILE TRUE TRANSACTION ON ERROR UNDO, RETRY:

                              FIND crapuni WHERE
                                   crapuni.cdcooper = glb_cdcooper      AND
                                   crapuni.nrdconta = tel_nrdconta      AND
                                   crapuni.dtmvtolt = glb_dtmvtolt      AND
                                   crapuni.nruniapl = tel_nrapluni      AND
                                   crapuni.nraplica = tel_nrapl[choice]
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                              IF   NOT AVAILABLE crapuni   THEN
                                   IF   LOCKED crapuni   THEN
                                        DO:
                                            PAUSE 2 NO-MESSAGE.
                                            NEXT.
                                        END.
                                   ELSE
                                   IF   tel_flgap[choice]   THEN
                                        DO:
                                            CREATE crapuni.
                                            ASSIGN
                                              crapuni.dtmvtolt = glb_dtmvtolt
                                              crapuni.insituni = 0
                                              crapuni.nrdconta = tel_nrdconta
                                              crapuni.nruniapl = tel_nrapluni
                                              crapuni.nraplica =
                                                             tel_nrapl[choice]
                                              crapuni.cdcooper = glb_cdcooper.
                                            VALIDATE crapuni.
                                        END.
                                   ELSE .
                              ELSE
                              IF   NOT tel_flgap[choice]   THEN
                                   DELETE crapuni.

                              LEAVE.

                           END.  /*  Fim do DO WHILE TRUE e da transacao  */

                        END.  /*  Fim do DO .. TO  */
                    END.

               tel_vlsdesti = 0.

               DISPLAY tel_vlsdesti WITH FRAME f_unific.

               CLEAR FRAME f_aplicacoes NO-PAUSE.

            END.  /*  Fim do DO WHILE TRUE  */

            HIDE MESSAGE NO-PAUSE.

        END.  /*  Fim da Opcao U  */
   ELSE
   IF   glb_cddopcao = "C"   THEN
        DO:
            ASSIGN tel_nrapluni = 0
                   tel_vlsdesti = 0
                   tel_dtapluni = ?.

            DISPLAY tel_dtapluni tel_vlsdesti WITH FRAME f_unific.

            CLEAR FRAME f_aplicacoes NO-PAUSE.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        tel_dtapluni = ?.
                        DISPLAY tel_dtapluni WITH FRAME f_unific.
                        CLEAR FRAME f_aplicacoes NO-PAUSE.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.

               UPDATE tel_nrapluni WITH FRAME f_unific

               EDITING:

                  READKEY.

                  IF   LASTKEY = KEYCODE("F7")   THEN
                       DO:
                           RUN fontes/listauni.p (INPUT tel_nrdconta,
                                                  OUTPUT tel_nrapluni).

                           IF   glb_cdcritic > 0   THEN
                                DO:
                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    glb_cdcritic = 0.
                                END.

                           DISPLAY tel_nrapluni WITH FRAME f_unific.
                       END.

                  APPLY LASTKEY.

               END.  /*  Fim do EDITING  */

               IF   tel_nrapluni = 0   THEN
                    DO:
                        glb_cdcritic = 425.
                        NEXT.
                    END.

               ASSIGN choice = 0
                      tel_nrapl = 0
                      tel_flgap = FALSE.

               FOR EACH crapuni WHERE crapuni.cdcooper = glb_cdcooper   AND
                                      crapuni.nrdconta = tel_nrdconta   AND
                                      crapuni.nruniapl = tel_nrapluni   NO-LOCK:

                   choice = choice + 1.

                   IF   choice > cmdcount   THEN
                        LEAVE.

                   ASSIGN tel_nrapl[choice] = crapuni.nraplica
                          tel_dtapluni      = crapuni.dtmvtolt.

               END.  /*  Fim do FOR EACH  --  Leitura da unificacao  */

               IF   choice = 0   THEN
                    DO:
                        glb_cdcritic = 465.
                        NEXT.
                    END.

               HIDE MESSAGE NO-PAUSE.

               DISPLAY tel_dtapluni WITH FRAME f_unific.
               DISPLAY tel_nrapl tel_flgap WITH FRAME f_aplicacoes.

            END.  /*  Fim do DO WHILE TRUE  */

            HIDE MESSAGE NO-PAUSE.
            CLEAR FRAME f_aplicacoes NO-PAUSE.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

