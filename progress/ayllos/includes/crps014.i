/* .............................................................................

   Programa: Includes/crps014.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                      Ultima alteracao: 16/01/2009

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 010
               Listar os associados cadastrados conforme solicitacao.
               
    Alteracao: Tratar opcao: geral, por ordem alfabetica e ativos (Deborah).

               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               16/01/2008 - Alteracao cdempres (Kbase IT) - Eduardo Silva.
............................................................................. */

IF   SUBSTRING(glb_dsparame,1,3) = "111"   THEN   /* Geral alfabetica todos */
     DO:
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK
                                BY crapass.nmprimtl
                                   BY crapass.nrdconta:

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassger = aux_qtassger + 1.

             ASSIGN rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_cdsitdct[aux_contador] = crapass.cdsitdct
                    rel_cdtipcta[aux_contador] = crapass.cdtipcta
                    rel_indnivel[aux_contador] = crapass.indnivel
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                              rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                              rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                              rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      ASSIGN rel_nrdconta[1] = 0  rel_nrmatric[1] = 0
                             rel_cdsitdct[1] = 0  rel_cdtipcta[1] = 0
                             rel_indnivel[1] = 0  rel_nmprimtl[1] = ""
                             rel_nrdconta[2] = 0  rel_nrmatric[2] = 0
                             rel_cdsitdct[2] = 0  rel_cdtipcta[2] = 0
                             rel_indnivel[2] = 0  rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                          rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                          rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                          rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1 rel_nrdconta[1] WITH FRAME f_associados.
                  DOWN STREAM str_1 WITH FRAME f_associados.
              END.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              PAGE STREAM str_1.

         rel_qtdassoc = aux_qtassger.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.
     END.
ELSE
IF   SUBSTRING(glb_dsparame,1,3) = "112"   THEN   /* Geral alfabetica ativos */
     DO:
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper  AND 
                                dtdemiss = ?                     NO-LOCK
                                BY crapass.nmprimtl
                                   BY crapass.nrdconta:

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassger = aux_qtassger + 1.

             ASSIGN rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_cdsitdct[aux_contador] = crapass.cdsitdct
                    rel_cdtipcta[aux_contador] = crapass.cdtipcta
                    rel_indnivel[aux_contador] = crapass.indnivel
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                              rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                              rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                              rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      ASSIGN rel_nrdconta[1] = 0  rel_nrmatric[1] = 0
                             rel_cdsitdct[1] = 0  rel_cdtipcta[1] = 0
                             rel_indnivel[1] = 0  rel_nmprimtl[1] = ""
                             rel_nrdconta[2] = 0  rel_nrmatric[2] = 0
                             rel_cdsitdct[2] = 0  rel_cdtipcta[2] = 0
                             rel_indnivel[2] = 0  rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                          rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                          rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                          rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1 rel_nrdconta[1] WITH FRAME f_associados.
                  DOWN STREAM str_1 WITH FRAME f_associados.
              END.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              PAGE STREAM str_1.

         rel_qtdassoc = aux_qtassger.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.
     END.
ELSE
IF   SUBSTRING(glb_dsparame,1,3) = "121"   THEN   /* Geral por conta todos */
     DO:
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK
                                BY crapass.nrdconta:

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassger = aux_qtassger + 1.

             ASSIGN rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_cdsitdct[aux_contador] = crapass.cdsitdct
                    rel_cdtipcta[aux_contador] = crapass.cdtipcta
                    rel_indnivel[aux_contador] = crapass.indnivel
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                              rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                              rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                              rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      ASSIGN rel_nrdconta[1] = 0  rel_nrmatric[1] = 0
                             rel_cdsitdct[1] = 0  rel_cdtipcta[1] = 0
                             rel_indnivel[1] = 0  rel_nmprimtl[1] = ""
                             rel_nrdconta[2] = 0  rel_nrmatric[2] = 0
                             rel_cdsitdct[2] = 0  rel_cdtipcta[2] = 0
                             rel_indnivel[2] = 0  rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                          rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                          rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                          rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                          WITH FRAME f_associados.

                   DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1 rel_nrdconta[1] WITH FRAME f_associados.
                  DOWN STREAM str_1 WITH FRAME f_associados.
              END.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              PAGE STREAM str_1.

         rel_qtdassoc = aux_qtassger.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.
     END.
ELSE
IF   SUBSTRING(glb_dsparame,1,3) = "131"   THEN   /* Geral por cadastro todos */
     DO:
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK
                                BY crapass.nrcadast
                                   BY crapass.nrdconta:

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassger = aux_qtassger + 1.

             ASSIGN rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_cdsitdct[aux_contador] = crapass.cdsitdct
                    rel_cdtipcta[aux_contador] = crapass.cdtipcta
                    rel_indnivel[aux_contador] = crapass.indnivel
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                              rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                              rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                              rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      ASSIGN rel_nrdconta[1] = 0  rel_nrmatric[1] = 0
                             rel_cdsitdct[1] = 0  rel_cdtipcta[1] = 0
                             rel_indnivel[1] = 0  rel_nmprimtl[1] = ""
                             rel_nrdconta[2] = 0  rel_nrmatric[2] = 0
                             rel_cdsitdct[2] = 0  rel_cdtipcta[2] = 0
                             rel_indnivel[2] = 0  rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                          rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                          rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                          rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1 rel_nrdconta WITH FRAME f_associados.
                  DOWN STREAM str_1 WITH FRAME f_associados.
              END.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              PAGE STREAM str_1.

         rel_qtdassoc = aux_qtassger.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.
     END.
