/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                     |
  +---------------------------------+-----------------------------------------+
  | includes/rdca2a.i               | APLI0001.pc_calc_aniver_rdca2a          |
  +---------------------------------+-----------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/









/* .............................................................................

   Programa: Includes/rdca2a.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/96.                    Ultima atualizacao: 05/02/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina de calculo do aniversario do RDCA2 - Deve ser chamada
               dentro de um FOR EACH ou DO WHILE e com label TRANS_1.

   Alteracoes: 28/01/97 - Alterado para acertar vlsdrdan (quando for o primeiro
                          mes de extrato, deixar com 0) (Deborah).

               11/04/97 - Alterado para capitalizar as taxas do primeiro
                          aniversario (Edson).

               11/03/98 - Alterado para tratar taxa especial no periodo
                          de 10/02/98 a 05/03/98 (Deborah).

               29/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               01/12/1999 - Tratar somente carencia 0 (Deborah). 

               26/04/2002 - Nova regra para pegar a taxa (Margarete).

               10/12/2003 - Incluir cobranca de IRRF (Margarete).

               26/01/2004 - Gerar lancamentos do abono e do IR sobre abono
                            na aplicacao (Margarete).

               02/07/2004 - Zerar saldos do final do mes quando saque
                            total (Margarete).

               23/09/2004 - Incluido historico 494(CI)(Mirtes)

               14/12/2004 - Ajustes para tratar das novas aliquotas de 
                           IRRF (Margarete).

              21/01/2005 - IRRF sobre abono CPMF usara maior taxa (Margarete).
              
              28/02/2005 - Efetuado acerto gravacao taxa - historico 871(Mirtes)
             
              06/05/2005 - Utilizar o indice craplap5 na leitura dos 
                           lancamentos (Edson).

              06/07/2005 - Alimentado campo cdcooper das tabelas craplot e 
                           craplap (Diego).

              03/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
             
              03/08/2006 - Campo vlslfmes substituido por vlsdextr (Magui).

              23/08/2006 - Nao atualizar mais craprda.dtsdfmes (Magui).

              27/07/2007 - Alteracao para melhoria de performance (Evandro).

              14/10/2013 - Eliminado var aux_lsaplica, retirado atribuicao de 
                           craplap.lsaplica . (Jorge)
              
              12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
                            
              05/02/2014 - Alteração de atribuição da var aux_tptaxrda = 4 p/
                           aux_tptaxrda = 5. (Jean Michel)
............................................................................. */

DEF VAR pri_txaplica AS DECIMAL DECIMALS 6                           NO-UNDO.
DEF VAR seg_txaplica AS DECIMAL DECIMALS 6                           NO-UNDO.
DEF VAR cap_txaplica AS DECIMAL DECIMALS 6                           NO-UNDO.
DEF VAR aux_tptaxrda AS INTEGER                                      NO-UNDO.

DEF VAR aux_vlirrdca LIKE craprda.vlsdrdca                           NO-UNDO.

ASSIGN aux_vlrgtper = 0
       aux_ttajtlct = 0
       aux_renrgper = 0
       rd2_vlrentot = 0
       rd2_vlrendim = 0
       rd2_vllan178 = 0
       rd2_vllan180 = 0
       rd2_vlprovis = 0

       rd2_vlsdrdca = craprda.vlsdrdca

       rd2_dtcalcul = IF craprda.inaniver = 0
                         THEN craprda.dtmvtolt
                         ELSE craprda.dtiniper

       rd2_dtrefant = IF craprda.inaniver = 0                  AND
                         craprda.dtmvtolt <> craprda.dtiniper
                         THEN craprda.dtiniper
                         ELSE craprda.dtfimper

       rd2_dtrefere = craprda.dtfimper

       rd2_dtmvtolt = glb_dtmvtolt

       pri_txaplica = 0
       seg_txaplica = 0
       cap_txaplica = 0
       aux_vlirrdca = 0.

/*   Verifica se esta no periodo especial */

IF   craprda.dtmvtolt > 02/09/1998 AND
     craprda.dtmvtolt < 03/06/1998 THEN
     aux_tptaxrda = 5.
ELSE
     aux_tptaxrda = 3.

/*  Verifica se deve lancar apenas a provisao  */

