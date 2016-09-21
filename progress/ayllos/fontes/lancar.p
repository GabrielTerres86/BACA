/* .............................................................................

   Programa: Fontes/lancar.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/97                        Ultima atualizacao: 16/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANCAR.

   Alteracoes: 04/03/98 - Alterado para incluir a opcao K (Deborah).

               09/09/98 - Tratar mais de um tipo de cartao (Deborah).
                  
               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).  
                
             17/01/2001 - Substituir CCOH por COOP (Margarete/Planner).  
             
             09/03/2001 - Incluir tratamento do boletim caixa (Margarete).

             04/07/2005 - Alimentado campo cdcooper da tabela craplau (Diego).
             
             10/12/2005 - Atualizar craplau.nrdctitg (Magui).

             30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
             
             19/04/2006 - Ajustes na pesquisa pelo cartao de credito,
                          digitar o numero inteiro. (Julio)
                          
             12/09/2006 - Excluida opcao "TAB" (Diego).
             
             10/10/2006 - Alterado help dos campos (Elton).
             
             19/05/2010 - Incluido novo motivo de cancelamento de cartao 
                          "Por fraude" (Elton).
                          
             25/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                          para crapbcl (Adriano).  
                                        
             05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                          a escrita será PA (André Euzébio - Supero).
                          
             16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                          nao cadastrado.". (Reinert)                          
             
............................................................................. */

{ includes/var_online.i }

DEF       VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF       VAR tel_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF       VAR tel_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF       VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF       VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF       VAR tel_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF       VAR tel_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF       VAR tel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF       VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF       VAR tel_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF       VAR tel_nrseqdig AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF       VAR tel_reganter AS CHAR    FORMAT "x(76)" EXTENT 6      NO-UNDO.

DEF       VAR tel_nrdocmto AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF       VAR tel_nrcrcard AS DECI    FORMAT "9999,9999,9999,9999" NO-UNDO.
DEF       VAR tel_vllanmto AS DECIMAL FORMAT "zzzzz,zz9.99"        NO-UNDO.
DEF       VAR tel_nmtitcrd AS CHAR    FORMAT "x(25)"               NO-UNDO.

DEF       VAR aux_nrcartao AS CHAR                                 NO-UNDO.
DEF       VAR aux_nrcrcard AS DECI                                 NO-UNDO.

DEF       VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.
DEF       VAR aux_flgretor AS LOGICAL                              NO-UNDO.
DEF       VAR aux_regexist AS LOGICAL                              NO-UNDO.
DEF       VAR aux_contador AS INT                                  NO-UNDO.
DEF       VAR aux_cddopcao AS CHAR                                 NO-UNDO.

