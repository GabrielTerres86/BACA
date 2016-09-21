/* ..........................................................................

   Programa: Includes/crps082_1.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 05/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Processar o tratamento para o relatorio 67 - inrelato = 1.

   Alteracoes: 15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
               05/06/2014 - Alterado format do cdlcremp de 3 para 4 
                            Softdesk 137074 (Lucas R.) 

............................................................................. */

IF   aux_cdagenci <> aux_cdageant   THEN
     DO:
         IF   aux_cdageant > 0   THEN
              DO:
                  ASSIGN tot_vlemprst = tot_vlemprst + aux_vlemprst
                         tot_qtctremp = tot_qtctremp + aux_qtctremp

                         age_vlemprst[aux_cdageant] =
                                      age_vlemprst[aux_cdageant] + tot_vlemprst
                         age_qtctremp[aux_cdageant] =
                                      age_qtctremp[aux_cdageant] + tot_qtctremp.

                  DISPLAY STREAM str_1
                          rel_dslcremp WHEN aux_impdslcr
                          rel_dsfinemp aux_vlemprst aux_qtctremp aux_qtassoci
                          WITH FRAME f_linha_1.

                  DOWN STREAM str_1 WITH FRAME f_linha_1.

                  IF  (LINE-COUNTER(str_1) + 4) > PAGE-SIZE(str_1)   THEN
                       DO:
                           PAGE STREAM str_1.
                           DISPLAY STREAM str_1 rel_nmmesref
                                   WITH FRAME f_refere.
                           DISPLAY STREAM str_1 rel_dsagenci
                                   WITH FRAME f_agencia.
                           VIEW STREAM str_1 FRAME f_label_1.
                           aux_impdslcr = TRUE.
                       END.
                  ELSE
                       IF   aux_impdslcr   THEN
                            aux_impdslcr = FALSE.

                  rel_dsfinemp = aux_dstotais.

                  DISPLAY STREAM str_1
                          rel_dsfinemp tot_vlemprst tot_qtctremp
                          WITH FRAME f_total_1.

                  IF  (LINE-COUNTER(str_1) + 4) > PAGE-SIZE(str_1)   THEN
                       DO:
                           PAGE STREAM str_1.
                           DISPLAY STREAM str_1 rel_nmmesref
                                   WITH FRAME f_refere.
                           DISPLAY STREAM str_1 rel_dsagenci
                                   WITH FRAME f_agencia.
                           VIEW STREAM str_1 FRAME f_label_1.
                       END.

                  rel_dsfinemp = "TOTAIS DA AGENCIA ==>".

                  DISPLAY STREAM str_1
                          rel_dsfinemp
                          age_vlemprst[aux_cdageant] @ tot_vlemprst
                          age_qtctremp[aux_cdageant] @ tot_qtctremp
                          WITH FRAME f_total_agencia.

                  PAGE STREAM str_1.
                  DISPLAY STREAM str_1 rel_nmmesref WITH FRAME f_refere.
              END.

         ASSIGN aux_vlemprst = 0
                aux_qtctremp = 0
                aux_qtassoci = 0

                aux_cdlcrant = 0
                aux_cdfinant = 0
                aux_nrctaant = 0

                tot_vlemprst = 0
                tot_qtctremp = 0

                aux_cdageant = aux_cdagenci

                aux_impdslcr = TRUE.

         /*  Leitura da descricao da agencia  */

         FIND crapage WHERE crapage.cdcooper = glb_cdcooper   AND
                            crapage.cdagenci = aux_cdagenci   NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE crapage   THEN
              IF   aux_cdagenci = 999   THEN
                   rel_dsagenci = "999 - RESUMO".
              ELSE
                   rel_dsagenci = STRING(aux_cdagenci,"zz9") + " - " +
                                  FILL("*",15).
         ELSE
              rel_dsagenci = STRING(aux_cdagenci,"zz9") + " - " +
                             crapage.nmresage.

         DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_agencia.

         VIEW STREAM str_1 FRAME f_label_1.
     END.