ELSE
IF   SUBSTRING(glb_dsparame,1,3) = "211"   THEN   /* Agencia alfabetica todos */
     DO:
         aux_flgfirst = TRUE.

         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK
                                BREAK BY crapass.cdagenci
                                         BY crapass.nmprimtl
                                            BY crapass.nrdconta:

             IF   FIRST-OF(crapass.cdagenci)   THEN
                  DO:
                      IF   aux_flgfirst   THEN
                           aux_flgfirst = FALSE.
                      ELSE
                           DO:
                               IF   rel_nrdconta[1] <> 0   THEN
                                    DO:
                                        DISPLAY STREAM str_1
                                                rel_nrdconta[1]  rel_nrmatric[1]
                                                rel_cdsitdct[1]
                                                rel_cdtipcta[1]  rel_indnivel[1]
                                                rel_nmprimtl[1]
                                                rel_nrdconta[2]  rel_nrmatric[2]
                                                rel_cdsitdct[2]
                                                rel_cdtipcta[2]  rel_indnivel[2]
                                                rel_nmprimtl[2]
                                                WITH FRAME f_associados.

                                        ASSIGN rel_nrdconta[1] = 0
                                               rel_nrmatric[1] = 0
                                               rel_cdsitdct[1] = 0
                                               rel_cdtipcta[1] = 0
                                               rel_indnivel[1] = 0
                                               rel_nmprimtl[1] = ""
                                               rel_nrdconta[2] = 0
                                               rel_nrmatric[2] = 0
                                               rel_cdsitdct[2] = 0
                                               rel_cdtipcta[2] = 0
                                               rel_indnivel[2] = 0
                                               rel_nmprimtl[2] = ""
                                               aux_contador    = 0.

                                        DOWN STREAM str_1
                                             2 WITH FRAME f_associados.

                                    END.
                               ELSE
                                    DOWN STREAM str_1
                                         1 WITH FRAME f_associados.

                               IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
                                    DO:
                                        PAGE STREAM str_1.

                                        rel_nrseqage = rel_nrseqage + 1.

                                        DISPLAY STREAM str_1
                                                rel_cdagenci rel_nmresage
                                                rel_nrseqage
                                                WITH FRAME f_agencia.

                                        ASSIGN rel_qtdassoc = aux_qtassage
                                               aux_qtassage = 0.

                                        DISPLAY STREAM str_1
                                                rel_qtdassoc
                                                WITH FRAME f_qtdassoc.
                                    END.
                               ELSE
                                    DO:
                                        ASSIGN rel_qtdassoc = aux_qtassage
                                               aux_qtassage = 0.

                                        DISPLAY STREAM str_1
                                                rel_qtdassoc
                                                WITH FRAME f_qtdassoc.
                                    END.

                               PAGE STREAM str_1.
                           END.

                      FIND crapage WHERE crapage.cdcooper = glb_cdcooper    AND
                                         crapage.cdagenci = crapass.cdagenci
                                         NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapage   THEN
                           ASSIGN rel_cdagenci = crapass.cdagenci
                                  rel_nmresage = FILL("?",15).
                      ELSE
                           ASSIGN rel_cdagenci = crapass.cdagenci
                                  rel_nmresage = crapage.nmresage.

                      rel_nrseqage = 1.

                      DISPLAY STREAM str_1
                              rel_cdagenci rel_nmresage rel_nrseqage
                              WITH FRAME f_agencia.

                  END.

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassage = aux_qtassage + 1
                    aux_qtassger = aux_qtassger + 1.

             ASSIGN rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_cdsitdct[aux_contador] = crapass.cdsitdct
                    rel_cdtipcta[aux_contador] = crapass.cdtipcta
                    rel_indnivel[aux_contador] = crapass.indnivel
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                              rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                              rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                              rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               rel_nrseqage = rel_nrseqage + 1.

                               DISPLAY STREAM str_1
                                       rel_cdagenci rel_nmresage rel_nrseqage
                                       WITH FRAME f_agencia.
                           END.

                      ASSIGN rel_nrdconta[1] = 0  rel_nrmatric[1] = 0
                             rel_cdsitdct[1] = 0  rel_cdtipcta[1] = 0
                             rel_indnivel[1] = 0  rel_nmprimtl[1] = ""
                             rel_nrdconta[2] = 0  rel_nrmatric[2] = 0
                             rel_cdsitdct[2] = 0  rel_cdtipcta[2] = 0
                             rel_indnivel[2] = 0  rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                          rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                          rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                          rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DOWN STREAM str_1 WITH FRAME f_associados.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.

                  rel_nrseqage = rel_nrseqage + 1.

                  DISPLAY STREAM str_1 rel_cdagenci rel_nmresage rel_nrseqage
                          WITH FRAME f_agencia.

                  rel_qtdassoc = aux_qtassage.
                  DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.

              END.
         ELSE
              DO:
                  rel_qtdassoc = aux_qtassage.

                  DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.

                  DOWN STREAM str_1 WITH FRAME f_associados.

                  IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                       PAGE STREAM str_1.
              END.

         rel_qtdassoc = aux_qtassger.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtgassoc.

     END.
