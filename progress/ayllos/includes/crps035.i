/* .............................................................................

   Programa: Includes/crps035.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91                         Ultima atualizacao: 10/06/2009

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 022
               Listar os associados cadastrados conforme solicitacao.

   Alteracao : 05/04/95 - Alterado para listar relatorios quando dsparame =
                          1 3, 2 2, 2 3, 3 2  e 3 3 (Odair).

             14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando

             01/09/2008 - Alteracao cdempres (Kbase IT) - Eduardo Silva.
             
             10/06/2009 - Corrigido SUBSTRING da variavel glb_dsparame devido
                          o aumento do campo cdempres (Diego).
                          
............................................................................. */

IF   SUBSTRING(glb_dsparame,7,3) = "1 1"  THEN  /* Alfabetica todos */
     DO:
     
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper  NO-LOCK  
                                BY crapass.nmprimtl 
                                   BY crapass.nrdconta:

             IF   crapass.inpessoa = 1   THEN 
                  DO:
                      FIND crapttl WHERE 
                           crapttl.cdcooper = glb_cdcooper       AND
                           crapttl.nrdconta = crapass.nrdconta   AND
                           crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                      IF   AVAIL crapttl  THEN
                           ASSIGN aux_cdempres_2 = crapttl.cdempres.
                  END.
             ELSE
                  DO:
                      FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                         crapjur.nrdconta = crapass.nrdconta
                                         NO-LOCK NO-ERROR.

                      IF   AVAIL crapjur  THEN
                           ASSIGN aux_cdempres_2 = crapjur.cdempres.
                  END.
        
             IF   aux_cdempres <> aux_cdempres_2 THEN
                  NEXT.

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassemp = aux_qtassemp + 1.

             ASSIGN rel_cdagenci[aux_contador] = crapass.cdagenci
                    rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_cdagenci[1] rel_nrdconta[1]
                              rel_nrmatric[1] rel_nmprimtl[1]
                              rel_cdagenci[2] rel_nrdconta[2]
                              rel_nrmatric[2] rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.
                               DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                              WITH FRAME f_empresa.
                           END.

                      ASSIGN rel_cdagenci[1] = 0 rel_nrdconta[1] = 0
                             rel_nrmatric[1] = 0 rel_nmprimtl[1] = ""
                             rel_cdagenci[2] = 0 rel_nrdconta[2] = 0
                             rel_nrmatric[2] = 0 rel_nmprimtl[2] = ""
                             aux_contador = 0.
                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_cdagenci[1] rel_nrdconta[1]
                          rel_nrmatric[1] rel_nmprimtl[1]
                          rel_cdagenci[2] rel_nrdconta[2]
                          rel_nrmatric[2] rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1 rel_nrdconta[1] WITH FRAME f_associados.
                  DOWN STREAM str_1 WITH FRAME f_associados.
              END.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.
                  DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                 WITH FRAME f_empresa.
              END.

         rel_qtdassoc = aux_qtassemp.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.
     END.
ELSE
IF   SUBSTRING(glb_dsparame,7,3) = "1 2"  THEN  /* Alfabetica ativos */
     DO:

         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper    AND
                                crapass.dtdemiss = ?               NO-LOCK
                                BY crapass.nmprimtl 
                                   BY crapass.nrdconta:

             IF   crapass.inpessoa = 1   THEN 
                  DO:
                      FIND crapttl WHERE 
                           crapttl.cdcooper = glb_cdcooper       AND
                           crapttl.nrdconta = crapass.nrdconta   AND
                           crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                      IF   AVAIL crapttl  THEN
                           ASSIGN aux_cdempres_2 = crapttl.cdempres.
                  END.
             ELSE
                  DO:
                      FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                         crapjur.nrdconta = crapass.nrdconta
                                         NO-LOCK NO-ERROR.

                      IF   AVAIL crapjur  THEN
                           ASSIGN aux_cdempres_2 = crapjur.cdempres.
                  END.
        
             IF   aux_cdempres <> aux_cdempres_2 THEN
                  NEXT.

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassemp = aux_qtassemp + 1.

             ASSIGN rel_cdagenci[aux_contador] = crapass.cdagenci
                    rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_cdagenci[1] rel_nrdconta[1]
                              rel_nrmatric[1] rel_nmprimtl[1]
                              rel_cdagenci[2] rel_nrdconta[2]
                              rel_nrmatric[2] rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.
                               DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                              WITH FRAME f_empresa.
                           END.

                      ASSIGN rel_cdagenci[1] = 0 rel_nrdconta[1] = 0
                             rel_nrmatric[1] = 0 rel_nmprimtl[1] = ""
                             rel_cdagenci[2] = 0 rel_nrdconta[2] = 0
                             rel_nrmatric[2] = 0 rel_nmprimtl[2] = ""
                             aux_contador = 0.
                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_cdagenci[1] rel_nrdconta[1]
                          rel_nrmatric[1] rel_nmprimtl[1]
                          rel_cdagenci[2] rel_nrdconta[2]
                          rel_nrmatric[2] rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1 rel_nrdconta[1] WITH FRAME f_associados.
                  DOWN STREAM str_1 WITH FRAME f_associados.
              END.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.
                  DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                 WITH FRAME f_empresa.
              END.

         rel_qtdassoc = aux_qtassemp.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.
     END.
