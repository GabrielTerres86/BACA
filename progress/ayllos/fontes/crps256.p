/* ..........................................................................

   Programa: Fontes/crps256.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Janeiro/99                       Ultima atualizacao: 20/01/2014  

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001.
               Lanca diariamente o IOF e o abono/estorno do IOF.

   Alteracoes:  22/09/2004 - Incluidos historicos 498/500(CI)(Mirtes)

                30/06/2005 - Alimentado campo cdcooper da tabela craplot
                             e do buffer crablcm (Diego).

                16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
                22/10/2011 - Alterado a mascara do histor no FOR EACH (Ze).
                
                21/12/2011 - Aumentado o format do campo cdhistor
                            de "999" para "9999" (Tiago).
                            
                20/01/2014 - Incluir VALIDATE craplot, crablcm (Lucas R.)
..............................................................................*/

{ includes/var_batch.i }

DEF VAR aux_vliofapl AS DECIMAL                                        NO-UNDO.
DEF VAR aux_vlaboiof AS DECIMAL                                        NO-UNDO.
DEF VAR aux_vlbsiapl AS DECIMAL                                        NO-UNDO.
DEF VAR aux_vliofcot AS DECIMAL                                        NO-UNDO.
DEF VAR tab_dtiniiof AS DATE                                           NO-UNDO.
DEF VAR tab_dtfimiof AS DATE                                           NO-UNDO.
DEF VAR tab_txiofapl AS DECIMAL FORMAT "zzzzzzzz9,999999"              NO-UNDO.

DEF        BUFFER crablcm  FOR craplcm.

glb_cdprogra = "crps256".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.

/*  Tabela com a taxa do IOF */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                   craptab.nmsistem = "CRED"             AND
                   craptab.tptabela = "USUARI"           AND
                   craptab.cdempres = 11                 AND
                   craptab.cdacesso = "CTRIOFRDCA"       AND
                   craptab.tpregist = 1
                   USE-INDEX craptab1                    NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 626.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic  +
                           " >> log/proc_batch.log").
         RETURN.
     END.
 
ASSIGN tab_dtiniiof = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                           INT(SUBSTRING(craptab.dstextab,1,2)),
                           INT(SUBSTRING(craptab.dstextab,7,4)))
       tab_dtfimiof = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                           INT(SUBSTRING(craptab.dstextab,12,2)),
                           INT(SUBSTRING(craptab.dstextab,18,4)))
       tab_txiofapl = IF   glb_dtmvtolt >= tab_dtiniiof AND
                           glb_dtmvtolt <= tab_dtfimiof 
                           THEN DECIMAL(SUBSTR(craptab.dstextab,23,16))
                           ELSE 0.
 
IF   tab_txiofapl = 0 THEN
     DO:
         RUN fontes/fimprg.p.
         RETURN.
     END.

FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                       crapass.nrdconta > glb_nrctares 
                       TRANSACTION ON ERROR UNDO, RETURN:

    ASSIGN aux_vlaboiof = 0
           aux_vlbsiapl = 0
           aux_vliofapl = 0
           aux_vliofcot = 0.
    
    FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper       AND
                           craplcm.nrdconta = crapass.nrdconta   AND
                           craplcm.dtmvtolt  = glb_dtmvtolt      AND
                           CAN-DO("0114,0160,0177,0186,0187,0498,0500",
                                   STRING(craplcm.cdhistor,"9999")) 
                           USE-INDEX craplcm2 NO-LOCK:

        IF   CAN-DO("0114,0160,0177",STRING(craplcm.cdhistor,"9999")) THEN
             DO:

                ASSIGN aux_vliofapl = (TRUNCATE(craplcm.vllanmto *
                                       tab_txiofapl,2))
                       aux_vlaboiof = aux_vlaboiof + aux_vliofapl
                       aux_vlbsiapl = aux_vlbsiapl + craplcm.vllanmto
                       aux_vliofcot = aux_vliofcot + aux_vliofapl.
                                            
                IF   aux_vliofapl > 0 THEN
                     DO:
                         /* Verifica o lote */

                        FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                                           craplot.dtmvtolt = glb_dtmvtolt  AND
                                           craplot.cdagenci = 1             AND
                                           craplot.cdbccxlt = 100           AND
                                           craplot.nrdolote = 8461
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF   NOT AVAILABLE craplot   THEN
                             DO:
                                 CREATE craplot.
                                 ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                        craplot.cdagenci = 1
                                        craplot.cdbccxlt = 100
                                        craplot.nrdolote = 8461
                                        craplot.tplotmov = 1
                                        craplot.nrseqdig = 0
                                        craplot.vlcompcr = 0
                                        craplot.vlinfocr = 0
                                        craplot.vlcompdb = 0
                                        craplot.vlcompcr = 0
                                        craplot.cdhistor = 0
                                        craplot.cdoperad = "1"
                                        craplot.dtmvtopg = ?
                                        craplot.cdcooper = glb_cdcooper.
                             END.

                        /* Cria lancamento de IOF sobre a aplicacao */
       
                        CREATE crablcm.
                        ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                               craplot.qtcompln = craplot.qtcompln + 1
                               craplot.qtinfoln = craplot.qtcompln
                               craplot.vlcompdb = craplot.vlcompdb +
                                                  aux_vliofapl    
                               craplot.vlinfodb = craplot.vlcompdb
            
                               crablcm.cdagenci = craplot.cdagenci
                               crablcm.cdbccxlt = craplot.cdbccxlt
                               crablcm.cdhistor = 324
                               crablcm.dtmvtolt = glb_dtmvtolt
                               crablcm.cdpesqbb = ""
                               crablcm.nrdconta = craplcm.nrdconta
                               crablcm.nrdctabb = craplcm.nrdconta
                               crablcm.nrdocmto = craplot.nrseqdig
                               crablcm.nrdolote = craplot.nrdolote
                               crablcm.nrseqdig = craplot.nrseqdig
                               crablcm.vllanmto = aux_vliofapl
                               crablcm.cdcooper = glb_cdcooper.

                        VALIDATE crablcm.
                        VALIDATE craplot.
                     END.
             END.
        ELSE
             IF  craplcm.cdpesqbb = " " THEN
                 ASSIGN aux_vlaboiof = aux_vlaboiof -
                            (TRUNCATE(craplcm.vllanmto * tab_txiofapl,2)).
    END.
    
    IF   aux_vlaboiof <> 0 THEN
         DO:
             FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                                craplot.dtmvtolt = glb_dtmvtolt  AND
                                craplot.cdagenci = 1             AND
                                craplot.cdbccxlt = 100           AND
                                craplot.nrdolote = 8461
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

             IF   NOT AVAILABLE craplot   THEN
                  DO:
                      CREATE craplot.
                      ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                             craplot.cdagenci = 1
                             craplot.cdbccxlt = 100
                             craplot.nrdolote = 8461
                             craplot.tplotmov = 1
                             craplot.nrseqdig = 0
                             craplot.vlcompcr = 0
                             craplot.vlinfocr = 0
                             craplot.vlcompdb = 0
                             craplot.vlcompcr = 0
                             craplot.cdhistor = 0
                             craplot.cdoperad = "1"
                             craplot.dtmvtopg = ?
                             craplot.cdcooper = glb_cdcooper.
                  END.

             /* Cria lancamento de abono/estorno */
       
             CREATE crablcm.
             ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                    craplot.qtcompln = craplot.qtcompln + 1
                    craplot.qtinfoln = craplot.qtcompln
                    craplot.vlcompdb = IF aux_vlaboiof < 0 
                                          THEN craplot.vlcompdb +
                                               (aux_vlaboiof * -1) 
                                          ELSE craplot.vlcompdb
                    craplot.vlinfodb = craplot.vlcompdb
                    craplot.vlcompcr = IF aux_vlaboiof > 0 
                                          THEN craplot.vlcompcr + aux_vlaboiof
                                          ELSE craplot.vlcompcr
                    craplot.vlinfocr = craplot.vlcompcr
                    crablcm.cdagenci = craplot.cdagenci
                    crablcm.cdbccxlt = craplot.cdbccxlt
                    crablcm.cdhistor = IF aux_vlaboiof < 0 
                                          THEN 326
                                          ELSE 325
                    crablcm.dtmvtolt = glb_dtmvtolt
                    crablcm.cdpesqbb = ""
                    crablcm.nrdconta = crapass.nrdconta 
                    crablcm.nrdctabb = crapass.nrdconta
                    crablcm.nrdocmto = craplot.nrseqdig
                    crablcm.nrdolote = craplot.nrdolote
                    crablcm.nrseqdig = craplot.nrseqdig
                    crablcm.cdcooper = glb_cdcooper
                    crablcm.vllanmto = IF aux_vlaboiof < 0 
                                          THEN (aux_vlaboiof * -1)
                                          ELSE aux_vlaboiof.

             VALIDATE crablcm.
             VALIDATE craplot.

         END.
 
    IF   aux_vlbsiapl <> 0 OR aux_vliofcot <> 0 THEN
         DO:
             /* Atualiza IOF pago e base de calculo no crapcot */
             
             DO WHILE TRUE:

                FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper     AND
                                   crapcot.nrdconta = crapass.nrdconta 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE crapcot   THEN
                     IF   LOCKED crapcot   THEN
                          DO:
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              glb_cdcritic = 169.
                              RUN fontes/critic.p.
                              UNIX SILENT VALUE("echo " +
                                               STRING(TIME,"HH:MM:SS") + " - " +
                                               glb_cdprogra + "' --> '" +
                                               glb_dscritic +
                                               " >> log/proc_batch.log").
                              UNDO, RETURN.
                          END.

                LEAVE.

             END.  /*  Fim do DO WHILE TRUE  */

             ASSIGN crapcot.vliofapl = crapcot.vliofapl + aux_vliofcot    
                    crapcot.vlbsiapl = crapcot.vlbsiapl + aux_vlbsiapl.
         END.

    FIND crapres WHERE crapres.cdcooper = glb_cdcooper   AND
                       crapres.cdprogra = glb_cdprogra
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   NOT AVAILABLE crapres   THEN
         DO:
             glb_cdcritic = 151.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + " >> log/proc_batch.log").
             UNDO, RETURN.
         END.

    crapres.nrdconta = crapass.nrdconta.

END. /* END TRANSACTION */

RUN fontes/fimprg.p.

/* .......................................................................... */