ELSE
IF   SUBSTRING(glb_dsparame,1,3) = "221"   THEN   /* Agencia por conta todos */
     DO:
         aux_flgfirst = TRUE.

         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK
                                BREAK BY crapass.cdagenci
                                         BY crapass.nrdconta:

             IF   FIRST-OF(crapass.cdagenci)   THEN
                  DO:
                      IF   aux_flgfirst   THEN
                           aux_flgfirst = FALSE.
                      ELSE
                           DO:
                               IF   rel_nrdconta[1] <> 0   THEN
                                    DO:
                                        DISPLAY STREAM str_1
                                                rel_nrdconta[1]  rel_nrmatric[1]
                                                rel_cdsitdct[1]
                                                rel_cdtipcta[1]  rel_indnivel[1]
                                                rel_nmprimtl[1]
                                                rel_nrdconta[2]  rel_nrmatric[2]
                                                rel_cdsitdct[2]
                                                rel_cdtipcta[2]  rel_indnivel[2]
                                                rel_nmprimtl[2]
                                                WITH FRAME f_associados.

                                        ASSIGN rel_nrdconta[1] = 0
                                               rel_nrmatric[1] = 0
                                               rel_cdsitdct[1] = 0
                                               rel_cdtipcta[1] = 0
                                               rel_indnivel[1] = 0
                                               rel_nmprimtl[1] = ""
                                               rel_nrdconta[2] = 0
                                               rel_nrmatric[2] = 0
                                               rel_cdsitdct[2] = 0
                                               rel_cdtipcta[2] = 0
                                               rel_indnivel[2] = 0
                                               rel_nmprimtl[2] = ""
                                               aux_contador    = 0.

                                        DOWN STREAM str_1
                                             2 WITH FRAME f_associados.

                                    END.
                               ELSE
                                    DOWN STREAM str_1
                                         1 WITH FRAME f_associados.

                               IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
                                    DO:
                                        PAGE STREAM str_1.

                                        rel_nrseqage = rel_nrseqage + 1.

                                        DISPLAY STREAM str_1
                                                rel_cdagenci rel_nmresage
                                                rel_nrseqage
                                                WITH FRAME f_agencia.

                                        ASSIGN rel_qtdassoc = aux_qtassage
                                               aux_qtassage = 0.

                                        DISPLAY STREAM str_1 rel_qtdassoc
                                                WITH FRAME f_qtdassoc.
                                    END.
                               ELSE
                                    DO:
                                        ASSIGN rel_qtdassoc = aux_qtassage
                                               aux_qtassage = 0.

                                        DISPLAY STREAM str_1 rel_qtdassoc
                                                WITH FRAME f_qtdassoc.
                                    END.

                               PAGE STREAM str_1.
                           END.

                      FIND crapage WHERE crapage.cdcooper = glb_cdcooper    AND
                                         crapage.cdagenci = crapass.cdagenci
                                         NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapage   THEN
                           ASSIGN rel_cdagenci = crapass.cdagenci
                                  rel_nmresage = FILL("?",15).
                      ELSE
                           ASSIGN rel_cdagenci = crapass.cdagenci
                                  rel_nmresage = crapage.nmresage.

                      rel_nrseqage = 1.

                      DISPLAY STREAM str_1
                              rel_cdagenci rel_nmresage rel_nrseqage
                              WITH FRAME f_agencia.

                  END.

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassage = aux_qtassage + 1
                    aux_qtassger = aux_qtassger + 1.

             ASSIGN rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_cdsitdct[aux_contador] = crapass.cdsitdct
                    rel_cdtipcta[aux_contador] = crapass.cdtipcta
                    rel_indnivel[aux_contador] = crapass.indnivel
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                              rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                              rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                              rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               rel_nrseqage = rel_nrseqage + 1.

                               DISPLAY STREAM str_1
                                       rel_cdagenci rel_nmresage rel_nrseqage
                                       WITH FRAME f_agencia.
                           END.

                      ASSIGN rel_nrdconta[1] = 0  rel_nrmatric[1] = 0
                             rel_cdsitdct[1] = 0  rel_cdtipcta[1] = 0
                             rel_indnivel[1] = 0  rel_nmprimtl[1] = ""
                             rel_nrdconta[2] = 0  rel_nrmatric[2] = 0
                             rel_cdsitdct[2] = 0  rel_cdtipcta[2] = 0
                             rel_indnivel[2] = 0  rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                          rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                          rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                          rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DOWN STREAM str_1 WITH FRAME f_associados.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.

                  rel_nrseqage = rel_nrseqage + 1.

                  DISPLAY STREAM str_1 rel_cdagenci rel_nmresage rel_nrseqage
                          WITH FRAME f_agencia.

                  rel_qtdassoc = aux_qtassage.
                  DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.

              END.
         ELSE
              DO:
                  rel_qtdassoc = aux_qtassage.

                  DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.

                  DOWN STREAM str_1 WITH FRAME f_associados.

                  IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                       PAGE STREAM str_1.
              END.

         rel_qtdassoc = aux_qtassger.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtgassoc.

     END.
