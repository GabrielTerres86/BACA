/* ..........................................................................

   Programa: Fontes/crps313.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Oni Junior
   Data    : Junho/2001.                       Ultima atualizacao: 20/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Cobrar tarifa referente aos debitos de INSS.

   Alteracoes: 24/08/2001 - Gerar aviso de debito no valor total que foi
                            debitado de cada conta corrente (Junior).
                            
               17/09/2004 - Se o valor da tarifa for zero, sair do programa
                            (Edson).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapavs (Diego).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder       
               
               20/01/2014 - Incluir VALIDATE crapavs,craplot,craplcm (Lucas R)
                            
............................................................................ */
 
{ includes/var_batch.i } 

DEF BUFFER crablcm FOR craplcm.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_vltarifa AS DECI                                  NO-UNDO.
DEF        VAR tab_cdhistor AS INT                                   NO-UNDO.

DEF        VAR aux_vllanmto AS DECI                                  NO-UNDO.

ASSIGN glb_cdprogra = "crps313".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.

/* Tabela que contem o historico a procurar no lcm */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "VLTARIF040"  AND
                   craptab.tpregist = 1             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " CRED-USUARI-00-VLTARIF040-001 " +
                           " >> log/proc_batch.log").
         RETURN.
     END.

aux_vltarifa = DECIMAL(craptab.dstextab).

IF   aux_vltarifa = 0   THEN     
     DO:
         RUN fontes/fimprg.p.

         RETURN.
     END.

TRANS_1:

FOR EACH crablcm WHERE crablcm.cdcooper = glb_cdcooper  AND
                       crablcm.dtmvtolt = glb_dtmvtolt  AND
                       crablcm.nrdconta > glb_nrctares  AND
                       crablcm.cdhistor = 40 USE-INDEX craplcm4 NO-LOCK 
                       BREAK BY crablcm.nrdconta
                       TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

    aux_vllanmto = aux_vllanmto + aux_vltarifa.
         
    IF   LAST-OF(crablcm.nrdconta) THEN
         DO:
             IF   aux_vllanmto = 0 THEN
                  NEXT.
                  
             DO WHILE TRUE:

                FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                                   craplot.dtmvtolt = glb_dtmvtolt  AND
                                   craplot.cdagenci = 1             AND  
                                   craplot.cdbccxlt = 100           AND
                                   craplot.nrdolote = 8452        
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
                              ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                     craplot.cdagenci = 1 
                                     craplot.cdbccxlt = 100
                                     craplot.nrdolote = 8452
                                     craplot.tplotmov = 1
                                     craplot.cdcooper = glb_cdcooper.
                          END.

                LEAVE.

             END.  /*  Fim do DO WHILE TRUE  */

             CREATE craplcm.
             ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                    craplcm.cdagenci = craplot.cdagenci
                    craplcm.cdbccxlt = craplot.cdbccxlt
                    craplcm.nrdolote = craplot.nrdolote
                    craplcm.nrdconta = crablcm.nrdconta
                    craplcm.nrdctabb = crablcm.nrdconta
                    craplcm.nrdctitg = STRING(crablcm.nrdconta,"99999999")
                    craplcm.nrdocmto = craplot.nrseqdig + 1
                    craplcm.cdhistor = 380
                    craplcm.nrseqdig = craplot.nrseqdig + 1
                    craplcm.vllanmto = aux_vllanmto
                    craplcm.cdcooper = glb_cdcooper
 
                    craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
                    craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto
                    craplot.qtinfoln = craplot.qtinfoln + 1
                    craplot.qtcompln = craplot.qtcompln + 1
                    craplot.nrseqdig = craplot.nrseqdig + 1

                    aux_vllanmto = 0.
   
             VALIDATE craplot.
             VALIDATE craplcm.

             FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                crapass.nrdconta = crablcm.nrdconta
                                NO-LOCK NO-ERROR.
             
             IF   NOT AVAILABLE crapass   THEN
                  DO:
                      glb_cdcritic = 251.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                        " - " + glb_cdprogra + "' --> '" +
                                        glb_dscritic + " Conta " +
                                        STRING(crablcm.nrdconta) +
                                        " >> log/proc_batch.log").
                      RETURN.
                  END.
                       
             CREATE crapavs.
             ASSIGN crapavs.cdagenci = crapass.cdagenci
                    crapavs.cdempres = 0
                    crapavs.cdhistor = 380
                    crapavs.cdsecext = crapass.cdsecext
                    crapavs.dtdebito = glb_dtmvtolt
                    crapavs.dtmvtolt = glb_dtmvtolt
                    crapavs.dtrefere = glb_dtmvtolt
                    crapavs.insitavs = 0
                    crapavs.nrdconta = crapass.nrdconta
                    crapavs.nrdocmto = craplcm.nrdocmto
                    crapavs.nrseqdig = craplcm.nrseqdig
                    crapavs.tpdaviso = 2
                    crapavs.vldebito = 0
                    crapavs.vlestdif = 0
                    crapavs.vllanmto = craplcm.vllanmto
                    crapavs.flgproce = FALSE
                    crapavs.cdcooper = glb_cdcooper.
             
             VALIDATE crapavs.

             /* Cria registro de restart  */
             DO WHILE TRUE:

                FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND
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
                              UNIX SILENT VALUE ("echo " + 
                                   STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                    glb_dscritic + " >> log/proc_batch.log").
                              UNDO TRANS_1, RETURN.
                          END.

                LEAVE.

             END.  /*  Fim do DO WHILE TRUE  */

             crapres.nrdconta = crablcm.nrdconta.
         END.

END.  /*  Fim do FOR EACH e da transacao  */

RUN fontes/fimprg.p.

/* .......................................................................... */