ELSE
IF   SUBSTRING(glb_dsparame,7,3) = "1 3"  THEN  /* Alfabetica inativos */
     DO:
         
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                                crapass.dtdemiss <> ?            NO-LOCK 
                                BY crapass.nmprimtl 
                                   BY crapass.nrdconta:

             IF   crapass.inpessoa = 1   THEN 
                  DO:
                      FIND crapttl WHERE 
                           crapttl.cdcooper = glb_cdcooper       AND
                           crapttl.nrdconta = crapass.nrdconta   AND
                           crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                      IF   AVAIL crapttl  THEN
                           ASSIGN aux_cdempres_2 = crapttl.cdempres.
                  END.
             ELSE
                  DO:
                      FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                         crapjur.nrdconta = crapass.nrdconta
                                         NO-LOCK NO-ERROR.

                      IF   AVAIL crapjur  THEN
                           ASSIGN aux_cdempres_2 = crapjur.cdempres.
                  END.
        
             IF   aux_cdempres <> aux_cdempres_2 THEN
                  NEXT.

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassemp = aux_qtassemp + 1.

             ASSIGN rel_cdagenci[aux_contador] = crapass.cdagenci
                    rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_cdagenci[1] rel_nrdconta[1]
                              rel_nrmatric[1] rel_nmprimtl[1]
                              rel_cdagenci[2] rel_nrdconta[2]
                              rel_nrmatric[2] rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.
                               DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                              WITH FRAME f_empresa.
                           END.

                      ASSIGN rel_cdagenci[1] = 0 rel_nrdconta[1] = 0
                             rel_nrmatric[1] = 0 rel_nmprimtl[1] = ""
                             rel_cdagenci[2] = 0 rel_nrdconta[2] = 0
                             rel_nrmatric[2] = 0 rel_nmprimtl[2] = ""
                             aux_contador = 0.
                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_cdagenci[1] rel_nrdconta[1]
                          rel_nrmatric[1] rel_nmprimtl[1]
                          rel_cdagenci[2] rel_nrdconta[2]
                          rel_nrmatric[2] rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1 rel_nrdconta[1] WITH FRAME f_associados.
                  DOWN STREAM str_1 WITH FRAME f_associados.
              END.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.
                  DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                 WITH FRAME f_empresa.
              END.

         rel_qtdassoc = aux_qtassemp.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.
     END.
ELSE
IF   SUBSTRING(glb_dsparame,7,3) = "2 1"   THEN   /* Conta todos */
     DO:

         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper  NO-LOCK
                                BY crapass.nrdconta:

             IF   crapass.inpessoa = 1   THEN 
                  DO:
                      FIND crapttl WHERE 
                           crapttl.cdcooper = glb_cdcooper       AND
                           crapttl.nrdconta = crapass.nrdconta   AND
                           crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                      IF   AVAIL crapttl  THEN
                           ASSIGN aux_cdempres_2 = crapttl.cdempres.
                  END.
             ELSE
                  DO:
                      FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                         crapjur.nrdconta = crapass.nrdconta
                                         NO-LOCK NO-ERROR.

                      IF   AVAIL crapjur  THEN
                           ASSIGN aux_cdempres_2 = crapjur.cdempres.
                  END.
        
             IF   aux_cdempres <> aux_cdempres_2 THEN
                  NEXT.

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassemp = aux_qtassemp + 1.

             ASSIGN rel_cdagenci[aux_contador] = crapass.cdagenci
                    rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_cdagenci[1] rel_nrdconta[1]
                              rel_nrmatric[1] rel_nmprimtl[1]
                              rel_cdagenci[2] rel_nrdconta[2]
                              rel_nrmatric[2] rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.
                               DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                              WITH FRAME f_empresa.
                           END.

                      ASSIGN rel_cdagenci[1] = 0 rel_nrdconta[1] = 0
                             rel_nrmatric[1] = 0 rel_nmprimtl[1] = ""
                             rel_cdagenci[2] = 0 rel_nrdconta[2] = 0
                             rel_nrmatric[2] = 0 rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_cdagenci[1] rel_nrdconta[1]
                          rel_nrmatric[1] rel_nmprimtl[1]
                          rel_cdagenci[2] rel_nrdconta[2]
                          rel_nrmatric[2] rel_nmprimtl[2]
                          WITH FRAME f_associados.

                   DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1 rel_nrdconta[1] WITH FRAME f_associados.
                  DOWN STREAM str_1 WITH FRAME f_associados.
              END.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.
                  DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                 WITH FRAME f_empresa.
              END.

         rel_qtdassoc = aux_qtassemp.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.
     END.