ELSE
IF   SUBSTRING(glb_dsparame,1,3) = "231"   THEN /* Agencia por cadastro todos */
     DO:
         aux_flgfirst = TRUE.

         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK
                                BREAK BY crapass.cdagenci
                                         BY crapass.nrcadast
                                            BY crapass.nrdconta:

             IF   FIRST-OF(crapass.cdagenci)   THEN
                  DO:
                      IF   aux_flgfirst   THEN
                           aux_flgfirst = FALSE.
                      ELSE
                           DO:
                               IF   rel_nrdconta[1] <> 0   THEN
                                    DO:
                                        DISPLAY STREAM str_1
                                                rel_nrdconta[1]  rel_nrmatric[1]
                                                rel_cdsitdct[1]
                                                rel_cdtipcta[1]  rel_indnivel[1]
                                                rel_nmprimtl[1]
                                                rel_nrdconta[2]  rel_nrmatric[2]
                                                rel_cdsitdct[2]
                                                rel_cdtipcta[2]  rel_indnivel[2]
                                                rel_nmprimtl[2]
                                                WITH FRAME f_associados.

                                        ASSIGN rel_nrdconta[1] = 0
                                               rel_nrmatric[1] = 0
                                               rel_cdsitdct[1] = 0
                                               rel_cdtipcta[1] = 0
                                               rel_indnivel[1] = 0
                                               rel_nmprimtl[1] = ""
                                               rel_nrdconta[2] = 0
                                               rel_nrmatric[2] = 0
                                               rel_cdsitdct[2] = 0
                                               rel_cdtipcta[2] = 0
                                               rel_indnivel[2] = 0
                                               rel_nmprimtl[2] = ""
                                               aux_contador    = 0.

                                        DOWN STREAM str_1
                                             2 WITH FRAME f_associados.

                                    END.
                               ELSE
                                    DOWN STREAM str_1
                                         1 WITH FRAME f_associados.

                               IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
                                    DO:
                                        PAGE STREAM str_1.

                                        rel_nrseqage = rel_nrseqage + 1.

                                        DISPLAY STREAM str_1
                                                rel_cdagenci rel_nmresage
                                                rel_nrseqage
                                                WITH FRAME f_agencia.

                                        ASSIGN rel_qtdassoc = aux_qtassage
                                               aux_qtassage = 0.

                                        DISPLAY STREAM str_1
                                                rel_qtdassoc
                                                WITH FRAME f_qtdassoc.
                                    END.
                               ELSE
                                    DO:
                                        ASSIGN rel_qtdassoc = aux_qtassage
                                               aux_qtassage = 0.

                                        DISPLAY STREAM str_1
                                                rel_qtdassoc
                                                WITH FRAME f_qtdassoc.
                                    END.

                               PAGE STREAM str_1.
                           END.

                      FIND crapage WHERE crapage.cdcooper = glb_cdcooper    AND
                                         crapage.cdagenci = crapass.cdagenci
                                         NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapage   THEN
                           ASSIGN rel_cdagenci = crapass.cdagenci
                                  rel_nmresage = FILL("?",15).
                      ELSE
                           ASSIGN rel_cdagenci = crapass.cdagenci
                                  rel_nmresage = crapage.nmresage.

                      rel_nrseqage = 1.

                      DISPLAY STREAM str_1
                              rel_cdagenci rel_nmresage rel_nrseqage
                              WITH FRAME f_agencia.

                  END.

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassage = aux_qtassage + 1
                    aux_qtassger = aux_qtassger + 1.

             ASSIGN rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_cdsitdct[aux_contador] = crapass.cdsitdct
                    rel_cdtipcta[aux_contador] = crapass.cdtipcta
                    rel_indnivel[aux_contador] = crapass.indnivel
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                              rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                              rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                              rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               rel_nrseqage = rel_nrseqage + 1.

                               DISPLAY STREAM str_1
                                       rel_cdagenci rel_nmresage rel_nrseqage
                                       WITH FRAME f_agencia.
                           END.

                      ASSIGN rel_nrdconta[1] = 0  rel_nrmatric[1] = 0
                             rel_cdsitdct[1] = 0  rel_cdtipcta[1] = 0
                             rel_indnivel[1] = 0  rel_nmprimtl[1] = ""
                             rel_nrdconta[2] = 0  rel_nrmatric[2] = 0
                             rel_cdsitdct[2] = 0  rel_cdtipcta[2] = 0
                             rel_indnivel[2] = 0  rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                          rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                          rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                          rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DOWN STREAM str_1 WITH FRAME f_associados.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.

                  rel_nrseqage = rel_nrseqage + 1.

                  DISPLAY STREAM str_1
                          rel_cdagenci rel_nmresage rel_nrseqage
                          WITH FRAME f_agencia.

                  rel_qtdassoc = aux_qtassage.
                  DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.

              END.
         ELSE
              DO:
                  rel_qtdassoc = aux_qtassage.

                  DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.

                  DOWN STREAM str_1 WITH FRAME f_associados.

                  IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                       PAGE STREAM str_1.
              END.

         rel_qtdassoc = aux_qtassger.
         DISPLAY STREAM str_1
                 rel_qtdassoc WITH FRAME f_qtgassoc.

     END.