IF   craprda.inaniver = 0              AND
     rd2_dtrefant     = rd2_dtrefere   THEN
     rd2_flgentra = FALSE.                                  /*  Primeiro Mes  */
ELSE
     rd2_flgentra = TRUE.                                    /*  Segundo Mes  */

/*  Leitura dos lancamentos de resgate e/ou provisao da aplicacao  */

rd2_lshistor = "178,180,181,182,494,876".

DO  rd2_contador = 1 TO NUM-ENTRIES(rd2_lshistor,","):

    rd2_cdhistor = INT(ENTRY(rd2_contador,rd2_lshistor,",")).

    FOR EACH craplap WHERE (craplap.cdcooper  = glb_cdcooper       AND
                            craplap.nrdconta  = craprda.nrdconta   AND
                            craplap.nraplica  = craprda.nraplica   AND
                            craplap.dtrefere  = rd2_dtrefant       AND
                            craplap.cdhistor  = rd2_cdhistor       AND
                            craplap.dtmvtolt >= rd2_dtcalcul       AND
                            craplap.dtmvtolt <= rd2_dtmvtolt)            OR
                            
                           (craplap.cdcooper  = glb_cdcooper       AND
                            craplap.nrdconta  = craprda.nrdconta   AND
                            craplap.nraplica  = craprda.nraplica   AND
                            craplap.dtrefere  = rd2_dtrefere       AND
                            craplap.cdhistor  = rd2_cdhistor       AND
                            craplap.dtmvtolt >= rd2_dtcalcul       AND
                            craplap.dtmvtolt <= rd2_dtmvtolt)
                            NO-LOCK:

        IF   craplap.cdhistor = 180   OR     /*  Provisao  */
             craplap.cdhistor = 181   THEN   /*  Ajuste Provisao +  */
             rd2_vllan180 = rd2_vllan180 + craplap.vllanmto.
        ELSE
        IF   craplap.cdhistor = 182   THEN   /*  Ajuste Provisao -  */
             rd2_vllan180 = rd2_vllan180 - craplap.vllanmto.
        ELSE
        IF   craplap.cdhistor = 876   THEN   /* Ajuste de IR no resgate */
             ASSIGN rd2_vllan178 = rd2_vllan178 + craplap.vllanmto
                    aux_ttajtlct = aux_ttajtlct + craplap.vllanmto.
        ELSE     
        IF   craplap.cdhistor = 178   OR
             craplap.cdhistor = 494   THEN   /* Resgate */
             ASSIGN rd2_vllan178 = rd2_vllan178 + craplap.vllanmto
                    aux_vlrgtper = aux_vlrgtper + craplap.vllanmto
                    aux_renrgper = aux_renrgper + craplap.vlrenreg.

    END.  /*  Fim do FOR EACH -- Leitura dos lancamentos da aplicacao  */
    
END.

rd2_vlsdrdca = rd2_vlsdrdca - rd2_vllan178.

/*** Calcular saldo para resgate enxergando as novas faixas de percentual de
     imposto de renda e o ajuste necessario ***/
ASSIGN aux_nrctaapl = craprda.nrdconta
       aux_nraplres = craprda.nraplica
       aux_vlsldapl = rd2_vlsdrdca
       aux_vlrenper = 0
       aux_sldpresg = 0
       aux_dtregapl = glb_dtmvtolt.

RUN fontes/saldo_rdca_resgate.p. 

