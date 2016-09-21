/* ..........................................................................

   Programa: Includes/crps082_2.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 05/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Processar o tratamento para o relatorio 68 - inrelato = 2.

   Alteracoes: 13/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               25/06/2008 - Incluir 'Vlr Atraso' e '%Atraso'(Guilherme).

               29/12/2008 - Inclusao taxa do mes(Mirtes)
               
               05/06/2014 - Alterado format do cdlcremp de 3 para 4 
                            Softdesk 137074 (Lucas R.)

............................................................................. */
/* muda o pac */
IF   aux_cdagenci <> aux_cdageant   THEN
     DO:
         IF   aux_cdageant > 0   THEN
              DO:
                  ASSIGN tot_vlemprst = tot_vlemprst + aux_vlemprst
                         tot_qtctremp = tot_qtctremp + aux_qtctremp
                         tot_ematraso = tot_ematraso + aux_ematraso
                         aux_peratras = (100 * aux_ematraso) / aux_vlemprst
                         tot_peratras = (100 * tot_ematraso) / tot_vlemprst.

                  DISPLAY STREAM str_2
                          rel_txmensal
                          rel_dslcremp aux_vlemprst aux_qtctremp aux_qtassoci
                          aux_ematraso aux_peratras
                          WITH FRAME f_linha_2.

                  DOWN STREAM str_2 WITH FRAME f_linha_2.

                  IF  (LINE-COUNTER(str_2) + 4) > PAGE-SIZE(str_2)   THEN
                       DO:
                           PAGE STREAM str_2.
                           DISPLAY STREAM str_2 rel_nmmesref
                                   WITH FRAME f_refere.
                           DISPLAY STREAM str_2 rel_dsagenci
                                   WITH FRAME f_agencia.
                           VIEW STREAM str_2 FRAME f_label_2.
                       END.

                  rel_dslcremp = aux_dstotais.

                  DISPLAY STREAM str_2
                          rel_dslcremp
                          tot_qtassoci
                          tot_vlemprst tot_qtctremp 
                          tot_ematraso tot_peratras
                          WITH FRAME f_total_2.

                  IF  (LINE-COUNTER(str_2) + 5) > PAGE-SIZE(str_2)   THEN
                       DO:
                           PAGE STREAM str_2.
                           DISPLAY STREAM str_2 rel_nmmesref
                                   WITH FRAME f_refere.
                       END.
              END.

         ASSIGN aux_vlemprst = 0
                aux_qtctremp = 0
                aux_qtassoci = 0
                tot_qtassoci = 0
                aux_ematraso = 0
                aux_peratras = 0

                aux_cdlcrant = 0
                aux_nrctaant = 0

                tot_vlemprst = 0
                tot_qtctremp = 0
                tot_ematraso = 0
                tot_peratras = 0

                aux_cdageant = aux_cdagenci.

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

         DISPLAY STREAM str_2 rel_dsagenci WITH FRAME f_agencia.

         VIEW STREAM str_2 FRAME f_label_2.
     END.

IF   aux_cdlcremp <> aux_cdlcrant   THEN
     DO:
         IF   aux_cdlcrant > 0   THEN
              DO:
                  ASSIGN tot_vlemprst = tot_vlemprst + aux_vlemprst
                         tot_qtctremp = tot_qtctremp + aux_qtctremp
                         tot_ematraso = tot_ematraso + aux_ematraso
                         aux_peratras = (100 * aux_ematraso) / aux_vlemprst
                         tot_peratras = (100 * tot_ematraso) / tot_vlemprst.
                  
                  DISPLAY STREAM str_2
                          rel_txmensal
                          rel_dslcremp aux_vlemprst aux_qtctremp aux_qtassoci
                          aux_ematraso aux_peratras
                          WITH FRAME f_linha_2.

                  DOWN STREAM str_2 WITH FRAME f_linha_2.

                  IF  (LINE-COUNTER(str_2) + 4) > PAGE-SIZE(str_2)   THEN
                       DO:
                           PAGE STREAM str_2.
                           DISPLAY STREAM str_2 rel_nmmesref
                                   WITH FRAME f_refere.
                           DISPLAY STREAM str_2 rel_dsagenci
                                   WITH FRAME f_agencia.
                           VIEW STREAM str_2 FRAME f_label_2.
                       END.

              END.

         ASSIGN aux_vlemprst = 0
                aux_qtctremp = 0
                aux_qtassoci = 0
                aux_ematraso = 0
                aux_peratras = 0

                aux_nrctaant = 0

                aux_cdlcrant = aux_cdlcremp.

         /*  Leitura da descricao da linha de credito do emprestimo  */

         FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper   AND
                            craplcr.cdlcremp = aux_cdlcremp   NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craplcr   THEN
              ASSIGN rel_dslcremp = STRING(aux_cdlcremp,"9999") + " - " +
                                    "NAO CADASTRADA!" 
                     rel_txmensal = 0.
         ELSE
              ASSIGN rel_dslcremp = STRING(craplcr.cdlcremp,"9999") + " - " +
                                    craplcr.dslcremp 
                     rel_txmensal = craplcr.txmensal.
     END.

IF   aux_nrdconta <> aux_nrctaant   THEN
     ASSIGN aux_qtassoci = aux_qtassoci + 1
            tot_qtassoci = tot_qtassoci + 1
            aux_nrctaant = aux_nrdconta.

ASSIGN aux_qtctremp = aux_qtctremp + 1
       aux_vlemprst = aux_vlemprst + aux_vlsdeved
       aux_ematraso = aux_ematraso + aux_vlratras

       aux_regextp2 = TRUE.

/* .......................................................................... */