ELSE
IF   SUBSTRING(glb_dsparame,1,3) = "311"   THEN   /* Empresa alfabetica todos */
     DO:
         aux_flgfirst = TRUE.

         FOR EACH tt-crapass:
             DELETE tt-crapass.
         END.
   
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK:

             FIND tt-crapass WHERE
                  tt-crapass.cdcooper   = crapass.cdcooper   AND
                  tt-crapass.nrdconta   = crapass.nrdconta   NO-LOCK NO-ERROR.
             
             IF  NOT AVAIL tt-crapass THEN 
                 DO:
                     CREATE tt-crapass.
                     ASSIGN tt-crapass.cdcooper   = crapass.cdcooper
                            tt-crapass.nrdconta   = crapass.nrdconta.

                     IF   crapass.inpessoa = 1   THEN 
                          DO:
                              FIND crapttl WHERE 
                                   crapttl.cdcooper = glb_cdcooper       AND
                                   crapttl.nrdconta = crapass.nrdconta   AND
                                   crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
    
                              IF  AVAIL crapttl  THEN
                                  ASSIGN tt-crapass.cdempres = crapttl.cdempres.
                          END.
                     ELSE
                          DO:
                              FIND crapjur WHERE 
                                   crapjur.cdcooper = glb_cdcooper  AND
                                   crapjur.nrdconta = crapass.nrdconta
                                   NO-LOCK NO-ERROR.
    
                              IF  AVAIL crapjur  THEN
                                  ASSIGN tt-crapass.cdempres = crapjur.cdempres.
                          END.          
                 END.
         END.

         FOR EACH tt-crapass NO-LOCK,
            FIRST crapass WHERE crapass.cdcooper = tt-crapass.cdcooper AND
                                crapass.nrdconta = tt-crapass.nrdconta NO-LOCK
                                BREAK BY tt-crapass.cdempres
                                         BY crapass.nmprimtl
                                            BY crapass.nrdconta:

             IF   FIRST-OF(tt-crapass.cdempres)   THEN
                  DO:
                      IF   aux_flgfirst   THEN
                           aux_flgfirst = FALSE.
                      ELSE
                           DO:
                               IF   rel_nrdconta[1] <> 0   THEN
                                    DO:
                                        DISPLAY STREAM str_1
                                                rel_nrdconta[1]  rel_nrmatric[1]
                                                rel_cdsitdct[1]
                                                rel_cdtipcta[1]  rel_indnivel[1]
                                                rel_nmprimtl[1]
                                                rel_nrdconta[2]  rel_nrmatric[2]
                                                rel_cdsitdct[2]
                                                rel_cdtipcta[2]  rel_indnivel[2]
                                                rel_nmprimtl[2]
                                                WITH FRAME f_associados.

                                        ASSIGN rel_nrdconta[1] = 0
                                               rel_nrmatric[1] = 0
                                               rel_cdsitdct[1] = 0
                                               rel_cdtipcta[1] = 0
                                               rel_indnivel[1] = 0
                                               rel_nmprimtl[1] = ""
                                               rel_nrdconta[2] = 0
                                               rel_nrmatric[2] = 0
                                               rel_cdsitdct[2] = 0
                                               rel_cdtipcta[2] = 0
                                               rel_indnivel[2] = 0
                                               rel_nmprimtl[2] = ""
                                               aux_contador    = 0.

                                        DOWN STREAM str_1
                                             2 WITH FRAME f_associados.

                                    END.
                               ELSE
                                    DOWN STREAM str_1
                                         1 WITH FRAME f_associados.

                               IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
                                    DO:
                                        PAGE STREAM str_1.

                                        rel_nrseqemp = rel_nrseqemp + 1.

                                        DISPLAY STREAM str_1
                                                rel_cdempres rel_nmresemp
                                                rel_nrseqemp
                                                WITH FRAME f_empresa.

                                        ASSIGN rel_qtdassoc = aux_qtassemp
                                               aux_qtassemp = 0.

                                        DISPLAY STREAM str_1
                                                rel_qtdassoc
                                                WITH FRAME f_qtdassoc.
                                    END.
                               ELSE
                                    DO:
                                        ASSIGN rel_qtdassoc = aux_qtassemp
                                               aux_qtassemp = 0.

                                        DISPLAY STREAM str_1
                                                rel_qtdassoc
                                                WITH FRAME f_qtdassoc.
                                    END.

                               PAGE STREAM str_1.
                           END.

                      FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper    AND
                                         crapemp.cdempres = tt-crapass.cdempres
                                         NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapemp   THEN
                           ASSIGN rel_cdempres = tt-crapass.cdempres
                                  rel_nmresemp = FILL("?",15).
                      ELSE
                           ASSIGN rel_cdempres = tt-crapass.cdempres
                                  rel_nmresemp = crapemp.nmresemp.

                      rel_nrseqemp = 1.

                      DISPLAY STREAM str_1
                              rel_cdempres rel_nmresemp rel_nrseqemp
                              WITH FRAME f_empresa.

                  END.

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassemp = aux_qtassemp + 1
                    aux_qtassger = aux_qtassger + 1.

             ASSIGN rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_cdsitdct[aux_contador] = crapass.cdsitdct
                    rel_cdtipcta[aux_contador] = crapass.cdtipcta
                    rel_indnivel[aux_contador] = crapass.indnivel
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                              rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                              rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                              rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               rel_nrseqemp = rel_nrseqemp + 1.

                               DISPLAY STREAM str_1
                                       rel_cdempres rel_nmresemp rel_nrseqemp
                                       WITH FRAME f_empresa.
                           END.

                      ASSIGN rel_nrdconta[1] = 0  rel_nrmatric[1] = 0
                             rel_cdsitdct[1] = 0  rel_cdtipcta[1] = 0
                             rel_indnivel[1] = 0  rel_nmprimtl[1] = ""
                             rel_nrdconta[2] = 0  rel_nrmatric[2] = 0
                             rel_cdsitdct[2] = 0  rel_cdtipcta[2] = 0
                             rel_indnivel[2] = 0  rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                          rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                          rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                          rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DOWN STREAM str_1 WITH FRAME f_associados.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.

                  rel_nrseqemp = rel_nrseqemp + 1.

                  DISPLAY STREAM str_1 rel_cdempres rel_nmresemp rel_nrseqemp
                          WITH FRAME f_empresa.

                  rel_qtdassoc = aux_qtassemp.
                  DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.

              END.
         ELSE
              DO:
                  rel_qtdassoc = aux_qtassemp.

                  DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.

                  DOWN STREAM str_1 WITH FRAME f_associados.

                  IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                       PAGE STREAM str_1.
              END.

         rel_qtdassoc = aux_qtassger.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtgassoc.

     END.
