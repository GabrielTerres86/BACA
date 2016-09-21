/* .............................................................................

   Programa: Includes/aplicacao.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/94.                    Ultima atualizacao: 18/06/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina de calculo do RDCA -- Deve ser chamada de dentro de um
               FOR EACH ou DO WHILE e com label TRANS_1.

   Alteracoes: 06/02/95 - Se o ultimo dia do mes anterior for dia util e o
                          primeiro dia do mes atual tambem, seleciona os lan-
                          camentos do primeiro dia do mes (Edson).

               27/03/95 - Dar tratamento ao programa crps117.

               09/05/95 - Alimentar o campo craprda.dtsaqtot quando a aplica-
                          cao foi totalmente resgatada com a data do movimento
                          (Edson).

               25/09/95 - Alterado para tratar vlsdrdan no craprda e txaplmes
                          no craplap. (Deborah)

               16/10/95 - Alterado para tratar historicos e porgramas da rotina
                          de unificacao (crps135, hist.143)

               24/10/95 - Alterado para tratar craprda.dtsdrdan (Deborah).

               30/11/95 - Alterado para calcular com 8 casas decimais e arredon-
                          dar os resultados finais para 2 casas decimais (Edson)

               07/12/95 - Alterado para tratar o programa 133 (Deborah).

               18/12/95 - Alterado para tratar o programa 011 (Edson).

               22/02/96 - Alterado para tratar extrato trimestral (Edson).

               16/09/96 - Substituido os programas 133 e 143 pelos programas
                          168 e 169 (Edson).

               28/11/96 - Alterar para tratar 105 e 148 complementar indices
                          (Odair)

               14/10/97 - Alterado para tratar o programa crps210 (Edson).

               12/11/98 - Tratar atendimento noturno (Deborah).

               25/03/2002 - Tratar o programa crps323.p (Deborah)
                            Acerto no tratamento do programa crps210.p (Ze)

               19/08/2003 - Tratar o programa crps349.p (Deborah)

               24/10/2003 - Incalcul = 2 somente se aniversario (Margarete).
               
               09/12/2003 - Incluir cobranca de IRRF (Margarete).

               07/01/2004 - Quando resgate on_line nao pagar rendimento
                            no dia do resgate (Margarete).

               26/01/2004 - Gerar lancamento de abono e IR sobre o abono
                            no aniversario da aplicacao (Margarete).

               02/07/2004 - Zerar saldos de final do mes quando saque
                            total (Margarete).
               
              23/09/2004 - Incluido historico 492(CI)(Mirtes)

              10/12/2004 - Ajustes para tratar das novas aliquotas de 
                           IRRF (Margarete).

              21/01/2005 - IRRF sobre abono CPMF usara maior taxa (Margarete).
              
              25/01/2005 - Incluido tratamento programa crps431(Mirtes)
              
              01/03/2005 - Incluido tratamento programa crps414 (Junior).

              08/03/2005 - Permitir acessar tela ATENDA(glb_inproces>=3)(Mirtes)

              06/05/2005 - Utilizar o indice craplap5 na leitura dos 
                           lancamentos (Edson).

              05/07/2005 - Alimentado campo cdcooper das tabelas craplot e
                           craplap (Diego).

              28/07/2005 - Saldo para resgate errado quando dentro da
                           carencia (Margarete).

              24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

              24/02/2006 - Incluido programa crps445 - Mirtes

              23/03/2006 - Algumas aplicacoes com resgate total estavam
                           ficando com saldo (Magui).

              19/06/2006 - Alterado o indice na leitura do craplap (trocado o 
                           craplap2 pelo craplap5 e tirado o can-do na selecao
                           do historico (Edson).

              03/08/2006 - Campo vlslfmes substituido por vlsdextr (Magui).

              23/08/2006 - Nao atualizar mais craprda.dtsdfmes (Magui).
              
              14/06/2007 - Alteracao para melhoria de performance (Evandro).

              30/01/2009 - Incluir programas crps175 e 176 na lista para 
                           calculo do saldo (David).
                           
              22/04/2010 - Incluido programa crps563 para calculo do saldo 
                           (Elton).             
              
              18/06/2012 - Incluir tratamento para resgate de RDCA menor que
                           R$ 1,00 (Ze).
............................................................................. */

DEF        BUFFER crablap5 FOR craplap.

DEF        VAR aux_ttrenrgt AS DECIMAL DECIMALS 8                    NO-UNDO.
/* total dos rendimentos resgatados no periodo com ajuste no dia do aniver */
                                  
DEF        VAR aux_vlrenrgt AS DECIMAL DECIMALS 8                    NO-UNDO.
                               /* rendimento resgatado periodo */
DEF        VAR aux_ajtirrgt AS DECIMAL DECIMALS 8                    NO-UNDO.
                              /* IRRF pago do que foi resgatado no periodo */
DEF        VAR aux_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlrendim AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vldperda AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdrdat AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdresg AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlprovis AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlajuste AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vllan117 AS DECIMAL                               NO-UNDO.
DEF        VAR aux_txaplica AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_txaplmes AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR aux_dtcalajt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtdolote AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.

DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF        VAR aux_vlajtsld AS DEC                                   NO-UNDO.

DEF        VAR aux_flglanca AS LOGICAL                               NO-UNDO.
DEF        VAR aux_vlabcpmf AS DEC                                   NO-UNDO.
DEF        VAR aux_flgncalc AS LOG                                   NO-UNDO.
DEF        VAR aux_sldcaren AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR dup_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR dup_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR dup_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR dup_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.

ASSIGN aux_vlrgtper = 0       aux_vlrenper = 0
       aux_renrgper = 0       aux_vlrentot = 0
       aux_vldperda = 0       aux_vlajuste = 0
       aux_vllan117 = 0       aux_ajtirrgt = 0
       aux_vlprovis = 0       aux_vlrenrgt = 0
       aux_ttrenrgt = 0       aux_flgncalc = NO
       aux_ttajtlct = 0       aux_ttpercrg = 0
       aux_trergtaj = 0       aux_vlajtsld = 0
       aux_vlabcpmf = IF craprda.vlabcpmf > 0 THEN craprda.vlabcpmf ELSE 0
       aux_vlsdrdca = craprda.vlsdrdca
       aux_dtcalcul = craprda.dtiniper
       aux_dtcalajt = craprda.dtiniper
       aux_dtrefere = craprda.dtfimper
       aux_dtultdia = glb_dtmvtolt - DAY(glb_dtmvtolt)
       aux_flglanca = FALSE.

