/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+-----------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL               |
  +------------------------------------------+-----------------------------------+
  | sistema/generico/includes/b1wgen0006.i   | APLI0001.pc_calc_saldo_rpp        |
  +------------------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/*..............................................................................

    Programa: sistema/generico/includes/b1wgen0006.i                  
    Autor   : Junior
    Data    : 12/09/2005                      Ultima atualizacao: 24/06/2014

    Dados referentes ao programa:

    Objetivo  : Include para calculo do saldo da poupanca programada
                Baseada no programa includes/poupanca.i.
               
    Alteracoes: 03/03/2010 - Adaptacao para rotina POUP.PROGRAMADA (David).
    
                18/01/2011 - Tratar historico 925 (Db.Trf.Aplic) (Irlan)
                18/12/2012 - Tratar historico 1115-Transferencia
                             Viacredi/AltoVale (Rosangela).
                             
                10/12/2013 - Incluir VALIDATE crapspp, craplot, craplpp (Lucas R)
                
                10/02/2014 - Alterado leitura na craptrd, incluida leitura na
                             craptab para verificacao de liberacao da nova regra da
                             poupanca. (Jean Michel)
                             
                24/06/2014 - Incluida data fixa de liberacao projeto novo 
                            indexador de poupanca - 07/01/2014 (Jean Michel).
   
..............................................................................*/

DEF        VAR aux_datliber AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_tptaxrda AS INT                                   NO-UNDO.

FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                   craptab.nmsistem = "CRED"       AND   
                   craptab.cdempres = 0            AND
                   craptab.tptabela = "CONFIG"     AND   
                   craptab.cdacesso = "PERCIRAPLI" AND
                   craptab.tpregist = 0            NO-LOCK NO-ERROR.

ASSIGN aux_percenir = IF  AVAILABLE craptab  THEN
                          DECI(craptab.dstextab) 
                      ELSE 
                          0
       aux_vlrentot = 0
       aux_vldperda = 0
       aux_vlajuste = 0
       aux_vllan150 = 0
       aux_vllan152 = 0
       aux_vllan158 = 0
       aux_vllan925 = 0
       aux_vlprovis = 0
       aux_txaplica = 0
       aux_txaplmes = 0
       aux_vlrirrpp = 0
       aux_vlsdrdpp = craprpp.vlsdrdpp
       aux_dtcalcul = craprpp.dtiniper
       aux_dtrefere = craprpp.dtfimper
       aux_dtultdia = IF  par_cdprogra = "crps147"  THEN
                          par_dtmvtolt - DAY(par_dtmvtolt)
                      ELSE 
                          par_dtmvtopr - DAY(par_dtmvtopr).

IF  par_inproces > 2                        AND   /** BATCH **/
    CAN-DO("crps147,crps148",par_cdprogra)  THEN
    DO:
        IF  par_cdprogra = "crps147"  THEN        /** MENSAL **/
            ASSIGN aux_dtmvtolt = par_dtmvtolt + 1.
        ELSE
        IF  par_cdprogra = "crps148"  THEN       /** ANIVERSARIO **/
            DO:
                ASSIGN aux_dtmvtolt = craprpp.dtfimper.

                DO WHILE TRUE:

                    IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt)))  OR
                        CAN-FIND(crapfer WHERE
                                 crapfer.cdcooper = par_cdcooper     AND
                                 crapfer.dtferiad = aux_dtmvtolt)    THEN
                        DO:
                            ASSIGN aux_dtmvtolt = aux_dtmvtolt + 1.
                            NEXT.
                        END.

                    LEAVE.

                END. /** Fim do DO WHILE TRUE **/
            END.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 145 
                       aux_dscritic = "".
           
                UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.
    END.
ELSE                                           /** ON-LINE **/
    DO:
        IF  par_cdprogra = "crps156"  THEN     /** RESGATE **/
            ASSIGN aux_dtmvtolt = par_dtmvtopr.   
        ELSE
            ASSIGN aux_dtmvtolt = par_dtmvtolt + 1. 
    END.

