/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  |includes/poupanca.i                    | APLI0001.pc_calc_poupanca         |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/* ...........................................................................

   Programa: Includes/poupanca.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                       Ultima atualizacao: 24/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina de calculo do RPP  -- Deve ser chamada de dentro de um
               FOR EACH ou DO WHILE e com label TRANS_POUP.

   Alteracoes: 04/12/96 - No acesso ao TRD complementar os campos do indice
                          (Odair).

               13/12/96 - Alterado para tratar impressao dos extratos (Odair)

               18/02/98 - Alterado para guardar no crapcot o valor abonado
                          (Deborah).

               27/03/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               12/11/98 - Tratar atendimento noturno (Deborah).

               25/01/99 - Tratar abono do IOF (Deborah).

               24/11/1999 - Taxas por faixa de valores (Deborah).

               16/03/2000 - Atualizar crapcot.vlrentot (Deborah).

               24/10/2003 - Incalcul = 2 somente no aniversario (Margarete).
               
               03/12/2003 - Atualizar novos campos crapcot para IR (Margarete).
               
               28/01/2004 - Gerar lancamento de abono e IR sobre o abono
                            no aniversario da aplicacao. E nao atualizar
                            abono da cpmf no crapcot (Margarete).

               23/09/2004 - Incluido historico 496(CI)(Mirtes)

               03/01/2005 - Nao mostrar saldo negativo nas telas (Margarete).
                 
               06/07/2005 - Alimentado campo cdcooper das tabelas craplot e
                            craplpp (Diego).

               21/07/2005 - Nao calcular rendimento sobre o imposto que
                            falta pagar (Margarete).

               07/10/2005 - Saldo do final do ano deve enxergar o IR sobre
                            o abono da CPMF (Margarete).
                       
               24/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               24/07/2008 - Cria registros na tabela CRAPSPP com informacoes do
                            saldo do aniversario da poupanca (Elton).
                            
               18/01/2011 - Tratar historico 925 (Db.Trf.Aplic) (Irlan)
               18/12/2012 - Tratar historico 1115 - Transferencia
                            Viacredi/AltoVale  (Rosangela)
                            
               21/08/2013 - Tratamento para Imunidade Tributaria (Ze).
               
               05/11/2013 - Retirado instacia da b1wgen0159 desta include para
                            instanciar fora (Lucas R.)
                            
               12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)    
                            
               10/02/2014 - Alterado leitura na craptrd, incluida leitura na
                            craptab para verificacao de liberacao da nova regra da
                            poupanca. (Jean Michel) 
                            
               24/06/2014 - Incluida data fixa de liberacao projeto novo 
                            indexador de poupanca - 07/01/2014 (Jean Michel).        
............................................................................*/

DEF        VAR rpp_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rpp_vlrendim AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rpp_vldperda AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rpp_vlsdrdpp AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rpp_vlprovis AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rpp_vlajuste AS DECIMAL                               NO-UNDO.
DEF        VAR rpp_vllan150 AS DECIMAL                               NO-UNDO.
DEF        VAR rpp_vllan152 AS DECIMAL                               NO-UNDO.
DEF        VAR rpp_vllan158 AS DECIMAL                               NO-UNDO.
DEF        VAR rpp_vllan925 AS DECIMAL                               NO-UNDO.
DEF        VAR rpp_txaplica AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rpp_txaplmes AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR rpp_dtcalcul AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rpp_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rpp_dtdolote AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rpp_dtultdia AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rpp_dtrefere AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR rpp_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR rpp_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR rpp_nrdolote AS INT                                   NO-UNDO.
DEF        VAR rpp_cdhistor AS INT                                   NO-UNDO.
DEF        VAR rpp_vlrirrpp AS DEC                                   NO-UNDO.

DEF        VAR aux_flgimune AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flggrvir AS LOGICAL                               NO-UNDO.

DEF        VAR aux_datliber AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_tptaxrda AS INT                                   NO-UNDO.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND   
                   craptab.cdempres = 0              AND
                   craptab.tptabela = "CONFIG"       AND   
                   craptab.cdacesso = "PERCIRAPLI"   AND
                   craptab.tpregist = 0              NO-LOCK NO-ERROR.

ASSIGN glb_percenir = IF AVAILABLE craptab THEN
                         DECIMAL(craptab.dstextab) 
                      ELSE 0.   

