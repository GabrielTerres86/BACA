/* .............................................................................

   Programa: Fontes/lanplae.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/92.                         Ultima atualizacao: 14/08/2013 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela LANPLA.

   Alteracoes: 02/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               27/01/2005 - Mudado o LABEL do campo "tel_cdagenci" de "Agencia"
                            para "PAC";
                            HELP de "codigo da agencia." para "codigo do PAC.";
                            VALIDATE de "015 - Agencia nao cadastrada." para
                            "015 - PAC nao cadastrado." (Evandro).
                            
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 

               14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
............................................................................. */

{ includes/var_online.i } 

DEF SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"              NO-UNDO.
DEF SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                     NO-UNDO.
DEF SHARED VAR tel_cdbccxlt AS INT     FORMAT "zz9"                     NO-UNDO.
DEF SHARED VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"                 NO-UNDO.
DEF SHARED VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"                  NO-UNDO.
DEF SHARED VAR tel_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"      NO-UNDO.
DEF SHARED VAR tel_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"      NO-UNDO.
DEF SHARED VAR tel_qtcompln AS INT     FORMAT "zz,zz9"                  NO-UNDO.
DEF SHARED VAR tel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"      NO-UNDO.
DEF SHARED VAR tel_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"      NO-UNDO.
DEF SHARED VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"                 NO-UNDO.
DEF SHARED VAR tel_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"     NO-UNDO.
DEF SHARED VAR tel_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"     NO-UNDO.
DEF SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"              NO-UNDO.
DEF SHARED VAR tel_vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"      NO-UNDO.
DEF SHARED VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"                  NO-UNDO.
DEF SHARED VAR tel_reganter AS CHAR    FORMAT "x(50)" EXTENT 6          NO-UNDO.

DEF SHARED VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz,9"              NO-UNDO.
DEF SHARED VAR aux_dtmvtolt AS DATE                                     NO-UNDO.
DEF SHARED VAR aux_cdagenci AS INT     FORMAT "zz9"                     NO-UNDO.
DEF SHARED VAR aux_cdbccxlt AS INT     FORMAT "zz9"                     NO-UNDO.
DEF SHARED VAR aux_nrdolote AS INT     FORMAT "zzz,zz9"                 NO-UNDO.
DEF SHARED VAR aux_qtinfoln AS INT     FORMAT "zz,zz9"                  NO-UNDO.
DEF SHARED VAR aux_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"      NO-UNDO.
DEF SHARED VAR aux_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"      NO-UNDO.
DEF SHARED VAR aux_qtcompln AS INT     FORMAT "zz,zz9"                  NO-UNDO.
DEF SHARED VAR aux_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"      NO-UNDO.
DEF SHARED VAR aux_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"      NO-UNDO.
DEF SHARED VAR aux_qtdifeln AS INT     FORMAT "zz,zz9-"                 NO-UNDO.
DEF SHARED VAR aux_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"     NO-UNDO.
DEF SHARED VAR aux_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"     NO-UNDO.
DEF SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"                    NO-UNDO.
DEF SHARED VAR aux_flgerros AS LOGICAL                                  NO-UNDO.
DEF SHARED VAR aux_flgretor AS LOGICAL                                  NO-UNDO.
DEF SHARED VAR aux_regexist AS LOGICAL                                  NO-UNDO.
DEF SHARED VAR aux_contador AS INT                                      NO-UNDO.
DEF SHARED VAR aux_cddopcao AS CHAR                                     NO-UNDO.
DEF SHARED VAR aux_vllanmto AS DECIMAL                                  NO-UNDO.

DEF SHARED FRAME f_lanpla.
DEF SHARED FRAME f_regant.
DEF SHARED FRAME f_lanctos.