FOR EACH craplpp WHERE craplpp.cdcooper  = par_cdcooper     AND
                       craplpp.nrdconta  = craprpp.nrdconta AND
                       craplpp.nrctrrpp  = craprpp.nrctrrpp AND
                      (craplpp.dtmvtolt >= aux_dtcalcul     AND
                       craplpp.dtmvtolt <= aux_dtmvtolt)    AND
                       craplpp.dtrefere  = aux_dtrefere     AND
                       CAN-DO("150,152,154,155,158,496,925,1115",
                              STRING(craplpp.cdhistor))     NO-LOCK:

    IF  craplpp.cdhistor = 150  THEN   /** Credito do plano **/
        DO:
            ASSIGN aux_vllan150 = aux_vllan150 + craplpp.vllanmto.
            NEXT.
        END.
    ELSE
    IF  craplpp.cdhistor = 152  OR     /** Provisao do mes **/
        craplpp.cdhistor = 154  THEN   /** Ajuste provisao **/
        DO:
            ASSIGN aux_vllan152 = aux_vllan152 + craplpp.vllanmto.
            NEXT.
        END.
    ELSE
    IF  craplpp.cdhistor = 155  THEN   /** Ajuste provisao **/
        DO:
            ASSIGN aux_vllan152 = aux_vllan152 - craplpp.vllanmto.
            NEXT.
        END.
    ELSE
    IF  craplpp.cdhistor = 158  OR
        craplpp.cdhistor = 496  THEN   /** Resgate **/
        DO:
            ASSIGN aux_vllan158 = aux_vllan158 + craplpp.vllanmto.
            NEXT.
        END.
    ELSE
    IF  craplpp.cdhistor = 925  OR
        craplpp.cdhistor = 1115 THEN   /* Db.Trf.Aplic. */
        DO:
            ASSIGN aux_vllan925 = aux_vllan925 + craplpp.vllanmto.
            NEXT.
        END.


END. /** Fim do FOR EACH craplpp **/

ASSIGN aux_vlsdrdpp = aux_vlsdrdpp + aux_vllan150 - aux_vllan158 - aux_vllan925.

IF  aux_vlsdrdpp < 0  THEN
    aux_vlsdrdpp = 0.
     
IF  par_inproces > 2                        AND    /** BATCH **/
    CAN-DO("crps147,crps148",par_cdprogra)  THEN
    DO:
        DO aux_contador = 1 TO 10:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
            
            /********************************************************************/
            /** Em maio de 2012 o novo calculo foi liberado para utilizacao,   **/
            /** portanto poupancas cadastradas a partir desta data poderiam    **/
            /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
            /** a nova regra sera utilizada somente para poupancas cadastradas **/
            /** apos a liberacao do projeto de novo indexador de poupanca,     **/
            /** pois o passado anterior a liberacao ja foi contratado com a    **/
            /** regra antiga                                                   **/
            /********************************************************************/

            /* Data de liberacao do projeto novo indexador de poupanca */            
            ASSIGN aux_datliber = 07/01/2014.

            IF craprpp.dtmvtolt >= aux_datliber THEN
                ASSIGN aux_tptaxrda = 4. /** Novo Indexador poupanca - Lei 12.703 **/
            ELSE
                ASSIGN aux_tptaxrda = 2. /** Regra antiga **/

            FIND FIRST craptrd WHERE craptrd.cdcooper  = par_cdcooper     AND
                                     craptrd.dtiniper  = craprpp.dtiniper AND
                                     craptrd.tptaxrda  = aux_tptaxrda     AND
                                     craptrd.incarenc  = 0                AND
                                     craptrd.vlfaixas <= aux_vlsdrdpp    
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craptrd  THEN
                DO:
                    IF  LOCKED craptrd THEN
                        DO:
                            ASSIGN aux_dscritic = "Registro de taxa ja esta " +
                                                  "sendo alterado.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 347.
                END.

            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
            UNDO TRANS_POUP, LEAVE TRANS_POUP.

        IF  craptrd.txofidia > 0  THEN
            ASSIGN aux_txaplica = (craptrd.txofidia / 100)
                   aux_txaplmes =  craptrd.txofimes.
        ELSE
        IF  craptrd.txprodia > 0  THEN
            ASSIGN aux_txaplica = (craptrd.txprodia / 100)
                   aux_txaplmes =  0.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 427 
                       aux_dscritic = "".
          
                UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.
       
        IF  par_cdprogra = "crps148"  THEN
            ASSIGN craptrd.incalcul = 2.
        ELSE
            ASSIGN craptrd.incalcul = 1.
    END. 