IF   craprda.inaniver = 0   AND   rd2_flgentra   THEN /*  Recalcula o 1o mes  */
     DO:
         /*  Taxa a ser aplicada conforme a faixa  */

         DO WHILE TRUE:

            FIND FIRST craptrd WHERE craptrd.cdcooper  = glb_cdcooper     AND
                                     craptrd.dtiniper  = craprda.dtmvtolt AND
                                     craptrd.tptaxrda  = aux_tptaxrda     AND
                                 /*  craptrd.incarenc  = 1                AND */
                                     craptrd.incarenc  = 0                AND
                                     craptrd.vlfaixas <= aux_vltotrda
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAILABLE craptrd   THEN
                 IF   LOCKED craptrd   THEN
                      DO:
                          PAUSE 2 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          glb_cdcritic = 347.
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " +
                                    STRING(TIME,"HH:MM:SS") + " - " +
                                    glb_cdprogra + "' --> '" + glb_dscritic +
                                    " DIA " +
                                    STRING(craprda.dtmvtolt,"99/99/9999") +
                                    " >> log/proc_batch.log").
                          UNDO TRANS_1, RETURN.
                      END.

            IF   craptrd.txofimes > 0   THEN
                 ASSIGN craptrd.incalcul = 2
                        rd2_txaplica = craptrd.txofimes / 100.
            ELSE
                 DO:
                     glb_cdcritic = 427.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " +
                               STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                              " >> log/proc_batch.log").
                     UNDO TRANS_1, RETURN.
                 END.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

         /*  Recalculo do rendimento  */

         ASSIGN rd2_vlrendim = TRUNCATE(rd2_vlsdrdca * rd2_txaplica,8)
                rd2_vlsdrdca = rd2_vlsdrdca + rd2_vlrendim

                pri_txaplica = rd2_txaplica

         /*  Arredondamento dos valores calculados  */

                rd2_vlsdrdca = ROUND(rd2_vlsdrdca,2)
                rd2_vlrendim = ROUND(rd2_vlrendim,2)

                rd2_vlrentot = rd2_vlrendim.
     END.

/*  Taxa a ser aplicada conforme a faixa  */

DO WHILE TRUE:

   IF   craprda.inaniver = 1   THEN                                     /* SC */

        FIND FIRST craptrd WHERE craptrd.cdcooper  = glb_cdcooper     AND
                                 craptrd.dtiniper  = craprda.dtiniper AND
                                 craptrd.tptaxrda  = 3                AND
                                 craptrd.incarenc  = 0                AND
                                 craptrd.vlfaixas <= aux_vltotrda
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
  
   ELSE                                                                 /* CC */
   
        FIND FIRST craptrd WHERE craptrd.cdcooper  = glb_cdcooper     AND
                                 craptrd.dtiniper  = craprda.dtiniper AND
                                 craptrd.tptaxrda  = aux_tptaxrda     AND
                             /*  craptrd.incarenc  = 1                AND */
                                 craptrd.incarenc  = 0                AND
                                 craptrd.vlfaixas <= aux_vltotrda
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craptrd   THEN
        IF   LOCKED craptrd   THEN
             DO:
                 PAUSE 2 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             DO:
                 glb_cdcritic = 347.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " DIA " +
                                   STRING(craprda.dtiniper,"99/99/9999") +
                                   " >> log/proc_batch.log").
                 UNDO TRANS_1, RETURN.
             END.

   IF   craptrd.txofimes > 0   THEN
        ASSIGN craptrd.incalcul = 2
               rd2_txaplica = craptrd.txofimes / 100.
   ELSE
        DO:
            glb_cdcritic = 427.
            RUN fontes/critic.p.
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                              glb_cdprogra + "' --> '" + glb_dscritic +
                              " >> log/proc_batch.log").
            UNDO TRANS_1, RETURN.
        END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

/*  Calculo do rendimento  */

ASSIGN rd2_vlrendim = TRUNCATE(rd2_vlsdrdca * rd2_txaplica,8)
       rd2_vlsdrdca = rd2_vlsdrdca + rd2_vlrendim

       seg_txaplica = rd2_txaplica

       /*  Arredondamento dos valores calculados  */

       rd2_vlsdrdca = ROUND(rd2_vlsdrdca,2)
       rd2_vlrendim = ROUND(rd2_vlrendim,2)

       rd2_vlrentot = rd2_vlrentot + rd2_vlrendim

       aux_vlirrdca = aux_vlirrdca + 
                      TRUNCATE((rd2_vlrentot * aux_perirtab[4] / 100),2)
                      
       rd2_txaplica = rd2_txaplica * 100

       cap_txaplica = rd2_txaplica

       craprda.qtmesext = craprda.qtmesext + 1.

IF   craprda.qtmesext = 4   THEN
     craprda.qtmesext = 1.

IF   craprda.qtmesext = 1   THEN
     ASSIGN craprda.dtiniext = craprda.dtfimext
            craprda.dtsdrdan = craprda.dtiniper

            craprda.vlsdrdan = IF   craprda.dtiniext = craprda.dtmvtolt
                                    THEN craprda.vlsdrdan
                                    ELSE craprda.vlsdrdca.

IF   rd2_vlsdrdca = 0 THEN
     craprda.qtmesext = 3.

