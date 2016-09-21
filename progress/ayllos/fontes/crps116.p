/* ..........................................................................

   Programa: Fontes/crps116.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/95.                           Ultima atualizacao: 15/01/2014

   Dados referentes ao programa:

   Frequencia: Trimestral.
   Objetivo  : Atende a solicitacao 18.
               Ajuste trimestral do saldo de capital das transferencias.

   Alteracoes: 29/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            e craplct (Diego).
                            
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               15/01/2014 - Inclusao de VALIDATE craplot e craplct (Carlos)

............................................................................. */

DEF BUFFER crabcot FOR crapcot.

{ includes/var_batch.i }

DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.

DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nrdolote AS INT     INIT 8007                     NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

glb_cdprogra = "crps116".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

IF   NOT CAN-DO("3,6,9,12",STRING(MONTH(glb_dtmvtolt)))   THEN
     DO:
         RUN fontes/fimprg.p.
         RETURN.
     END.

aux_dtrefere = DATE(MONTH(glb_dtmvtolt) - 2,01,YEAR(glb_dtmvtolt)).

FOR EACH craptrf WHERE craptrf.cdcooper  = glb_cdcooper   AND
                       craptrf.dttransa >= aux_dtrefere   AND
                       craptrf.tptransa  = 1              AND
                       craptrf.insittrs  = 2 NO-LOCK
                       BY craptrf.dttransa BY craptrf.nrdconta
                       TRANSACTION ON ERROR UNDO, RETURN:

    /*  Leitura da conta anterior  */

    DO WHILE TRUE:

       FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper     AND
                          crapcot.nrdconta = craptrf.nrdconta
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE crapcot   THEN
            IF   LOCKED crapcot   THEN
                 DO:
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 169.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " Conta: " +
                                       STRING(craptrf.nrdconta,"9999,999,9") +
                                       " >> log/proc_batch.log").
                     RETURN.
                 END.

       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    /*  Leitura da conta atual  */

    DO WHILE TRUE:

       FIND crabcot WHERE crabcot.cdcooper = glb_cdcooper     AND
                          crabcot.nrdconta = craptrf.nrsconta
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE crabcot   THEN
            IF   LOCKED crabcot   THEN
                 DO:
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 169.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " Conta: " +
                                       STRING(craptrf.nrsconta,"9999,999,9") +
                                       " >> log/proc_batch.log").
                     RETURN.
                 END.

       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    DO aux_contador = 1 TO 12:

       crabcot.vlcapmes[aux_contador] = crabcot.vlcapmes[aux_contador] +
                                        crapcot.vlcapmes[aux_contador].

    END.  /*  Fim do DO .. TO  */

    ASSIGN crabcot.vldcotas = crabcot.vldcotas + crapcot.vldcotas
           crabcot.qtcotmfx = crabcot.qtcotmfx + crapcot.qtcotmfx.

    IF   crapcot.vldcotas > 0   THEN
         DO:
             DO WHILE TRUE:

                FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                   craplot.dtmvtolt = glb_dtmvtolt   AND
                                   craplot.cdagenci = aux_cdagenci   AND
                                   craplot.cdbccxlt = aux_cdbccxlt   AND
                                   craplot.nrdolote = aux_nrdolote
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE craplot   THEN
                     IF   LOCKED craplot   THEN
                          DO:
                              PAUSE 2 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              CREATE craplot.
                              ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                     craplot.cdagenci = aux_cdagenci
                                     craplot.cdbccxlt = aux_cdbccxlt
                                     craplot.nrdolote = aux_nrdolote
                                     craplot.tplotmov = 2
                                     craplot.cdcooper = glb_cdcooper.
                              VALIDATE craplot.
                          END.

                LEAVE.

             END.  /*  Fim do DO WHILE TRUE  */

             CREATE craplct.
             ASSIGN craplct.dtmvtolt = craplot.dtmvtolt
                    craplct.cdagenci = craplot.cdagenci
                    craplct.cdbccxlt = craplot.cdbccxlt
                    craplct.nrdolote = craplot.nrdolote
                    craplct.nrdconta = crapcot.nrdconta
                    craplct.cdhistor = 86
                    craplct.vllanmto = crapcot.vldcotas
                    craplct.qtlanmfx = crapcot.qtcotmfx
                    craplct.nrdocmto = craplot.nrseqdig + 1
                    craplct.nrseqdig = craplot.nrseqdig + 1
                    craplct.cdcooper = glb_cdcooper

                    craplot.vlinfodb = craplot.vlinfodb + craplct.vllanmto
                    craplot.vlcompdb = craplot.vlcompdb + craplct.vllanmto
                    craplot.qtinfoln = craplot.qtinfoln + 1
                    craplot.qtcompln = craplot.qtcompln + 1
                    craplot.nrseqdig = craplot.nrseqdig + 1.
             VALIDATE craplct.

             CREATE craplct.
             ASSIGN craplct.dtmvtolt = craplot.dtmvtolt
                    craplct.cdagenci = craplot.cdagenci
                    craplct.cdbccxlt = craplot.cdbccxlt
                    craplct.nrdolote = craplot.nrdolote
                    craplct.nrdconta = crabcot.nrdconta
                    craplct.cdhistor = 67
                    craplct.vllanmto = crapcot.vldcotas
                    craplct.qtlanmfx = crapcot.qtcotmfx
                    craplct.nrdocmto = craplot.nrseqdig + 1
                    craplct.nrseqdig = craplot.nrseqdig + 1
                    craplct.cdcooper = glb_cdcooper

                    craplot.vlinfocr = craplot.vlinfocr + craplct.vllanmto
                    craplot.vlcompcr = craplot.vlcompcr + craplct.vllanmto
                    craplot.qtinfoln = craplot.qtinfoln + 1
                    craplot.qtcompln = craplot.qtcompln + 1
                    craplot.nrseqdig = craplot.nrseqdig + 1

                    crapcot.vldcotas = 0
                    crapcot.vlcapmes = 0
                    crapcot.qtcotmfx = 0.
             VALIDATE craplct.

         END.

END.  /*  Fim do FOR EACH -- Leitura do craptrf  */

RUN fontes/fimprg.p.

/* .......................................................................... */