ASSIGN rpp_vlrentot = 0
       rpp_vldperda = 0
       rpp_vlajuste = 0
       rpp_vllan150 = 0
       rpp_vllan152 = 0
       rpp_vllan158 = 0
       rpp_vllan925 = 0
       rpp_vlprovis = 0
       rpp_txaplica = 0
       rpp_txaplmes = 0
       rpp_vlrirrpp = 0
       rpp_vlsdrdpp = craprpp.vlsdrdpp
       rpp_dtcalcul = craprpp.dtiniper
       rpp_dtrefere = craprpp.dtfimper
       rpp_dtultdia = IF   glb_cdprogra = "crps147"
                           THEN glb_dtmvtolt - DAY(glb_dtmvtolt)
                           ELSE glb_dtmvtopr - DAY(glb_dtmvtopr).

IF   glb_inproces > 2                         AND               /*  No BATCH  */
     CAN-DO("crps147,crps148",glb_cdprogra)   THEN
     DO:
        IF   glb_cdprogra = "crps147"   THEN                      /*  MENSAL  */
             rpp_dtmvtolt = glb_dtmvtolt + 1.
        ELSE
        IF   glb_cdprogra = "crps148"   THEN                 /*  ANIVERSARIO  */
             DO:
                 rpp_dtmvtolt = craprpp.dtfimper.

                 DO WHILE TRUE:

                    IF   CAN-DO("1,7",STRING(WEEKDAY(rpp_dtmvtolt)))    OR
                         CAN-FIND(crapfer WHERE
                                  crapfer.cdcooper = glb_cdcooper    AND
                                  crapfer.dtferiad = rpp_dtmvtolt)   THEN
                         DO:
                             rpp_dtmvtolt = rpp_dtmvtolt + 1.
                             NEXT.
                         END.

                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */
             END.
        ELSE
             DO:
                 glb_cdcritic = 145.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " para esta rotina: includes/poupanca.i " +
                                   " >> log/proc_batch.log").
                 UNDO TRANS_POUP, RETURN.
             END.
     END.  /*  Fim do DO */
ELSE                                                          /*  No ON-LINE  */
     DO:
         IF   glb_cdprogra = "crps156"   THEN
              rpp_dtmvtolt = glb_dtmvtopr.                       /*  RESGATE  */
         ELSE
              rpp_dtmvtolt = glb_dtmvtolt + 1.   /* Calculo ate o dia do mvto */
     END.

/*  Leitura dos lancamentos de resgate da aplicacao  */

FOR EACH craplpp WHERE craplpp.cdcooper  = glb_cdcooper       AND
                       craplpp.nrdconta  = craprpp.nrdconta   AND
                       craplpp.nrctrrpp  = craprpp.nrctrrpp   AND
                      (craplpp.dtmvtolt >= rpp_dtcalcul       AND
                       craplpp.dtmvtolt <= rpp_dtmvtolt)      AND
                       craplpp.dtrefere  = rpp_dtrefere       AND
                      CAN-DO("150,152,154,155,158,496,925,1115",STRING(craplpp.cdhistor))
                       NO-LOCK:

    IF   craplpp.cdhistor = 150   THEN   /* Credito do plano */
         DO:
             rpp_vllan150 = rpp_vllan150 + craplpp.vllanmto.
             NEXT.
         END.
    ELSE
    IF   craplpp.cdhistor = 152   OR    /* Provisao do mes */
         craplpp.cdhistor = 154   THEN  /* Ajuste provisao */
         DO:
             rpp_vllan152 = rpp_vllan152 + craplpp.vllanmto.
             NEXT.
         END.
    ELSE
    IF   craplpp.cdhistor = 155   THEN  /* Ajuste provisao */
         DO:
             rpp_vllan152 = rpp_vllan152 - craplpp.vllanmto.
             NEXT.
         END.
    ELSE
    IF   craplpp.cdhistor = 158  OR
         craplpp.cdhistor = 496 THEN   /* Resgate */
         DO:
             rpp_vllan158 = rpp_vllan158 + craplpp.vllanmto.
             NEXT.
         END.
    ELSE
    IF   craplpp.cdhistor = 925  OR
         craplpp.cdhistor = 1115 THEN  /* Db.Trf.Aplic. */
         DO:
             rpp_vllan925 = rpp_vllan925 + craplpp.vllanmto.
             NEXT.
         END.

END.  /*  Fim do FOR EACH -- Leitura dos lancamentos da aplicacao  */

rpp_vlsdrdpp = rpp_vlsdrdpp + rpp_vllan150 - rpp_vllan158 - rpp_vllan925.

if   rpp_vlsdrdpp < 0  then
     rpp_vlsdrdpp = 0.

