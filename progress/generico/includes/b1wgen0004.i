/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
                             ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
+--------------------------------------+--------------------------------------+
| Rotina Progress                      | Rotina Oracle PLSQL                  |
+--------------------------------------+--------------------------------------+
|sistema/generico/includes/b1wgen0004.i| APLI0001.pc_consul_saldo_aplic_rdca30|
+--------------------------------------+--------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
    
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/






/* .............................................................................

   Programa: b1wgen0004.i                  
   Autora  : Junior.
   Data    : 24/10/2005                     Ultima atualizacao: 10/12/2013

   Dados referentes ao programa:

   Objetivo  : INCLUDE CONSULTA SALDO APLICACAO RDCA30

   Alteracoes: 19/05/2006 - Incluido codigo da cooperativa nas leituras das
                            tabelas (Diego).

               03/10/2007 - Igualar include b1wgen0004.i com a include
                            aplicacao.i (David/Evandro).

               30/01/2009 - Incluir programas crps175 e 176 na lista para 
                            calculo do saldo (David).
                            
               04/11/2009 - Incluir parametros de saida para procedure
                            saldo-rdca-resgate (David).
               
               22/04/2010 - Incluido programa crps563 para calculo do 
                            saldo (Elton).
                            
               30/08/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            no destino dos arquivos de log (Elton).

               28/09/2010 - Melhorar critica 145 (Magui).
               
               18/06/2012 - Incluir tratamento para resgate de RDCA menor que
                            R$ 1,00 (Ze).
                            
               25/10/2013 - Incluir IMPRES nas condicoes de programas (David).
               
               10/12/2013 - Incluir VALIDATE na craplot, craplap (Lucas R.)
               
............................................................................ */
       
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
       aux_dtultdia = crapdat.dtmvtolt - DAY(crapdat.dtmvtolt)
       aux_flglanca = FALSE.

IF   crapdat.inproces > 2            AND                  /*  No BATCH  */
     NOT CAN-DO("crps011,crps109,crps110,crps113,crps128,crps175,crps176," +
                "crps168,crps140,crps169,crps210,crps323," +
                "crps349,crps414,crps445,crps563,crps029,atenda,anota,impres," + 
                "InternetBank",p-cdprogra)  
     THEN
     DO WHILE TRUE :

        FIND craptrd WHERE craptrd.dtiniper = craprda.dtiniper AND
                           craptrd.tptaxrda = 1                AND
                           craptrd.incarenc = 0                AND
                           craptrd.vlfaixas = 0                AND
                           craptrd.cdcooper = p-cdcooper
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
        IF   NOT AVAILABLE craptrd   THEN
             IF   LOCKED craptrd   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO: 
                      ASSIGN i-cod-erro = 347
                             c-dsc-erro = " ".
                   
                      {sistema/generico/includes/b1wgen0001.i}

                      UNDO, RETURN "NOK".
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
                 ASSIGN i-cod-erro = 427
                        c-dsc-erro = " ".
       
                 {sistema/generico/includes/b1wgen0001.i}

                 UNDO, RETURN "NOK".
             END.

        ASSIGN craptrd.incalcul = 1.
    
        IF   p-cdprogra = "crps103"   THEN     /*  MENSAL  */
             aux_dtmvtolt = crapdat.dtmvtolt + 1.
        ELSE
        IF   p-cdprogra = "crps104"   THEN     /*  ANIVERSARIO  */
             DO:
                 ASSIGN craptrd.incalcul = 2
                        aux_dtmvtolt     = craprda.dtfimper.
          
                 DO WHILE TRUE:

                    IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt)))    OR
                         CAN-FIND(crapfer WHERE
                                  crapfer.dtferiad = aux_dtmvtolt AND
                                  crapfer.cdcooper = p-cdcooper)   THEN
                         DO:
                             aux_dtmvtolt = aux_dtmvtolt + 1.
                             NEXT.
                         END.

                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */
             END.
        ELSE
        IF   p-cdprogra = "crps105"   THEN
             aux_dtmvtolt = crapdat.dtmvtopr.       /*  RESGATE  */
        ELSE
        IF   p-cdprogra = "crps117" OR       /* RESGATE PARA O DIA */
             p-cdprogra = "crps135" OR       /*  UNIFICACAO */
             p-cdprogra = "crps431" THEN   
             aux_dtmvtolt = crapdat.dtmvtolt.
        ELSE
             DO:
                 ASSIGN i-cod-erro = 145 
                        c-dsc-erro = "batch parte taxas-b1wgen0004.i-" +
                                     p-cdprogra.
       
                 {sistema/generico/includes/b1wgen0001.i}

                 UNDO, RETURN "NOK".                 
             END.

        LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */
ELSE       /*  No ON-LINE  */
     DO:
         FIND craptrd WHERE craptrd.dtiniper = craprda.dtiniper AND
                            craptrd.tptaxrda = 1                AND
                            craptrd.incarenc = 0                AND
                            craptrd.vlfaixas = 0                AND
                            craptrd.cdcooper = p-cdcooper
                            NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craptrd   THEN
              DO:
                  ASSIGN i-cod-erro = 347 
                         c-dsc-erro = " ".
       
                 {sistema/generico/includes/b1wgen0001.i}

                 UNDO, RETURN "NOK".                  
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
                  ASSIGN i-cod-erro = 427 
                         c-dsc-erro = " ".
       
                  {sistema/generico/includes/b1wgen0001.i}
     
                  UNDO, RETURN "NOK".                  
              END.

         IF   p-cdprogra = "crps110"   THEN
              aux_dtmvtolt = craprda.dtfimper.
         ELSE
              IF   p-cdprogra = "crps210"   THEN
                   aux_dtmvtolt = crapdat.dtmvtopr.
              ELSE
                   IF   p-cdprogra = "crps117"  OR /* Resgate para o Dia*/
                        p-cdprogra = "crps431" THEN /* nao roda on_line */
                        aux_dtmvtolt = crapdat.dtmvtolt.
                   ELSE     
                        aux_dtmvtolt = crapdat.dtmvtolt + 1.  
                       /* Calculo ate o dia do mvto */
     END.

/* Leitura dos lancamentos de resgate da aplicacao

   OBS.: Para melhoria de performance, o FOR EACH foi feito com cada clausula
         separada para conter somente igualdades de acordo com o indice
         craplap6 e nao deve ter o USE-INDEX pois o PROGRESS fara varredura na
         tabela inteira caso o indice seja forcado */

