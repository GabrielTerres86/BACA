/* .............................................................................

   Programa: Fontes/lanplac.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/92                          Ultima atualizacao: 05/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela LANPLA.

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

               05/09/2013 - Nova forma de chamar as agências, de PAC agora 
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
     tel_cdagenci AT 32 LABEL "PA" AUTO-RETURN
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

      IF   tel_nrdconta = 0  THEN
           LEAVE.

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

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                      craplot.dtmvtolt = tel_dtmvtolt   AND
                      craplot.cdagenci = tel_cdagenci   AND
                      craplot.cdbccxlt = tel_cdbccxlt   AND
                      craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craplot   THEN
        glb_cdcritic = 60.
   ELSE
        IF   craplot.tplotmov <> 3   THEN
             glb_cdcritic = 100.

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_lanpla NO-PAUSE.
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

   ASSIGN tel_qtinfoln = craplot.qtinfoln
          aux_qtinfoln = tel_qtinfoln
          tel_qtcompln = craplot.qtcompln
          aux_qtcompln = tel_qtcompln
          tel_vlinfodb = craplot.vlinfodb
          aux_vlinfodb = tel_vlinfodb
          tel_vlcompdb = craplot.vlcompdb
          aux_vlcompdb = tel_vlcompdb
          tel_vlinfocr = craplot.vlinfocr
          aux_vlinfocr = tel_vlinfocr
          tel_vlcompcr = craplot.vlcompcr
          aux_vlcompcr = tel_vlcompcr
          tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
          aux_qtdifeln = tel_qtdifeln
          tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
          aux_vldifedb = tel_vldifedb
          tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
          aux_vldifecr = tel_vldifecr.

   IF   tel_nrdconta = 0   THEN
        DO:
            ASSIGN aux_flgretor = FALSE
                   aux_regexist = FALSE
                   aux_contador = 0.

            DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
                    tel_qtcompln tel_vlcompdb tel_vlcompcr
                    tel_qtdifeln tel_vldifedb tel_vldifecr
                    WITH FRAME f_lanpla.

            PUT SCREEN ROW 14 COLUMN 17 FILL(" ",50).
            HIDE FRAME f_regant.

            CLEAR FRAME f_lanctos ALL NO-PAUSE.

            FOR EACH craplct WHERE craplct.cdcooper = glb_cdcooper   AND
                                   craplct.dtmvtolt = tel_dtmvtolt   AND
                                   craplct.cdagenci = tel_cdagenci   AND
                                   craplct.cdbccxlt = tel_cdbccxlt   AND
                                   craplct.nrdolote = tel_nrdolote   NO-LOCK
                                   USE-INDEX craplct3:

                ASSIGN aux_regexist = TRUE
                       aux_contador = aux_contador + 1

                       tel_nrdconta = craplct.nrdconta
                       tel_vllanmto = craplct.vllanmto
                       tel_nrseqdig = craplct.nrseqdig.

                IF   aux_contador = 1   THEN
                     IF   aux_flgretor   THEN
                          DO:
                              PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                              CLEAR FRAME f_lanctos ALL NO-PAUSE.
                          END.
                     ELSE
                          aux_flgretor = TRUE.

                PAUSE (0).

                DISPLAY tel_nrdconta  tel_vllanmto  tel_nrseqdig
                        WITH FRAME f_lanctos.

                IF   aux_contador = 6   THEN
                     aux_contador = 0.
                ELSE
                     DOWN WITH FRAME f_lanctos.

            END.  /*  Fim do FOR EACH -- Leitura do craplct  */

            IF   NOT aux_regexist   THEN
                 glb_cdcritic = 11.

            IF   glb_cdcritic > 0 THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     CLEAR FRAME f_lanpla NO-PAUSE.
                     ASSIGN glb_cddopcao = aux_cddopcao
                            tel_dtmvtolt = aux_dtmvtolt
                            tel_cdagenci = aux_cdagenci
                            tel_cdbccxlt = aux_cdbccxlt
                            tel_nrdolote = aux_nrdolote
                            glb_cdcritic = 0.

                     DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                             tel_cdbccxlt tel_nrdolote
                             WITH FRAME f_lanpla.
                     MESSAGE glb_dscritic.
                     NEXT.
                 END.
            NEXT.
        END.

   FIND craplct WHERE craplct.cdcooper = glb_cdcooper   AND
                      craplct.dtmvtolt = tel_dtmvtolt   AND
                      craplct.cdagenci = tel_cdagenci   AND
                      craplct.cdbccxlt = tel_cdbccxlt   AND
                      craplct.nrdolote = tel_nrdolote   AND
                      craplct.nrdconta = tel_nrdconta   AND
                      craplct.nrdocmto = tel_nrdolote   NO-LOCK
                      USE-INDEX craplct1 NO-ERROR.

   IF   NOT AVAILABLE craplct   THEN
        glb_cdcritic = 90.
   ELSE
        ASSIGN tel_nrdconta = craplct.nrdconta
               tel_vllanmto = craplct.vllanmto
               tel_nrseqdig = craplct.nrseqdig.

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

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_nrdconta tel_vllanmto tel_nrseqdig
           WITH FRAME f_lanpla.
END.

/* .......................................................................... */