IF   glb_inproces > 2            AND                            /*  No BATCH  */
     NOT CAN-DO("crps011,crps109,crps110,crps113,crps128,crps175,crps176," +
                "crps168,crps140,crps169,crps210,crps323," +    
                "crps349,crps414,crps445,crps563,crps029,atenda,anota," + 
                "InternetBank",glb_cdprogra) THEN
     DO WHILE TRUE :

        FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper      AND
                           craptrd.dtiniper = craprda.dtiniper  AND
                           craptrd.tptaxrda = 1                 AND
                           craptrd.incarenc = 0                 AND
                           craptrd.vlfaixas = 0
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
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                        " - " + glb_cdprogra + "' --> '" +
                                        glb_dscritic + " " +
                                        STRING(craprda.dtiniper,"99/99/9999") +
                                        " >> log/proc_batch.log").
                      UNDO TRANS_1, RETURN.
                  END.

        IF   craptrd.txofidia > 0   THEN
             ASSIGN aux_txaplica     = (craptrd.txofidia / 100)
                    aux_txaplmes     =  craptrd.txofimes.
        ELSE
        IF   craptrd.txprodia > 0   THEN
             ASSIGN aux_txaplica     = (craptrd.txprodia / 100)
                    aux_txaplmes     =  0.
        ELSE
             DO:
                 glb_cdcritic = 427.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " >> log/proc_batch.log").
                 UNDO TRANS_1, RETURN.
             END.

        ASSIGN craptrd.incalcul = 1.
        
        IF   glb_cdprogra = "crps103"   THEN                      /*  MENSAL  */
             aux_dtmvtolt = glb_dtmvtolt + 1.
        ELSE
        IF   glb_cdprogra = "crps104"   THEN                 /*  ANIVERSARIO  */
             DO:
                 ASSIGN craptrd.incalcul = 2
                        aux_dtmvtolt     = craprda.dtfimper.

                 DO WHILE TRUE:

                    IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt)))    OR
                         CAN-FIND(crapfer WHERE
                                  crapfer.cdcooper = glb_cdcooper    AND
                                  crapfer.dtferiad = aux_dtmvtolt)   THEN
                         DO:
                             aux_dtmvtolt = aux_dtmvtolt + 1.
                             NEXT.
                         END.

                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */
             END.
        ELSE
        IF   glb_cdprogra = "crps105"   THEN
             aux_dtmvtolt = glb_dtmvtopr.                        /*  RESGATE  */
        ELSE
        IF   glb_cdprogra = "crps117" OR                /* RESGATE PARA O DIA */
             glb_cdprogra = "crps135" OR                /*  UNIFICACAO */
             glb_cdprogra = "crps431" THEN   
             aux_dtmvtolt = glb_dtmvtolt.
        ELSE
             DO:
                 glb_cdcritic = 145.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " para esta rotina: includes/aplicacao.i " +
                                   " >> log/proc_batch.log").
                 UNDO TRANS_1, RETURN.
             END.

        LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */
ELSE                                                          /*  No ON-LINE  */
     DO:
         FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper      AND
                            craptrd.dtiniper = craprda.dtiniper  AND
                            craptrd.tptaxrda = 1                 AND
                            craptrd.incarenc = 0                 AND
                            craptrd.vlfaixas = 0               
                            NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craptrd   THEN
              DO:
                  glb_cdcritic = 347.
                  UNDO TRANS_1, LEAVE.
              END.

         IF   craptrd.txofidia > 0   THEN
              ASSIGN aux_txaplica = (craptrd.txofidia / 100)
                     aux_txaplmes =  craptrd.txofimes.
         ELSE
         IF   craptrd.txprodia > 0   THEN
              ASSIGN aux_txaplica = (craptrd.txprodia / 100)
                     aux_txaplmes = 0.
         ELSE
              DO:
                  glb_cdcritic = 427.
                  UNDO TRANS_1, LEAVE.
              END.

         IF   glb_cdprogra = "crps110"   THEN
              aux_dtmvtolt = craprda.dtfimper.
         ELSE
              IF   glb_cdprogra = "crps210"   THEN
                   aux_dtmvtolt = glb_dtmvtopr.
              ELSE
                   IF   glb_cdprogra = "crps117"  OR   /* Resgate para o Dia*/
                        glb_cdprogra = "crps431" THEN  /* nao roda on_line */
                        aux_dtmvtolt = glb_dtmvtolt.
                   ELSE     
                        aux_dtmvtolt = glb_dtmvtolt + 1.  
                       /* Calculo ate o dia do mvto */
     END.


/* Leitura dos lancamentos de resgate da aplicacao 
   
   OBS.: Para melhoria de performance, o FOR EACH foi feito com cada clausula
         separada para conter somente igualdades de acordo com o indice
         craplap6 e nao deve ter o USE-INDEX pois o PROGRESS fara varredura na
         tabela inteira caso o indice seja forcado */

