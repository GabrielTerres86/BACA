/* ..........................................................................

   Programa: Fontes/crps190.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Abril/97.                       Ultima atualizacao: 25/09/2015
                                                                  
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Debitar em conta corrente as faturas de Credicard.

   Alteracoes: 15/10/1999 - Selecionar os numeros de lote abaixo de 6870
                            (Deborah).
                            
               02/10/2003 - Tratar erro em Duplicate no craplcm (Ze Eduardo).

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapdcd (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
               
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)
               
               14/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - paulo
                            
               02/06/2011 - incluido no for each a condição - 
                            craplau.dsorigem <> "TAA" (Evandro).

               30/09/2011 - incluido no for each a condigco -
                            craplau.dsorigem <> "CARTAOBB" (Ze).
                            
               03/06/2013 - incluido no FOR EACH craplau a condicao -
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)
                            
               16/01/2014 - Inclusao de VALIDATE craplot, craplcm e crapdcd 
                            (Carlos)
                            
               01/04/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
               
               25/09/2015 - Incluida string “CAIXA” em todas as ocorrências de 
                            loop da LAU Projeto 254 (Lombardi).
                            
 ............................................................................ */

DEF  BUFFER crablot FOR craplot.

DEF  VAR aux_nrcheque AS DECIMAL                                      NO-UNDO.

{ includes/var_batch.i {1} }

glb_cdprogra = "crps190".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

IF   glb_inrestar = 0 THEN
     glb_nrctares = 0.

FOR EACH crablot WHERE crablot.cdcooper  = glb_cdcooper  AND
                       crablot.dtmvtopg  > glb_dtmvtoan  AND
                       crablot.dtmvtopg <= glb_dtmvtolt  AND
                       crablot.tplotmov  = 17            AND
                       crablot.nrdolote  < 6870          AND
                       crablot.nrdolote >= glb_nrctares  NO-LOCK:

    FOR EACH craplau WHERE craplau.cdcooper  = glb_cdcooper          AND
                           craplau.dtmvtolt  = crablot.dtmvtolt      AND
                           craplau.cdagenci  = crablot.cdagenci      AND
                           craplau.cdbccxlt  = crablot.cdbccxlt      AND
                           craplau.nrdolote  = crablot.nrdolote      AND
                           craplau.nrseqlan  > INTEGER(glb_dsrestar) AND
                           craplau.dsorigem <> "INTERNET"            AND
                           craplau.dsorigem <> "TAA"                 AND
                           craplau.dsorigem <> "CAIXA"               AND
                           craplau.dsorigem <> "PG555"               AND
                           craplau.dsorigem <> "CARTAOBB"            AND
                           craplau.dsorigem <> "BLOQJUD"             AND
                           craplau.dsorigem <> "DAUT BANCOOB"
                           USE-INDEX craplau3 TRANSACTION:

        IF  glb_inrestar > 0 THEN
            glb_dsrestar = "0".

        DO WHILE TRUE:

           FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                              craplot.dtmvtolt = glb_dtmvtolt   AND
                              craplot.cdagenci = 1              AND
                              craplot.cdbccxlt = 100            AND
                              craplot.nrdolote = 8459
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
                                craplot.cdagenci = 1
                                craplot.cdbccxlt = 100
                                craplot.nrdolote = 8459
                                craplot.tpdmoeda = 1
                                craplot.cdoperad = "1"
                                craplot.tplotmov = 1
                                craplot.cdcooper = glb_cdcooper.
                         VALIDATE craplot.
                     END.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        ASSIGN aux_nrcheque = craplau.nrdocmto.
        
        DO WHILE TRUE:

             FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper      AND
                                craplcm.dtmvtolt = glb_dtmvtolt      AND
                                craplcm.cdagenci = 1                 AND
                                craplcm.cdbccxlt = 100               AND
                                craplcm.nrdolote = 8459              AND
                                craplcm.nrdctabb = craplau.nrdconta  AND
                                craplcm.nrdocmto = aux_nrcheque
                                USE-INDEX craplcm1
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

             IF   AVAILABLE craplcm THEN
                  aux_nrcheque = (aux_nrcheque + 1000000).
             ELSE
                  LEAVE.
          
        END.  /*  Fim do DO WHILE TRUE  */

        CREATE craplcm.
        ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
               craplcm.cdagenci = craplot.cdagenci
               craplcm.cdbccxlt = craplot.cdbccxlt
               craplcm.nrdolote = craplot.nrdolote
               craplcm.nrdconta = craplau.nrdconta
               craplcm.nrdctabb = craplau.nrdconta
               craplcm.nrdctitg = STRING(craplau.nrdconta,"99999999")
               craplcm.nrdocmto = aux_nrcheque
               craplcm.cdhistor = craplau.cdhistor
               craplcm.nrseqdig = craplot.nrseqdig + 1
               craplcm.vllanmto = craplau.vllanaut
               craplcm.cdpesqbb = ""
               craplcm.cdcooper = glb_cdcooper

               craplau.dtdebito = glb_dtmvtolt

               craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
               craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto
               craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.nrseqdig = craplot.nrseqdig + 1.
        VALIDATE craplcm.

        DO WHILE TRUE:

           FIND crapdcd WHERE crapdcd.cdcooper = glb_cdcooper       AND
                              crapdcd.nrdconta = craplau.nrdconta   AND
                              crapdcd.nrcrcard = craplau.nrcrcard   AND
                              crapdcd.dtdebito = glb_dtmvtolt
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE crapdcd   THEN
                IF   LOCKED crapdcd   THEN
                     DO:
                         PAUSE 2 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         CREATE crapdcd.
                         ASSIGN crapdcd.dtdebito = glb_dtmvtolt
                                crapdcd.nrdconta = craplau.nrdconta
                                crapdcd.nrcrcard = craplau.nrcrcard
                                crapdcd.cdcooper = glb_cdcooper.
                         VALIDATE crapdcd.
                     END.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        crapdcd.vldebito = crapdcd.vldebito + craplcm.vllanmto.

        DO WHILE TRUE:

           FIND crapres WHERE crapres.cdcooper = glb_cdcooper   AND
                              crapres.cdprogra = glb_cdprogra
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE crapres   THEN
                IF   LOCKED crapres   THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         glb_cdcritic = 151.
                         RUN fontes/critic.p.
                         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " >> log/proc_batch.log").
                         RETURN.
                     END.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        ASSIGN crapres.nrdconta = craplau.nrdolote
               crapres.dsrestar = STRING(craplau.nrseqlan).

    END.  /*  Fim do FOR EACH e da transacao  */
END.  /* FOR EACH craplot */

RUN fontes/fimprg.p.

/* .......................................................................... */

