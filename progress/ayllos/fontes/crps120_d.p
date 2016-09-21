/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps120_d.p              | Incorparado ao pc_crps120         |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/











/* ..........................................................................

   Programa: Fontes/crps120_d.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Maio/95.                            Ultima atualizacao: 15/01/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado pelo crps120.
   Objetivo  : Processar os debitos de emprestimos.

   Alteracoes: 04/06/97 - Alterado para fazer rotina de debito generica
                          (Deborah).

               29/06/2005 - Alimentado campo cdcooper da tabela craplcm (Diego).

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               29/10/2008 - Alteracao CDEMPRES (Diego).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               15/01/2014 - Inclusao de VALIDATE craplcm (Carlos)
               
............................................................................. */

{ includes/var_batch.i }

{ includes/var_crps120.i }

TRANS_1:

DO ON ERROR UNDO TRANS_1, RETURN:

   DO aux_contador = 1 TO 999:

      IF   tot_vldebcta[aux_contador] > 0   THEN
           DO:
               DO WHILE TRUE:

                  FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                     craplot.dtmvtolt = aux_dtintegr   AND
                                     craplot.cdagenci = aux_cdagenci   AND
                                     craplot.cdbccxlt = aux_cdbccxlt   AND
                                     craplot.nrdolote = aux_nrlotfol
                                     USE-INDEX craplot1
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE craplot   THEN
                       IF   LOCKED craplot   THEN
                            DO:
                                PAUSE 2 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            DO:
                                glb_cdcritic = 60.
                                RUN fontes/critic.p.
                                UNIX SILENT VALUE("echo " +
                                      STRING(TIME,"HH:MM:SS") +
                                      " - " + glb_cdprogra + "' --> '" +
                                      glb_dscritic + " EMPRESA = " +
                                      STRING(aux_cdempres,"99999") +
                                      " LOTE = " +
                                      STRING(aux_nrlotfol,"9,999") +
                                      " >> log/proc_batch.log").
                                UNDO TRANS_1, RETURN.
                            END.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               CREATE craplcm.
               ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                      craplcm.cdagenci = craplot.cdagenci
                      craplcm.cdbccxlt = craplot.cdbccxlt
                      craplcm.nrdolote = craplot.nrdolote
                      craplcm.nrdconta = aux_nrdconta
                      craplcm.nrdctabb = aux_nrdconta
                      craplcm.nrdctitg = STRING(aux_nrdconta,"99999999")
                      craplcm.nrdocmto = craplot.nrseqdig + 1
                      craplcm.cdhistor = aux_contador
                      craplcm.vllanmto = tot_vldebcta[aux_contador]
                      craplcm.nrseqdig = craplot.nrseqdig + 1
                      craplcm.cdcooper = glb_cdcooper

                      craplot.qtinfoln = craplot.qtinfoln + 1
                      craplot.qtcompln = craplot.qtcompln + 1
                      craplot.vlinfodb = craplot.vlinfodb +
                                         tot_vldebcta[aux_contador]
                      craplot.vlcompdb = craplot.vlcompdb +
                                         tot_vldebcta[aux_contador]
                      craplot.nrseqdig = craplcm.nrseqdig.
               VALIDATE craplcm.
           END.

   END.  /*  Fim do DO .. TO  */

END.

/* .......................................................................... */