ASSIGN craprda.incalmes = 1
       craprda.dtfimext = craprda.dtfimper

       craprda.dtiniper = craprda.dtfimper.


ASSIGN craprda.dtfimper = IF MONTH(craprda.dtfimper) = 12
                             THEN DATE(01,DAY(craprda.dtfimper),
                                         YEAR(craprda.dtfimper) + 1)
                             ELSE DATE(MONTH(craprda.dtfimper) + 1,
                                         DAY(craprda.dtfimper),
                                        YEAR(craprda.dtfimper)) NO-ERROR.

IF   ERROR-STATUS:ERROR THEN
     IF   MONTH(craprda.dtfimper) = 11 THEN  
          craprda.dtfimper = DATE(1, 1, (YEAR(craprda.dtfimper) + 1)).
     ELSE
     IF   MONTH(craprda.dtfimper) = 12 THEN
          craprda.dtfimper = DATE(2, 1, (YEAR(craprda.dtfimper) + 1)).
     ELSE
          craprda.dtfimper = DATE((MONTH(craprda.dtfimper) + 2),
                                            1, YEAR(craprda.dtfimper)).

ASSIGN craprda.inaniver = IF (craprda.inaniver = 0) AND
                             (craprda.dtiniper - craprda.dtmvtolt) > 50
                              THEN 1
                              ELSE craprda.inaniver

       craprda.vlsdrdca = IF craprda.inaniver = 0
                             THEN craprda.vlsdrdca
                             ELSE rd2_vlsdrdca - aux_vlirrdca  

       craprda.insaqtot = IF rd2_vlsdrdca = 0
                             THEN 1
                             ELSE craprda.insaqtot

       craprda.dtsaqtot = IF rd2_vlsdrdca = 0
                             THEN glb_dtmvtolt
                             ELSE craprda.dtsaqtot

       craprda.dtcalcul = glb_dtmvtopr

       rd2_dtdolote = glb_dtmvtopr
       rd2_nrdolote = 8381.

IF   craprda.insaqtot = 1   THEN /* SAQUE TOTAL */
     ASSIGN craprda.vlsdextr = 0.
            
IF   MONTH(craprda.dtfimper) = MONTH(glb_dtmvtopr)   AND
     YEAR(craprda.dtfimper) =  YEAR(glb_dtmvtopr)   THEN
     craprda.incalmes = 0.