ELSE
IF   SUBSTRING(glb_dsparame,7,3) = "2 2"   THEN   /* Conta ativos */
     DO:
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                                crapass.dtdemiss = ?             NO-LOCK
                                BY crapass.nrdconta:

             IF   crapass.inpessoa = 1   THEN 
                  DO:
                      FIND crapttl WHERE 
                           crapttl.cdcooper = glb_cdcooper       AND
                           crapttl.nrdconta = crapass.nrdconta   AND
                           crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                      IF   AVAIL crapttl  THEN
                           ASSIGN aux_cdempres_2 = crapttl.cdempres.
                  END.
             ELSE
                  DO:
                      FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                         crapjur.nrdconta = crapass.nrdconta
                                         NO-LOCK NO-ERROR.

                      IF   AVAIL crapjur  THEN
                           ASSIGN aux_cdempres_2 = crapjur.cdempres.
                  END.
        
             IF   aux_cdempres <> aux_cdempres_2 THEN
                  NEXT.

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassemp = aux_qtassemp + 1.

             ASSIGN rel_cdagenci[aux_contador] = crapass.cdagenci
                    rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_cdagenci[1] rel_nrdconta[1]
                              rel_nrmatric[1] rel_nmprimtl[1]
                              rel_cdagenci[2] rel_nrdconta[2]
                              rel_nrmatric[2] rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.
                               DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                              WITH FRAME f_empresa.
                           END.

                      ASSIGN rel_cdagenci[1] = 0 rel_nrdconta[1] = 0
                             rel_nrmatric[1] = 0 rel_nmprimtl[1] = ""
                             rel_cdagenci[2] = 0 rel_nrdconta[2] = 0
                             rel_nrmatric[2] = 0 rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_cdagenci[1] rel_nrdconta[1]
                          rel_nrmatric[1] rel_nmprimtl[1]
                          rel_cdagenci[2] rel_nrdconta[2]
                          rel_nrmatric[2] rel_nmprimtl[2]
                          WITH FRAME f_associados.

                   DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1 rel_nrdconta[1] WITH FRAME f_associados.
                  DOWN STREAM str_1 WITH FRAME f_associados.
              END.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.
                  DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                 WITH FRAME f_empresa.
              END.

         rel_qtdassoc = aux_qtassemp.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.
     END.
ELSE
IF   SUBSTRING(glb_dsparame,7,3) = "2 3"   THEN   /* Conta inativos */
     DO:

         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                                crapass.dtdemiss <> ?            NO-LOCK 
                                BY crapass.nrdconta:

             IF   crapass.inpessoa = 1   THEN 
                  DO:
                      FIND crapttl WHERE 
                           crapttl.cdcooper = glb_cdcooper       AND
                           crapttl.nrdconta = crapass.nrdconta   AND
                           crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                      IF   AVAIL crapttl  THEN
                           ASSIGN aux_cdempres_2 = crapttl.cdempres.
                  END.
             ELSE
                  DO:
                      FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                         crapjur.nrdconta = crapass.nrdconta
                                         NO-LOCK NO-ERROR.

                      IF   AVAIL crapjur  THEN
                           ASSIGN aux_cdempres_2 = crapjur.cdempres.
                  END.
        
             IF   aux_cdempres <> aux_cdempres_2 THEN
                  NEXT.

             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassemp = aux_qtassemp + 1.

             ASSIGN rel_cdagenci[aux_contador] = crapass.cdagenci
                    rel_nrdconta[aux_contador] = crapass.nrdconta
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_cdagenci[1] rel_nrdconta[1]
                              rel_nrmatric[1] rel_nmprimtl[1]
                              rel_cdagenci[2] rel_nrdconta[2]
                              rel_nrmatric[2] rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.
                               DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                              WITH FRAME f_empresa.
                           END.

                      ASSIGN rel_cdagenci[1] = 0 rel_nrdconta[1] = 0
                             rel_nrmatric[1] = 0 rel_nmprimtl[1] = ""
                             rel_cdagenci[2] = 0 rel_nrdconta[2] = 0
                             rel_nrmatric[2] = 0 rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_cdagenci[1] rel_nrdconta[1]
                          rel_nrmatric[1] rel_nmprimtl[1]
                          rel_cdagenci[2] rel_nrdconta[2]
                          rel_nrmatric[2] rel_nmprimtl[2]
                          WITH FRAME f_associados.

                   DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1 rel_nrdconta[1] WITH FRAME f_associados.
                  DOWN STREAM str_1 WITH FRAME f_associados.
              END.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.
                  DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                 WITH FRAME f_empresa.
              END.

         rel_qtdassoc = aux_qtassemp.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.
     END.