ELSE
IF   SUBSTRING(glb_dsparame,1,3) = "321"   THEN   /* Empresa por conta todos */
     DO:
         aux_flgfirst = TRUE.

         FOR EACH tt-crapass:
             DELETE tt-crapass.
         END.
   
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK:

             FIND tt-crapass WHERE
                  tt-crapass.cdcooper   = crapass.cdcooper   AND
                  tt-crapass.nrdconta   = crapass.nrdconta   NO-LOCK NO-ERROR.
             
             IF  NOT AVAIL tt-crapass THEN 
                 DO:
                     CREATE tt-crapass.
                     ASSIGN tt-crapass.cdcooper   = crapass.cdcooper
                            tt-crapass.nrdconta   = crapass.nrdconta.

                     IF   crapass.inpessoa = 1   THEN 
                          DO:
                              FIND crapttl WHERE 
                                   crapttl.cdcooper = glb_cdcooper       AND
                                   crapttl.nrdconta = crapass.nrdconta   AND
                                   crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
    
                              IF  AVAIL crapttl  THEN
                                  ASSIGN tt-crapass.cdempres = crapttl.cdempres.
                          END.
                     ELSE
                          DO:
                              FIND crapjur WHERE 
                                   crapjur.cdcooper = glb_cdcooper  AND
                                   crapjur.nrdconta = crapass.nrdconta
                                   NO-LOCK NO-ERROR.
    
                              IF  AVAIL crapjur  THEN
                                  ASSIGN tt-crapass.cdempres = crapjur.cdempres.
                          END.          
                  END.
         END.

         FOR EACH tt-crapass NO-LOCK,
            FIRST crapass WHERE crapass.cdcooper = tt-crapass.cdcooper AND
                                crapass.nrdconta = tt-crapass.nrdconta NO-LOCK
                                BREAK BY tt-crapass.cdempres
                                         BY crapass.nrdconta:

             IF   FIRST-OF(tt-crapass.cdempres)   THEN
                  DO:
                      IF   aux_flgfirst   THEN
                           aux_flgfirst = FALSE.
                      ELSE
                           DO:
                               IF   rel_nrdconta[1] <> 0   THEN
                                    DO:
                                        DISPLAY STREAM str_1
                                                rel_nrdconta[1]  rel_nrmatric[1]
                                                rel_cdsitdct[1]
                                                rel_cdtipcta[1]  rel_indnivel[1]
                                                rel_nmprimtl[1]
                                                rel_nrdconta[2]  rel_nrmatric[2]
                                                rel_cdsitdct[2]
                                                rel_cdtipcta[2]  rel_indnivel[2]
                                                rel_nmprimtl[2]
                                                WITH FRAME f_associados.

                                        ASSIGN rel_nrdconta[1] = 0
                                               rel_nrmatric[1] = 0
                                               rel_cdsitdct[1] = 0
                                               rel_cdtipcta[1] = 0
                                               rel_indnivel[1] = 0
                                               rel_nmprimtl[1] = ""
                                               rel_nrdconta[2] = 0
                                               rel_nrmatric[2] = 0
                                               rel_cdsitdct[2] = 0
                                               rel_cdtipcta[2] = 0
                                               rel_indnivel[2] = 0
                                               rel_nmprimtl[2] = ""
                                               aux_contador    = 0.

                                        DOWN STREAM str_1
                                             2 WITH FRAME f_associados.

                                    END.
                               ELSE
                                    DOWN STREAM str_1
                                         1 WITH FRAME f_associados.

                               IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
                                    DO:
                                        PAGE STREAM str_1.

                                        rel_nrseqemp = rel_nrseqemp + 1.

                                        DISPLAY STREAM str_1
                                                rel_cdempres rel_nmresemp
                                                rel_nrseqemp
                                                WITH FRAME f_empresa.

                                        ASSIGN rel_qtdassoc = aux_qtassemp
                                               aux_qtassemp = 0.

                                        DISPLAY STREAM str_1
                                                rel_qtdassoc
                                                WITH FRAME f_qtdassoc.
                                    END.
                               ELSE
                                    DO:
                                        ASSIGN rel_qtdassoc = aux_qtassemp
                                               aux_qtassemp = 0.

                                        DISPLAY STREAM str_1
                                                rel_qtdassoc
                                                WITH FRAME f_qtdassoc.
                                    END.

                               PAGE STREAM str_1.
                           END.

                      FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper    AND
                                         crapemp.cdempres = tt-crapass.cdempres
                                         NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapemp   THEN
                           ASSIGN rel_cdempres = tt-crapass.cdempres
                                  rel_nmresemp = FILL("?",15).
                      ELSE
                           ASSIGN rel_cdempres = tt-crapass.cdempres
                                  rel_nmresemp = crapemp.nmresemp.

                      rel_nrseqemp = 1.

                      DISPLAY STREAM str_1
                              rel_cdempres rel_nmresemp rel_nrseqemp
                              WITH FRAME f_empresa.

                  END.

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassemp = aux_qtassemp + 1
                    aux_qtassger = aux_qtassger + 1.

             ASSIGN rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_cdsitdct[aux_contador] = crapass.cdsitdct
                    rel_cdtipcta[aux_contador] = crapass.cdtipcta
                    rel_indnivel[aux_contador] = crapass.indnivel
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                              rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                              rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                              rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               rel_nrseqemp = rel_nrseqemp + 1.

                               DISPLAY STREAM str_1
                                       rel_cdempres rel_nmresemp rel_nrseqemp
                                       WITH FRAME f_empresa.
                           END.

                      ASSIGN rel_nrdconta[1] = 0  rel_nrmatric[1] = 0
                             rel_cdsitdct[1] = 0  rel_cdtipcta[1] = 0
                             rel_indnivel[1] = 0  rel_nmprimtl[1] = ""
                             rel_nrdconta[2] = 0  rel_nrmatric[2] = 0
                             rel_cdsitdct[2] = 0  rel_cdtipcta[2] = 0
                             rel_indnivel[2] = 0  rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                          rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                          rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                          rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DOWN STREAM str_1 WITH FRAME f_associados.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.

                  rel_nrseqemp = rel_nrseqemp + 1.

                  DISPLAY STREAM str_1 rel_cdempres rel_nmresemp rel_nrseqemp
                          WITH FRAME f_empresa.

                  rel_qtdassoc = aux_qtassemp.
                  DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.

              END.
         ELSE
              DO:
                  rel_qtdassoc = aux_qtassemp.

                  DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.

                  DOWN STREAM str_1 WITH FRAME f_associados.

                  IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                       PAGE STREAM str_1.
              END.

         rel_qtdassoc = aux_qtassger.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtgassoc.

     END.