IF  par_inproces > 2                        AND  /** BATCH **/
    CAN-DO("crps147,crps148",par_cdprogra)  AND
    aux_dtcalcul < aux_dtmvtolt             AND
    aux_vlsdrdpp > 0                        THEN
    DO WHILE aux_dtcalcul < aux_dtmvtolt:

        IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtcalcul)))              OR
            CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper   AND
                                   crapfer.dtferiad = aux_dtcalcul)  THEN
            DO:
                ASSIGN aux_dtcalcul = aux_dtcalcul + 1.
                NEXT.
            END.

       ASSIGN aux_vlrendim = TRUNCATE(aux_vlsdrdpp * aux_txaplica,8)
              aux_vlsdrdpp = aux_vlsdrdpp + aux_vlrendim
              aux_vlrentot = aux_vlrentot + aux_vlrendim
              aux_vlprovis = IF  aux_dtcalcul <= aux_dtultdia  THEN
                                 aux_vlprovis + aux_vlrendim
                             ELSE 
                                 aux_vlprovis
              aux_dtcalcul = aux_dtcalcul + 1.

    END. /** Fim do DO WHILE **/

/** Arredondamento dos valores calculados **/
ASSIGN aux_vlsdrdpp = ROUND(aux_vlsdrdpp,2)
       aux_vlrentot = ROUND(aux_vlrentot,2)
       aux_vlprovis = ROUND(aux_vlprovis,2)
       aux_vlrirrpp = TRUNC((aux_vlrentot * aux_percenir / 100),2).

IF  par_inproces = 1  THEN   /** ON-LINE **/
    ASSIGN aux_vlsdrdpp = aux_vlsdrdpp -
                          TRUNC((craprpp.vlabcpmf * aux_percenir / 100),2)
           aux_vlsdrdpp = IF  aux_vlsdrdpp < 0  THEN 
                              0
                          ELSE 
                              aux_vlsdrdpp.