FOR EACH craplap WHERE (craplap.cdcooper  = glb_cdcooper       AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 117                AND
                        craplap.dtmvtolt >= aux_dtcalcul       AND
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR

                       (craplap.cdcooper  = glb_cdcooper       AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 118                AND
                        craplap.dtmvtolt >= aux_dtcalcul       AND
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR
                        
                       (craplap.cdcooper  = glb_cdcooper       AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 124                AND
                        craplap.dtmvtolt >= aux_dtcalcul       AND
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR

                       (craplap.cdcooper  = glb_cdcooper       AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 125                AND
                        craplap.dtmvtolt >= aux_dtcalcul       AND
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR
                        
                       (craplap.cdcooper  = glb_cdcooper       AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 143                AND
                        craplap.dtmvtolt >= aux_dtcalcul       AND
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR

                       (craplap.cdcooper  = glb_cdcooper       AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 492                AND
                        craplap.dtmvtolt >= aux_dtcalcul       AND
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR
                        
                       (craplap.cdcooper  = glb_cdcooper       AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 875                AND
                        craplap.dtmvtolt >= aux_dtcalcul       AND
                        craplap.dtmvtolt <= aux_dtmvtolt)

                        NO-LOCK BREAK BY craplap.dtmvtolt:

    IF   craplap.cdhistor = 117   OR
         craplap.cdhistor = 124   THEN
         DO:
             aux_vllan117 = aux_vllan117 + craplap.vllanmto.
             NEXT.
         END.
    ELSE
    IF   craplap.cdhistor = 125   THEN
         DO:
             aux_vllan117 = aux_vllan117 - craplap.vllanmto.
             NEXT.
         END.
    ELSE
    IF   craplap.cdhistor = 875   THEN /* ajuste IRRF dos resgates */
         DO: 
             ASSIGN aux_vlsdrdca = aux_vlsdrdca - craplap.vllanmto
                    aux_ttajtlct = aux_ttajtlct + craplap.vllanmto.
             NEXT.
         END.

    /*  Verifica dias uteis e calcula os rendimentos  */
    DO WHILE aux_dtcalcul < craplap.dtmvtolt   AND   aux_vlsdrdca > 0:

       IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtcalcul)))               OR
            CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                                   crapfer.dtferiad = aux_dtcalcul)   THEN
            DO:
                aux_dtcalcul = aux_dtcalcul + 1.
                NEXT.
            END.
        
       ASSIGN aux_vlrendim = TRUNCATE(aux_vlsdrdca * aux_txaplica,8)
              aux_vlsdrdca = aux_vlsdrdca + aux_vlrendim 
              aux_vlrentot = aux_vlrentot + aux_vlrendim
               
              aux_vlprovis = IF aux_dtcalcul <= aux_dtultdia
                                THEN aux_vlprovis + aux_vlrendim
                                ELSE aux_vlprovis

              aux_dtcalcul = aux_dtcalcul + 1.

    END.  /*  Fim do DO WHILE  */

    aux_vlsdrdca = aux_vlsdrdca - craplap.vllanmto.

    IF   (aux_vlsdrdca < 0)   THEN
         DO:
             IF   glb_cdprogra = "crps103"   THEN
                  .
             ELSE     
             IF   (glb_cdprogra = "crps104" OR glb_inproces < 3)   THEN
                   ASSIGN aux_vldperda = aux_vldperda +
                                        (aux_vlsdrdca * -1)
                          aux_vlsdrdca = 0.
         END.
            
END.  /*  Fim do FOR EACH -- Leitura dos lancamentos da aplicacao  */

/*** Magui pegar os ajustes de IR devidos ***/
FOR EACH craplap WHERE (craplap.cdcooper  = glb_cdcooper       AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 118                AND
                        craplap.dtmvtolt >= craprda.dtiniper   AND   
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR

                       (craplap.cdcooper  = glb_cdcooper       AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 492                AND
                        craplap.dtmvtolt >= craprda.dtiniper   AND
                        craplap.dtmvtolt <= aux_dtmvtolt)
                        
                        NO-LOCK BREAK BY craplap.dtmvtolt:

    ASSIGN aux_vlrgtper = aux_vlrgtper + craplap.vllanmto
           aux_renrgper = aux_renrgper + craplap.vlrenreg
           aux_ttpercrg = aux_ttpercrg + craplap.pcajsren.

    IF   LAST(craplap.dtmvtolt)    AND
         aux_ttpercrg >= 99.9      THEN
         ASSIGN aux_vlrenrgt = craplap.rendatdt - aux_trergtaj.
    ELSE                
         ASSIGN aux_vlrenrgt = IF craplap.vlslajir <> 0 THEN
                                 (craplap.vllanmto * 
                                  craplap.rendatdt / craplap.vlslajir)
                               ELSE 0 
                aux_trergtaj = aux_trergtaj + aux_vlrenrgt.
                                                            
    ASSIGN aux_ttrenrgt = aux_ttrenrgt + aux_vlrenrgt
           aux_ajtirrgt = aux_ajtirrgt + 
                             (TRUNCATE((aux_vlrenrgt * 
                                        craplap.aliaplaj / 100),2) -
                              TRUNCATE((aux_vlrenrgt *
                                        aux_perirtab[4] / 100),2)).
    IF   aux_ttpercrg >= 99.9  THEN
         ASSIGN aux_flgncalc = YES.
END.


/* Alimenta campos para a rotina duplicada */

ASSIGN aux_trergtaj = 0
       dup_dtcalcul = aux_dtcalcul
       dup_dtmvtolt = IF glb_cdprogra = "crps105" THEN glb_dtmvtopr
                      ELSE glb_dtmvtolt
       dup_vlsdrdca = aux_vlsdrdca
       dup_vlrentot = aux_vlrentot
       aux_sldcaren = aux_vlsdrdca.

/* fim */

IF   NOT aux_flgncalc              AND
     aux_dtcalcul < aux_dtmvtolt   AND
     aux_vlsdrdca > 0              THEN
     DO WHILE aux_dtcalcul < aux_dtmvtolt:

        IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtcalcul)))               OR
             CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                                    crapfer.dtferiad = aux_dtcalcul)   THEN
             DO:
                 aux_dtcalcul = aux_dtcalcul + 1.
                 NEXT.
             END.
        ASSIGN aux_vlrendim = TRUNCATE(aux_vlsdrdca * aux_txaplica,8)
               aux_vlsdrdca = aux_vlsdrdca + aux_vlrendim 
               aux_vlrentot = aux_vlrentot + aux_vlrendim
             
               aux_vlprovis = IF aux_dtcalcul <= aux_dtultdia
                                 THEN aux_vlprovis + aux_vlrendim
                                 ELSE aux_vlprovis

               aux_dtcalcul = aux_dtcalcul + 1.

     END.  /*  Fim do DO WHILE  */