ELSE
IF   SUBSTRING(glb_dsparame,1,3) = "331"   THEN /* Empresa por cadastro todos */
     DO:
         aux_flgfirst = TRUE.

         FOR EACH tt-crapass:
             DELETE tt-crapass.
         END.
   
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK:
             
             FIND tt-crapass WHERE
                  tt-crapass.cdcooper   = crapass.cdcooper   AND
                  tt-crapass.nrdconta   = crapass.nrdconta   NO-LOCK NO-ERROR.
             
             IF  NOT AVAIL tt-crapass THEN 
                 DO:
                     CREATE tt-crapass.
                     ASSIGN tt-crapass.cdcooper   = crapass.cdcooper
                            tt-crapass.nrdconta   = crapass.nrdconta.

                     IF   crapass.inpessoa = 1   THEN 
                          DO:
                              FIND crapttl WHERE 
                                   crapttl.cdcooper = glb_cdcooper       AND
                                   crapttl.nrdconta = crapass.nrdconta   AND
                                   crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
    
                              IF  AVAIL crapttl  THEN
                                  ASSIGN tt-crapass.cdempres = crapttl.cdempres.
                          END.
                     ELSE
                          DO:
                              FIND crapjur WHERE 
                                   crapjur.cdcooper = glb_cdcooper  AND
                                   crapjur.nrdconta = crapass.nrdconta
                                   NO-LOCK NO-ERROR.
    
                              IF  AVAIL crapjur  THEN
                                  ASSIGN tt-crapass.cdempres = crapjur.cdempres.
                          END.          
                  END.
         END.

         FOR EACH tt-crapass NO-LOCK,
            FIRST crapass WHERE crapass.cdcooper = tt-crapass.cdcooper AND
                                crapass.nrdconta = tt-crapass.nrdconta NO-LOCK
                                BREAK BY tt-crapass.cdempres
                                         BY crapass.nrcadast
                                            BY crapass.nrdconta:

             IF   FIRST-OF(tt-crapass.cdempres)   THEN
                  DO:
                      IF   aux_flgfirst   THEN
                           aux_flgfirst = FALSE.
                      ELSE
                           DO:
                               IF   rel_nrdconta[1] <> 0   THEN
                                    DO:
                                        DISPLAY STREAM str_1
                                                rel_nrdconta[1]  rel_nrmatric[1]
                                                rel_cdsitdct[1]
                                                rel_cdtipcta[1]  rel_indnivel[1]
                                                rel_nmprimtl[1]
                                                rel_nrdconta[2]  rel_nrmatric[2]
                                                rel_cdsitdct[2]
                                                rel_cdtipcta[2]  rel_indnivel[2]
                                                rel_nmprimtl[2]
                                                WITH FRAME f_associados.

                                        ASSIGN rel_nrdconta[1] = 0
                                               rel_nrmatric[1] = 0
                                               rel_cdsitdct[1] = 0
                                               rel_cdtipcta[1] = 0
                                               rel_indnivel[1] = 0
                                               rel_nmprimtl[1] = ""
                                               rel_nrdconta[2] = 0
                                               rel_nrmatric[2] = 0
                                               rel_cdsitdct[2] = 0
                                               rel_cdtipcta[2] = 0
                                               rel_indnivel[2] = 0
                                               rel_nmprimtl[2] = ""
                                               aux_contador    = 0.

                                        DOWN STREAM str_1
                                             2 WITH FRAME f_associados.

                                    END.
                               ELSE
                                    DOWN STREAM str_1
                                         1 WITH FRAME f_associados.

                               IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
                                    DO:
                                        PAGE STREAM str_1.

                                        rel_nrseqemp = rel_nrseqemp + 1.

                                        DISPLAY STREAM str_1
                                                rel_cdempres rel_nmresemp
                                                rel_nrseqemp
                                                WITH FRAME f_empresa.

                                        ASSIGN rel_qtdassoc = aux_qtassemp
                                               aux_qtassemp = 0.

                                        DISPLAY STREAM str_1
                                                rel_qtdassoc
                                                WITH FRAME f_qtdassoc.
                                    END.
                               ELSE
                                    DO:
                                        ASSIGN rel_qtdassoc = aux_qtassemp
                                               aux_qtassemp = 0.

                                        DISPLAY STREAM str_1
                                                rel_qtdassoc
                                                WITH FRAME f_qtdassoc.
                                    END.

                               PAGE STREAM str_1.
                           END.

                      FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper    AND
                                         crapemp.cdempres = tt-crapass.cdempres
                                         NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapemp   THEN
                           ASSIGN rel_cdempres = tt-crapass.cdempres
                                  rel_nmresemp = FILL("?",15).
                      ELSE
                           ASSIGN rel_cdempres = tt-crapass.cdempres
                                  rel_nmresemp = crapemp.nmresemp.

                      rel_nrseqemp = 1.

                      DISPLAY STREAM str_1
                              rel_cdempres rel_nmresemp rel_nrseqemp
                              WITH FRAME f_empresa.

                  END.

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassemp = aux_qtassemp + 1
                    aux_qtassger = aux_qtassger + 1.

             ASSIGN rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_cdsitdct[aux_contador] = crapass.cdsitdct
                    rel_cdtipcta[aux_contador] = crapass.cdtipcta
                    rel_indnivel[aux_contador] = crapass.indnivel
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                              rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                              rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                              rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.

                               rel_nrseqemp = rel_nrseqemp + 1.

                               DISPLAY STREAM str_1
                                       rel_cdempres rel_nmresemp rel_nrseqemp
                                       WITH FRAME f_empresa.
                           END.

                      ASSIGN rel_nrdconta[1] = 0  rel_nrmatric[1] = 0
                             rel_cdsitdct[1] = 0  rel_cdtipcta[1] = 0
                             rel_indnivel[1] = 0  rel_nmprimtl[1] = ""
                             rel_nrdconta[2] = 0  rel_nrmatric[2] = 0
                             rel_cdsitdct[2] = 0  rel_cdtipcta[2] = 0
                             rel_indnivel[2] = 0  rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_nrdconta[1]  rel_nrmatric[1]  rel_cdsitdct[1]
                          rel_cdtipcta[1]  rel_indnivel[1]  rel_nmprimtl[1]
                          rel_nrdconta[2]  rel_nrmatric[2]  rel_cdsitdct[2]
                          rel_cdtipcta[2]  rel_indnivel[2]  rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DOWN STREAM str_1 WITH FRAME f_associados.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.

                  rel_nrseqemp = rel_nrseqemp + 1.

                  DISPLAY STREAM str_1 rel_cdempres rel_nmresemp rel_nrseqemp
                          WITH FRAME f_empresa.

                  rel_qtdassoc = aux_qtassemp.
                  DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.

              END.
         ELSE
              DO:
                  rel_qtdassoc = aux_qtassemp.

                  DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.

                  DOWN STREAM str_1 WITH FRAME f_associados.

                  IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                       PAGE STREAM str_1.
              END.

         rel_qtdassoc = aux_qtassger.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtgassoc.

     END.

/* .......................................................................... */