IF   rd2_vlrentot > 0   AND   rd2_flgentra   THEN
     DO:
         DO WHILE TRUE:

            FIND craplot WHERE craplot.cdcooper = glb_cdcooper AND
                               craplot.dtmvtolt = rd2_dtdolote AND
                               craplot.cdagenci = rd2_cdagenci AND
                               craplot.cdbccxlt = rd2_cdbccxlt AND
                               craplot.nrdolote = rd2_nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAILABLE craplot   THEN
                 IF   LOCKED craplot   THEN
                      DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          CREATE craplot.
                          ASSIGN craplot.dtmvtolt = rd2_dtdolote
                                 craplot.cdagenci = rd2_cdagenci
                                 craplot.cdbccxlt = rd2_cdbccxlt
                                 craplot.nrdolote = rd2_nrdolote
                                 craplot.tplotmov = 10
                                 craplot.cdcooper = glb_cdcooper.
                          VALIDATE craplot.
                      END.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

         /*  Capitaliza taxas do primeiro aniversario  */

         IF   pri_txaplica > 0   THEN
              cap_txaplica = TRUNCATE((((1 + pri_txaplica) *
                                        (1 + seg_txaplica)) - 1) * 100,6).

         CREATE craplap.
         ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                craplap.cdagenci = craplot.cdagenci
                craplap.cdbccxlt = craplot.cdbccxlt
                craplap.nrdolote = craplot.nrdolote
                craplap.nrdconta = craprda.nrdconta
                craplap.nraplica = craprda.nraplica
                craplap.nrdocmto = craplot.nrseqdig + 1
                craplap.txaplica = cap_txaplica
                craplap.txaplmes = cap_txaplica
                craplap.cdhistor = 179
                craplap.nrseqdig = craplot.nrseqdig + 1
                craplap.vllanmto = rd2_vlrentot
                craplap.dtrefere = rd2_dtrefere
                craplap.vlsdlsap = aux_vltotrda
                craplap.vlrenacu = TRUNCATE((aux_vlrenacu + rd2_vlrentot -
                                   aux_renrgper),2)
                craplap.vlslajir = TRUNCATE(aux_vlslajir + rd2_vlrentot -
                                   aux_vlrgtper - aux_ttajtlct -
                                   aux_vlirrdca -
               (TRUNCATE((craprda.vlabcpmf * aux_perirtab[1] / 100),2)),2)
                craplap.cdcooper = glb_cdcooper
  
                craplot.vlinfocr = craplot.vlinfocr + craplap.vllanmto
                craplot.vlcompcr = craplot.vlcompcr + craplap.vllanmto
                craplot.qtinfoln = craplot.qtinfoln + 1
                craplot.qtcompln = craplot.qtcompln + 1
                craplot.nrseqdig = craplot.nrseqdig + 1.
         VALIDATE craplap.

         IF   aux_vlirrdca > 0   THEN      
              DO:
                  CREATE craplap.
                  ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                         craplap.cdagenci = craplot.cdagenci
                         craplap.cdbccxlt = craplot.cdbccxlt
                         craplap.nrdolote = craplot.nrdolote
                         craplap.nrdconta = craprda.nrdconta
                         craplap.nraplica = craprda.nraplica
                         craplap.nrdocmto = craplot.nrseqdig + 1
                         craplap.txaplica = aux_perirtab[4]
                         craplap.txaplmes = aux_perirtab[4]
                         craplap.cdhistor = 862
                         craplap.nrseqdig = craplot.nrseqdig + 1
                         craplap.vllanmto = aux_vlirrdca
                         craplap.dtrefere = rd2_dtrefere
                         craplap.vlsdlsap = 0
                         craplap.cdcooper = glb_cdcooper
                
                         craplot.vlinfocr =
                                 craplot.vlinfocr + craplap.vllanmto
                         craplot.vlcompcr =
                                 craplot.vlcompcr + craplap.vllanmto
                         craplot.qtinfoln = craplot.qtinfoln + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.nrseqdig = craplot.nrseqdig + 1.
                  VALIDATE craplap.
              END.
     END.

/*** Abono do Cpmf agora e na aplicacao no dia aniver ***/
IF   craprda.vlabcpmf > 0   AND
     rd2_flgentra           THEN      
     DO:
         DO WHILE TRUE:

            FIND craplot WHERE craplot.cdcooper = glb_cdcooper AND
                               craplot.dtmvtolt = rd2_dtdolote AND
                               craplot.cdagenci = rd2_cdagenci AND
                               craplot.cdbccxlt = rd2_cdbccxlt AND
                               craplot.nrdolote = rd2_nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAILABLE craplot   THEN
                 IF   LOCKED craplot   THEN
                      DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                      ELSE
                          DO:
                              CREATE craplot.
                              ASSIGN craplot.dtmvtolt = rd2_dtdolote
                                     craplot.cdagenci = rd2_cdagenci
                                     craplot.cdbccxlt = rd2_cdbccxlt
                                     craplot.nrdolote = rd2_nrdolote
                                     craplot.tplotmov = 10
                                     craplot.cdcooper = glb_cdcooper.
                              VALIDATE craplot.
                          END.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */
                  
         CREATE craplap.
         ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                craplap.cdagenci = craplot.cdagenci
                craplap.cdbccxlt = craplot.cdbccxlt
                craplap.nrdolote = craplot.nrdolote
                craplap.nrdconta = craprda.nrdconta
                craplap.nraplica = craprda.nraplica
                craplap.nrdocmto = craplot.nrseqdig + 1
                craplap.txaplica = 0
                craplap.txaplmes = 0
                craplap.cdhistor = 866
                craplap.nrseqdig = craplot.nrseqdig + 1
                craplap.vllanmto = craprda.vlabcpmf
                craplap.dtrefere = rd2_dtrefere
                craplap.vlsdlsap = 0
                craplap.cdcooper = glb_cdcooper
               
                craplot.vlinfocr = craplot.vlinfocr + craplap.vllanmto
                craplot.vlcompcr = craplot.vlcompcr + craplap.vllanmto
                craplot.qtinfoln = craplot.qtinfoln + 1
                craplot.qtcompln = craplot.qtcompln + 1
                craplot.nrseqdig = craplot.nrseqdig + 1.
          VALIDATE craplap.

         /*** Ir sobre o abono ***/

         IF   TRUNCATE((craprda.vlabcpmf * aux_perirtab[1] / 100),2) > 0   THEN
              DO:
                  CREATE craplap.
                  ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                         craplap.cdagenci = craplot.cdagenci
                         craplap.cdbccxlt = craplot.cdbccxlt
                         craplap.nrdolote = craplot.nrdolote
                         craplap.nrdconta = craprda.nrdconta
                         craplap.nraplica = craprda.nraplica
                         craplap.nrdocmto = craplot.nrseqdig + 1
                         craplap.txaplica = aux_perirtab[1]
                         craplap.txaplmes = aux_perirtab[1]
                         craplap.cdhistor = 871
                         craplap.nrseqdig = craplot.nrseqdig + 1
                         craplap.vllanmto = TRUNCATE((craprda.vlabcpmf * 
                                                 aux_perirtab[1] / 100),2)
                                   
                         craplap.dtrefere = rd2_dtrefere
                         craplap.cdcooper = glb_cdcooper

                         craplot.vlinfocr = craplot.vlinfocr +
                                                    craplap.vllanmto
                         craplot.vlcompcr = craplot.vlcompcr +
                                                    craplap.vllanmto
                         craplot.qtinfoln = craplot.qtinfoln + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.nrseqdig = craplot.nrseqdig + 1.
                  VALIDATE craplap.
              END.
              
         ASSIGN craprda.vlsdrdca = craprda.vlsdrdca -
                        TRUNCATE((craprda.vlabcpmf * aux_perirtab[1] / 100),2)
                craprda.vlabonrd = craprda.vlabonrd + craprda.vlabcpmf
                craprda.vlabcpmf = 0.        