IF   glb_inproces > 2                         AND               /*  No BATCH  */
     CAN-DO("crps147,crps148",glb_cdprogra)   THEN
     DO WHILE TRUE :
        
        /********************************************************************/
        /** Em maio de 2012 o novo calculo foi liberado para utilizacao,   **/
        /** portanto poupancas cadastradas a partir desta data poderiam    **/
        /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
        /** a nova regra sera utilizada somente para poupancas cadastradas **/
        /** apos a liberacao do projeto de novo indexador de poupanca,     **/
        /** pois o passado anterior a liberacao ja foi contratado com a    **/
        /** regra antiga                                                   **/
        /********************************************************************/

        /* Data de liberacao projeto novo indexador de poupanca */
        ASSIGN aux_datliber = 07/01/2014.

        IF craprpp.dtmvtolt >= aux_datliber THEN
            ASSIGN aux_tptaxrda = 4. /** Novo Indexador poupanca - Lei 12.703 **/
        ELSE
            ASSIGN aux_tptaxrda = 2. /** Regra antiga **/

        FIND FIRST craptrd WHERE craptrd.cdcooper = glb_cdcooper     AND
                                 craptrd.dtiniper = craprpp.dtiniper AND
                                 craptrd.tptaxrda = aux_tptaxrda     AND
                                 craptrd.incarenc = 0                AND
                                 craptrd.vlfaixas <= rpp_vlsdrdpp
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE craptrd   THEN
             IF   LOCKED craptrd   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:

                      message "conta/dv" craprpp.nrdconta
                              "nrctrrpp" craprpp.nrctrrpp
                              "faixa" rpp_vlsdrdpp.
                      glb_cdcritic = 347.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                        " - " + glb_cdprogra + "' --> '" +
                                        glb_dscritic + " DATA " +
                                        STRING(craprpp.dtiniper,"99/99/9999") +
                                        " FAIXA " + STRING(rpp_vlsdrdpp,
                                                           "zzz,zzz,zz9.99-") +
                                        " >> log/proc_batch.log").
                      UNDO TRANS_POUP, RETURN.
                  END.

        IF   craptrd.txofidia > 0   THEN
             ASSIGN rpp_txaplica     = (craptrd.txofidia / 100)
                    rpp_txaplmes     =  craptrd.txofimes.
        ELSE
        IF   craptrd.txprodia > 0   THEN
             ASSIGN rpp_txaplica     = (craptrd.txprodia / 100)
                    rpp_txaplmes     =  0.
        ELSE
             DO:
                 glb_cdcritic = 427.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " DATA " +
                                   STRING(craprpp.dtiniper,"99/99/9999") +
                                   " >> log/proc_batch.log").
                 UNDO TRANS_POUP, RETURN.
             END.
        
        IF   glb_cdprogra = "crps148"   THEN
             ASSIGN craptrd.incalcul = 2.
        ELSE
             ASSIGN craptrd.incalcul = 1.

        LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */
     
IF   glb_inproces > 2                         AND
     CAN-DO("crps147,crps148",glb_cdprogra)   AND
     rpp_dtcalcul < rpp_dtmvtolt              AND
    /*** Magui precisa de mais estudos
    (craprpp.vlabcpmf <> 0 AND
     TRUNCATE((craprpp.vlabcpmf * glb_percenir / 100),2) <> rpp_vlsdrdpp) AND
     ******************/
     rpp_vlsdrdpp > 0                         THEN
     DO WHILE rpp_dtcalcul < rpp_dtmvtolt:

        IF   CAN-DO("1,7",STRING(WEEKDAY(rpp_dtcalcul)))               OR
             CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                                    crapfer.dtferiad = rpp_dtcalcul)   THEN
             DO:
                 rpp_dtcalcul = rpp_dtcalcul + 1.
                 NEXT.
             END.

        ASSIGN rpp_vlrendim = TRUNCATE(rpp_vlsdrdpp * rpp_txaplica,8)
               rpp_vlsdrdpp = rpp_vlsdrdpp + rpp_vlrendim
               rpp_vlrentot = rpp_vlrentot + rpp_vlrendim

               rpp_vlprovis = IF rpp_dtcalcul <= rpp_dtultdia
                                 THEN rpp_vlprovis + rpp_vlrendim
                                 ELSE rpp_vlprovis
               rpp_dtcalcul = rpp_dtcalcul + 1.

     END.  /*  Fim do DO WHILE  */

/*  Arredondamento dos valores calculados  */