IF   NOT aux_flgncalc              AND
     dup_dtcalcul < dup_dtmvtolt   AND
     dup_vlsdrdca > 0              THEN
     DO WHILE dup_dtcalcul < dup_dtmvtolt:
        
        IF   CAN-DO("1,7",STRING(WEEKDAY(dup_dtcalcul)))               OR
             CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                                    crapfer.dtferiad = dup_dtcalcul)   THEN
             DO:
                 dup_dtcalcul = dup_dtcalcul + 1.
                 NEXT.
             END.
                            
             ASSIGN aux_vlrendim = TRUNCATE(dup_vlsdrdca * aux_txaplica,8)
                    dup_vlrentot = dup_vlrentot + aux_vlrendim
                    dup_vlsdrdca = dup_vlsdrdca + aux_vlrendim
                    dup_dtcalcul = dup_dtcalcul + 1.
  
     END.  /*  Fim do DO WHILE  */
     
/*  Arredondamento dos valores calculados  */

ASSIGN aux_vlsdrdca = ROUND(aux_vlsdrdca,2)
       aux_vlrentot = ROUND(aux_vlrentot,2)
       aux_vldperda = ROUND(aux_vldperda,2)
       aux_vlprovis = ROUND(aux_vlprovis,2)
       dup_vlsdrdca = ROUND(dup_vlsdrdca,2).

IF   glb_inproces     = 1  AND
     craprda.inaniver = 0  AND
     craprda.dtmvtolt = craprda.dtiniper AND
     craprda.dtfimper > glb_dtmvtolt     THEN
     ASSIGN aux_sldpresg = aux_sldcaren.
ELSE           
     DO:        
/*** Calcular saldo para resgate enxergando as novas faixas de percentual de
     imposto de renda e o ajuste necessario ***/
         ASSIGN aux_nrctaapl = craprda.nrdconta
                aux_nraplres = craprda.nraplica
                aux_vlsldapl = dup_vlsdrdca
                aux_vlrenper = dup_vlrentot
                aux_sldpresg = 0
                aux_dtregapl = glb_dtmvtolt.
           
          RUN fontes/saldo_rdca_resgate.p. 
     END.      

IF   glb_cdprogra <> "crps103"   THEN
     DO:
         ASSIGN aux_vlsdrdca = aux_vlsdrdca -
                    TRUNCATE((aux_vlrentot * aux_perirtab[4] / 100),2)
                dup_vlsdrdca = dup_vlsdrdca -
                    TRUNCATE((dup_vlrentot * aux_perirtab[4] / 100),2).
         IF   craprda.dtfimper <= glb_dtmvtolt   THEN
              ASSIGN aux_vlsdrdca = aux_vlsdrdca -
                         TRUNCATE((aux_vlabcpmf * aux_perirtab[1] / 100),2)
                     dup_vlsdrdca = dup_vlsdrdca -
                         TRUNCATE((aux_vlabcpmf * aux_perirtab[1] / 100),2).
     END.