FOR EACH craplap WHERE (craplap.cdcooper  = p-cdcooper         AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 117                AND
                        craplap.dtmvtolt >= aux_dtcalcul       AND
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR

                       (craplap.cdcooper  = p-cdcooper         AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 118                AND
                        craplap.dtmvtolt >= aux_dtcalcul       AND
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR

                       (craplap.cdcooper  = p-cdcooper         AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 124                AND
                        craplap.dtmvtolt >= aux_dtcalcul       AND
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR
                        
                       (craplap.cdcooper  = p-cdcooper         AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 125                AND
                        craplap.dtmvtolt >= aux_dtcalcul       AND
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR

                       (craplap.cdcooper  = p-cdcooper         AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 143                AND
                        craplap.dtmvtolt >= aux_dtcalcul       AND
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR
                        
                       (craplap.cdcooper  = p-cdcooper         AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 492                AND
                        craplap.dtmvtolt >= aux_dtcalcul       AND
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR

                       (craplap.cdcooper  = p-cdcooper         AND
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
            CAN-FIND(crapfer WHERE crapfer.dtferiad = aux_dtcalcul AND
                                   crapfer.cdcooper = p-cdcooper)   THEN
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
             IF   p-cdprogra = "crps103"   THEN
                  .
             ELSE     
             IF   (p-cdprogra = "crps104" OR crapdat.inproces < 3)   THEN
                  ASSIGN aux_vldperda = aux_vldperda + (aux_vlsdrdca * -1)
                         aux_vlsdrdca = 0.
         END.
        
END.  /*  Fim do FOR EACH -- Leitura dos lancamentos da aplicacao  */

/*** Magui pegar os ajustes de IR devidos ***/
FOR EACH craplap WHERE (craplap.cdcooper  = p-cdcooper         AND
                        craplap.nrdconta  = craprda.nrdconta   AND
                        craplap.nraplica  = craprda.nraplica   AND
                        craplap.dtrefere  = aux_dtrefere       AND
                        craplap.cdhistor  = 118                AND
                        craplap.dtmvtolt >= craprda.dtiniper   AND
                        craplap.dtmvtolt <= aux_dtmvtolt)            OR

                       (craplap.cdcooper  = p-cdcooper         AND
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
       dup_dtmvtolt = IF p-cdprogra = "crps105" THEN crapdat.dtmvtopr
                      ELSE crapdat.dtmvtolt
       dup_vlsdrdca = aux_vlsdrdca
       dup_vlrentot = aux_vlrentot
       aux_sldcaren = aux_vlsdrdca.

/* fim */

IF   NOT aux_flgncalc              AND
     aux_dtcalcul < aux_dtmvtolt   AND
     aux_vlsdrdca > 0              THEN
     DO WHILE aux_dtcalcul < aux_dtmvtolt:

        IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtcalcul)))               OR
             CAN-FIND(crapfer WHERE crapfer.dtferiad = aux_dtcalcul  AND
                                    crapfer.cdcooper = p-cdcooper)   THEN
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
             CAN-FIND(crapfer WHERE crapfer.dtferiad = dup_dtcalcul  AND
                                    crapfer.cdcooper = p-cdcooper)   THEN
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

IF   crapdat.inproces = 1                  AND
     craprda.inaniver = 0                  AND
     craprda.dtmvtolt = craprda.dtiniper   AND
     craprda.dtfimper > crapdat.dtmvtolt   THEN
     ASSIGN aux_sldpresg = aux_sldcaren.
ELSE           
     DO:        
        /*** Calcular saldo para resgate enxergando as novas faixas de 
             percentual de imposto de renda e o ajuste necessario      ***/

        ASSIGN aux_nrctaapl = craprda.nrdconta
               aux_nraplres = craprda.nraplica
               aux_vlsldapl = dup_vlsdrdca
               aux_vlrenper = dup_vlrentot
               aux_sldpresg = 0
               aux_dtregapl = crapdat.dtmvtolt.
                 
        RUN sistema/generico/procedures/b1wgen0005.p PERSISTENT SET h-b1wgen05.
                 
        RUN saldo-rdca-resgate IN h-b1wgen05 (INPUT crapcop.cdcooper,       
                                              INPUT 1,       
                                              INPUT 999,       
                                              INPUT "996",       
                                              INPUT 3,       
                                              INPUT "InternetBank",       
                                              INPUT aux_nrctaapl,       
                                              INPUT aux_dtregapl,       
                                              INPUT aux_nraplres,       
                                              INPUT aux_vlsldapl,       
                                              INPUT aux_vlrenper,       
                                             OUTPUT aux_pcajsren,       
                                             OUTPUT aux_vlrenreg, 
                                             OUTPUT aux_vldajtir, 
                                             OUTPUT aux_sldrgttt, 
                                             OUTPUT aux_vlslajir, 
                                             OUTPUT aux_vlrenacu, 
                                             OUTPUT aux_nrmeses,       
                                             OUTPUT aux_nrdias,       
                                             OUTPUT aux_dtiniapl,       
                                             OUTPUT aux_cdhisren,       
                                             OUTPUT aux_cdhisajt,       
                                             OUTPUT aux_perirapl,
                                             INPUT-OUTPUT aux_sldpresg, 
                                             OUTPUT TABLE tt-erro).
                    
        DELETE PROCEDURE h-b1wgen05.
         
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FOR EACH tt-erro NO-LOCK.
                            
                    ASSIGN aux_dsmsgerr = "<dsmsgerr>" +
                                          TRIM(tt-erro.dscritic) +
                                          "</dsmsgerr>".
                END.
                 
                {&out} aux_dsmsgerr.
                 
                LEAVE.
            END.
     END.      

IF   p-cdprogra <> "crps103"   THEN
     DO:
         ASSIGN aux_vlsdrdca = aux_vlsdrdca -
                    TRUNCATE((aux_vlrentot * aux_perirtab[4] / 100),2)
                dup_vlsdrdca = dup_vlsdrdca -
                    TRUNCATE((dup_vlrentot * aux_perirtab[4] / 100),2).
         IF   craprda.dtfimper <= crapdat.dtmvtolt   THEN
              ASSIGN aux_vlsdrdca = aux_vlsdrdca -
                         TRUNCATE((aux_vlabcpmf * aux_perirtab[1] / 100),2)
                     dup_vlsdrdca = dup_vlsdrdca -
                         TRUNCATE((aux_vlabcpmf * aux_perirtab[1] / 100),2).
     END.
IF   crapdat.inproces > 2                                                   AND
     NOT CAN-DO("crps011,crps105,crps109,crps110,crps113,crps117,crps128," +
     "crps175,crps176,crps168,crps135,crps431,crps140,crps169,crps210," +
     "crps323,crps349,crps414,crps445,crps563,crps029,atenda,anota,impres," + 
     "InternetBank",p-cdprogra)   THEN
     DO:     
         IF   p-cdprogra = "crps103"   THEN                     /*  MENSAL  */
              ASSIGN aux_dtdolote = crapdat.dtmvtolt
                     aux_nrdolote = 8380
                     aux_cdhistor = 117
                     aux_flglanca = TRUE

                     craprda.incalmes = 0.
         ELSE
         IF   p-cdprogra = "crps104"   THEN                /*  ANIVERSARIO  */
              DO:
                  FIND craptrd WHERE craptrd.cdcooper = p-cdcooper        AND
                                     craptrd.dtiniper = craprda.dtfimper  AND
                                     craptrd.tptaxrda = 1                 AND
                                     craptrd.incarenc = 0                 AND
                                     craptrd.vlfaixas = 0
                                     NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craptrd   THEN
                       DO:
                           ASSIGN i-cod-erro = 347 
                                  c-dsc-erro = " ".       
       
                           {sistema/generico/includes/b1wgen0001.i}

                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + p-cdprogra + "' --> '" +
                                             STRING(i-cod-erro,"999") + " " +
                                       STRING(craprda.dtfimper,"99/99/9999") +
                                    " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                    "/log/proc_batch.log").

                           UNDO, RETURN "NOK".
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
                               STRING(crapdat.dtmvtolt,"99/99/9999") + " - " +
                               STRING(TIME,"HH:MM:SS") +
                               " - " + p-cdprogra + "' --> '" +
                               "Conta = " + 
                               STRING(craprda.nrdconta,"zzzz,zzz,9") +
                               " Aplicacao = " +
                               STRING(craprda.nraplica,"z,zzz,zz9") +
                               " aux_vlsdrdca = " +
                               STRING(aux_vlsdrdca,"zzz,zzz,zz9.99-") +
                               " aux_ajtirrgt = " +
                               STRING(aux_ajtirrgt,"zzz,zzz,zz9.99-") +
                               " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                               "/log/crps104.log").
                               
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
                                               THEN crapdat.dtmvtolt
                                               ELSE craprda.dtsaqtot

                         craprda.dtcalcul = IF craprda.insaqtot = 1
                                               THEN crapdat.dtmvtolt
                                               ELSE aux_dtcalcul

                         aux_dtdolote = crapdat.dtmvtolt
                         aux_nrdolote = 8381
                         aux_cdhistor = 116
                         aux_flglanca = TRUE.

                  IF   craprda.insaqtot = 1   THEN /* SAQUE TOTAL */
                       ASSIGN craprda.vlsdextr = 0.
                              
                  IF   craprda.vlabcpmf > 0   THEN
                       ASSIGN craprda.vlabonrd = craprda.vlabonrd + 
                                                         craprda.vlabcpmf.
                                           
                  IF   MONTH(craprda.dtfimper) = MONTH(crapdat.dtmvtolt)   THEN
                       craprda.incalmes = 0.
              END.
         ELSE
              DO:
                  ASSIGN i-cod-erro = 145 
                         c-dsc-erro = "batch atualiza craprda-b1wgen0004.i-" +
                                      p-cdprogra.       
 
                  {sistema/generico/includes/b1wgen0001.i}
                  
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                    p-cdprogra + "' --> '" + c-dsc-erro +
                                    " para esta rotina: b1wgen0004.i " +
                                    " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                    "/log/proc_batch.log").

                  UNDO, RETURN "NOK".
              END.
          
         IF   p-cdprogra = "crps103"   THEN
              aux_vlrentot = aux_vlrentot - aux_vlprovis.
         
         IF   aux_vlrentot > 0   AND
              aux_flglanca       THEN
              DO:
                  DO WHILE TRUE:

                     FIND craplot WHERE craplot.cdcooper = p-cdcooper    AND
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
                                          craplot.cdcooper = crapcop.cdcooper.
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
                         craplap.cdcooper = p-cdcooper

                         craplot.vlinfocr = craplot.vlinfocr + craplap.vllanmto
                         craplot.vlcompcr = craplot.vlcompcr + craplap.vllanmto
                         craplot.qtinfoln = craplot.qtinfoln + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.nrseqdig = craplot.nrseqdig + 1.
              
                  IF   craplap.vlrenacu < 0 THEN
                       craplap.vlrenacu = 0.
                    
                  VALIDATE craplap.

                  IF   aux_cdhistor = 116   AND
                       TRUNCATE((aux_vlrentot * aux_perirtab[4] / 100),2) > 0 
                       THEN DO:
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
                                  craplap.cdhistor = 861
                                  craplap.nrseqdig = craplot.nrseqdig + 1
                                  craplap.vllanmto = 
                          TRUNCATE((aux_vlrentot * aux_perirtab[4] / 100),2)
                                  craplap.dtrefere = aux_dtrefere
                                  craplap.cdcooper = p-cdcooper

                                  craplot.vlinfocr =
                                          craplot.vlinfocr + craplap.vllanmto
                                  craplot.vlcompcr = 
                                          craplot.vlcompcr + craplap.vllanmto
                                  craplot.qtinfoln = craplot.qtinfoln + 1
                                  craplot.qtcompln = craplot.qtcompln + 1
                                  craplot.nrseqdig = craplot.nrseqdig + 1.

                           VALIDATE craplap.
                       END.

                VALIDATE craplot.

              END.

         IF   p-cdprogra = "crps104"   THEN
              DO:
                  /* Abono do Cpmf agora e na aplicacao no dia aniver */
                  IF   craprda.vlabcpmf > 0   THEN
                       DO: 
                           DO WHILE TRUE:

                              FIND craplot WHERE
                                   craplot.cdcooper = p-cdcooper    AND
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
                                                           p-cdcooper.
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
                                  craplap.dtrefere = aux_dtrefere
                                  craplap.cdcooper = p-cdcooper

                                  craplot.vlinfocr = craplot.vlinfocr +
                                                             craplap.vllanmto
                                  craplot.vlcompcr = craplot.vlcompcr +
                                                             craplap.vllanmto
                                  craplot.qtinfoln = craplot.qtinfoln + 1
                                  craplot.qtcompln = craplot.qtcompln + 1
                                  craplot.nrseqdig = craplot.nrseqdig + 1.
                          
                           VALIDATE craplap.

                           /*** Ir sobre o abono ***/
                           IF   TRUNCATE((craprda.vlabcpmf * 
                                         aux_perirtab[1] / 100),2) > 0    THEN
                                DO:
                           
                                    CREATE craplap.
                                    ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                                           craplap.cdagenci = craplot.cdagenci
                                           craplap.cdbccxlt = craplot.cdbccxlt
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
                                           craplap.cdcooper = p-cdcooper
                                         
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

                                    VALIDATE craplap.
                                END.

                           ASSIGN craprda.vlabcpmf = 0. 

                           VALIDATE craplot.         

                       END.
                  
                  /* Ajuste IRRF sobre resgates */
                  IF   aux_ajtirrgt > 0   THEN 
                       DO:
                           DO WHILE TRUE:
     
                              FIND craplot WHERE
                                   craplot.cdcooper = p-cdcooper    AND
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
                                                           p-cdcooper.
                                        END.

                                   LEAVE.

                           END.  /*  Fim do DO WHILE TRUE  */

                           aux_vlsdrdat = aux_vlsdrdca.
                           
                           FOR EACH crablap5 WHERE
                                   (crablap5.cdcooper  = p-cdcooper         AND
                                    crablap5.nrdconta  = craprda.nrdconta   AND
                                    crablap5.nraplica  = craprda.nraplica   AND
                                    crablap5.dtrefere  = aux_dtrefere       AND
                                    crablap5.cdhistor  = 118                AND
                                    crablap5.dtmvtolt >= aux_dtcalajt       AND
                                    crablap5.dtmvtolt <= aux_dtmvtolt)      OR

                                   (crablap5.cdcooper  = p-cdcooper         AND
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
                               STRING(crapdat.dtmvtolt,"99/99/9999") + " - " +
                               STRING(TIME,"HH:MM:SS") +
                               " - " + p-cdprogra + "' --> '" +
                               "Conta = " + 
                               STRING(craprda.nrdconta,"zzzz,zzz,9") +
                               " Aplicacao = " +
                               STRING(craprda.nraplica,"z,zzz,zz9") +
                               " aux_vlsdrdat = " +
                               STRING(aux_vlsdrdat,"zzz,zzz,zz9.99-") +
                               " aux_ajtirrgt = " +
                               STRING(aux_ajtirrgt,"zzz,zzz,zz9.99-") +
                               " >> /usr/coop/" + TRIM(crapcop.dsdircop) + 
                               "/log/crps104b.log").
                                                   
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
                                           craplap.cdcooper = p-cdcooper

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
                                            
                                            VALIDATE craplap.
                                        END.
                                    END.
                           END.            
                          VALIDATE craplot.

                       END.
              END.

         IF   p-cdprogra = "crps104"             AND
              aux_cdhistor = 116                 AND
             (aux_vlrentot - aux_vlprovis) > 0   THEN
              DO:
                  DO WHILE TRUE:

                     FIND craplot WHERE craplot.cdcooper = p-cdcooper    AND
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
                                          craplot.cdcooper = p-cdcooper.
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
                         craplap.txaplica = (aux_txaplica * 100)
                         craplap.txaplmes = aux_txaplmes
                         craplap.cdhistor = 117
                         craplap.nrseqdig = craplot.nrseqdig + 1
                         craplap.vllanmto = aux_vlrentot - aux_vlprovis
                         craplap.dtrefere = aux_dtrefere
                         craplap.cdcooper = p-cdcooper

                         craplot.vlinfocr = craplot.vlinfocr + craplap.vllanmto
                         craplot.vlcompcr = craplot.vlcompcr + craplap.vllanmto
                         craplot.qtinfoln = craplot.qtinfoln + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.nrseqdig = craplot.nrseqdig + 1.

                  VALIDATE craplot.
                  VALIDATE craplap.
              END.
              
         IF   CAN-DO("crps103,crps104",p-cdprogra)   THEN
              DO:
                  aux_vlajuste = aux_vlprovis - aux_vllan117.
                  
                  IF   aux_vlajuste <> 0   THEN
                       DO:
                           DO WHILE TRUE:

                              FIND craplot WHERE
                                   craplot.cdcooper = p-cdcooper     AND
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
                                                craplot.cdcooper = p-cdcooper.
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
                                  craplap.cdcooper = p-cdcooper.

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

                           VALIDATE craplot.
                           VALIDATE craplap.

                       END.
              END.

         IF   aux_vldperda <> 0   AND   p-cdprogra = "crps104"   THEN
              DO:
                  DO WHILE TRUE:

                     FIND craplot WHERE craplot.cdcooper = p-cdcooper     AND
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
                                          craplot.cdcooper = p-cdcooper.
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
                         craplap.cdcooper = p-cdcooper.

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

                  VALIDATE craplot.
                  VALIDATE craplap.

              END.
     END.

IF   p-cdprogra = "crps117"  OR
     p-cdprogra = "crps177"  OR
     p-cdprogra = "atenda"   THEN
     DO:
         IF   craprda.vlsdrdca <= 1 AND
              aux_sldpresg      = 0 THEN
              DO:
                  FIND LAST craplap WHERE
                            craplap.cdcooper  = p-cdcooper         AND
                            craplap.nrdconta  = craprda.nrdconta   AND
                            craplap.nraplica  = craprda.nraplica
                            NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craplap THEN
                       aux_sldpresg = craprda.vlsdrdca.
                  ELSE
                       DO:
                           IF   YEAR(craplap.dtmvtolt) <
                                YEAR(crapdat.dtmvtolt) THEN
                                aux_sldpresg = craprda.vlsdrdca.
                       END.
              END.
     END.

/* b1wgen0004.p */

/* ......................................................................... */