ASSIGN rpp_vlsdrdpp = ROUND(rpp_vlsdrdpp,2)
       rpp_vlrentot = ROUND(rpp_vlrentot,2)
       rpp_vlprovis = ROUND(rpp_vlprovis,2).

    
/* Tratamento para Imunidade Tributaria */
IF   glb_inproces > 2                 AND
     CAN-DO("crps148",glb_cdprogra)   THEN
     ASSIGN aux_flggrvir = TRUE.
ELSE
     ASSIGN aux_flggrvir = FALSE.



RUN verifica-imunidade-tributaria IN h-b1wgen0159(INPUT glb_cdcooper,
                                                  INPUT craprpp.nrdconta,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT aux_flggrvir,
                                                  INPUT 5,
                                                  INPUT TRUNC((rpp_vlrentot * 
                                                       glb_percenir / 100),2),
                                                  OUTPUT aux_flgimune,
                                                  OUTPUT TABLE tt-erro).

IF  aux_flgimune THEN
    rpp_vlrirrpp = 0.
ELSE
    rpp_vlrirrpp = TRUNCATE((rpp_vlrentot * glb_percenir / 100),2).

IF   glb_inproces = 1  /*AND
     craprpp.dtfimper <= glb_dtmvtolt*/  AND
     aux_flgimune = FALSE THEN
     ASSIGN rpp_vlsdrdpp = rpp_vlsdrdpp -
                           TRUNC((craprpp.vlabcpmf * glb_percenir / 100),2)
            rpp_vlsdrdpp = IF rpp_vlsdrdpp < 0 THEN 0
                         ELSE rpp_vlsdrdpp.