IF   glb_inproces > 2                                                     AND
     NOT CAN-DO("crps011,crps105,crps109,crps110,crps113,crps117,crps128," +
     "crps175,crps176,crps168,crps135,crps431,crps140,crps169,crps210," + 
     "crps323,crps349,crps414,crps445,crps563,crps029,atenda,anota," + 
     "InternetBank",glb_cdprogra)   THEN     
     DO:
         IF   glb_cdprogra = "crps103"   THEN                     /*  MENSAL  */
              ASSIGN aux_dtdolote = glb_dtmvtolt
                     aux_nrdolote = 8380
                     aux_cdhistor = 117
                     aux_flglanca = TRUE

                     craprda.incalmes = 0.
         ELSE
         IF   glb_cdprogra = "crps104"   THEN                /*  ANIVERSARIO  */
              DO:
                  FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper      AND
                                     craptrd.dtiniper = craprda.dtfimper  AND
                                     craptrd.tptaxrda = 1                 AND
                                     craptrd.incarenc = 0                 AND
                                     craptrd.vlfaixas = 0
                                     NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craptrd   THEN
                       DO:
                           glb_cdcritic = 347.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             glb_dscritic + " " +
                                       STRING(craprda.dtfimper,"99/99/9999") +
                                             " >> log/proc_batch.log").
                           UNDO TRANS_1, RETURN.
                       END.

                  craprda.qtmesext = craprda.qtmesext + 1.

                  IF   craprda.qtmesext = 4   THEN
                       craprda.qtmesext = 1.

                  IF   craprda.qtmesext = 1   THEN
                       ASSIGN craprda.dtiniext = craprda.dtfimext
                              craprda.dtsdrdan = craprda.dtiniper

                              craprda.vlsdrdan = IF (craprda.inaniver = 0) OR
                                               ((craprda.nraplica > 499999) AND
                                                (craprda.dtmvtolt =
                                                         craprda.dtsdrdan))
                                               THEN 0
                                               ELSE craprda.vlsdrdca.

                  IF   TRUNCATE(aux_vlsdrdca - aux_ajtirrgt,2) = 0   THEN
                       craprda.qtmesext = 3.

                  ASSIGN craprda.incalmes = 1
                         craprda.dtfimext = craprda.dtfimper

                         craprda.dtiniper = craprda.dtfimper
                         craprda.dtfimper = craptrd.dtfimper

                         craprda.inaniver = 1

                         aux_vlsdrdca = truncate(aux_vlsdrdca,2)
                         aux_ajtirrgt = truncate(aux_ajtirrgt,2).
                  
                  IF   aux_ajtirrgt > aux_vlsdrdca   and 
                       aux_ajtirrgt <> 0             and
                       craprda.tpaplica = 3          THEN
                       DO:
                           UNIX SILENT VALUE("echo " + 
                               STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                               STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               "Conta = " + 
                               STRING(craprda.nrdconta,"zzzz,zzz,9") +
                               " Aplicacao = " +
                               STRING(craprda.nraplica,"z,zzz,zz9") +
                               " aux_vlsdrdca = " +
                               STRING(aux_vlsdrdca,"zzz,zzz,zz9.99-") +
                               " aux_ajtirrgt = " +
                               STRING(aux_ajtirrgt,"zzz,zzz,zz9.99-") +
                               " >> log/crps104.log").
                               
                           IF   aux_vlsdrdca > 0   THEN
                                aux_ajtirrgt = aux_vlsdrdca.
                           ELSE
                                aux_ajtirrgt = 0.
                       END.   

                  if   aux_vlsdrdca <> aux_ajtirrgt   THEN
                       DO:
                           if  aux_vlsdrdca - aux_ajtirrgt = 0.01   THEN 
                               ASSIGN aux_ajtirrgt = aux_ajtirrgt + 0.01
                                      aux_vlajtsld = 0.01.
                       END.

                  ASSIGN craprda.vlsdrdca = aux_vlsdrdca - aux_ajtirrgt
                  
                         craprda.insaqtot = IF TRUNCATE(aux_vlsdrdca -
                                               aux_ajtirrgt,2) = 0 OR
                                               aux_flgncalc
                                               THEN 1
                                               ELSE craprda.insaqtot

                         craprda.dtsaqtot = IF aux_vlsdrdca = 0
                                               THEN glb_dtmvtolt
                                               ELSE craprda.dtsaqtot

                         craprda.dtcalcul = IF craprda.insaqtot = 1
                                               THEN glb_dtmvtolt
                                               ELSE aux_dtcalcul

                         aux_dtdolote = glb_dtmvtolt
                         aux_nrdolote = 8381
                         aux_cdhistor = 116
                         aux_flglanca = TRUE.

                  IF   craprda.insaqtot = 1   THEN /* SAQUE TOTAL */
                       ASSIGN craprda.vlsdextr = 0.
                              
                  IF   craprda.vlabcpmf > 0   THEN
                       ASSIGN craprda.vlabonrd = craprda.vlabonrd + 
                                                         craprda.vlabcpmf.
                                           
                  IF   MONTH(craprda.dtfimper) = MONTH(glb_dtmvtolt)   THEN
                       craprda.incalmes = 0.
              END.
         ELSE
              DO:
                  glb_cdcritic = 145.
                  RUN fontes/critic.p.
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                    glb_cdprogra + "' --> '" + glb_dscritic +
                                    " para esta " +
                                    "rotina: includes/aplicacao.i " +
                                    " >> log/proc_batch.log").
                  UNDO TRANS_1, RETURN.
              END.

         IF   glb_cdprogra = "crps103"   THEN
              aux_vlrentot = aux_vlrentot - aux_vlprovis.

         IF   aux_vlrentot > 0   AND
              aux_flglanca       THEN
              DO:
                  DO WHILE TRUE:

                     FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                                        craplot.dtmvtolt = aux_dtdolote  AND
                                        craplot.cdagenci = aux_cdagenci  AND
                                        craplot.cdbccxlt = aux_cdbccxlt  AND
                                        craplot.nrdolote = aux_nrdolote
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
                                   ASSIGN craplot.dtmvtolt = aux_dtdolote
                                          craplot.cdagenci = aux_cdagenci
                                          craplot.cdbccxlt = aux_cdbccxlt
                                          craplot.nrdolote = aux_nrdolote
                                          craplot.tplotmov = 10
                                          craplot.cdcooper = glb_cdcooper.
                               END.

                     LEAVE.

                  END.  /*  Fim do DO WHILE TRUE  */

                  CREATE craplap.
                  ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                         craplap.cdagenci = craplot.cdagenci
                         craplap.cdbccxlt = craplot.cdbccxlt
                         craplap.cdoperad = "1"
                         craplap.nrdolote = craplot.nrdolote
                         craplap.nrdconta = craprda.nrdconta
                         craplap.nraplica = craprda.nraplica
                         craplap.nrdocmto = craplot.nrseqdig + 1
                         craplap.txaplica = (aux_txaplica * 100)
                         craplap.txaplmes = aux_txaplmes
                         craplap.cdhistor = aux_cdhistor
                         craplap.nrseqdig = craplot.nrseqdig + 1
                         craplap.vllanmto = aux_vlrentot
                         craplap.dtrefere = aux_dtrefere
                         craplap.vlrenacu = 
                                   TRUNCATE(aux_vlrenacu + aux_vlrentot -
                                            aux_renrgper - aux_ttrenrgt,2)
                         craplap.vlslajir = 
                                   TRUNCATE(aux_vlslajir + aux_vlrentot -
                                            aux_vlrgtper - aux_ttajtlct -  
                         (TRUNCATE((aux_vlabcpmf * aux_perirtab[1] / 100),2)) -
                         (TRUNCATE((aux_vlrentot * aux_perirtab[4] /           
                                                   100),2)),2) - aux_ajtirrgt
                         craplap.cdcooper = glb_cdcooper

                         craplot.vlinfocr = craplot.vlinfocr + craplap.vllanmto
                         craplot.vlcompcr = craplot.vlcompcr + craplap.vllanmto
                         craplot.qtinfoln = craplot.qtinfoln + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.nrseqdig = craplot.nrseqdig + 1.
              
                  IF   craplap.vlrenacu < 0 THEN
                       craplap.vlrenacu = 0.
                  IF   aux_cdhistor = 116   AND
                       TRUNCATE((aux_vlrentot * aux_perirtab[4] / 100),2) > 0 
                       THEN DO:
                           CREATE craplap.
                           ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                                  craplap.cdagenci = craplot.cdagenci
                                  craplap.cdbccxlt = craplot.cdbccxlt
                                  craplap.cdoperad = "1"
                                  craplap.nrdolote = craplot.nrdolote
                                  craplap.nrdconta = craprda.nrdconta
                                  craplap.nraplica = craprda.nraplica
                                  craplap.nrdocmto = craplot.nrseqdig + 1
                                  craplap.txaplica = aux_perirtab[4]
                                  craplap.txaplmes = aux_perirtab[4]
                                  craplap.cdhistor = 861
                                  craplap.nrseqdig = craplot.nrseqdig + 1
                                  craplap.vllanmto = 
                          TRUNCATE((aux_vlrentot * aux_perirtab[4] / 100),2)
                                  craplap.dtrefere = aux_dtrefere
                                  craplap.cdcooper = glb_cdcooper

                                  craplot.vlinfocr =
                                          craplot.vlinfocr + craplap.vllanmto
                                  craplot.vlcompcr = 
                                          craplot.vlcompcr + craplap.vllanmto
                                  craplot.qtinfoln = craplot.qtinfoln + 1
                                  craplot.qtcompln = craplot.qtcompln + 1
                                  craplot.nrseqdig = craplot.nrseqdig + 1.
                       END.

              END.

         IF   glb_cdprogra = "crps104"   THEN
              DO:
                  /* Abono do Cpmf agora e na aplicacao no dia aniver */
                  IF   craprda.vlabcpmf > 0   THEN
                       DO: 
                           DO WHILE TRUE:

                              FIND craplot WHERE
                                   craplot.cdcooper = glb_cdcooper  AND
                                   craplot.dtmvtolt = aux_dtdolote  AND
                                   craplot.cdagenci = aux_cdagenci  AND
                                   craplot.cdbccxlt = aux_cdbccxlt  AND
                                   craplot.nrdolote = aux_nrdolote
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
                                            ASSIGN craplot.dtmvtolt =
                                                           aux_dtdolote
                                                   craplot.cdagenci = 
                                                           aux_cdagenci
                                                   craplot.cdbccxlt = 
                                                           aux_cdbccxlt
                                                   craplot.nrdolote = 
                                                           aux_nrdolote
                                                   craplot.tplotmov = 10
                                                   craplot.cdcooper =
                                                           glb_cdcooper.
                                        END.

                                   LEAVE.

                           END.  /*  Fim do DO WHILE TRUE  */

                           CREATE craplap.
                           ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                                  craplap.cdagenci = craplot.cdagenci
                                  craplap.cdbccxlt = craplot.cdbccxlt
                                  craplap.cdoperad = "1"
                                  craplap.nrdolote = craplot.nrdolote
                                  craplap.nrdconta = craprda.nrdconta
                                  craplap.nraplica = craprda.nraplica
                                  craplap.nrdocmto = craplot.nrseqdig + 1
                                  craplap.txaplica = 0
                                  craplap.txaplmes = 0
                                  craplap.cdhistor = 866
                                  craplap.nrseqdig = craplot.nrseqdig + 1
                                  craplap.vllanmto = craprda.vlabcpmf
                                  craplap.dtrefere = aux_dtrefere
                                  craplap.cdcooper = glb_cdcooper

                                  craplot.vlinfocr = craplot.vlinfocr +
                                                             craplap.vllanmto
                                  craplot.vlcompcr = craplot.vlcompcr +
                                                             craplap.vllanmto
                                  craplot.qtinfoln = craplot.qtinfoln + 1
                                  craplot.qtcompln = craplot.qtcompln + 1
                                  craplot.nrseqdig = craplot.nrseqdig + 1.
                          
                           /*** Ir sobre o abono ***/
                           IF   TRUNCATE((craprda.vlabcpmf * 
                                         aux_perirtab[1] / 100),2) > 0    THEN
                                DO:
                           
                                    CREATE craplap.
                                    ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                                           craplap.cdagenci = craplot.cdagenci
                                           craplap.cdbccxlt = craplot.cdbccxlt
                                           craplap.cdoperad = "1"
                                           craplap.nrdolote = craplot.nrdolote
                                           craplap.nrdconta = craprda.nrdconta
                                           craplap.nraplica = craprda.nraplica
                                           craplap.nrdocmto =
                                                   craplot.nrseqdig + 1
                                           craplap.txaplica = aux_perirtab[1]
                                           craplap.txaplmes = aux_perirtab[1]
                                           craplap.cdhistor = 868
                                           craplap.nrseqdig = 
                                                   craplot.nrseqdig + 1
                                           craplap.vllanmto = 
                                                   TRUNCATE((craprda.vlabcpmf * 
                                                   aux_perirtab[1] / 100),2)
                                           craplap.dtrefere = aux_dtrefere
                                           craplap.cdcooper = glb_cdcooper
                                         
                                           craplot.vlinfocr = craplot.vlinfocr 
                                                            + craplap.vllanmto
                                           craplot.vlcompcr = craplot.vlcompcr 
                                                            + craplap.vllanmto
                                           craplot.qtinfoln = 
                                                   craplot.qtinfoln + 1
                                           craplot.qtcompln = 
                                                   craplot.qtcompln + 1
                                           craplot.nrseqdig = 
                                                   craplot.nrseqdig + 1.
                                END.

                           ASSIGN craprda.vlabcpmf = 0. 
                       END.
                  
                  /* Ajuste IRRF sobre resgates */
                  IF   aux_ajtirrgt > 0   THEN 
                       DO:
                           DO WHILE TRUE:
     
                              FIND craplot WHERE
                                   craplot.cdcooper = glb_cdcooper  AND
                                   craplot.dtmvtolt = aux_dtdolote  AND
                                   craplot.cdagenci = aux_cdagenci  AND
                                   craplot.cdbccxlt = aux_cdbccxlt  AND
                                   craplot.nrdolote = aux_nrdolote
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
                                            ASSIGN craplot.dtmvtolt =
                                                           aux_dtdolote
                                                   craplot.cdagenci = 
                                                           aux_cdagenci
                                                   craplot.cdbccxlt = 
                                                           aux_cdbccxlt
                                                   craplot.nrdolote = 
                                                           aux_nrdolote
                                                   craplot.tplotmov = 10
                                                   craplot.cdcooper =          
                                                           glb_cdcooper.
                                        END.

                                   LEAVE.

                           END.  /*  Fim do DO WHILE TRUE  */

                           aux_vlsdrdat = aux_vlsdrdca.
                           
                           FOR EACH crablap5 WHERE
                                   (crablap5.cdcooper  = glb_cdcooper       AND
                                    crablap5.nrdconta  = craprda.nrdconta   AND
                                    crablap5.nraplica  = craprda.nraplica   AND
                                    crablap5.dtrefere  = aux_dtrefere       AND
                                    crablap5.cdhistor  = 118                AND
                                    crablap5.dtmvtolt >= aux_dtcalajt       AND
                                    crablap5.dtmvtolt <= aux_dtmvtolt)      OR
                                    
                                   (crablap5.cdcooper  = glb_cdcooper       AND
                                    crablap5.nrdconta  = craprda.nrdconta   AND
                                    crablap5.nraplica  = craprda.nraplica   AND
                                    crablap5.dtrefere  = aux_dtrefere       AND
                                    crablap5.cdhistor  = 492                AND
                                    crablap5.dtmvtolt >= aux_dtcalajt       AND
                                    crablap5.dtmvtolt <= aux_dtmvtolt)      
                                    
                                    NO-LOCK BREAK BY crablap5.dtmvtolt:
                                    
                                 IF   LAST(crablap5.dtmvtolt) AND
                                      aux_ttpercrg >= 99.9      THEN
                                      ASSIGN aux_vlrenrgt = 
                                                 crablap5.rendatdt -
                                                 aux_trergtaj.
                                 ELSE                
                                      ASSIGN aux_vlrenrgt = 
                                             crablap5.vllanmto * 
                                        crablap5.rendatdt / crablap5.vlslajir
                                             aux_trergtaj = aux_trergtaj +
                                                            aux_vlrenrgt.
                                                   
                                 ASSIGN aux_ajtirrgt =
                                    TRUNCATE((aux_vlrenrgt * 
                                                  crablap5.aliaplaj / 100),2) -
                                    TRUNCATE((aux_vlrenrgt *
                                                  aux_perirtab[4] / 100),2).

                               aux_ajtirrgt = TRUNCATE(aux_ajtirrgt,2).
                               
                               IF   LAST(crablap5.dtmvtolt)   AND
                                    aux_vlajtsld <> 0   THEN
                                    ASSIGN aux_ajtirrgt = aux_ajtirrgt +
                                                          aux_vlajtsld.
                                    
                               IF   aux_ajtirrgt > 0   THEN
                                    DO:
                                        IF  aux_ajtirrgt > aux_vlsdrdat  AND
                                            aux_vlsdrdat > 0             THEN
                                            do:
                                                
                           UNIX SILENT VALUE("echo " + 
                               STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                               STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               "Conta = " + 
                               STRING(craprda.nrdconta,"zzzz,zzz,9") +
                               " Aplicacao = " +
                               STRING(craprda.nraplica,"z,zzz,zz9") +
                               " aux_vlsdrdat = " +
                               STRING(aux_vlsdrdat,"zzz,zzz,zz9.99-") +
                               " aux_ajtirrgt = " +
                               STRING(aux_ajtirrgt,"zzz,zzz,zz9.99-") +
                               " >> log/crps104b.log").
                                                   
                                                aux_ajtirrgt = aux_vlsdrdat.
                                            end.
                                       
                                    if  aux_vlsdrdat <= 0   THEN
                                        aux_ajtirrgt = 0.
                                    
                                    IF  aux_ajtirrgt > 0  THEN
                                        DO:
                                        CREATE craplap.
                                        ASSIGN 
                                           craplap.dtmvtolt = craplot.dtmvtolt
                                           craplap.cdagenci = craplot.cdagenci
                                           craplap.cdbccxlt = craplot.cdbccxlt
                                           craplap.cdoperad = "1"
                                           craplap.nrdolote = craplot.nrdolote
                                           craplap.nrdconta = craprda.nrdconta
                                           craplap.nraplica = craprda.nraplica
                                           craplap.nrdocmto = 
                                                   craplot.nrseqdig + 1
                                           craplap.txaplica = crablap5.aliaplaj
                                           craplap.txaplmes = crablap5.aliaplaj
                                           craplap.cdhistor = 877
                                           craplap.nrseqdig = 
                                                   craplot.nrseqdig + 1
                                           craplap.vllanmto = aux_ajtirrgt
                                           craplap.dtrefere = aux_dtrefere
                                           craplap.vlslajir = crablap5.vlslajir
                                           craplap.vlrenacu = crablap5.vlrenacu
                                           craplap.pcajsren = crablap5.pcajsren 
                                           craplap.vlrenreg = 
                                                   TRUNCATE(aux_vlrenrgt,2) 
                                           craplap.vldajtir = 
                                                   TRUNCATE(aux_ajtirrgt,2)
                                           craplap.aliaplaj = crablap5.aliaplaj
                                           craplap.qtdmesaj = crablap5.qtdmesaj
                                           craplap.qtddiaaj = crablap5.qtddiaaj
                                           craplap.rendatdt = crablap5.rendatdt
                                           craplap.cdcooper = glb_cdcooper

                                           craplot.vlinfocr = craplot.vlinfocr 
                                                   + craplap.vllanmto
                                           craplot.vlcompcr = craplot.vlcompcr
                                                   + craplap.vllanmto
                                           craplot.qtinfoln =
                                                   craplot.qtinfoln + 1
                                           craplot.qtcompln =
                                                   craplot.qtcompln + 1
                                           craplot.nrseqdig = 
                                                   craplot.nrseqdig + 1
                                                   
                                           aux_vlsdrdat = aux_vlsdrdat -
                                                              craplap.vllanmto.
                                        END.
                                    END.
                           END.
                       END.
              END.

         IF   glb_cdprogra = "crps104"           AND
              aux_cdhistor = 116                 AND
             (aux_vlrentot - aux_vlprovis) > 0   THEN
              DO:
                  DO WHILE TRUE:

                     FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                                        craplot.dtmvtolt = aux_dtdolote  AND
                                        craplot.cdagenci = aux_cdagenci  AND
                                        craplot.cdbccxlt = aux_cdbccxlt  AND
                                        craplot.nrdolote = aux_nrdolote
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
                                   ASSIGN craplot.dtmvtolt = aux_dtdolote
                                          craplot.cdagenci = aux_cdagenci
                                          craplot.cdbccxlt = aux_cdbccxlt
                                          craplot.nrdolote = aux_nrdolote
                                          craplot.tplotmov = 10
                                          craplot.cdcooper = glb_cdcooper.
                               END.

                     LEAVE.

                  END.  /*  Fim do DO WHILE TRUE  */

                  CREATE craplap.
                  ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                         craplap.cdagenci = craplot.cdagenci
                         craplap.cdbccxlt = craplot.cdbccxlt
                         craplap.cdoperad = "1"
                         craplap.nrdolote = craplot.nrdolote
                         craplap.nrdconta = craprda.nrdconta
                         craplap.nraplica = craprda.nraplica
                         craplap.nrdocmto = craplot.nrseqdig + 1
                         craplap.txaplica = (aux_txaplica * 100)
                         craplap.txaplmes = aux_txaplmes
                         craplap.cdhistor = 117
                         craplap.nrseqdig = craplot.nrseqdig + 1
                         craplap.vllanmto = aux_vlrentot - aux_vlprovis
                         craplap.dtrefere = aux_dtrefere
                         craplap.cdcooper = glb_cdcooper

                         craplot.vlinfocr = craplot.vlinfocr + craplap.vllanmto
                         craplot.vlcompcr = craplot.vlcompcr + craplap.vllanmto
                         craplot.qtinfoln = craplot.qtinfoln + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.nrseqdig = craplot.nrseqdig + 1.
              END.

         IF   CAN-DO("crps103,crps104",glb_cdprogra)   THEN
              DO:
                  aux_vlajuste = aux_vlprovis - aux_vllan117.

                  IF   aux_vlajuste <> 0   THEN
                       DO:
                           DO WHILE TRUE:

                              FIND craplot WHERE
                                   craplot.cdcooper = glb_cdcooper   AND
                                   craplot.dtmvtolt = aux_dtdolote   AND
                                   craplot.cdagenci = aux_cdagenci   AND
                                   craplot.cdbccxlt = aux_cdbccxlt   AND
                                   craplot.nrdolote = 8381
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
                                                craplot.dtmvtolt = aux_dtdolote
                                                craplot.cdagenci = aux_cdagenci
                                                craplot.cdbccxlt = aux_cdbccxlt
                                                craplot.nrdolote = 8381
                                                craplot.tplotmov = 10
                                                craplot.cdcooper = glb_cdcooper.
                                        END.

                              LEAVE.

                           END.  /*  Fim do DO WHILE TRUE  */

                           CREATE craplap.
                           ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                                  craplap.cdagenci = craplot.cdagenci
                                  craplap.cdbccxlt = craplot.cdbccxlt
                                  craplap.cdoperad = "1"
                                  craplap.nrdolote = craplot.nrdolote
                                  craplap.nrdconta = craprda.nrdconta
                                  craplap.nraplica = craprda.nraplica
                                  craplap.nrdocmto = craplot.nrseqdig + 1
                                  craplap.txaplica = (aux_txaplica * 100)
                                  craplap.txaplmes = aux_txaplmes
                                  craplap.cdhistor = IF aux_vlajuste > 0
                                                        THEN 124
                                                        ELSE 125
                                  craplap.nrseqdig = craplot.nrseqdig + 1
                                  craplap.vllanmto = IF aux_vlajuste > 0
                                                        THEN aux_vlajuste
                                                        ELSE aux_vlajuste * -1

                                  craplap.dtrefere = aux_dtrefere
                                  craplap.cdcooper = glb_cdcooper.

                           IF   aux_vlajuste > 0   THEN
                                ASSIGN craplot.vlinfocr = craplot.vlinfocr +
                                                          craplap.vllanmto
                                       craplot.vlcompcr = craplot.vlcompcr +
                                                          craplap.vllanmto.
                           ELSE
                                ASSIGN craplot.vlinfodb = craplot.vlinfodb +
                                                          craplap.vllanmto
                                       craplot.vlcompdb = craplot.vlcompdb +
                                                          craplap.vllanmto.

                           ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
                                  craplot.qtcompln = craplot.qtcompln + 1
                                  craplot.nrseqdig = craplot.nrseqdig + 1.
                       END.

              END.

         IF   aux_vldperda <> 0   AND   glb_cdprogra = "crps104"   THEN
              DO:
                  DO WHILE TRUE:

                     FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                        craplot.dtmvtolt = aux_dtdolote   AND
                                        craplot.cdagenci = aux_cdagenci   AND
                                        craplot.cdbccxlt = aux_cdbccxlt   AND
                                        craplot.nrdolote = 8391
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
                                   ASSIGN craplot.dtmvtolt = aux_dtdolote
                                          craplot.cdagenci = aux_cdagenci
                                          craplot.cdbccxlt = aux_cdbccxlt
                                          craplot.nrdolote = 8391
                                          craplot.tplotmov = 10
                                          craplot.cdcooper = glb_cdcooper.
                               END.

                     LEAVE.

                  END.  /*  Fim do DO WHILE TRUE  */

                  CREATE craplap.
                  ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                         craplap.cdagenci = craplot.cdagenci
                         craplap.cdbccxlt = craplot.cdbccxlt
                         craplap.cdoperad = "1"
                         craplap.nrdolote = craplot.nrdolote     
                         craplap.nrdconta = craprda.nrdconta
                         craplap.nraplica = craprda.nraplica
                         craplap.nrdocmto = craplot.nrseqdig + 1
                         craplap.txaplica = (aux_txaplica * 100)
                         craplap.txaplmes = aux_txaplmes
                         craplap.cdhistor = IF aux_vldperda > 0
                                               THEN 119
                                               ELSE 121
                         craplap.nrseqdig = craplot.nrseqdig + 1
                         craplap.vllanmto = IF aux_vldperda > 0
                                               THEN aux_vldperda
                                               ELSE aux_vldperda * -1

                         craplap.dtrefere = aux_dtrefere
                         craplap.cdcooper = glb_cdcooper.

                  IF   aux_vldperda > 0   THEN
                       ASSIGN craplot.vlinfocr = craplot.vlinfocr +
                                                         craplap.vllanmto
                              craplot.vlcompcr = craplot.vlcompcr +
                                                         craplap.vllanmto.
                  ELSE
                       ASSIGN craplot.vlinfodb = craplot.vlinfodb +
                                                         craplap.vllanmto
                              craplot.vlcompdb = craplot.vlcompdb +
                                                         craplap.vllanmto.

                  ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.nrseqdig = craplot.nrseqdig + 1.
              END.
     END.

IF   glb_cdprogra = "crps117" OR
     glb_cdprogra = "crps177" THEN
     DO:
         IF   craprda.vlsdrdca <= 1 AND
              aux_sldpresg      = 0 THEN
              DO:
                  FIND LAST craplap WHERE
                            craplap.cdcooper  = craprda.cdcooper   AND
                            craplap.nrdconta  = craprda.nrdconta   AND
                            craplap.nraplica  = craprda.nraplica
                            NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craplap THEN
                       aux_sldpresg = craprda.vlsdrdca.
                  ELSE
                       DO:
                           IF   YEAR(craplap.dtmvtolt) <
                                YEAR(glb_dtmvtolt) THEN
                                aux_sldpresg = craprda.vlsdrdca.
                       END.
              END.
     END.

/* .......................................................................... */