ELSE
IF   SUBSTRING(glb_dsparame,7,3) = "3 1"   THEN   /* Cadastro todos */
     DO:
         
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper  NO-LOCK
                                BY crapass.nrcadast 
                                   BY crapass.nrdconta:

             IF   crapass.inpessoa = 1   THEN 
                  DO:
                      FIND crapttl WHERE 
                           crapttl.cdcooper = glb_cdcooper       AND
                           crapttl.nrdconta = crapass.nrdconta   AND
                           crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                      IF   AVAIL crapttl  THEN
                           ASSIGN aux_cdempres_2 = crapttl.cdempres.
                  END.
             ELSE
                  DO:
                      FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                         crapjur.nrdconta = crapass.nrdconta
                                         NO-LOCK NO-ERROR.

                      IF   AVAIL crapjur  THEN
                           ASSIGN aux_cdempres_2 = crapjur.cdempres.
                  END.
        
             IF   aux_cdempres <> aux_cdempres_2 THEN
                  NEXT.
             
             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassemp = aux_qtassemp + 1.

             ASSIGN rel_cdagenci[aux_contador] = crapass.cdagenci
                    rel_nrdconta[aux_contador] = crapass.nrcadast
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_cdagenci[1] rel_nrdconta[1]
                              rel_nrmatric[1] rel_nmprimtl[1]
                              rel_cdagenci[2] rel_nrdconta[2]
                              rel_nrmatric[2] rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.
                               DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                              WITH FRAME f_empresa.
                           END.

                      ASSIGN rel_cdagenci[1] = 0 rel_nrdconta[1] = 0
                             rel_nrmatric[1] = 0 rel_nmprimtl[1] = ""
                             rel_cdagenci[2] = 0 rel_nrdconta[2] = 0
                             rel_nrmatric[2] = 0 rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_cdagenci[1] rel_nrdconta[1]
                          rel_nrmatric[1] rel_nmprimtl[1]
                          rel_cdagenci[2] rel_nrdconta[2]
                          rel_nrmatric[2] rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1 rel_nrdconta WITH FRAME f_associados.
                  DOWN STREAM str_1 WITH FRAME f_associados.
              END.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.
                  DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                 WITH FRAME f_empresa.
              END.

         rel_qtdassoc = aux_qtassemp.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.
     END.