IF   glb_inproces > 2                         AND
     CAN-DO("crps147,crps148",glb_cdprogra)   THEN
     DO:
         IF   glb_cdprogra = "crps147"   THEN                     /*  MENSAL  */
              ASSIGN rpp_dtdolote = glb_dtmvtolt
                     rpp_nrdolote = 8383
                     rpp_cdhistor = 152

                     craprpp.incalmes = 0
                     craprpp.indebito = 0.
         ELSE
         IF   glb_cdprogra = "crps148"   THEN                /*  ANIVERSARIO  */
              DO:    
                   /********************************************************************/
                    /** Em maio de 2012 o novo calculo foi liberado para utilizacao,   **/
                    /** portanto poupancas cadastradas a partir desta data poderiam    **/
                    /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
                    /** a nova regra sera utilizada somente para poupancas cadastradas **/
                    /** apos a liberacao do projeto de novo indexador de poupanca,     **/
                    /** pois o passado anterior a liberacao ja foi contratado com a    **/
                    /** regra antiga                                                   **/
                    /********************************************************************/
            
                    /* Data de liberacao projeto novo indexador de poupanca */
                    ASSIGN aux_datliber = 07/01/2014.
            
                    IF craprpp.dtmvtolt >= aux_datliber THEN
                        ASSIGN aux_tptaxrda = 4. /** Novo Indexador poupanca - Lei 12.703 **/
                    ELSE
                        ASSIGN aux_tptaxrda = 2. /** Regra antiga **/
            
                  FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper     AND
                                     craptrd.dtiniper = craprpp.dtfimper AND
                                     craptrd.tptaxrda = aux_tptaxrda     AND
                                     craptrd.incarenc = 0                AND
                                     craptrd.vlfaixas = 0 
                                     NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craptrd   THEN
                       DO:
                           glb_cdcritic = 347.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " DATA " +
                                       STRING(craprpp.dtfimper,"99/99/9999") +
                                       STRING(craprpp.nrdconta,"zzzz,zzz,9") +
                                       STRING(craprpp.nrctrrpp,"zzz,zzz") +    
                                             " >> log/proc_batch.log").
                           UNDO TRANS_POUP, RETURN.
                       END.

                  craprpp.qtmesext = craprpp.qtmesext + 1.

                  IF   craprpp.qtmesext = 4   THEN
                       craprpp.qtmesext = 1.

                  IF   MONTH(craprpp.dtfimper) = 12   THEN
                       ASSIGN craprpp.qtmesext = 3.

                  IF   craprpp.qtmesext = 1   THEN
                       ASSIGN craprpp.dtiniext = craprpp.dtfimext
                              craprpp.dtsdppan = craprpp.dtiniper

                              craprpp.vlsdppan = craprpp.vlsdrdpp.

                  ASSIGN craprpp.incalmes = 1
                         craprpp.dtfimext = craprpp.dtfimper

                         craprpp.dtiniper = craprpp.dtfimper
                         craprpp.dtfimper = craptrd.dtfimper

                         craprpp.vlsdrdpp = rpp_vlsdrdpp - rpp_vlrirrpp

                         craprpp.dtcalcul = glb_dtmvtopr

                         rpp_dtdolote = glb_dtmvtopr
                         rpp_nrdolote = 8384
                         rpp_cdhistor = 151.
                         
                  IF   craprpp.vlabcpmf > 0   THEN
                       ASSIGN craprpp.vlsdrdpp = craprpp.vlsdrdpp -
                                      TRUNCATE((craprpp.vlabcpmf * 
                                                glb_percenir / 100),2).

                  IF   MONTH(craprpp.dtfimper) = MONTH(glb_dtmvtopr)   AND
                       YEAR(craprpp.dtfimper)  =  YEAR(glb_dtmvtopr)   THEN
                       craprpp.incalmes = 0.
                  
                  FIND crapspp WHERE crapspp.cdcooper = craprpp.cdcooper AND
                                     crapspp.nrdconta = craprpp.nrdconta AND
                                     crapspp.nrctrrpp = craprpp.nrctrrpp AND
                                     crapspp.dtsldrpp = craprpp.dtiniper
                                     NO-LOCK  NO-ERROR.

                  IF  AVAIL crapspp THEN
                      DO:
                          ASSIGN crapspp.vlsldrpp = craprpp.vlsdrdpp
                                 crapspp.dtmvtolt = glb_dtmvtolt.
                      END.
                  ELSE
                      DO:
                          CREATE  crapspp.
                          ASSIGN  crapspp.cdcooper = craprpp.cdcooper
                                  crapspp.nrdconta = craprpp.nrdconta
                                  crapspp.nrctrrpp = craprpp.nrctrrpp
                                  crapspp.dtsldrpp = craprpp.dtiniper
                                  crapspp.vlsldrpp = craprpp.vlsdrdpp
                                  crapspp.dtmvtolt = glb_dtmvtolt.
                          VALIDATE crapspp.
                      END.
              END.
         ELSE
              DO:
                  glb_cdcritic = 145.
                  RUN fontes/critic.p.
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                    glb_cdprogra + "' --> '" + glb_dscritic +
                                    " para esta " +
                                    "rotina: includes/poupanca.i " +
                                    " >> log/proc_batch.log").
                  UNDO TRANS_POUP, RETURN.
              END.

         IF   glb_cdprogra = "crps147"   THEN
              rpp_vlrentot = rpp_vlrentot - rpp_vlprovis.

         IF   rpp_vlrentot > 0   THEN
              DO:
                  DO WHILE TRUE:

                     FIND craplot WHERE craplot.cdcooper = glb_cdcooper AND
                                        craplot.dtmvtolt = rpp_dtdolote AND
                                        craplot.cdagenci = rpp_cdagenci AND
                                        craplot.cdbccxlt = rpp_cdbccxlt AND
                                        craplot.nrdolote = rpp_nrdolote
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
                                   ASSIGN craplot.dtmvtolt = rpp_dtdolote
                                          craplot.cdagenci = rpp_cdagenci
                                          craplot.cdbccxlt = rpp_cdbccxlt
                                          craplot.nrdolote = rpp_nrdolote
                                          craplot.tplotmov = 14
                                          craplot.cdcooper = glb_cdcooper.
                                  VALIDATE craplot.
                               END.

                     LEAVE.

                  END.  /*  Fim do DO WHILE TRUE  */

                  CREATE craplpp.
                  ASSIGN craplpp.dtmvtolt = craplot.dtmvtolt
                         craplpp.cdagenci = craplot.cdagenci
                         craplpp.cdbccxlt = craplot.cdbccxlt
                         craplpp.nrdolote = craplot.nrdolote
                         craplpp.nrdconta = craprpp.nrdconta
                         craplpp.nrctrrpp = craprpp.nrctrrpp
                         craplpp.nrdocmto = craplot.nrseqdig + 1
                         craplpp.txaplica = (rpp_txaplica * 100)
                         craplpp.txaplmes = rpp_txaplmes
                         craplpp.cdhistor = rpp_cdhistor
                         craplpp.nrseqdig = craplot.nrseqdig + 1
                         craplpp.vllanmto = rpp_vlrentot
                         craplpp.dtrefere = rpp_dtrefere
                         craplpp.cdcooper = glb_cdcooper

                         craplot.vlinfocr = craplot.vlinfocr + craplpp.vllanmto
                         craplot.vlcompcr = craplot.vlcompcr + craplpp.vllanmto
                         craplot.qtinfoln = craplot.qtinfoln + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.nrseqdig = craplot.nrseqdig + 1.
                  VALIDATE craplpp.

                  IF   glb_cdprogra = "crps148"   AND
                       rpp_vlrirrpp > 0           THEN 
                       DO:
                           CREATE craplpp.
                           ASSIGN craplpp.dtmvtolt = craplot.dtmvtolt
                                  craplpp.cdagenci = craplot.cdagenci
                                  craplpp.cdbccxlt = craplot.cdbccxlt
                                  craplpp.nrdolote = craplot.nrdolote
                                  craplpp.nrdconta = craprpp.nrdconta
                                  craplpp.nrctrrpp = craprpp.nrctrrpp
                                  craplpp.nrdocmto = craplot.nrseqdig + 1
                                  craplpp.txaplica = glb_percenir
                                  craplpp.txaplmes = glb_percenir
                                  craplpp.cdhistor = 863
                                  craplpp.nrseqdig = craplot.nrseqdig + 1
                                  craplpp.vllanmto = rpp_vlrirrpp
                                  craplpp.dtrefere = rpp_dtrefere
                                  craplpp.cdcooper = glb_cdcooper

                                  craplot.vlinfocr = 
                                          craplot.vlinfocr + craplpp.vllanmto
                                  craplot.vlcompcr =
                                          craplot.vlcompcr + craplpp.vllanmto
                                  craplot.qtinfoln = craplot.qtinfoln + 1
                                  craplot.qtcompln = craplot.qtcompln + 1
                                  craplot.nrseqdig = craplot.nrseqdig + 1.
                           VALIDATE craplpp.
                       END.
              END.

         IF   glb_cdprogra = "crps148"           AND
              rpp_cdhistor = 151                 AND
              (rpp_vlrentot > 0 OR
               craprpp.vlabdiof > 0 OR  rpp_vlrirrpp > 0) THEN
              DO:
                  DO WHILE TRUE:

                     /*
                     FIND crapcot OF craprpp EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                     */
                     FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper     AND
                                        crapcot.nrdconta = craprpp.nrdconta
                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                     IF   NOT AVAILABLE craprpp   THEN
                          IF   LOCKED(craprpp)   THEN
                               DO:
                                   PAUSE 2 NO-MESSAGE.
                                   NEXT.
                               END.
                          ELSE
                               DO:
                                   glb_cdcritic = 169.
                                   RUN fontes/critic.p.
                                   UNIX SILENT VALUE("echo " +
                                        STRING(TIME,"HH:MM:SS") + " - " +
                                        glb_cdprogra + "' --> '" +
                                        glb_dscritic + " CONTA = " +
                                        STRING(craprpp.nrdconta) +
                                        " >> log/proc_batch.log").
                                   UNDO TRANS_POUP, RETURN.
                               END.

                     LEAVE.

                  END.  /*  Fim do DO WHILE TRUE  */

                  IF   rpp_vlrentot > 0 THEN
                       ASSIGN craprpp.vljuracu =
                                      craprpp.vljuracu + rpp_vlrentot
                              crapcot.vlrenrpp =
                                      crapcot.vlrenrpp + rpp_vlrentot
                              crapcot.vlrenrpp_ir[MONTH(rpp_dtrefere)] =
                                    crapcot.vlrenrpp_ir[MONTH(rpp_dtrefere)] +
                                    rpp_vlrentot 
                              crapcot.vlrentot[MONTH(rpp_dtrefere)] = 
                                      crapcot.vlrentot[MONTH(rpp_dtrefere)] + 
                                      rpp_vlrentot.

                  IF   craprpp.vlabdiof > 0 THEN
                       ASSIGN crapcot.vlabiopp = 
                                      crapcot.vlabiopp + craprpp.vlabdiof
                              crapcot.vlrentot[MONTH(rpp_dtrefere)] =
                                      crapcot.vlrentot[MONTH(rpp_dtrefere)] + 
                                      craprpp.vlabdiof
                              craprpp.vlabdiof = 0.

                  IF  (rpp_vlrentot - rpp_vlprovis) > 0   THEN
                       DO:
                           DO WHILE TRUE:

                              FIND craplot WHERE
                                   craplot.cdcooper = glb_cdcooper AND
                                   craplot.dtmvtolt = rpp_dtdolote AND
                                   craplot.cdagenci = rpp_cdagenci AND
                                   craplot.cdbccxlt = rpp_cdbccxlt AND
                                   craplot.nrdolote = rpp_nrdolote
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
                                            ASSIGN
                                               craplot.dtmvtolt = rpp_dtdolote
                                               craplot.cdagenci = rpp_cdagenci
                                               craplot.cdbccxlt = rpp_cdbccxlt
                                               craplot.nrdolote = rpp_nrdolote
                                               craplot.tplotmov = 14
                                               craplot.cdcooper = glb_cdcooper.
                                            VALIDATE craplot.
                                        END.

                              LEAVE.

                           END.  /*  Fim do DO WHILE TRUE  */

                           CREATE craplpp.
                           ASSIGN craplpp.dtmvtolt = craplot.dtmvtolt
                                  craplpp.cdagenci = craplot.cdagenci
                                  craplpp.cdbccxlt = craplot.cdbccxlt
                                  craplpp.nrdolote = craplot.nrdolote
                                  craplpp.nrdconta = craprpp.nrdconta
                                  craplpp.nrctrrpp = craprpp.nrctrrpp
                                  craplpp.nrdocmto = craplot.nrseqdig + 1
                                  craplpp.txaplica = (rpp_txaplica * 100)
                                  craplpp.txaplmes = rpp_txaplmes
                                  craplpp.cdhistor = 152
                                  craplpp.nrseqdig = craplot.nrseqdig + 1
                                  craplpp.vllanmto = rpp_vlrentot - rpp_vlprovis
                                  craplpp.dtrefere = rpp_dtrefere
                                  craplpp.cdcooper = glb_cdcooper

                                  craplot.vlinfocr = craplot.vlinfocr +
                                                             craplpp.vllanmto
                                  craplot.vlcompcr = craplot.vlcompcr +
                                                             craplpp.vllanmto
                                  craplot.qtinfoln = craplot.qtinfoln + 1
                                  craplot.qtcompln = craplot.qtcompln + 1
                                  craplot.nrseqdig = craplot.nrseqdig + 1.
                           VALIDATE craplpp.
                       END.
              END.


         IF   glb_cdprogra = "crps148"   AND
              craprpp.vlabcpmf > 0       THEN
              DO: /* Abono do cpmf agora na poupanca */
                  DO WHILE TRUE:

                     FIND craplot WHERE craplot.cdcooper = glb_cdcooper AND
                                        craplot.dtmvtolt = rpp_dtdolote AND
                                        craplot.cdagenci = rpp_cdagenci AND
                                        craplot.cdbccxlt = rpp_cdbccxlt AND
                                        craplot.nrdolote = rpp_nrdolote
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
                                       ASSIGN craplot.dtmvtolt = rpp_dtdolote
                                              craplot.cdagenci = rpp_cdagenci
                                              craplot.cdbccxlt = rpp_cdbccxlt
                                              craplot.nrdolote = rpp_nrdolote
                                              craplot.tplotmov = 14
                                              craplot.cdcooper = glb_cdcooper.
                                       VALIDATE craplot.
                                   END.

                     LEAVE.

                  END.  /*  Fim do DO WHILE TRUE  */

                  CREATE craplpp.
                  ASSIGN craplpp.dtmvtolt = craplot.dtmvtolt
                         craplpp.cdagenci = craplot.cdagenci
                         craplpp.cdbccxlt = craplot.cdbccxlt
                         craplpp.nrdolote = craplot.nrdolote
                         craplpp.nrdconta = craprpp.nrdconta
                         craplpp.nrctrrpp = craprpp.nrctrrpp
                         craplpp.nrdocmto = craplot.nrseqdig + 1
                         craplpp.txaplica = 0
                         craplpp.txaplmes = 0
                         craplpp.cdhistor = 869
                         craplpp.nrseqdig = craplot.nrseqdig + 1
                         craplpp.vllanmto = craprpp.vlabcpmf
                         craplpp.dtrefere = rpp_dtrefere
                         craplpp.cdcooper = glb_cdcooper
                         craplot.vlinfocr = craplot.vlinfocr + craplpp.vllanmto
                         craplot.vlcompcr = craplot.vlcompcr + craplpp.vllanmto
                         craplot.qtinfoln = craplot.qtinfoln + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.nrseqdig = craplot.nrseqdig + 1.
                   VALIDATE craplpp.
                  /* Ir sobre o abono de cpmf na poupanca */
                  IF   TRUNCATE((craprpp.vlabcpmf * 
                                         glb_percenir / 100),2) > 0   THEN
                       DO:
                           CREATE craplpp.
                           ASSIGN craplpp.dtmvtolt = craplot.dtmvtolt
                                  craplpp.cdagenci = craplot.cdagenci
                                  craplpp.cdbccxlt = craplot.cdbccxlt
                                  craplpp.nrdolote = craplot.nrdolote
                                  craplpp.nrdconta = craprpp.nrdconta
                                  craplpp.nrctrrpp = craprpp.nrctrrpp
                                  craplpp.nrdocmto = craplot.nrseqdig + 1
                                  craplpp.txaplica = glb_percenir
                                  craplpp.txaplmes = glb_percenir
                                  craplpp.cdhistor = 870
                                  craplpp.nrseqdig = craplot.nrseqdig + 1
                                  craplpp.vllanmto = 
                                          TRUNCATE((craprpp.vlabcpmf * 
                                                    glb_percenir / 100),2)
                                  craplpp.dtrefere = rpp_dtrefere
                                  craplpp.cdcooper = glb_cdcooper

                                  craplot.vlinfocr = craplot.vlinfocr +
                                                             craplpp.vllanmto
                                  craplot.vlcompcr = craplot.vlcompcr +
                                                             craplpp.vllanmto
                                  craplot.qtinfoln = craplot.qtinfoln + 1
                                  craplot.qtcompln = craplot.qtcompln + 1
                                  craplot.nrseqdig = craplot.nrseqdig + 1.
                           VALIDATE craplpp.
                       END.
                                
                  ASSIGN craprpp.vlabcpmf = 0.
                           
              END.
                    
         IF   CAN-DO("crps147,crps148",glb_cdprogra)   THEN
              DO:
                  rpp_vlajuste = rpp_vlprovis - rpp_vllan152.

                  IF   rpp_vlajuste <> 0   THEN
                       DO:
                           DO WHILE TRUE:

                              FIND craplot WHERE
                                   craplot.cdcooper = glb_cdcooper   AND
                                   craplot.dtmvtolt = rpp_dtdolote   AND
                                   craplot.cdagenci = rpp_cdagenci   AND
                                   craplot.cdbccxlt = rpp_cdbccxlt   AND
                                   craplot.nrdolote = 8384
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
                                            ASSIGN
                                                craplot.dtmvtolt = rpp_dtdolote
                                                craplot.cdagenci = rpp_cdagenci
                                                craplot.cdbccxlt = rpp_cdbccxlt
                                                craplot.nrdolote = 8384
                                                craplot.tplotmov = 14
                                                craplot.cdcooper = glb_cdcooper.
                                            VALIDATE craplot.
                                        END.

                              LEAVE.

                           END.  /*  Fim do DO WHILE TRUE  */

                           CREATE craplpp.
                           ASSIGN craplpp.dtmvtolt = craplot.dtmvtolt
                                  craplpp.cdagenci = craplot.cdagenci
                                  craplpp.cdbccxlt = craplot.cdbccxlt
                                  craplpp.nrdolote = craplot.nrdolote
                                  craplpp.nrdconta = craprpp.nrdconta
                                  craplpp.nrctrrpp = craprpp.nrctrrpp
                                  craplpp.nrdocmto = craplot.nrseqdig + 1
                                  craplpp.txaplica = (rpp_txaplica * 100)
                                  craplpp.txaplmes = rpp_txaplmes
                                  craplpp.cdhistor = IF rpp_vlajuste > 0
                                                        THEN 154
                                                        ELSE 155
                                  craplpp.nrseqdig = craplot.nrseqdig + 1
                                  craplpp.vllanmto = IF rpp_vlajuste > 0
                                                        THEN rpp_vlajuste
                                                        ELSE rpp_vlajuste * -1

                                  craplpp.dtrefere = rpp_dtrefere
                                  craplpp.cdcooper = glb_cdcooper.
                           VALIDATE craplpp.

                           IF   rpp_vlajuste > 0   THEN
                                ASSIGN craplot.vlinfocr = craplot.vlinfocr +
                                                          craplpp.vllanmto
                                       craplot.vlcompcr = craplot.vlcompcr +
                                                          craplpp.vllanmto.
                           ELSE
                                ASSIGN craplot.vlinfodb = craplot.vlinfodb +
                                                          craplpp.vllanmto
                                       craplot.vlcompdb = craplot.vlcompdb +
                                                          craplpp.vllanmto.

                           ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
                                  craplot.qtcompln = craplot.qtcompln + 1
                                  craplot.nrseqdig = craplot.nrseqdig + 1.
                       END.
              END.
     END.

/* .......................................................................... */




