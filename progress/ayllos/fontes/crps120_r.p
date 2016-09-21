/* ..........................................................................

   Programa: Fontes/crps120_r.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/95.                           Ultima atualizacao: 06/07/2011

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado pelo crps120.
   Objetivo  : Processar os resumos da integracao.

   Alteracao : 02/01/98  - Quando integrar arquivo zerado nao listar o anterior
                           (Odair)
                           
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               11/12/2006 - Verificar se eh Conta Salario - crapccs (Ze).
               
               06/07/2011 - Zerar variavel glb_cdcritic apos segunda leitura
                            da tabela craprej (Diego).
                            
               01/10/2013 - Renomeado "aux_nmarqimp EXTENT" para "aux_nmarquiv", 
                            pois aux_nmarqimp eh usado na impressao.i (Carlos)
                            
............................................................................. */

{ includes/var_batch.i }

{ includes/var_crps120.i }

{ includes/cabrel080_1.i }               /* Monta cabecalho do relatorio */

OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv[aux_contaarq]) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel080_1.

IF   aux_lshstden <> ""   THEN
     rel_dsintegr = "CREDITO DE PAGAMENTO, DEBITO DE EMPRESTIMOS, CAPITAL E " +
                    "CONVENIOS".
ELSE
     rel_dsintegr = "CREDITO DE PAGAMENTO, DEBITO DE EMPRESTIMOS E CAPITAL".

ASSIGN rel_nmempres = rel_dsempres.

IF   aux_nrlotfol = 0 THEN
     DO:
         DISPLAY STREAM str_1
                        rel_dsintegr      rel_dsempres
                        "  /  /" @  craplot.dtmvtolt
                        0 @ craplot.cdagenci
                        0 @ craplot.cdbccxlt
                        0 @ craplot.nrdolote
                        0 @ craplot.tplotmov
                        WITH FRAME f_integracao.

         ASSIGN rel_qtdifeln = 0
                rel_vldifedb = 0
                rel_vldifecr = 0.
     END.
ELSE
     DO:

          /*  Resumo da integracao da folha  */

        FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                           craplot.dtmvtolt = aux_dtmvtolt   AND
                           craplot.cdagenci = aux_cdagenci   AND
                           craplot.cdbccxlt = aux_cdbccxlt   AND
                           craplot.nrdolote = aux_nrlotfol
                           USE-INDEX craplot1 NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE craplot   THEN
             DO:
                 glb_cdcritic = 60.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra + "' --> '" + glb_dscritic +
                             " EMPRESA = " + rel_dsempres +
                             " LOTE = " + STRING(aux_nrlotfol,"9,999") +
                             " >> log/proc_batch.log").
                 RETURN.
             END.

        ASSIGN rel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
               rel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
               rel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

        DISPLAY STREAM str_1
                       rel_dsintegr      rel_dsempres
                       craplot.dtmvtolt  craplot.cdagenci
                       craplot.cdbccxlt  craplot.nrdolote
                       craplot.tplotmov
                       WITH FRAME f_integracao.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "USUARI"     AND
                   craptab.cdempres = aux_cdempres AND
                   craptab.cdacesso = "VLTARIF008" AND
                   craptab.tpregist = 1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     rel_vltarifa = 0.
ELSE
     rel_vltarifa = DECIMAL(craptab.dstextab).

rel_vlcobrar = rel_qttarifa * rel_vltarifa.

FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper   AND
                       craprej.dtmvtolt = aux_dtmvtolt   AND
                       craprej.cdagenci = aux_cdagenci   AND
                       craprej.cdbccxlt = aux_cdbccxlt   AND
                       craprej.nrdolote = aux_nrlotfol   AND
                       craprej.cdempres = aux_cdempres   AND
                       craprej.tpintegr = 1              NO-LOCK
                       BREAK BY craprej.dtmvtolt  BY craprej.cdagenci
                                BY craprej.cdbccxlt  BY craprej.nrdolote
                                   BY craprej.cdempres  BY craprej.tpintegr
                                      BY craprej.nrdconta:

    IF   glb_cdcritic <> craprej.cdcritic   THEN
         DO:
             glb_cdcritic = craprej.cdcritic.
             RUN fontes/critic.p.
             IF   glb_cdcritic = 211   THEN
                  glb_dscritic = glb_dscritic + " URV do dia " +
                                 STRING(aux_dtintegr,"99/99/9999").
         END.

    DISPLAY STREAM str_1
            craprej.nrdconta  craprej.cdhistor  craprej.vllanmto  glb_dscritic
            WITH FRAME f_rejeitados.

    DOWN STREAM str_1 WITH FRAME f_rejeitados.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         DO:
             PAGE STREAM str_1.

             DISPLAY STREAM str_1
                     rel_dsintegr      rel_dsempres
                     craplot.dtmvtolt  craplot.cdagenci
                     craplot.cdbccxlt  craplot.nrdolote
                     craplot.tplotmov
                     WITH FRAME f_integracao.
         END.