ELSE
IF   SUBSTRING(glb_dsparame,7,3) = "3 2"   THEN   /* Cadastro ativos */
     DO:

         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                                crapass.dtdemiss = ?              NO-LOCK
                                BY crapass.nrcadast 
                                   BY crapass.nrdconta:

             IF   crapass.inpessoa = 1   THEN 
                  DO:
                      FIND crapttl WHERE 
                           crapttl.cdcooper = glb_cdcooper       AND
                           crapttl.nrdconta = crapass.nrdconta   AND
                           crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                      IF   AVAIL crapttl  THEN
                           ASSIGN aux_cdempres_2 = crapttl.cdempres.
                  END.
             ELSE
                  DO:
                      FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                         crapjur.nrdconta = crapass.nrdconta
                                         NO-LOCK NO-ERROR.

                      IF   AVAIL crapjur  THEN
                           ASSIGN aux_cdempres_2 = crapjur.cdempres.
                  END.
        
             IF   aux_cdempres <> aux_cdempres_2 THEN
                  NEXT.
                               
             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassemp = aux_qtassemp + 1.

             ASSIGN rel_cdagenci[aux_contador] = crapass.cdagenci
                    rel_nrdconta[aux_contador] = crapass.nrcadast
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_cdagenci[1] rel_nrdconta[1]
                              rel_nrmatric[1] rel_nmprimtl[1]
                              rel_cdagenci[2] rel_nrdconta[2]
                              rel_nrmatric[2] rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.
                               DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                              WITH FRAME f_empresa.
                           END.

                      ASSIGN rel_cdagenci[1] = 0 rel_nrdconta[1] = 0
                             rel_nrmatric[1] = 0 rel_nmprimtl[1] = ""
                             rel_cdagenci[2] = 0 rel_nrdconta[2] = 0
                             rel_nrmatric[2] = 0 rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_cdagenci[1] rel_nrdconta[1]
                          rel_nrmatric[1] rel_nmprimtl[1]
                          rel_cdagenci[2] rel_nrdconta[2]
                          rel_nrmatric[2] rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1 rel_nrdconta WITH FRAME f_associados.
                  DOWN STREAM str_1 WITH FRAME f_associados.
              END.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.
                  DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                 WITH FRAME f_empresa.
              END.

         rel_qtdassoc = aux_qtassemp.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.
     END.
ELSE
IF   SUBSTRING(glb_dsparame,7,3) = "3 3"   THEN   /* Cadastro inativos */
     DO:
      
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper    AND
                                crapass.dtdemiss <> ?              NO-LOCK
                                BY crapass.nrcadast 
                                   BY crapass.nrdconta:

             IF   crapass.inpessoa = 1   THEN 
                  DO:
                      FIND crapttl WHERE 
                           crapttl.cdcooper = glb_cdcooper       AND
                           crapttl.nrdconta = crapass.nrdconta   AND
                           crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                      IF   AVAIL crapttl  THEN
                           ASSIGN aux_cdempres_2 = crapttl.cdempres.
                  END.
             ELSE
                  DO:
                      FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                         crapjur.nrdconta = crapass.nrdconta
                                         NO-LOCK NO-ERROR.

                      IF   AVAIL crapjur  THEN
                           ASSIGN aux_cdempres_2 = crapjur.cdempres.
                  END.
        
             IF   aux_cdempres <> aux_cdempres_2 THEN
                  NEXT.
                  
             ASSIGN aux_contador = aux_contador + 1
                    aux_qtassemp = aux_qtassemp + 1.

             ASSIGN rel_cdagenci[aux_contador] = crapass.cdagenci
                    rel_nrdconta[aux_contador] = crapass.nrcadast
                    rel_nrmatric[aux_contador] = crapass.nrmatric
                    rel_nmprimtl[aux_contador] = crapass.nmprimtl.

             IF   aux_contador = 2   THEN
                  DO:
                      DISPLAY STREAM str_1
                              rel_cdagenci[1] rel_nrdconta[1]
                              rel_nrmatric[1] rel_nmprimtl[1]
                              rel_cdagenci[2] rel_nrdconta[2]
                              rel_nrmatric[2] rel_nmprimtl[2]
                              WITH FRAME f_associados.

                      DOWN STREAM str_1 WITH FRAME f_associados.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                               PAGE STREAM str_1.
                               DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                              WITH FRAME f_empresa.
                           END.

                      ASSIGN rel_cdagenci[1] = 0 rel_nrdconta[1] = 0
                             rel_nrmatric[1] = 0 rel_nmprimtl[1] = ""
                             rel_cdagenci[2] = 0 rel_nrdconta[2] = 0
                             rel_nrmatric[2] = 0 rel_nmprimtl[2] = ""
                             aux_contador = 0.

                  END.
         END.

         IF   rel_nrdconta[1] <> 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_cdagenci[1] rel_nrdconta[1]
                          rel_nrmatric[1] rel_nmprimtl[1]
                          rel_cdagenci[2] rel_nrdconta[2]
                          rel_nrmatric[2] rel_nmprimtl[2]
                          WITH FRAME f_associados.

                  DOWN STREAM str_1 2 WITH FRAME f_associados.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1 rel_nrdconta WITH FRAME f_associados.
                  DOWN STREAM str_1 WITH FRAME f_associados.
              END.

         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.
                  DISPLAY STREAM str_1 rel_cdempres rel_nmresemp
                                 WITH FRAME f_empresa.
              END.

         rel_qtdassoc = aux_qtassemp.
         DISPLAY STREAM str_1 rel_qtdassoc WITH FRAME f_qtdassoc.
     END.

/* .......................................................................... */