IF   aux_cdlcremp <> aux_cdlcrant   THEN
     DO:
         IF   aux_cdlcrant > 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_dslcremp WHEN aux_impdslcr
                          rel_dsfinemp aux_vlemprst aux_qtctremp aux_qtassoci
                          WITH FRAME f_linha_1.

                  DOWN STREAM str_1 WITH FRAME f_linha_1.

                  IF  (LINE-COUNTER(str_1) + 4) > PAGE-SIZE(str_1)   THEN
                       DO:
                           PAGE STREAM str_1.
                           DISPLAY STREAM str_1 rel_nmmesref
                                   WITH FRAME f_refere.
                           DISPLAY STREAM str_1 rel_dsagenci
                                   WITH FRAME f_agencia.
                           VIEW STREAM str_1 FRAME f_label_1.
                           aux_impdslcr = TRUE.
                       END.
                  ELSE
                       IF   aux_impdslcr   THEN
                            aux_impdslcr = FALSE.

                  ASSIGN tot_vlemprst = tot_vlemprst + aux_vlemprst
                         tot_qtctremp = tot_qtctremp + aux_qtctremp

                         age_vlemprst[aux_cdagenci] =
                                      age_vlemprst[aux_cdagenci] + tot_vlemprst
                         age_qtctremp[aux_cdagenci] =
                                      age_qtctremp[aux_cdagenci] + tot_qtctremp.

                         rel_dsfinemp = aux_dstotais.

                  DISPLAY STREAM str_1
                          rel_dsfinemp tot_vlemprst tot_qtctremp
                          WITH FRAME f_total_1.
              END.

         ASSIGN aux_vlemprst = 0
                aux_qtctremp = 0
                aux_qtassoci = 0

                aux_cdfinant = 0
                aux_nrctaant = 0

                tot_vlemprst = 0
                tot_qtctremp = 0

                aux_cdlcrant = aux_cdlcremp

                aux_impdslcr = TRUE.

         /*  Leitura da descricao da linha de credito do emprestimo  */

         FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper  AND
                            craplcr.cdlcremp = aux_cdlcremp  NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craplcr   THEN
              rel_dslcremp = STRING(aux_cdlcremp,"9999") + " - " +
                             "NAO CADASTRADA!".
         ELSE
              rel_dslcremp = STRING(craplcr.cdlcremp,"9999") + " - " +
                             craplcr.dslcremp.
     END.

IF   aux_cdfinemp <> aux_cdfinant   THEN
     DO:
         IF   aux_cdfinant > 0   THEN
              DO:
                  DISPLAY STREAM str_1
                          rel_dslcremp WHEN aux_impdslcr
                          rel_dsfinemp aux_vlemprst aux_qtctremp aux_qtassoci
                          WITH FRAME f_linha_1.

                  DOWN STREAM str_1 WITH FRAME f_linha_1.

                  IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                       DO:
                           PAGE STREAM str_1.
                           DISPLAY STREAM str_1 rel_nmmesref
                                   WITH FRAME f_refere.
                           DISPLAY STREAM str_1 rel_dsagenci
                                   WITH FRAME f_agencia.
                           VIEW STREAM str_1 FRAME f_label_1.
                           aux_impdslcr = TRUE.
                       END.
                  ELSE
                       aux_impdslcr = FALSE.

                  ASSIGN tot_vlemprst = tot_vlemprst + aux_vlemprst
                         tot_qtctremp = tot_qtctremp + aux_qtctremp.
              END.

         ASSIGN aux_vlemprst = 0
                aux_qtctremp = 0
                aux_qtassoci = 0
                aux_nrctaant = 0

                aux_cdfinant = aux_cdfinemp.

         /*  Leitura da descricao da finalidade do emprestimo  */

         FIND crapfin WHERE crapfin.cdcooper = glb_cdcooper   AND
                            crapfin.cdfinemp = aux_cdfinemp   NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE crapfin   THEN
              rel_dsfinemp = STRING(aux_cdfinemp,"999") + " - " +
                             "NAO CADASTRADA!".
         ELSE
              rel_dsfinemp = STRING(aux_cdfinemp,"999") + " - " +
                             crapfin.dsfinemp.
     END.

IF   aux_nrdconta <> aux_nrctaant   THEN
     ASSIGN aux_qtassoci = aux_qtassoci + 1
            aux_nrctaant = aux_nrdconta.

ASSIGN aux_qtctremp = aux_qtctremp + 1
       aux_vlemprst = aux_vlemprst + aux_vlsdeved

       aux_regextp1 = TRUE.

/* .......................................................................... */