FORM    SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE COLOR MESSAGE " Lancamentos de Planos "
                      FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E ou I)"
                        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I",
                                  "014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 31 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE (CAN-FIND (crapage WHERE crapage.cdcooper =
                                                           glb_cdcooper AND
                                                          crapage.cdagenci =
                                  tel_cdagenci),"015 - PA nao cadastrado.")

     tel_cdbccxlt AT 47 LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE (CAN-FIND (crapbcl WHERE crapbcl.cdbccxlt =
                                  tel_cdbccxlt),"057 - Banco nao cadastrado.")

     tel_nrdolote AT 65 LABEL "Lote" AUTO-RETURN
                        HELP "Entre com o numero do lote."
                        VALIDATE (tel_nrdolote > 0,
                                  "058 - Numero do lote errado.")

     SKIP(1)
     tel_qtinfoln AT  2 LABEL "Informado:Qtd"
     tel_vlinfodb AT 24 LABEL "Debito"
     tel_vlinfocr AT 51 LABEL "Credito"
     SKIP
     tel_qtcompln AT  2 LABEL "Computado:Qtd"
     tel_vlcompdb AT 24 LABEL "Debito"
     tel_vlcompcr AT 51 LABEL "Credito"
     SKIP
     tel_qtdifeln AT  2 LABEL "Diferenca:Qtd"
     tel_vldifedb AT 24 LABEL "Debito"
     tel_vldifecr AT 51 LABEL "Credito"
     SKIP(1)
     "Conta/dv                  Valor        Seq." AT 19
     SKIP(1)
     tel_nrdconta AT 17 NO-LABEL AUTO-RETURN
                        HELP "Informe o numero da conta do associado."

     tel_vllanmto AT 32 NO-LABEL AUTO-RETURN
                        HELP "Entre com o valor do lancamento."

     tel_nrseqdig AT 56 NO-LABEL

     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_lanpla.

FORM tel_reganter[1] AT 17 NO-LABEL  tel_reganter[2] AT 17 NO-LABEL
     tel_reganter[3] AT 17 NO-LABEL  tel_reganter[4] AT 17 NO-LABEL
     tel_reganter[5] AT 17 NO-LABEL  tel_reganter[6] AT 17 NO-LABEL
     WITH ROW 15 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