DEF       VAR aux_nrlotant AS INT                                  NO-UNDO.
DEF       VAR aux_cdadmcrd AS INT                                  NO-UNDO.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C, E, I ou K)"
                        VALIDATE (glb_cddopcao = "C" OR glb_cddopcao = "E" OR
                                  glb_cddopcao = "I" OR glb_cddopcao = "K",
                                  "014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
                        HELP "Informe a data que deseja efetuar a consulta."
     tel_cdagenci AT 36 LABEL "PA" AUTO-RETURN
                        HELP "Informe o numero do PA."
                        VALIDATE (CAN-FIND(crapage WHERE 
                                           crapage.cdcooper = glb_cdcooper AND
                                           crapage.cdagenci = tel_cdagenci),
                                           "962 - PA nao cadastrado.")

     tel_cdbccxlt AT 47 LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Informe o numero do banco/caixa."
                        VALIDATE (CAN-FIND(crapbcl WHERE 
                                           crapbcl.cdbccxlt = tel_cdbccxlt),
                                           "057 - Banco nao cadastrado.")

     tel_nrdolote AT 65 LABEL "Lote" AUTO-RETURN
                        HELP "Informe o numero do lote."
                        VALIDATE (tel_nrdolote > 0,
                                  "058 - Numero do lote errado.")

     SKIP(1)
     tel_qtinfoln AT 12 LABEL "Informado:   Qtd"
     tel_vlinfodb AT 41 LABEL "Debito"
     SKIP
     tel_qtcompln AT 12 LABEL "Computado:   Qtd"
     tel_vlcompdb AT 41 LABEL "Debito"
     SKIP
     tel_qtdifeln AT 12 LABEL "Diferenca:   Qtd"
     tel_vldifedb AT 41 LABEL "Debito"
     SKIP(1)
     "Cartao              Titular "   AT 2
     "Documento        Valor     Seq."  AT  47
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM tel_nrcrcard AT 2 NO-LABEL
                  HELP "Informe o numero do cartao de credito."

     tel_nmtitcrd AT 22 NO-LABEL

     tel_nrdocmto AT 49 NO-LABEL
           HELP "Informe o numero do documento utilizado na digitacao do lote."     
     tel_vllanmto AT 57 NO-LABEL
                  HELP "Informe o valor do debito do cartao de credito."

     tel_nrseqdig AT 71 NO-LABEL
     WITH ROW 14 COLUMN 2 OVERLAY NO-LABELS NO-BOX FRAME f_lancar.

FORM tel_nrcrcard     AT  2 NO-LABEL
     crapcrd.nmtitcrd AT 22 NO-LABEL FORMAT "x(25)"
     craplau.nrdocmto AT 49 NO-LABEL FORMAT "zzz,zz9"
     craplau.vllanaut AT 57 NO-LABEL FORMAT "zzzzz,zz9.99"
     craplau.nrseqdig AT 71 NO-LABEL FORMAT "zzz,zz9"
     WITH 6 DOWN COLUMN 2 OVERLAY NO-LABELS NO-BOX FRAME f_lanctos.

FORM tel_reganter[1] AT 2 NO-LABEL  tel_reganter[2] AT 2 NO-LABEL
     tel_reganter[3] AT 2 NO-LABEL  tel_reganter[4] AT 2 NO-LABEL
     tel_reganter[5] AT 2 NO-LABEL  tel_reganter[6] AT 2 NO-LABEL
     WITH ROW 15 COLUMN 2 OVERLAY NO-BOX NO-LABELS FRAME f_regant.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "I"
       tel_dtmvtolt = glb_dtmvtolt
       tel_cdagenci = glb_cdagenci
       tel_cdbccxlt = glb_cdbccxlt
       tel_nrdolote = glb_nrdolote
       aux_flgretor = FALSE
       glb_cdcritic = 0.

DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_cdbccxlt tel_nrdolote
        WITH FRAME f_opcao.

CLEAR FRAME f_lancar ALL NO-PAUSE.

NEXT-PROMPT tel_cdagenci WITH FRAME f_opcao.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   NOT aux_flgretor   THEN
           IF   tel_cdagenci <> 0   AND
                tel_cdbccxlt <> 0   AND
                tel_nrdolote <> 0   THEN
                LEAVE.

      SET glb_cddopcao WITH FRAME f_opcao.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         IF   glb_cddopcao <> "K" THEN
              DO:
                  tel_dtmvtolt = glb_dtmvtolt.
                  DISPLAY tel_dtmvtolt WITH FRAME f_opcao.
                  SET tel_cdagenci tel_cdbccxlt tel_nrdolote
                      WITH FRAME f_opcao.
              END.
         ELSE
              SET tel_dtmvtolt tel_cdagenci tel_cdbccxlt tel_nrdolote
                  WITH FRAME f_opcao.

         LEAVE.

      END. /* Fim do WHILE TRUE mais interno */

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "LANCAR"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_lancar.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   aux_flgretor = TRUE.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                      craplot.dtmvtolt = tel_dtmvtolt   AND
                      craplot.cdagenci = tel_cdagenci   AND
                      craplot.cdbccxlt = tel_cdbccxlt   AND
                      craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craplot   THEN
        DO:
            glb_cdcritic = 60.
            RUN fontes/critic.p.
            CLEAR FRAME f_lancar.
            HIDE FRAME f_regant.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            CLEAR FRAME f_opcao.
            DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                    tel_cdbccxlt tel_nrdolote
                    WITH FRAME f_opcao.
            BELL.
            MESSAGE  glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

   IF   glb_cddopcao <> "C"   AND
        tel_cdbccxlt = 11     AND 
        craplot.nrdcaixa > 0  AND
        tel_cdagenci <> 11    THEN  /* boletim de caixa -   EDSON PA1 */ 
        DO:
            FIND LAST crapbcx WHERE crapbcx.cdcooper = glb_cdcooper     AND
                                    crapbcx.dtmvtolt = glb_dtmvtolt     AND
                                    crapbcx.cdagenci = craplot.cdagenci AND
                                    crapbcx.nrdcaixa = craplot.nrdcaixa AND
                                    crapbcx.cdopecxa = craplot.cdopecxa
                                    USE-INDEX crapbcx2 NO-LOCK NO-ERROR.
            IF   NOT AVAILABLE crapbcx    THEN
                 DO:
                     ASSIGN glb_cdcritic = 708. 
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     ASSIGN glb_cdcritic = 0.
                     NEXT.
                 END.            
            ELSE
                 IF   crapbcx.cdsitbcx = 2   THEN
                      DO:
                          ASSIGN glb_cdcritic = 698.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          ASSIGN glb_cdcritic = 0.
                          NEXT.
                      END.                  
        END.
         
   IF   craplot.tplotmov <> 17   THEN
        DO:
            glb_cdcritic = 545.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic .
            glb_cdcritic = 0.
            NEXT.
        END.

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND 
                      craptab.nmsistem = "CRED"           AND
                      craptab.tptabela = "USUARI"         AND
                      craptab.cdempres = 11               AND
                      craptab.cdacesso = "HISTCARTAO"     AND
                      craptab.tpregist = craplot.cdhistor NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab THEN
        DO:
            glb_cdcritic = 611.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

   aux_cdadmcrd = INT(craptab.dstextab).
   
   ASSIGN tel_nrseqdig = craplot.nrseqdig + 1

          tel_qtinfoln = craplot.qtinfoln
          tel_qtcompln = craplot.qtcompln
          tel_vlinfodb = craplot.vlinfodb
          tel_vlcompdb = craplot.vlcompdb
          tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
          tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb.

   DISPLAY tel_qtinfoln   tel_qtcompln
           tel_vlinfodb   tel_vlcompdb
           tel_qtdifeln   tel_vldifedb
           WITH FRAME f_opcao.

   IF   tel_nrdolote <> aux_nrlotant THEN
        DO:
            HIDE FRAME f_regant.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            CLEAR FRAME f_lancar.
            aux_nrlotant = tel_nrdolote.
        END.

    IF   glb_cddopcao = "C" OR glb_cddopcao = "K" THEN

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           IF   glb_cdcritic > 0 THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    CLEAR FRAME f_lancar.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                END.
         
           UPDATE tel_nrcrcard tel_nrdocmto WITH FRAME f_lancar.

           IF   tel_nrcrcard = 0 THEN
                DO:
                    ASSIGN aux_regexist = FALSE
                           aux_flgretor = FALSE
                           aux_contador = 0.

                    CLEAR FRAME f_lancar.

                    HIDE FRAME f_regant.

                    CLEAR FRAME f_lanctos ALL NO-PAUSE.

                    FOR EACH craplau WHERE craplau.cdcooper = glb_cdcooper   AND
                                           craplau.dtmvtolt = tel_dtmvtolt   AND
                                           craplau.cdagenci = tel_cdagenci   AND
                                           craplau.cdbccxlt = tel_cdbccxlt   AND
                                           craplau.nrdolote = tel_nrdolote
                                           NO-LOCK USE-INDEX craplau3:

                        FIND crapcrd WHERE crapcrd.cdcooper = glb_cdcooper AND 
                                           crapcrd.cdadmcrd = aux_cdadmcrd AND
                                           crapcrd.nrcrcard = craplau.nrcrcard
                                           NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE crapcrd THEN
                             DO:
                                 glb_cdcritic = 546.
                                 NEXT-PROMPT tel_nrcrcard WITH FRAME f_lancar.
                                 NEXT.
                             END.

                        ASSIGN aux_nrcartao = STRING(craplau.nrcrcard,
                                                     "9999999999999999")
                               tel_nrcrcard = DECIMAL(aux_nrcartao)

                               aux_regexist = TRUE
                               aux_contador = aux_contador + 1.

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

                        DISPLAY tel_nrcrcard      crapcrd.nmtitcrd
                                craplau.nrdocmto  craplau.vllanaut
                                craplau.nrseqdig WITH FRAME f_lanctos.

                        IF   aux_contador = 6   THEN
                             aux_contador = 0.
                        ELSE
                             DOWN WITH FRAME f_lanctos.

                    END. /* Fim do FOR EACH */

                    IF   NOT aux_regexist   THEN
                         ASSIGN glb_cdcritic = 11
                                aux_flgretor = TRUE.

                    tel_nrcrcard = 0.

                    NEXT.
                END.

           ASSIGN aux_nrcrcard = DECIMAL(STRING(tel_nrcrcard,
                                                          "9999999999999999")).
                                               
           FIND crapcrd WHERE crapcrd.cdcooper = glb_cdcooper AND
                              crapcrd.cdadmcrd = aux_cdadmcrd AND
                              crapcrd.nrcrcard = aux_nrcrcard
                              USE-INDEX crapcrd3 NO-LOCK NO-ERROR.

           IF   NOT AVAILABLE crapcrd   THEN
                DO:
                    glb_cdcritic = 546.
                    NEXT-PROMPT tel_nrcrcard WITH FRAME f_lancar.
                    NEXT.
                END.

           IF   tel_nrdocmto > 0 THEN
                DO:
                    FIND craplau WHERE craplau.cdcooper = glb_cdcooper     AND
                                       craplau.dtmvtolt = tel_dtmvtolt     AND
                                       craplau.cdagenci = tel_cdagenci     AND
                                       craplau.cdbccxlt = tel_cdbccxlt     AND
                                       craplau.nrdolote = tel_nrdolote     AND
                                       craplau.nrdctabb = crapcrd.nrdconta AND
                                       craplau.nrdocmto = tel_nrdocmto     AND
                                       craplau.nrcrcard = aux_nrcrcard
                                       USE-INDEX craplau1 NO-LOCK NO-ERROR.

                    IF   NOT AVAILABLE craplau THEN
                         DO:
                             glb_cdcritic = 090.
                             NEXT-PROMPT tel_nrdocmto WITH FRAME f_lancar.
                             NEXT.
                         END.

                    ASSIGN tel_nmtitcrd = crapcrd.nmtitcrd
                           tel_vllanmto = craplau.vllanaut
                           tel_nrseqdig = craplau.nrseqdig.

                    DISPLAY tel_nmtitcrd tel_vllanmto tel_nrseqdig
                            WITH FRAME f_lancar.

                END.
           ELSE
                DO:
                    ASSIGN aux_regexist = FALSE
                           aux_flgretor = FALSE
                           aux_contador = 0.

                    CLEAR FRAME f_lancar.

                    HIDE FRAME f_regant.

                    CLEAR FRAME f_lanctos ALL NO-PAUSE.

                    FOR EACH craplau WHERE 
                             craplau.cdcooper = glb_cdcooper     AND 
                             craplau.dtmvtolt = tel_dtmvtolt     AND
                             craplau.cdagenci = tel_cdagenci     AND
                             craplau.cdbccxlt = tel_cdbccxlt     AND
                             craplau.nrdolote = tel_nrdolote     AND
                             craplau.nrdctabb = crapcrd.nrdconta AND
                             craplau.nrcrcard = aux_nrcrcard     AND
                             craplau.nrdocmto > 0                NO-LOCK:

                        FIND crapcrd WHERE crapcrd.cdcooper = glb_cdcooper AND
                                           crapcrd.cdadmcrd = aux_cdadmcrd AND
                                           crapcrd.nrcrcard = craplau.nrcrcard
                                           NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE crapcrd THEN
                             DO:
                                 glb_cdcritic = 546.
                                 NEXT-PROMPT tel_nrcrcard WITH FRAME f_lancar.
                                 NEXT.
                             END.

                        ASSIGN aux_regexist = TRUE
                               aux_contador = aux_contador + 1.

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

                        DISPLAY tel_nrcrcard      crapcrd.nmtitcrd
                                craplau.nrdocmto  craplau.vllanaut
                                craplau.nrseqdig WITH FRAME f_lanctos.

                        IF   aux_contador = 6   THEN
                             aux_contador = 0.
                        ELSE
                             DOWN WITH FRAME f_lanctos.

                    END. /* Fim do FOR EACH */

                    IF   NOT aux_regexist   THEN
                         ASSIGN glb_cdcritic = 11
                                aux_flgretor = TRUE.
                END.

        END.   /* FIM do DO WHILE TRUE da consulta */

   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

            IF   glb_cdcritic > 0 THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     CLEAR FRAME f_lancar.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                 END.

            UPDATE tel_nrcrcard tel_nrdocmto WITH FRAME f_lancar.

            ASSIGN aux_nrcrcard = DECIMAL(STRING(tel_nrcrcard,
                                                         "9999999999999999")).
 
            FIND crapcrd WHERE crapcrd.cdcooper = glb_cdcooper AND
                               crapcrd.cdadmcrd = aux_cdadmcrd AND
                               crapcrd.nrcrcard = aux_nrcrcard NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapcrd THEN
                 DO:
                     glb_cdcritic = 546.
                     NEXT-PROMPT tel_nrcrcard WITH FRAME f_lancar.
                     NEXT.
                 END.

            IF   tel_nrdocmto = 0 THEN
                 DO:
                     glb_cdcritic = 22.
                     NEXT-PROMPT tel_nrdocmto WITH FRAME f_lancar.
                     NEXT.
                 END.

            DO TRANSACTION:

               DO WHILE TRUE:

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
                  ELSE
                       IF   craplot.tplotmov <> 17   THEN
                            glb_cdcritic = 100.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   glb_cdcritic > 0 THEN
                    NEXT.

               DO WHILE TRUE:

                  FIND craplau WHERE craplau.cdcooper = glb_cdcooper     AND 
                                     craplau.dtmvtolt = tel_dtmvtolt     AND
                                     craplau.cdagenci = tel_cdagenci     AND
                                     craplau.cdbccxlt = tel_cdbccxlt     AND
                                     craplau.nrdolote = tel_nrdolote     AND
                                     craplau.nrdctabb = crapcrd.nrdconta AND
                                     craplau.nrcrcard = aux_nrcrcard     AND
                                     craplau.nrdocmto = tel_nrdocmto
                                     USE-INDEX craplau1
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE craplau THEN
                       IF   LOCKED craplau   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            glb_cdcritic = 90.

                  LEAVE.

               END.  /* Fim do DO WHILE TRUE */

               IF   glb_cdcritic > 0 THEN
                    NEXT.

               ASSIGN tel_qtinfoln = craplot.qtinfoln
                      tel_qtcompln = craplot.qtcompln
                      tel_vlinfodb = craplot.vlinfodb
                      tel_vlcompdb = craplot.vlcompdb
                      tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                      tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb

                      tel_nmtitcrd = crapcrd.nmtitcrd
                      tel_vllanmto = craplau.vllanaut
                      tel_nrseqdig = craplau.nrseqdig.

               DISPLAY tel_qtinfoln tel_vlinfodb tel_qtcompln tel_vlcompdb
                       tel_qtdifeln tel_vldifedb
                       WITH FRAME f_opcao.

               DISPLAY  tel_nmtitcrd   tel_vllanmto   tel_nrseqdig
                        WITH FRAME f_lancar.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  aux_confirma = "N".

                  glb_cdcritic = 78.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  glb_cdcritic = 0.
                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S" THEN
                    DO:
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

               ASSIGN craplot.vlcompdb = craplot.vlcompdb - craplau.vllanaut
                      craplot.qtcompln = craplot.qtcompln - 1
                      tel_qtinfoln = craplot.qtinfoln
                      tel_qtcompln = craplot.qtcompln
                      tel_vlinfodb = craplot.vlinfodb
                      tel_vlcompdb = craplot.vlcompdb
                      tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                      tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb.

               DELETE craplau.

            END.   /*  Fim da transacao.  */

            RELEASE craplot.

            IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  THEN
                 DO:
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_lancar.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     glb_nmdatela = "LOTE".
                     RETURN.
                 END.

            ASSIGN  tel_nrcrcard = 0 tel_nrdocmto = 0
                    tel_vllanmto = 0 tel_nrseqdig = 0.

            DISPLAY tel_qtinfoln tel_vlinfodb
                    tel_qtcompln tel_vlcompdb
                    tel_qtdifeln tel_vldifedb
                    WITH FRAME f_opcao.

            CLEAR FRAME f_lancar.
        END.  /*  Fim do DO WHILE TRUE  */
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
             DO WHILE TRUE:

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                                      craplot.dtmvtolt = tel_dtmvtolt   AND
                                      craplot.cdagenci = tel_cdagenci   AND
                                      craplot.cdbccxlt = tel_cdbccxlt   AND
                                      craplot.nrdolote = tel_nrdolote
                                      NO-LOCK NO-ERROR.

                   IF   glb_cdcritic > 0   THEN
                        DO:
                            RUN fontes/critic.p.
                            CLEAR FRAME f_lancar.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                        END.
                   ELSE
                        ASSIGN tel_nrcrcard = 0
                               tel_nrdocmto = 0
                               tel_nmtitcrd = ""
                               tel_vllanmto = 0
                               tel_nrseqdig = craplot.nrseqdig + 1.

                   DISPLAY tel_nrseqdig tel_nmtitcrd WITH FRAME f_lancar.

                   UPDATE tel_nrcrcard tel_nrdocmto tel_vllanmto
                          WITH FRAME f_lancar

                   EDITING:

                       READKEY.

                       IF   FRAME-FIELD = "tel_nrcrcard"   THEN
                            IF   KEYFUNCTION(LASTKEY) = "RETURN"   OR
                                 KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                                 KEYFUNCTION(LASTKEY) = "GO"       THEN
                                 DO:
                                    ASSIGN aux_nrcartao = STRING(FRAME-VALUE)
                                           aux_nrcrcard = DECIMAL(aux_nrcartao).

                                     FIND crapcrd WHERE 
                                          crapcrd.cdcooper = glb_cdcooper AND
                                          crapcrd.cdadmcrd = aux_cdadmcrd AND
                                          crapcrd.nrcrcard = aux_nrcrcard
                                          USE-INDEX crapcrd3 NO-LOCK NO-ERROR.

                                     IF   NOT AVAILABLE crapcrd   THEN
                                          DO:
                                              glb_cdcritic = 546.
                                              RUN fontes/critic.p.
                                              MESSAGE glb_dscritic.
                                              BELL.
                                              NEXT-PROMPT tel_nrcrcard
                                                   WITH FRAME f_lancar.
                                              glb_cdcritic = 0.
                                              NEXT.

                                          END.
                                     ELSE
                                          DO:
                                              tel_nmtitcrd = crapcrd.nmtitcrd.

                                              DISPLAY tel_nmtitcrd
                                                      WITH FRAME f_lancar.

                                          END.

                                     APPLY LASTKEY.

                                 END.
                            ELSE
                            IF   LASTKEY = KEYCODE(",")    THEN
                                 APPLY 46.
                            ELSE
                                 APPLY LASTKEY.
                       ELSE
                       IF   FRAME-FIELD = "tel_vllanmto"   THEN
                            IF   LASTKEY =  KEYCODE(".")   THEN
                                 APPLY 44.
                            ELSE
                                 APPLY LASTKEY.
                       ELSE
                            APPLY LASTKEY.

                   END.  /*  Fim do EDITING  */
                      
                   IF   crapcrd.dddebito <> DAY(craplot.dtmvtopg) THEN
                        DO:
                            glb_cdcritic = 568.
                            NEXT-PROMPT tel_nrcrcard WITH FRAME f_lancar.
                            NEXT.
                        END.
                              
                   IF   tel_nrdocmto = 0 THEN
                        DO:
                            glb_cdcritic = 22.
                            NEXT-PROMPT tel_nrdocmto WITH FRAME f_lancar.
                            NEXT.
                        END.

                   IF   tel_vllanmto = 0 THEN
                        DO:
                            glb_cdcritic = 269.
                            NEXT-PROMPT tel_vllanmto WITH FRAME f_lancar.
                            NEXT.
                        END.

                   IF   CAN-FIND(craplau WHERE
                                 craplau.cdcooper = glb_cdcooper     AND 
                                 craplau.dtmvtolt = tel_dtmvtolt     AND
                                 craplau.cdagenci = tel_cdagenci     AND
                                 craplau.cdbccxlt = tel_cdbccxlt     AND
                                 craplau.nrdolote = tel_nrdolote     AND
                                 craplau.nrdctabb = crapcrd.nrdconta AND
                                 craplau.nrdocmto = tel_nrdocmto
                                 USE-INDEX craplau1) THEN
                        DO:
                            glb_cdcritic = 92.
                            NEXT-PROMPT tel_nrdocmto WITH FRAME f_lancar.
                            NEXT.
                        END.

                   IF   CAN-FIND(craplau WHERE
                                 craplau.cdcooper = glb_cdcooper      AND 
                                 craplau.nrdconta = crapcrd.nrdconta  AND
                                 craplau.dtmvtopg = craplot.dtmvtopg  AND
                                 craplau.cdhistor = craplot.cdhistor  AND
                                 craplau.nrdocmto = tel_nrdocmto
                                 USE-INDEX craplau2) THEN
                        DO:
                            glb_cdcritic = 103.
                            NEXT-PROMPT tel_nrdocmto WITH FRAME f_lancar.
                            NEXT.
                        END.
                   
                   IF   crapcrd.dtcancel <> ? THEN
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                               aux_confirma = "N".

                               HIDE MESSAGE NO-PAUSE.
                               glb_dscritic = "Cartao cancelado " +
                                              (IF  crapcrd.cdmotivo = 1
                                                   THEN "por Defeito"
                                              ELSE
                                              IF   crapcrd.cdmotivo = 2
                                                   THEN "por Perda/Roubo"
                                              ELSE
                                              IF   crapcrd.cdmotivo = 3
                                                   THEN "pelo socio"
                                              ELSE
                                              IF   crapcrd.cdmotivo = 6 
                                                   THEN "por fraude"
                                              ELSE
                                                   "pela COOP") +
                                              ". Confirma a operacao? (S/N):".
                               BELL.
                               MESSAGE glb_dscritic UPDATE aux_confirma.
                               glb_cdcritic = 0.
                               LEAVE.

                            END.  /*  Fim do DO WHILE TRUE  */

                            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                                 aux_confirma <> "S" THEN
                                 DO:
                                     glb_cdcritic = 79.
                                     RUN fontes/critic.p.
                                     BELL.
                                     MESSAGE glb_dscritic.
                                     glb_cdcritic = 0.
                                     NEXT.
                                 END.

                        END.

                   LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN   /* F4 OU FIM   */
                     LEAVE.   /* Volta pedir a opcao para o operador */

                DO TRANSACTION:

                   DO WHILE TRUE:

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
                                glb_cdcritic = 90.

                      LEAVE.

                   END.  /*  Fim do DO WHILE TRUE  */

                   IF   glb_cdcritic > 0   THEN
                        NEXT.

                   CREATE craplau.
                   ASSIGN craplau.cdagenci = tel_cdagenci
                          craplau.cdbccxlt = tel_cdbccxlt
                          craplau.cdbccxpg = craplot.cdbccxpg
                          craplau.cdcritic = 0
                          craplau.cdhistor = craplot.cdhistor
                          craplau.dtdebito = ?
                          craplau.dtmvtolt = glb_dtmvtolt
                          craplau.dtmvtopg = craplot.dtmvtopg
                          craplau.insitlau = 3
                          craplau.nrdconta = crapcrd.nrdconta
                          craplau.nrdctabb = crapcrd.nrdconta
                          craplau.nrdctitg = 
                                  STRING(crapcrd.nrdconta,"99999999")
                          
                          craplau.nrdocmto = tel_nrdocmto
                          craplau.nrdolote = tel_nrdolote
                          craplau.nrseqdig = craplot.nrseqdig + 1
                          craplau.nrseqlan = craplau.nrseqdig
                          craplau.tpdvalor = 1
                          craplau.vllanaut = tel_vllanmto
                          craplau.nrcrcard = aux_nrcrcard
                          craplau.cdcooper = glb_cdcooper

                          craplot.nrseqdig = craplot.nrseqdig + 1
                          craplot.qtcompln = craplot.qtcompln + 1
                          craplot.vlcompdb = craplot.vlcompdb + tel_vllanmto

                          tel_vlinfodb     = craplot.vlinfodb
                          tel_vlcompdb     = craplot.vlcompdb
                          tel_qtdifeln     = craplot.qtcompln - craplot.qtinfoln
                          tel_vldifedb     = craplot.vlcompdb - craplot.vlinfodb
                          tel_qtinfoln     = craplot.qtinfoln
                          tel_qtcompln     = craplot.qtcompln
                          tel_nrseqdig     = craplot.nrseqdig.

                END.   /* Fim da transacao */

                IF   tel_qtdifeln = 0   AND   tel_vldifedb = 0   THEN
                     DO:
                         HIDE FRAME f_opcao.
                         HIDE FRAME f_lancar NO-PAUSE.
                         HIDE FRAME f_regant.
                         HIDE FRAME f_lanctos.
                         HIDE FRAME f_moldura.
                         glb_nmdatela = "LOTE".
                         RETURN.
                     END.

                ASSIGN tel_reganter[6] = tel_reganter[5]
                       tel_reganter[5] = tel_reganter[4]
                       tel_reganter[4] = tel_reganter[3]
                       tel_reganter[3] = tel_reganter[2]
                       tel_reganter[2] = tel_reganter[1]
                       tel_reganter[1] =
                           STRING(tel_nrcrcard,"9999,9999,9999,9999") + " " +
                           STRING(crapcrd.nmtitcrd,"x(25)")  + "  " +
                           STRING(tel_nrdocmto,"zzz,zz9") + " " +
                           STRING(tel_vllanmto,"zzzzz,zz9.99") + "  " +
                           STRING(craplau.nrseqdig,"zzz,zz9")

                       tel_nrseqdig = craplot.nrseqdig + 1.

                DISPLAY tel_qtinfoln  tel_vlinfodb tel_qtcompln
                        tel_vlcompdb  tel_qtdifeln tel_vldifedb
                        WITH FRAME f_opcao.

                DISPLAY tel_nrseqdig WITH FRAME f_lancar.

                HIDE FRAME f_lanctos.

                DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3]
                        tel_reganter[4] tel_reganter[5] tel_reganter[6]
                        WITH FRAME f_regant.

                RELEASE craplau.
                RELEASE craplot.

             END.  /*  Fim do DO WHILE TRUE  */

        END.

   END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