END.   /*  Fim do FOR EACH  --  Leitura dos rejeitados  */

IF   LINE-COUNTER(str_1) > 78   THEN
     DO:
         PAGE STREAM str_1.

         IF   aux_nrlotfol = 0 THEN
              DO:
                  DISPLAY STREAM str_1
                        rel_dsintegr      rel_dsempres
                        "  /  /" @ craplot.dtmvtolt
                        0 @ craplot.cdagenci
                        0 @ craplot.cdbccxlt
                        0 @ craplot.nrdolote
                        0 @ craplot.tplotmov
                        WITH FRAME f_integracao.
              END.
         ELSE
              DO:
                  DISPLAY STREAM str_1
                          rel_dsintegr      rel_dsempres
                          craplot.dtmvtolt  craplot.cdagenci
                          craplot.cdbccxlt  craplot.nrdolote
                          craplot.tplotmov
                          WITH FRAME f_integracao.
              END.
     END.

IF   aux_nrlotfol = 0 THEN
     DO:
         DISPLAY STREAM str_1
                 0 @ craplot.qtinfoln
                 0 @ craplot.vlinfodb
                 0 @ craplot.vlinfocr
                 0 @ craplot.qtcompln
                 0 @ craplot.vlcompdb
                 0 @ craplot.vlcompcr
                 rel_qtdifeln      rel_vldifedb
                 rel_vldifecr
                 WITH FRAME f_totais.
     END.
ELSE
     DO:
         DISPLAY STREAM str_1
                 craplot.qtinfoln  craplot.vlinfodb
                 craplot.vlinfocr  craplot.qtcompln
                 craplot.vlcompdb  craplot.vlcompcr
                 rel_qtdifeln      rel_vldifedb
                 rel_vldifecr
                 WITH FRAME f_totais.
     END.

DISPLAY STREAM str_1 rel_qttarifa rel_vltarifa rel_vlcobrar WITH FRAME f_tarifa.

PAGE STREAM str_1.

glb_cdcritic = 0.

/*  Resumo da integra dos emprestimos  */

FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                   craplot.dtmvtolt = aux_dtmvtolt   AND
                   craplot.cdagenci = aux_cdagenci   AND
                   craplot.cdbccxlt = aux_cdbccxlt   AND
                   craplot.nrdolote = aux_nrlotemp
                   USE-INDEX craplot1 NO-LOCK NO-ERROR.

IF   AVAILABLE craplot   THEN
     DO:
         ASSIGN rel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                rel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
                rel_vldifecr = craplot.vlcompcr - craplot.vlinfocr

                rel_dsintegr = "CREDITO DE EMPRESTIMOS".

         DISPLAY STREAM str_1
                 rel_dsintegr      rel_dsempres
                 craplot.dtmvtolt  craplot.cdagenci
                 craplot.cdbccxlt  craplot.nrdolote
                 craplot.tplotmov
                 WITH FRAME f_integracao.

         DISPLAY STREAM str_1
                 craplot.qtinfoln  craplot.vlinfodb
                 craplot.vlinfocr  craplot.qtcompln
                 craplot.vlcompdb  craplot.vlcompcr
                 rel_qtdifeln      rel_vldifedb
                 rel_vldifecr
                 WITH FRAME f_totais.

         PAGE STREAM str_1.
     END.

/*  Resumo da integra dos planos de capital  */

FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                   craplot.dtmvtolt = aux_dtmvtolt   AND
                   craplot.cdagenci = aux_cdagenci   AND
                   craplot.cdbccxlt = aux_cdbccxlt   AND
                   craplot.nrdolote = aux_nrlotcot
                   USE-INDEX craplot1 NO-LOCK NO-ERROR.

