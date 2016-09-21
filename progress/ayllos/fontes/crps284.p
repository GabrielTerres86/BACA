/* ..........................................................................

   Programa: Fontes/crps284.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/2000.                     Ultima atualizacao: 20/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de tarifa de devolucao de cheque BANCOOB

   Alteracoes: 08/01/2003 - Criar tabela para contas isentas (Deboreah).

               07/04/2003 - Incluir tratamento do histor 399 (Margarete).
               
               30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            e craplcm (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
                
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.  
               
               20/01/2014 - Incluir VALIDATE craplcm, craplot (Lucas R.)
............................................................................. */
 
{ includes/var_batch.i  } 

DEF BUFFER crablcm FOR craplcm.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_vltarifa AS DECI                                  NO-UNDO.
DEF        VAR tab_cdhistor AS INT                                   NO-UNDO.

DEF        VAR aux_vllanmto AS DECI                                  NO-UNDO.
DEF        VAR aux_lscontas AS CHAR                                  NO-UNDO.

glb_cdprogra = "crps284".

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
                   craptab.cdacesso = "VLTARIF351"  AND
                   craptab.tpregist = 1             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " CRED-USUARI-00-VLTARIF351-001 " +
                           " >> log/proc_batch.log").
         RETURN.
     END.

aux_vltarifa= DECI(craptab.dstextab).

/* Tabela que contem as contas isentas */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "ISTARIF351"  AND
                   craptab.tpregist = 1             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     aux_lscontas = "".
ELSE
     aux_lscontas = craptab.dstextab.

TRANS_1:

FOR EACH crablcm WHERE crablcm.cdcooper = glb_cdcooper               AND
                       crablcm.dtmvtolt = glb_dtmvtolt               AND
                       crablcm.nrdconta > glb_nrctares               AND
                   NOT CAN-DO(aux_lscontas,STRING(crablcm.nrdconta)) AND 
                       CAN-DO("24,27,351,399",STRING(crablcm.cdhistor))
                       USE-INDEX craplcm4 NO-LOCK BREAK BY crablcm.nrdconta
                       TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

    aux_vllanmto = aux_vllanmto + aux_vltarifa.
         
    IF   LAST-OF(crablcm.nrdconta) THEN
         DO:
             
             IF   aux_vllanmto = 0 THEN
                  NEXT.
                  
             DO WHILE TRUE:

                FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                   craplot.dtmvtolt = glb_dtmvtolt   AND
                                   craplot.cdagenci = 1              AND  
                                   craplot.cdbccxlt = 100            AND
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
                              ASSIGN 
                                  craplot.dtmvtolt = glb_dtmvtolt
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
                    craplcm.cdhistor = 352
                    craplcm.nrseqdig = craplot.nrseqdig + 1
                    craplcm.vllanmto = aux_vllanmto
                    craplcm.cdcooper = glb_cdcooper
 
                    craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
                    craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto
                    craplot.qtinfoln = craplot.qtinfoln + 1
                    craplot.qtcompln = craplot.qtcompln + 1
                    craplot.nrseqdig = craplot.nrseqdig + 1

                    aux_vllanmto = 0.
            
             VALIDATE craplcm.
             VALIDATE craplot.
        
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

