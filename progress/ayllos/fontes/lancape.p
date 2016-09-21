/* .............................................................................

   Programa: Fontes/lancape.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/92.                           Ultima atualizacao: 14/08/2013 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela LANCAP.

   Alteracoes: 01/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               28/05/1999 - Dividir o lancamento em capital inicial e
                            nao permitir lancar apos encerramento da ADMISS
                            (Deborah).

               26/06/2000 - Tirar as criticas 642 e 643 (Odair)

               13/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               25/01/2002 - Nao eliminar o lote 10002 (Margarete).

               13/09/2002 - Alterado para tratar o boletim de caixa (Edson).
               
               27/01/2005 - Mudado o LABEL do campo "tel_cdagenci" de "Agencia"
                            para "PAC";
                            HELP de "codigo da agencia." para "codigo do PAC.";
                            VALIDATE de "015 - Agencia nao cadastrada." para
                            "015 - PAC nao cadastrado." (Evandro).

                27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

                13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada
                             do programa fontes/testa_boletim.p - SQLWorks - 
                             Fernando.
                             
                09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                             glb_cdcooper) no "find e CAN-FIND" da tabela
                             CRAPHIS.   
                           - Kbase IT Solutions - Eduardo Silva.         
                                 
                11/12/2008 - Incluir log na transacao de eliminacao(Gabriel).
                
                23/11/2009 - Alteracao Codigo Historico (Kbase).
                
                26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                             para crapbcl (Adriano). 
               
                14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
............................................................................. */

{ includes/var_online.i } 
                                                    
DEF SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF SHARED VAR tel_cdbccxlt AS INT     FORMAT "zz9"                  NO-UNDO.
DEF SHARED VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF SHARED VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF SHARED VAR tel_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR tel_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR tel_qtcompln AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF SHARED VAR tel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR tel_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"              NO-UNDO.
DEF SHARED VAR tel_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF SHARED VAR tel_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF SHARED VAR tel_cdhistor AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF SHARED VAR tel_nrdocmto AS INT     FORMAT "zz,zzz,zz9"           NO-UNDO.
DEF SHARED VAR tel_vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF SHARED VAR tel_reganter AS CHAR    FORMAT "x(60)" EXTENT 6       NO-UNDO.

DEF SHARED VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF SHARED VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF SHARED VAR aux_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF SHARED VAR aux_cdbccxlt AS INT     FORMAT "zz9"                  NO-UNDO.
DEF SHARED VAR aux_nrdolote AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF SHARED VAR aux_qtinfoln AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF SHARED VAR aux_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR aux_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR aux_qtcompln AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF SHARED VAR aux_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR aux_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR aux_qtdifeln AS INT     FORMAT "zz,zz9-"              NO-UNDO.
DEF SHARED VAR aux_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF SHARED VAR aux_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF SHARED VAR aux_flgerros AS LOGICAL                               NO-UNDO.
DEF SHARED VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF SHARED VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF SHARED VAR aux_contador AS INT                                   NO-UNDO.
DEF SHARED VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF SHARED VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF SHARED VAR aux_nrdocmto AS INT                                   NO-UNDO.
DEF SHARED VAR aux_vllanmto AS DECIMAL                               NO-UNDO.
DEF SHARED VAR aux_indebcre AS CHAR                                  NO-UNDO.
DEF SHARED VAR aux_inhistor AS INT                                   NO-UNDO.

DEF SHARED VAR aux_qtcotmfx AS DECIMAL                               NO-UNDO.
DEF SHARED VAR aux_vldcotas AS DECIMAL                               NO-UNDO.
DEF SHARED VAR aux_vlcmecot AS DECIMAL                               NO-UNDO.
DEF SHARED VAR aux_vlcmicot AS DECIMAL                               NO-UNDO.
DEF SHARED VAR aux_vlcmmcot AS DECIMAL                               NO-UNDO.
DEF SHARED VAR aux_vllanmfx AS DECIMAL                               NO-UNDO.
DEF SHARED VAR aux_dtrefcot AS DATE                                  NO-UNDO.

DEF VAR        aux_dstransa AS CHAR                                  NO-UNDO.

DEF SHARED FRAME f_lancap.
DEF SHARED FRAME f_regant.
DEF SHARED FRAME f_lanctos.