IF   AVAILABLE craplot   THEN
     DO:
         ASSIGN rel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                rel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
                rel_vldifecr = craplot.vlcompcr - craplot.vlinfocr

                rel_dsintegr = "CREDITO DE CAPITAL".

         DISPLAY STREAM str_1
                 rel_dsintegr      rel_dsempres
                 craplot.dtmvtolt  craplot.cdagenci
                 craplot.cdbccxlt  craplot.nrdolote
                 craplot.tplotmov
                 WITH FRAME f_integracao.

         DISPLAY STREAM str_1
                 craplot.qtinfoln  craplot.vlinfodb
                 craplot.vlinfocr  craplot.qtcompln
                 craplot.vlcompdb  craplot.vlcompcr
                 rel_qtdifeln      rel_vldifedb
                 rel_vldifecr
                 WITH FRAME f_totais.
     END.


/*  Imprime Conta Salario  */

PAGE STREAM str_1.

rel_dsintegr = "CREDITO DE CONTA SALARIO".

FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                   craplot.dtmvtolt = aux_dtintegr  AND
                   craplot.cdagenci = 1             AND
                   craplot.cdbccxlt = 100           AND
                   craplot.nrdolote = aux_nrlotccs
                   USE-INDEX craplot1 NO-LOCK NO-ERROR.

IF   AVAILABLE craplot   THEN
     ASSIGN rel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
            rel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
            rel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.
ELSE
     NEXT.

DISPLAY STREAM str_1 rel_dsintegr       rel_dsempres
                     craplot.dtmvtolt   craplot.cdagenci
                     craplot.cdbccxlt   craplot.nrdolote
                     craplot.tplotmov   WITH FRAME f_integracao.

FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                       craprej.dtmvtolt = aux_dtmvtolt  AND
                       craprej.cdagenci = 1             AND
                       craprej.cdbccxlt = 100           AND
                       craprej.nrdolote = aux_nrlotccs  AND
                       craprej.cdempres = aux_cdempres  AND
                       craprej.tpintegr = 1             NO-LOCK
                       BREAK BY craprej.dtmvtolt  
                                BY craprej.cdagenci
                                   BY craprej.cdbccxlt  
                                      BY craprej.nrdolote
                                         BY craprej.cdempres  
                                            BY craprej.tpintegr
                                               BY craprej.nrdconta:

    IF   glb_cdcritic <> craprej.cdcritic   THEN
         DO:
             glb_cdcritic = craprej.cdcritic.
             RUN fontes/critic.p.
         END.

    DISPLAY STREAM str_1 craprej.nrdconta  craprej.cdhistor
                         craprej.vllanmto  glb_dscritic
                         WITH FRAME f_rejeitados.

    DOWN STREAM str_1 WITH FRAME f_rejeitados.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         DO:
             PAGE STREAM str_1.

             DISPLAY STREAM str_1 rel_dsintegr      rel_dsempres
                                  craplot.dtmvtolt  craplot.cdagenci
                                  craplot.cdbccxlt  craplot.nrdolote
                                  craplot.tplotmov  WITH FRAME f_integracao.
         END.

END.   /*  Fim do FOR EACH  --  Leitura dos rejeitados  */

IF   LINE-COUNTER(str_1) > 78   THEN
     DO:
         PAGE STREAM str_1.

         DISPLAY STREAM str_1 rel_dsintegr      rel_dsempres
                              craplot.dtmvtolt  craplot.cdagenci
                              craplot.cdbccxlt  craplot.nrdolote
                              craplot.tplotmov  WITH FRAME f_integracao.
     END.

ASSIGN tot_qtinfoln = tot_qtinfoln + craplot.qtinfoln
       tot_vlinfodb = tot_vlinfodb + craplot.vlinfodb
       tot_vlinfocr = tot_vlinfocr + craplot.vlinfocr
       tot_qtcompln = tot_qtcompln + craplot.qtcompln
       tot_vlcompdb = tot_vlcompdb + craplot.vlcompdb
       tot_vlcompcr = tot_vlcompcr + craplot.vlcompcr
       tot_qtdifeln = tot_qtdifeln + rel_qtdifeln
       tot_vldifedb = tot_vldifedb + rel_vldifedb 
       tot_vldifecr = tot_vldifecr + rel_vldifecr. 

DISPLAY STREAM str_1 craplot.qtinfoln  craplot.vlinfodb
                     craplot.vlinfocr  craplot.qtcompln
                     craplot.vlcompdb  craplot.vlcompcr
                     rel_qtdifeln      rel_vldifedb
                     rel_vldifecr      WITH FRAME f_totais.

ASSIGN glb_cdcritic = 0.

OUTPUT STREAM str_1 CLOSE.

/* .......................................................................... */
