/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-------------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                       |
  +---------------------------------+-------------------------------------------+
  | includes/rdca2m.i               | APLI0001.pc_calcula_provisao_mensal_rdca2 |
  +---------------------------------+-------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/* .............................................................................

   Programa: Includes/rdca2m.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/96.                        Ultima atualizacao: 05/02/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina de calculo da provisao mensal do RDCA2 - Deve ser chamada
               dentro de um FOR EACH ou DO WHILE e com label TRANS_1.

   Alteracoes: 11/03/98 - Alterado para tratar taxa especial no periodo
                          de 10/02/98 a 05/03/98 (Deborah).

               29/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               23/03/99 - Nao marcar a taxa como utilizada no processo mensal
                          (Deborah).

               01/12/1999 - Tratar somente carencia 0 (Deborah). 

               29/04/2002 - Nova regra para pegar a taxa (Margarete).

               23/09/2004 - Incluido historico 494(CI)(Mirtes)

               16/12/2004 - Ajustes para tratar das novas aliquotas de 
                            IRRF (Margarete).

               06/05/2005 - Utilizar o indice craplap5 na leitura dos 
                            lancamentos (Edson).

               06/07/2005 - Alimentado campo cdcooper das tabelas craplot e
                            craplap (Diego).

               03/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               27/07/2007 - Alteracao para melhoria de performance (Evandro).
               
               14/10/2013 - Eliminado var aux_lsaplica, retirado atribuicao de 
                            craplap.lsaplica . (Jorge)
               
               12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)   
                            
               05/02/2014 - Alteração de atribuição da var aux_tptaxrda = 4 p/
                           aux_tptaxrda = 5. (Jean Michel)           

............................................................................. */

DEF VAR aux_tptaxrda AS INTEGER                                       NO-UNDO.

ASSIGN rd2_vlrentot = 0
       rd2_vlrendim = 0
       rd2_vllan178 = 0
       rd2_vllan180 = 0
       rd2_vlprovis = 0

       rd2_vlsdrdca = craprda.vlsdrdca

       rd2_dtcalcul = IF craprda.inaniver = 0
                         THEN craprda.dtmvtolt
                         ELSE craprda.dtiniper

       rd2_dtrefant = IF craprda.inaniver = 0   AND               
                         craprda.dtmvtolt <> craprda.dtiniper
                         THEN craprda.dtiniper
                         ELSE craprda.dtfimper

       rd2_dtrefere = craprda.dtfimper

       rd2_dtmvtolt = glb_dtmvtolt

       rd2_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                             DAY(DATE(MONTH(glb_dtmvtolt),28,
                             YEAR(glb_dtmvtolt)) + 4)).

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
        IF   craplap.cdhistor = 178   OR     /* Resgate para conta corrente */
             craplap.cdhistor = 876   OR     /* Ajuste de IR no resgate */
             craplap.cdhistor = 494   THEN   /* Resgate para CI */
             rd2_vllan178 = rd2_vllan178 + craplap.vllanmto.

    END.  /*  Fim do FOR EACH -- Leitura dos lancamentos da aplicacao  */
    
END.    

rd2_vlsdrdca = rd2_vlsdrdca - rd2_vllan178.

IF   craprda.inaniver = 0   AND   rd2_flgentra   THEN /*  Recalcula o 1o mes  */
     DO:
         /*  Taxa a ser aplicada conforme a faixa  */

         DO WHILE TRUE:
            
            FIND FIRST craptrd WHERE craptrd.cdcooper  = glb_cdcooper     AND
                                     craptrd.dtiniper  = craprda.dtmvtolt AND
                                     craptrd.tptaxrda  = aux_tptaxrda     AND
                                  /* craptrd.incarenc  = 1                AND */
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
                 rd2_txaplica = craptrd.txofimes / 100.
            ELSE
                 DO:                        
                     glb_cdcritic = 427.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " +
                               STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                               " DIA " +
                               STRING(craprda.dtmvtolt,"99/99/9999") +
                              " >> log/proc_batch.log").
                     UNDO TRANS_1, RETURN.
                     
                 END.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

         /*  Recalculo do rendimento  */

         ASSIGN rd2_vlrendim = TRUNCATE(rd2_vlsdrdca * rd2_txaplica,8)
                rd2_vlsdrdca = rd2_vlsdrdca + rd2_vlrendim

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
                              /* craptrd.incarenc  = 1                AND */
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
        rd2_txaplica = craptrd.txofimes / 100.
   ELSE
     
        DO:  
            glb_cdcritic = 427.
            RUN fontes/critic.p.
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                              glb_cdprogra + "' --> '" + glb_dscritic +
                              " DIA " +
                              STRING(craprda.dtiniper,"99/99/9999") +
                              " >> log/proc_batch.log").
            UNDO TRANS_1, RETURN.
            
        END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

/*  Calculo da provisao mensal  */

ASSIGN rd2_nrdiacal = craprda.dtfimper - craprda.dtiniper
       rd2_nrdiames = (rd2_dtultdia + 1) - craprda.dtiniper

       rd2_vlrendim = TRUNCATE(rd2_vlsdrdca * rd2_txaplica,8)

       rd2_vlprovis = TRUNCATE((rd2_vlrendim / rd2_nrdiacal) * rd2_nrdiames,8)
       rd2_vlsdrdca = rd2_vlsdrdca + rd2_vlprovis

       /*  Arredondamento dos valores calculados  */

       rd2_vlsdrdca = ROUND(rd2_vlsdrdca,2)
       rd2_vlrendim = ROUND(rd2_vlrentot,2)
       rd2_vlprovis = ROUND(rd2_vlprovis,2)

       rd2_vlrentot = rd2_vlrentot + rd2_vlprovis

       rd2_dtdolote = glb_dtmvtolt
       rd2_nrdolote = 8380

       rd2_vlprovis = rd2_vlrentot - rd2_vllan180

       rd2_txaplica = rd2_txaplica * 100

       craprda.incalmes = 0.

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
         VALIDATE craplap.
     END.

/* .......................................................................... */