END.

rd2_vlprovis = rd2_vlrentot - rd2_vllan180.

IF   rd2_vlprovis <> 0   THEN
     DO:
         DO WHILE TRUE:

            FIND craplot WHERE craplot.cdcooper = glb_cdcooper AND
                               craplot.dtmvtolt = rd2_dtdolote AND
                               craplot.cdagenci = rd2_cdagenci AND
                               craplot.cdbccxlt = rd2_cdbccxlt AND
                               craplot.nrdolote = rd2_nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAILABLE craplot   THEN
                 IF   LOCKED craplot   THEN
                      DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          CREATE craplot.
                          ASSIGN craplot.dtmvtolt = rd2_dtdolote
                                 craplot.cdagenci = rd2_cdagenci
                                 craplot.cdbccxlt = rd2_cdbccxlt
                                 craplot.nrdolote = rd2_nrdolote
                                 craplot.tplotmov = 10
                                 craplot.cdcooper = glb_cdcooper.
                          VALIDATE craplot.
                      END.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

         CREATE craplap.
         ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                craplap.cdagenci = craplot.cdagenci
                craplap.cdbccxlt = craplot.cdbccxlt
                craplap.nrdolote = craplot.nrdolote
                craplap.nrdconta = craprda.nrdconta
                craplap.nraplica = craprda.nraplica
                craplap.txaplica = rd2_txaplica
                craplap.txaplmes = rd2_txaplica
                craplap.dtrefere = rd2_dtrefere
                craplap.nrdocmto = craplot.nrseqdig + 1
                craplap.nrseqdig = craplot.nrseqdig + 1
                craplap.vlsdlsap = aux_vltotrda
                craplap.cdcooper = glb_cdcooper
                
                craplot.qtinfoln = craplot.qtinfoln + 1
                craplot.qtcompln = craplot.qtcompln + 1
                craplot.nrseqdig = craplot.nrseqdig + 1.
         VALIDATE craplap.

         IF   rd2_vlprovis > 0   THEN
              ASSIGN craplap.cdhistor = 180
                     craplap.vllanmto = rd2_vlprovis
                     craplot.vlinfocr = craplot.vlinfocr + craplap.vllanmto
                     craplot.vlcompcr = craplot.vlcompcr + craplap.vllanmto.
         ELSE
              ASSIGN craplap.cdhistor = 182
                     craplap.vllanmto = rd2_vlprovis * -1
                     craplot.vlinfodb = craplot.vlinfodb + craplap.vllanmto
                     craplot.vlcompdb = craplot.vlcompdb + craplap.vllanmto.
     END.

/* .......................................................................... */