FORM    SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE COLOR MESSAGE " Lancamentos de Capital "
                      FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E ou I)"
                        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I",
                                  "014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 31 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE (CAN-FIND(crapage WHERE 
                                           crapage.cdcooper = glb_cdcooper  AND
                                           crapage.cdagenci = tel_cdagenci),
                                           "015 - PA nao cadastrado.")

      tel_cdbccxlt AT 47 LABEL "Banco/Caixa" AUTO-RETURN
                         HELP "Entre com o codigo do Banco/Caixa."
                         VALIDATE (CAN-FIND(crapbcl WHERE 
                                            crapbcl.cdbccxlt = tel_cdbccxlt),
                                            "057 - Banco nao cadastrado.")

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
     "Hist   Conta/dv   Documento              Valor       Seq." AT 12
     SKIP(1)
     tel_cdhistor AT 12 NO-LABEL AUTO-RETURN
                        HELP "Entre com o codigo do historico."
                        VALIDATE (tel_cdhistor > 0 AND
                                  CAN-FIND(craphis WHERE 
                                           craphis.cdcooper = glb_cdcooper AND
                                           craphis.cdhistor = tel_cdhistor),
                                           "093 - Historico errado.")

     tel_nrdconta AT 17 NO-LABEL AUTO-RETURN
                        HELP "Informe o numero da conta do associado."

     tel_nrdocmto AT 29 NO-LABEL AUTO-RETURN
                        HELP "Entre com o numero do documento."

     tel_vllanmto AT 42 NO-LABEL AUTO-RETURN
                        HELP "Entre com o valor do lancamento."
                        VALIDATE (tel_vllanmto > 0,
                                  "091 - Valor do lancamento errado.")

     tel_nrseqdig AT 63 NO-LABEL

     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_lancap.

FORM tel_reganter[1] AT 12 NO-LABEL  tel_reganter[2] AT 12 NO-LABEL
     tel_reganter[3] AT 12 NO-LABEL  tel_reganter[4] AT 12 NO-LABEL
     tel_reganter[5] AT 12 NO-LABEL  tel_reganter[6] AT 12 NO-LABEL
     WITH ROW 15 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