FORM tel_nrdconta AT 17  tel_vllanmto AT 32
     tel_nrseqdig AT 56
     WITH ROW 15 COLUMN 2 OVERLAY NO-LABEL NO-BOX 6 DOWN FRAME f_lanctos.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      SET tel_nrdconta WITH FRAME f_lanpla.

      ASSIGN glb_nrcalcul = tel_nrdconta
             aux_nrdconta = tel_nrdconta
             glb_cdcritic = 0.

      RUN fontes/digfun.p.
      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanpla.
           END.
      ELSE
           DO:
               FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                  crapass.nrdconta = tel_nrdconta
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapass   THEN
                    DO:
                        glb_cdcritic = 9.
                        NEXT-PROMPT tel_nrdconta WITH FRAME f_lanpla.
                    END.
           END.

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lanpla.
               ASSIGN glb_cddopcao = aux_cddopcao
                      tel_dtmvtolt = aux_dtmvtolt
                      tel_cdagenci = aux_cdagenci
                      tel_cdbccxlt = aux_cdbccxlt
                      tel_nrdolote = aux_nrdolote
                      tel_nrdconta = aux_nrdconta
                      glb_cdcritic = 0.

               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_nrdconta
                       WITH FRAME f_lanpla.
               MESSAGE glb_dscritic.
               NEXT.
           END.

      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        RETURN.  /* Volta pedir a opcao para o operador */

   DO TRANSACTION:

      DO WHILE TRUE:

         aux_flgerros = FALSE.

         FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                            craplot.dtmvtolt = tel_dtmvtolt   AND
                            craplot.cdagenci = tel_cdagenci   AND
                            craplot.cdbccxlt = tel_cdbccxlt   AND
                            craplot.nrdolote = tel_nrdolote
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craplot   THEN
              IF   LOCKED craplot   THEN
                   DO:
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   glb_cdcritic = 60.
         LEAVE.
      END.

      IF   glb_cdcritic = 0   THEN
           IF   craplot.tplotmov <> 3   THEN
                glb_cdcritic = 100.

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lanpla.
               ASSIGN glb_cddopcao = aux_cddopcao
                      tel_dtmvtolt = aux_dtmvtolt
                      tel_cdagenci = aux_cdagenci
                      tel_cdbccxlt = aux_cdbccxlt
                      tel_nrdolote = aux_nrdolote
                      tel_nrdconta = aux_nrdconta
                      glb_cdcritic = 0.

               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_nrdconta
                       WITH FRAME f_lanpla.
               MESSAGE glb_dscritic.
               NEXT.
           END.

      ASSIGN tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      DO  aux_contador = 1 TO 10:

          glb_cdcritic = 0.

          FIND craplct WHERE craplct.cdcooper = glb_cdcooper   AND
                             craplct.dtmvtolt = tel_dtmvtolt   AND
                             craplct.cdagenci = tel_cdagenci   AND
                             craplct.cdbccxlt = tel_cdbccxlt   AND
                             craplct.nrdolote = tel_nrdolote   AND
                             craplct.nrdconta = tel_nrdconta   AND
                             craplct.nrdocmto = tel_nrdolote
                             USE-INDEX craplct1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE craplct   THEN
               IF   LOCKED craplct   THEN
                    DO:
                        glb_cdcritic = 114.
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 90.
                        LEAVE.
                    END.
          ELSE
               DO:
                   aux_contador = 0.
                   LEAVE.
               END.
      END.

      IF   glb_cdcritic = 0   THEN
           DO WHILE TRUE:

              FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper AND
                                 crapcot.nrdconta = tel_nrdconta
                                 USE-INDEX crapcot1
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE crapcot   THEN
                   IF   LOCKED crapcot   THEN
                        DO:
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
                   ELSE
                        glb_cdcritic = 169.

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic = 0   THEN
           DO WHILE TRUE:

              FIND FIRST crappla WHERE crappla.cdcooper = glb_cdcooper   AND
                                       crappla.nrdconta = tel_nrdconta   AND
                                       crappla.tpdplano = 1              AND
                                       crappla.dtultpag = tel_dtmvtolt   AND
                                       crappla.cdsitpla <> 9
                                       USE-INDEX crappla3
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE crappla   THEN
                   IF   LOCKED crappla   THEN
                        DO:
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
                   ELSE
                        glb_cdcritic = 200.
              ELSE
                   IF /* crappla.vlprepla <> craplct.vllanmto   OR     */
                        crappla.vlpagmes <  craplct.vllanmto   THEN
                        glb_cdcritic = 91.

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lanpla.
               ASSIGN glb_cddopcao = aux_cddopcao
                      tel_dtmvtolt = aux_dtmvtolt
                      tel_cdagenci = aux_cdagenci
                      tel_cdbccxlt = aux_cdbccxlt
                      tel_nrdolote = aux_nrdolote
                      tel_nrdconta = aux_nrdconta
                      glb_cdcritic = 0.

               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_nrdconta
                       WITH FRAME f_lanpla.
               MESSAGE glb_dscritic.
               NEXT.
           END.

      ASSIGN tel_vllanmto = craplct.vllanmto
             tel_nrseqdig = craplct.nrseqdig.

      DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
              tel_qtcompln tel_vlcompdb tel_vlcompcr
              tel_qtdifeln tel_vldifedb tel_vldifecr
              tel_nrdconta tel_vllanmto tel_nrseqdig
              WITH FRAME f_lanpla.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         aux_confirma = "N".

         glb_cdcritic = 78.
         RUN fontes/critic.p.
         BELL.
         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         LEAVE.

      END.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
           aux_confirma <> "S" THEN
           DO:
               glb_cdcritic = 79.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               NEXT.
           END.

      IF  (crapcot.vldcotas - tel_vllanmto) < 0   THEN
           DO:
               glb_cdcritic = 203.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               NEXT.
           END.
      ELSE
           ASSIGN crapcot.vldcotas = crapcot.vldcotas - tel_vllanmto
                  crapcot.qtprpgpl = crapcot.qtprpgpl - 1.

      ASSIGN craplot.vlcompcr = craplot.vlcompcr - tel_vllanmto
             craplot.qtcompln = craplot.qtcompln - 1

             crappla.qtprepag = crappla.qtprepag - 1
             crappla.vlprepag = crappla.vlprepag - tel_vllanmto
             crappla.vlpagmes = crappla.vlpagmes - tel_vllanmto
             crappla.dtultpag = 01/01/0001.

      ASSIGN tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      DELETE craplct.

   END.   /*  Fim da transacao.  */

   RELEASE craplot.

   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  AND  tel_vldifecr = 0   THEN
        DO:
            glb_nmdatela = "LOTE".
            RETURN.                 /* Volta ao lanpla.p */
        END.

   ASSIGN tel_nrdconta = 0 tel_vllanmto = 0  tel_nrseqdig = 0.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_nrdconta tel_vllanmto tel_nrseqdig
           WITH FRAME f_lanpla.

END.

/* .......................................................................... */