IF  par_inproces > 2                        AND
    CAN-DO("crps147,crps148",par_cdprogra)  THEN
    DO:
        IF  par_cdprogra = "crps147"  THEN      /** MENSAL **/
            ASSIGN aux_dtdolote     = par_dtmvtolt
                   aux_nrdolote     = 8383
                   aux_cdhistor     = 152
                   craprpp.incalmes = 0
                   craprpp.indebito = 0.
        ELSE
        IF  par_cdprogra = "crps148"  THEN      /** ANIVERSARIO **/
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
                
                /* Data de liberacao do projeto novo indexador de poupanca */            
                ASSIGN aux_datliber = 07/01/2014.

                IF craprpp.dtmvtolt >= aux_datliber THEN
                    ASSIGN aux_tptaxrda = 4. /** Novo Indexador poupanca - Lei 12.703 **/
                ELSE
                    ASSIGN aux_tptaxrda = 2. /** Regra antiga **/

                FIND craptrd WHERE craptrd.cdcooper = par_cdcooper     AND
                                   craptrd.dtiniper = craprpp.dtfimper AND
                                   craptrd.tptaxrda = aux_tptaxrda     AND
                                   craptrd.incarenc = 0                AND
                                   craptrd.vlfaixas = 0 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE craptrd  THEN
                    DO:
                        ASSIGN aux_cdcritic = 347
                               aux_dscritic = "".

                        UNDO TRANS_POUP, LEAVE TRANS_POUP.
                    END.

                ASSIGN craprpp.qtmesext = craprpp.qtmesext + 1.

                IF  craprpp.qtmesext = 4  THEN
                    ASSIGN craprpp.qtmesext = 1.

                IF  MONTH(craprpp.dtfimper) = 12  THEN
                    ASSIGN craprpp.qtmesext = 3.

                IF  craprpp.qtmesext = 1  THEN
                    ASSIGN craprpp.dtiniext = craprpp.dtfimext
                           craprpp.dtsdppan = craprpp.dtiniper
                           craprpp.vlsdppan = craprpp.vlsdrdpp.

                ASSIGN craprpp.incalmes = 1
                       craprpp.dtfimext = craprpp.dtfimper
                       craprpp.dtiniper = craprpp.dtfimper
                       craprpp.dtfimper = craptrd.dtfimper
                       craprpp.vlsdrdpp = aux_vlsdrdpp - aux_vlrirrpp
                       craprpp.dtcalcul = par_dtmvtopr               
                       aux_dtdolote     = par_dtmvtopr
                       aux_nrdolote     = 8384
                       aux_cdhistor     = 151.
                       
                IF  craprpp.vlabcpmf > 0  THEN
                    ASSIGN craprpp.vlsdrdpp = craprpp.vlsdrdpp -
                                              TRUNCATE((craprpp.vlabcpmf * 
                                                        aux_percenir / 100),2).

                IF  MONTH(craprpp.dtfimper) = MONTH(par_dtmvtopr)  AND
                    YEAR(craprpp.dtfimper)  =  YEAR(par_dtmvtopr)  THEN
                    ASSIGN craprpp.incalmes = 0.
                
                DO aux_contador = 1 TO 10:

                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "".

                    FIND crapspp WHERE crapspp.cdcooper = craprpp.cdcooper AND
                                       crapspp.nrdconta = craprpp.nrdconta AND
                                       crapspp.nrctrrpp = craprpp.nrctrrpp AND
                                       crapspp.dtsldrpp = craprpp.dtiniper
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapspp  THEN
                        DO:
                            IF  LOCKED crapspp  THEN
                                DO:
                                    aux_dscritic = "Registro de saldo da " +
                                                   "aplicacao ja esta sendo " +
                                                   "alterado.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                DO:
                                    CREATE crapspp.
                                    ASSIGN crapspp.cdcooper = craprpp.cdcooper
                                           crapspp.nrdconta = craprpp.nrdconta
                                           crapspp.nrctrrpp = craprpp.nrctrrpp
                                           crapspp.dtsldrpp = craprpp.dtiniper
                                           crapspp.vlsldrpp = craprpp.vlsdrdpp
                                           crapspp.dtmvtolt = par_dtmvtolt.
                                END.
                        END.
                    ELSE
                        ASSIGN crapspp.vlsldrpp = craprpp.vlsdrdpp
                               crapspp.dtmvtolt = par_dtmvtolt.

                    VALIDATE crapspp.

                    LEAVE.

                END. /** Fim do DO ... TO **/
                
                IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
                    UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 145
                       aux_dscritic = "".

                UNDO TRANS_POUP, LEAVE TRANS_POUP.
            END.

        IF  par_cdprogra = "crps147"  THEN
            ASSIGN aux_vlrentot = aux_vlrentot - aux_vlprovis.

        IF  aux_vlrentot > 0  THEN
            DO:
                DO aux_contador = 1 TO 10:

                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "".

                    FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                                       craplot.dtmvtolt = aux_dtdolote AND
                                       craplot.cdagenci = aux_cdagenci AND
                                       craplot.cdbccxlt = aux_cdbccxlt AND
                                       craplot.nrdolote = aux_nrdolote
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE craplot  THEN
                        DO:
                            IF  LOCKED craplot  THEN
                                DO:
                                    aux_dscritic = "Registro de lote ja " +
                                                   "esta sendo alterado.".
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
                                           craplot.tplotmov = 14
                                           craplot.cdcooper = par_cdcooper.
                              END.
                        END.

                    LEAVE.

                END. /** Fim do DO ... TO **/

                IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
                    UNDO TRANS_POUP, LEAVE TRANS_POUP.
                    
                CREATE craplpp.
                ASSIGN craplpp.cdcooper = par_cdcooper
                       craplpp.dtmvtolt = craplot.dtmvtolt
                       craplpp.cdagenci = craplot.cdagenci
                       craplpp.cdbccxlt = craplot.cdbccxlt
                       craplpp.nrdolote = craplot.nrdolote
                       craplpp.nrdconta = craprpp.nrdconta
                       craplpp.nrctrrpp = craprpp.nrctrrpp
                       craplpp.nrdocmto = craplot.nrseqdig + 1
                       craplpp.txaplica = (aux_txaplica * 100)
                       craplpp.txaplmes = aux_txaplmes
                       craplpp.cdhistor = aux_cdhistor
                       craplpp.nrseqdig = craplot.nrseqdig + 1
                       craplpp.vllanmto = aux_vlrentot
                       craplpp.dtrefere = aux_dtrefere
                                      
                       craplot.vlinfocr = craplot.vlinfocr + craplpp.vllanmto
                       craplot.vlcompcr = craplot.vlcompcr + craplpp.vllanmto
                       craplot.qtinfoln = craplot.qtinfoln + 1
                       craplot.qtcompln = craplot.qtcompln + 1
                       craplot.nrseqdig = craplot.nrseqdig + 1.
            
                VALIDATE craplpp.

                IF  par_cdprogra = "crps148"  AND
                    aux_vlrirrpp > 0          THEN 
                    DO:
                        CREATE craplpp.
                        ASSIGN craplpp.cdcooper = par_cdcooper
                               craplpp.dtmvtolt = craplot.dtmvtolt
                               craplpp.cdagenci = craplot.cdagenci
                               craplpp.cdbccxlt = craplot.cdbccxlt
                               craplpp.nrdolote = craplot.nrdolote
                               craplpp.nrdconta = craprpp.nrdconta
                               craplpp.nrctrrpp = craprpp.nrctrrpp
                               craplpp.nrdocmto = craplot.nrseqdig + 1
                               craplpp.txaplica = aux_percenir
                               craplpp.txaplmes = aux_percenir
                               craplpp.cdhistor = 863
                               craplpp.nrseqdig = craplot.nrseqdig + 1
                               craplpp.vllanmto = aux_vlrirrpp
                               craplpp.dtrefere = aux_dtrefere

                               craplot.vlinfocr = craplot.vlinfocr + 
                                                  craplpp.vllanmto
                               craplot.vlcompcr = craplot.vlcompcr + 
                                                  craplpp.vllanmto
                               craplot.qtinfoln = craplot.qtinfoln + 1
                               craplot.qtcompln = craplot.qtcompln + 1
                               craplot.nrseqdig = craplot.nrseqdig + 1.

                        VALIDATE craplpp.
                    END.

                VALIDATE craplot.    
            END.

        IF  par_cdprogra = "crps148"  AND
            aux_cdhistor = 151        AND
           (aux_vlrentot > 0          OR
            craprpp.vlabdiof > 0      OR 
            aux_vlrirrpp > 0)         THEN
            DO:
                DO aux_contador = 1 TO 10:

                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "".

                    FIND crapcot WHERE crapcot.cdcooper = par_cdcooper     AND
                                       crapcot.nrdconta = craprpp.nrdconta
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapcot  THEN
                        DO: 
                            IF  LOCKED crapcot  THEN
                                DO:
                                    aux_dscritic = "Registro de cotas ja " +
                                                   "esta sendo alterado.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                ASSIGN aux_cdcritic = 169.
                        END.

                    LEAVE.

                END. /** Fim do DO ... TO **/

                IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
                    UNDO TRANS_POUP, LEAVE TRANS_POUP.

                IF  aux_vlrentot > 0  THEN
                    ASSIGN craprpp.vljuracu = craprpp.vljuracu + aux_vlrentot
                           crapcot.vlrenrpp = crapcot.vlrenrpp + aux_vlrentot
                           crapcot.vlrenrpp_ir[MONTH(aux_dtrefere)] =
                                   crapcot.vlrenrpp_ir[MONTH(aux_dtrefere)] +
                                   aux_vlrentot 
                           crapcot.vlrentot[MONTH(aux_dtrefere)] = 
                                   crapcot.vlrentot[MONTH(aux_dtrefere)] + 
                                   aux_vlrentot.

                IF  craprpp.vlabdiof > 0  THEN
                    ASSIGN crapcot.vlabiopp = crapcot.vlabiopp + 
                                              craprpp.vlabdiof
                           crapcot.vlrentot[MONTH(aux_dtrefere)] =
                                   crapcot.vlrentot[MONTH(aux_dtrefere)] + 
                                   craprpp.vlabdiof
                           craprpp.vlabdiof = 0.

                IF  (aux_vlrentot - aux_vlprovis) > 0  THEN
                    DO:
                        DO aux_contador = 1 TO 10:

                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "".

                            FIND craplot WHERE
                                 craplot.cdcooper = par_cdcooper AND
                                 craplot.dtmvtolt = aux_dtdolote AND
                                 craplot.cdagenci = aux_cdagenci AND
                                 craplot.cdbccxlt = aux_cdbccxlt AND
                                 craplot.nrdolote = aux_nrdolote
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                            IF  NOT AVAILABLE craplot  THEN
                                DO:
                                    IF  LOCKED craplot  THEN
                                        DO:
                                            aux_dscritic = "Registro de lote " +
                                                           "ja esta sendo " +
                                                           "alterado.".
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
                                               craplot.nrdolote = aux_nrdolote
                                               craplot.tplotmov = 14
                                               craplot.cdcooper = par_cdcooper.
                                        END.
                                END.

                            LEAVE.

                        END. /** Fim do DO ... TO */

                        IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
                            UNDO TRANS_POUP, LEAVE TRANS_POUP.

                        CREATE craplpp.
                        ASSIGN craplpp.cdcooper = par_cdcooper
                               craplpp.dtmvtolt = craplot.dtmvtolt
                               craplpp.cdagenci = craplot.cdagenci
                               craplpp.cdbccxlt = craplot.cdbccxlt
                               craplpp.nrdolote = craplot.nrdolote
                               craplpp.nrdconta = craprpp.nrdconta
                               craplpp.nrctrrpp = craprpp.nrctrrpp
                               craplpp.nrdocmto = craplot.nrseqdig + 1
                               craplpp.txaplica = (aux_txaplica * 100)
                               craplpp.txaplmes = aux_txaplmes
                               craplpp.cdhistor = 152
                               craplpp.nrseqdig = craplot.nrseqdig + 1
                               craplpp.vllanmto = aux_vlrentot - aux_vlprovis
                               craplpp.dtrefere = aux_dtrefere

                               craplot.vlinfocr = craplot.vlinfocr +
                                                          craplpp.vllanmto
                               craplot.vlcompcr = craplot.vlcompcr +
                                                          craplpp.vllanmto
                               craplot.qtinfoln = craplot.qtinfoln + 1
                               craplot.qtcompln = craplot.qtcompln + 1
                               craplot.nrseqdig = craplot.nrseqdig + 1.

                          VALIDATE craplpp.
                          VALIDATE craplot.
                    END.                   
            END. 

        /** Abono do CPMF agora na poupanca **/
        IF  par_cdprogra = "crps148"  AND
            craprpp.vlabcpmf > 0      THEN
            DO: 
                DO aux_contador = 1 TO 10:

                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "".

                    FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                                       craplot.dtmvtolt = aux_dtdolote AND
                                       craplot.cdagenci = aux_cdagenci AND
                                       craplot.cdbccxlt = aux_cdbccxlt AND
                                       craplot.nrdolote = aux_nrdolote
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE craplot  THEN
                        DO:
                            IF  LOCKED craplot  THEN
                                DO:
                                    aux_dscritic = "Registro de lote ja " +
                                                   "esta sendo alterado.".
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
                                           craplot.tplotmov = 14
                                           craplot.cdcooper = par_cdcooper.
                                END.
                        END.

                    LEAVE.

                END. /** Fim do DO ... TO **/

                IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
                    UNDO TRANS_POUP, LEAVE TRANS_POUP.

                CREATE craplpp.
                ASSIGN craplpp.cdcooper = par_cdcooper
                       craplpp.dtmvtolt = craplot.dtmvtolt
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
                       craplpp.dtrefere = aux_dtrefere
                       
                       craplot.vlinfocr = craplot.vlinfocr + craplpp.vllanmto
                       craplot.vlcompcr = craplot.vlcompcr + craplpp.vllanmto
                       craplot.qtinfoln = craplot.qtinfoln + 1
                       craplot.qtcompln = craplot.qtcompln + 1
                       craplot.nrseqdig = craplot.nrseqdig + 1.
                
                VALIDATE craplpp.

                /** IR sobre o abono de cpmf na poupanca **/
                IF  TRUNC((craprpp.vlabcpmf * aux_percenir / 100),2) > 0  THEN
                    DO:
                        CREATE craplpp.
                        ASSIGN craplpp.cdcooper = par_cdcooper
                               craplpp.dtmvtolt = craplot.dtmvtolt
                               craplpp.cdagenci = craplot.cdagenci
                               craplpp.cdbccxlt = craplot.cdbccxlt
                               craplpp.nrdolote = craplot.nrdolote
                               craplpp.nrdconta = craprpp.nrdconta
                               craplpp.nrctrrpp = craprpp.nrctrrpp
                               craplpp.nrdocmto = craplot.nrseqdig + 1
                               craplpp.txaplica = aux_percenir
                               craplpp.txaplmes = aux_percenir
                               craplpp.cdhistor = 870
                               craplpp.nrseqdig = craplot.nrseqdig + 1
                               craplpp.vllanmto = TRUNC((craprpp.vlabcpmf * 
                                                         aux_percenir / 100),2)
                               craplpp.dtrefere = aux_dtrefere

                               craplot.vlinfocr = craplot.vlinfocr +
                                                  craplpp.vllanmto
                               craplot.vlcompcr = craplot.vlcompcr +
                                                  craplpp.vllanmto
                               craplot.qtinfoln = craplot.qtinfoln + 1
                               craplot.qtcompln = craplot.qtcompln + 1
                               craplot.nrseqdig = craplot.nrseqdig + 1.

                        VALIDATE craplpp.
                    END.

                VALIDATE craplot.
                ASSIGN craprpp.vlabcpmf = 0.
            END.
                   
        IF  CAN-DO("crps147,crps148",par_cdprogra)  THEN
            DO:
                ASSIGN aux_vlajuste = aux_vlprovis - aux_vllan152.

                IF  aux_vlajuste <> 0  THEN
                    DO:
                        DO aux_contador = 1 TO 10:

                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "".
                            
                            FIND craplot WHERE 
                                 craplot.cdcooper = par_cdcooper AND
                                 craplot.dtmvtolt = aux_dtdolote AND
                                 craplot.cdagenci = aux_cdagenci AND
                                 craplot.cdbccxlt = aux_cdbccxlt AND
                                 craplot.nrdolote = 8384
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                            IF  NOT AVAILABLE craplot  THEN
                                DO:
                                    IF  LOCKED craplot  THEN
                                        DO:
                                            aux_dscritic = "Registro de lote " +
                                                "ja esta sendo alterado.".
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
                                               craplot.nrdolote = 8384
                                               craplot.tplotmov = 14
                                               craplot.cdcooper = par_cdcooper.
                                        END.
                                END.

                            LEAVE.

                        END. /** Fim do DO ... TO **/

                        IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
                            UNDO TRANS_POUP, LEAVE TRANS_POUP.

                        CREATE craplpp.
                        ASSIGN craplpp.cdcooper = par_cdcooper
                               craplpp.dtmvtolt = craplot.dtmvtolt
                               craplpp.cdagenci = craplot.cdagenci
                               craplpp.cdbccxlt = craplot.cdbccxlt
                               craplpp.nrdolote = craplot.nrdolote
                               craplpp.nrdconta = craprpp.nrdconta
                               craplpp.nrctrrpp = craprpp.nrctrrpp
                               craplpp.nrdocmto = craplot.nrseqdig + 1
                               craplpp.txaplica = (aux_txaplica * 100)
                               craplpp.txaplmes = aux_txaplmes
                               craplpp.cdhistor = IF  aux_vlajuste > 0  THEN 
                                                      154
                                                  ELSE 
                                                      155
                               craplpp.nrseqdig = craplot.nrseqdig + 1
                               craplpp.vllanmto = IF  aux_vlajuste > 0  THEN 
                                                      aux_vlajuste
                                                  ELSE 
                                                      aux_vlajuste * -1
                               craplpp.dtrefere = aux_dtrefere.

                        IF  aux_vlajuste > 0  THEN
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

                        VALIDATE craplot.
                        VALIDATE craplpp.
                    END.
            END.
    END.

IF  AVAILABLE craptrd  THEN
    FIND CURRENT craptrd NO-LOCK NO-ERROR.

IF  AVAILABLE crapspp THEN
    FIND CURRENT crapspp NO-LOCK NO-ERROR.

IF  AVAILABLE crapcot THEN
    FIND CURRENT crapcot NO-LOCK NO-ERROR.

IF  AVAILABLE craplot THEN
    FIND CURRENT craplot NO-LOCK NO-ERROR.

/*............................................................................*/