FORM craplct.cdhistor AT 12  craplct.nrdconta AT 17
     craplct.nrdocmto AT 29  craplct.vllanmto AT 42
     craplct.nrseqdig AT 63
     WITH ROW 15 COLUMN 2 OVERLAY NO-LABEL NO-BOX 6 DOWN FRAME f_lanctos.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      SET tel_nrdconta tel_nrdocmto WITH FRAME f_lancap.

      ASSIGN glb_nrcalcul = tel_nrdconta
             aux_nrdconta = tel_nrdconta
             aux_nrdocmto = tel_nrdocmto
             glb_cdcritic = 0.

      RUN fontes/digfun.p.
      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lancap.
           END.
      ELSE
           IF   tel_nrdocmto = 0   THEN
                DO:
                    glb_cdcritic = 22.
                    NEXT-PROMPT tel_nrdocmto WITH FRAME f_lancap.
                END.
           ELSE
                DO:
                    FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND 
                                       crapass.nrdconta = tel_nrdconta
                                       NO-LOCK NO-ERROR.

                    IF   NOT AVAILABLE crapass   THEN
                         DO:
                             glb_cdcritic = 9.
                             NEXT-PROMPT tel_nrdconta WITH FRAME f_lancap.
                         END.
                END.

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lancap.
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_nrdconta
                       tel_nrdocmto WITH FRAME f_lancap.
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
                   DO:
                       ASSIGN glb_cdcritic = 60.
                              aux_flgerros = TRUE.
                       LEAVE.
                   END.
         LEAVE.
      END.

      IF   NOT aux_flgerros THEN
           DO:
               IF   craplot.tplotmov <> 2   THEN
                    glb_cdcritic = 213.
               ELSE
                    IF   craplot.nrdolote = 10002 THEN
                         ASSIGN glb_cdcritic = 261.
           END.              

      IF   glb_cdcritic = 0   THEN
           DO:
               IF   craplot.nrdcaixa > 0   THEN
                    RUN fontes/testa_boletim.p (INPUT  glb_cdcooper,
                                                INPUT  craplot.dtmvtolt,
                                                INPUT  craplot.cdagenci,
                                                INPUT  craplot.cdbccxlt,
                                                INPUT  craplot.nrdolote,
                                                INPUT  craplot.nrdcaixa,
                                                INPUT  craplot.cdopecxa,
                                                OUTPUT glb_cdcritic).
           END.
      
      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lancap.
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_nrdconta
                       tel_nrdocmto WITH FRAME f_lancap.
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
                             craplct.nrdocmto = tel_nrdocmto
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

              FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper   AND 
                                 crapcot.nrdconta = tel_nrdconta
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE crapcot   THEN
                   IF   LOCKED crapcot   THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                   ELSE
                        glb_cdcritic = 169.

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic = 0   THEN
           DO:
               FIND craphis WHERE
                    craphis.cdcooper = glb_cdcooper AND
                    craphis.cdhistor = craplct.cdhistor
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE craphis   THEN
                    glb_cdcritic = 83.
           END.

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lancap.
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_nrdconta
                       tel_nrdocmto WITH FRAME f_lancap.
               MESSAGE glb_dscritic.
               NEXT.
           END.

      ASSIGN tel_cdhistor = craplct.cdhistor  tel_vllanmto = craplct.vllanmto
             tel_nrseqdig = craplct.nrseqdig.

      DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
              tel_qtcompln tel_vlcompdb tel_vlcompcr
              tel_qtdifeln tel_vldifedb tel_vldifecr
              tel_cdhistor tel_nrdconta tel_nrdocmto
              tel_vllanmto tel_nrseqdig
              WITH FRAME f_lancap.

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

      IF   craphis.inhistor = 6   THEN
           IF  (crapcot.vldcotas - tel_vllanmto) < 0   THEN
                DO:
                    glb_cdcritic = 203.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.
           ELSE
                crapcot.vldcotas = crapcot.vldcotas - tel_vllanmto.
      ELSE
      IF   craphis.inhistor = 16   THEN
           crapcot.vldcotas = crapcot.vldcotas + tel_vllanmto.
      ELSE
      IF   NOT CAN-DO("7,8,17,18",STRING(craphis.inhistor))   THEN
           DO:
               glb_cdcritic = 214.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               UNDO, NEXT.
           END.

      IF   craphis.indebcre = "D"   THEN
           craplot.vlcompdb = craplot.vlcompdb - tel_vllanmto.
      ELSE
           IF   craphis.indebcre = "C"   THEN
                craplot.vlcompcr = craplot.vlcompcr - tel_vllanmto.

      craplot.qtcompln = craplot.qtcompln - 1.

      ASSIGN tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      aux_dstransa = "Exclusao de lancamento: " +
                     "Hst: " + STRING(craplct.cdhistor) +  " " +
                     "Doc: " + STRING(craplct.nrdocmto) +  " " +
                     "Valor: "                                 + 
                     TRIM(STRING(craplct.vllanmto,"zzzz,zzz,zz9.99"))  +
                     " Lote: " + STRING(craplct.dtmvtolt,"99/99/9999") + "-" +
                     STRING(craplct.cdagenci,"999")                    + "-" +
                     STRING(craplct.cdbccxlt,"999")                    + "-" +
                     STRING(craplct.nrdolote,"999,999").

      RUN fontes/gera_log.p (INPUT glb_cdcooper, INPUT craplct.nrdconta,
                             INPUT glb_cdoperad, INPUT aux_dstransa,
                             INPUT glb_nmdatela).
      DELETE craplct.

   END.   /*  Fim da transacao.  */

   RELEASE craplot.
   RELEASE craplct.
   RELEASE crapcot.

   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  AND  tel_vldifecr = 0   THEN
        DO:
            glb_nmdatela = "LOTE".
            RETURN.                 /* Volta ao lancap.p */
        END.

   ASSIGN tel_cdhistor = 0  tel_nrdconta = 0  tel_nrdocmto = 0
          tel_vllanmto = 0  tel_nrseqdig = 0.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_cdhistor tel_nrdconta tel_nrdocmto
           tel_vllanmto tel_nrseqdig
           WITH FRAME f_lancap.

END.

/* .......................................................................... */

