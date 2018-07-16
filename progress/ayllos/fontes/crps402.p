/*..............................................................................

   Programa: fontes/crps402.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Agosto/2004.                    Ultima atualizacao: 05/01/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Enviar via e-mail extratos de conta corrente depositos a vista,
               no padrao CNAB (Evandro).

   Alteracoes: 06/06/2005 - Incluir o campo aux_dtlimite na leitura do craplcm
                            (Edson).

               15/06/2005 - Tratamento para envio de extrato pela NEXXERA
                            "tpextrat = 4" (Julio)

               29/06/2005 - Correcao no calculo do saldo inicial e
                            inclusao da compentencia na nomenclatura do arquivo
                            (Julio).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               29/05/2006 - Usar idseqttl para acessar crapcem (Magui).

               24/07/2007 - Incluidos historicos de transferencia pela internet
                            (Evandro).

               11/03/2008 - Alterar o saldo final. Incluir o Bloqueado
                            Erro identificado pelo Sr. Adilson - Hering (Ze).

               01/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)

               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

               09/09/2009 - Incluir historicos de transferencia de credito de
                            salario (David).

               08/01/2010 - Acrescentar historico 573 no mesmo CAN-DO do 338
                            (Guilherme/Precise)
                            
               19/05/2010 - Acerto no SUBSTRING do campo craplcm.cdpesqbb
                            (Diego).
                            
               08/02/2012 - Substituido campo craplcm.nrdconta por 
                            crapcex.nrdconta na critica 812 (Diego).
                            
               10/10/2012 - Tratamento para novo campo da 'craphis' de descrição
                            do histórico em extratos (Lucas) [Projeto Tarifas].
               
               07/05/2014 - Removido a crítica 812 de e-mail não cadastrado 
                            para não poluir o arquivo de log. (Douglas)
                            
               05/03/2015 - Ajuste no estouro do format do campo nrdocmto (Daniel).  
                            
               05/01/2017 - Ajuste para quando enviar extrato CNAB240 por email 
                            fazer ux2dos (Tiago #820277)
..............................................................................*/
{ includes/var_batch.i "NEW" } 
{ includes/var_cnab.i "NEW" }  

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF    VAR  aux_nmarqimp     AS CHAR                              NO-UNDO.
DEF    VAR  aux_hrtransa     AS CHAR                              NO-UNDO.
DEF    VAR  aux_lshistor     AS CHAR                              NO-UNDO.
DEF    VAR  aux_nrdocmto     AS CHAR                              NO-UNDO.
DEF    VAR  aux_dsextrat     AS CHAR                              NO-UNDO.
DEF    VAR  aux_uldiames     AS DATE                              NO-UNDO.
DEF    VAR  aux_dtinicio     AS DATE    FORMAT "99/99/9999"       NO-UNDO.
DEF    VAR  aux_dtquizna     AS DATE    FORMAT "99/99/9999"       NO-UNDO.
DEF    VAR  aux_dtlimite     AS DATE                              NO-UNDO.
DEF    VAR  aux_vlstotal     AS DECIMAL                           NO-UNDO.

/*Saldo bloqueado mais de 24h*/
DEF    VAR  aux_vlmais24     AS DECIMAL                           NO-UNDO.

/*Saldo bloqueado ate 24h*/
DEF    VAR  aux_vlmeno24     AS DECIMAL                           NO-UNDO.

ASSIGN glb_cdprogra = "crps402".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0   THEN
     DO:
         RUN fontes/fimprg.p.
         QUIT.
     END.

    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN       
         DO:
             glb_cdcritic = 651.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" + glb_dscritic +
                                ">> log/proc_batch.log").
             glb_cdcritic = 0.
             RUN fontes/fimprg.p.
             QUIT.
         END.

/*  Historico de cheques  */
FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "HSTCHEQUES"   AND
                   craptab.tpregist = 0              NO-LOCK NO-ERROR.

IF   AVAILABLE craptab   THEN
     aux_lshistor = craptab.dstextab.
ELSE
     aux_lshistor = "999".

/* analisa se o dia 15 eh dia util senao calcula o primeiro dia util antes
   do dia 15 */
aux_dtquizna = DATE(MONTH(glb_dtmvtolt),15,YEAR(glb_dtmvtolt)).

DO WHILE TRUE:
   IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtquizna))) OR
     
        CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                               crapfer.dtferiad = aux_dtquizna)   THEN
        
        DO:
            aux_dtquizna = aux_dtquizna - 1.
            NEXT.
        END.
   LEAVE.
END.  /* fim DO WHILE TRUE */

/*calcula o ultimo dia util do mes*/
aux_uldiames = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4)
               -  DAY(DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4)).

DO WHILE TRUE:
   IF   CAN-DO("1,7",STRING(WEEKDAY(aux_uldiames))) OR

        CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                               crapfer.dtferiad = aux_uldiames)   THEN
        
        DO:
            aux_uldiames = aux_uldiames - 1.
            NEXT.
        END.
   LEAVE.
END.  /* fim DO WHILE TRUE */

FOR EACH crapcex WHERE 
         crapcex.cdcooper = glb_cdcooper  AND
        (crapcex.tpextrat = 3             OR  
         crapcex.tpextrat = 4)            AND
         /* diario     OU */
         (crapcex.cdperiod = 1            OR
         /* qunzenal E (ultimo dia da quinzena OU ultimo dia do mes) OU */
         (crapcex.cdperiod = 2 AND 
          ((glb_dtmvtolt = aux_dtquizna) OR (glb_dtmvtolt = aux_uldiames))) OR
         /* mensal E ultimo dia do mes */ 
         (crapcex.cdperiod = 3 AND (glb_dtmvtolt = aux_uldiames)))  NO-LOCK.

    ASSIGN aux_vlmais24 = 0
           aux_vlmeno24 = 0.

    IF   crapcex.cdperiod = 1   THEN
         aux_dtinicio = glb_dtmvtolt.
    ELSE
    IF   crapcex.cdperiod = 2 AND (DAY(glb_dtmvtolt) >= DAY(aux_dtquizna))  THEN
         DO:
            IF   glb_dtmvtolt = aux_dtquizna   THEN
                 aux_dtinicio = DATE(MONTH(glb_dtmvtolt),01,YEAR(glb_dtmvtolt)).
            ELSE
            IF   glb_dtmvtolt = aux_uldiames   THEN
                 aux_dtinicio = DATE(MONTH(glb_dtmvtolt),16,YEAR(glb_dtmvtolt)).
         END.
    ELSE
    IF   crapcex.cdperiod = 3 AND (glb_dtmvtolt = aux_uldiames)   THEN
         aux_dtinicio = DATE(MONTH(glb_dtmvtolt),01,YEAR(glb_dtmvtolt)).
          
    FOR EACH cratarq.
        DELETE cratarq.
    END.
    
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                       crapass.nrdconta = crapcex.nrdconta  NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass   THEN     
         DO: 
             glb_cdcritic = 9.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" + glb_dscritic +
                                " CONTA = " + STRING(crapcex.nrdconta) +
                                ">> log/proc_batch.log").
             glb_cdcritic = 0.
             NEXT.
         END.
         

    FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper      AND
                       crapsld.nrdconta = crapass.nrdconta  NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapsld   THEN       
         DO:
             glb_cdcritic = 10.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" + glb_dscritic +
                                " CONTA = " + STRING(crapass.nrdconta) +
                                ">> log/proc_batch.log").
             glb_cdcritic = 0.
             NEXT.
         END.

    CREATE cratarq. /*registro 0*/
    ASSIGN cratarq.cdbccxlt = 997 
           cratarq.nrdolote = 0
           cratarq.tpregist = 0
           cratarq.inpessoa = IF   crapass.inpessoa = 3  THEN   2 
                              ELSE crapass.inpessoa
           cratarq.nrcpfcgc = crapass.nrcpfcgc
           cratarq.cdagenci = crapass.cdagenci
           cratarq.nrdconta = INTEGER(SUBSTRING(STRING(crapass.nrdconta,
                                                         "99999999"),1,7))
           cratarq.nrdigcta = INTEGER(SUBSTRING(STRING(crapass.nrdconta,
                                                         "99999999"),8,1))
           cratarq.nmprimtl = crapass.nmprimtl
           cratarq.nmrescop = crapcop.nmrescop
           cratarq.cdremess = 1
           cratarq.dtmvtolt = glb_dtmvtolt
               aux_hrtransa = STRING(TIME,"HH:MM:SS")
               aux_hrtransa = REPLACE(aux_hrtransa,":","")
           cratarq.hrtransa = INTEGER(aux_hrtransa). 
    /* fim registro 0 */

    RUN saldo_atual.

    CREATE cratarq. /*registro 1*/
    ASSIGN cratarq.cdbccxlt = 997 
           cratarq.nrdolote = 1 
           cratarq.tpregist = 1
           cratarq.inpessoa = IF   crapass.inpessoa = 3  THEN   2
                              ELSE crapass.inpessoa
           cratarq.nrcpfcgc = crapass.nrcpfcgc
           cratarq.cdagenci = crapass.cdagenci
           cratarq.nrdconta = INTEGER(SUBSTRING(STRING(crapass.nrdconta,
                                                         "99999999"),1,7))
           cratarq.nrdigcta = INTEGER(SUBSTRING(STRING(crapass.nrdconta,
                                                         "99999999"),8,1))
           cratarq.nmprimtl = crapass.nmprimtl 
           cratarq.dtsldini = aux_dtinicio
           cratarq.vlsldini = IF   aux_vlstotal < 0  THEN
                                   aux_vlstotal * -1 
                              ELSE aux_vlstotal
           cratarq.insldini = IF   aux_vlstotal < 0  THEN  "D" 
                              ELSE "C".
    /* fim registro 1 */
    
    FOR EACH craplcm WHERE craplcm.cdcooper  = glb_cdcooper       AND
                           craplcm.nrdconta  = crapsld.nrdconta   AND
                           craplcm.dtmvtolt >= aux_dtinicio       AND
                           craplcm.dtmvtolt <= glb_dtmvtolt       AND
                           craplcm.cdhistor <> 289                AND
                           MONTH(craplcm.dtmvtolt) = MONTH(aux_dtinicio)
                           NO-LOCK USE-INDEX craplcm2
                                  BREAK BY craplcm.nrdconta
                                           BY craplcm.dtmvtolt
                                              BY craplcm.cdhistor
                                                 BY craplcm.nrdocmto:
                                        
        FIND craphis NO-LOCK WHERE craphis.cdcooper = craplcm.cdcooper AND 
                                   craphis.cdhistor = craplcm.cdhistor NO-ERROR.
        IF   NOT AVAILABLE craphis   THEN
             DO:
                 glb_cdcritic = 80.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " CONTA = " + STRING(craplcm.nrdconta) +
                                   ">> log/proc_batch.log").
                 glb_cdcritic = 0.
                 LEAVE.
             END.
             
        IF   CAN-DO("375,376,377,537,538,539,771,772",
                    STRING(craplcm.cdhistor))   THEN
             aux_nrdocmto = STRING(INT(SUBSTRING(craplcm.cdpesqbb,45,8)),
                                       "zzzzz,zzz,9").
        ELSE
        IF   CAN-DO("104,302,303",STRING(craplcm.cdhistor))   THEN
             DO:
                 IF   INT(craplcm.cdpesqbb) > 0   THEN
                      aux_nrdocmto = STRING(INT(craplcm.cdpesqbb),
                                                "zzzzz,zzz,9").
                 ELSE
                      aux_nrdocmto = STRING(craplcm.nrdocmto,"zzz,zzz,zz9").   
             END.
        ELSE     
        IF   craplcm.cdhistor = 418   THEN
             aux_nrdocmto = "    " + STRING(SUBSTR(craplcm.cdpesqbb,
                                                   60,07)).
        ELSE
             aux_nrdocmto =  IF   craplcm.cdhistor = 100   THEN  
                                  IF   craplcm.cdpesqbb <> ""   THEN 
                                       craplcm.cdpesqbb
                                  ELSE 
                                       STRING(craplcm.nrdocmto,"zzz,zzz,zz9")
                             ELSE 
                             IF   CAN-DO(aux_lshistor,STRING(craplcm.cdhistor))
                                  THEN
                                      STRING(craplcm.nrdocmto,"z,zzz,zz9,9")
                             ELSE 
                             IF   LENGTH(STRING(craplcm.nrdocmto)) < 10   THEN 
                                  STRING(craplcm.nrdocmto,"zzzzzzz,zz9")
                             ELSE 
                                  SUBSTR(STRING(craplcm.nrdocmto,
                                                "9999999999999999999999999"),4,11).
                                                   
        ASSIGN aux_dsextrat = IF  CAN-DO("24,27,47,78,156,191,338,351,399,573",
                                  STRING(craplcm.cdhistor))            THEN 
                                        craphis.dsextrat + craplcm.cdpesqbb
                              ELSE 
                                  craphis.dsextrat.

        /* Se pagamento de parcela, insere num. da parcela da descr. do extrato */
        IF  craplcm.nrparepr > 0 THEN
            DO:
                FIND crapepr WHERE crapepr.cdcooper = craplcm.cdcooper AND
                                   crapepr.nrdconta = craplcm.nrdconta AND
                                   crapepr.nrctremp = INT(craplcm.cdpesqbb)
                                   NO-LOCK NO-ERROR NO-WAIT.
      
                IF AVAIL crapepr THEN
                    ASSIGN aux_dsextrat = SUBSTRING(aux_dsextrat,1,13) + " "
                                          + STRING(craplcm.nrparepr,"999") 
                                          + "/" + STRING(crapepr.qtpreemp,"999").
      
            END.

        IF   craphis.inhistor >= 1   AND   craphis.inhistor <= 5   THEN
             DO:
                 aux_vlstotal = aux_vlstotal + craplcm.vllanmto.

                 IF   craphis.inhistor <> 1  AND  craphis.inhistor <> 2   THEN
                      DO:
                          FIND crapdpb WHERE 
                               crapdpb.cdcooper = glb_cdcooper       AND
                               crapdpb.dtmvtolt = craplcm.dtmvtolt   AND
                               crapdpb.cdagenci = craplcm.cdagenci   AND
                               crapdpb.cdbccxlt = craplcm.cdbccxlt   AND
                               crapdpb.nrdolote = craplcm.nrdolote   AND
                               crapdpb.nrdconta = craplcm.nrdconta   AND
                               crapdpb.nrdocmto = craplcm.nrdocmto
                               NO-LOCK NO-ERROR.

                          IF   NOT AVAILABLE crapdpb   THEN
                               DO:
                                   glb_cdcritic = 82.
                                   RUN fontes/critic.p.
                                   UNIX SILENT VALUE("echo " + STRING(TIME,
                                                     "HH:MM:SS") + " - " +
                                                     glb_cdprogra + "' --> '" +
                                                     glb_dscritic + " CONTA = "
                                                     + STRING(craplcm.nrdconta)
                                                     + ">> log/proc_batch.log").
                                   glb_cdcritic = 0.
                                   LEAVE.
                               END.
                                
                          /* bloqueados */ 
                          IF   crapdpb.dtliblan = glb_dtmvtopr   THEN
                               aux_vlmeno24 = aux_vlmeno24 + craplcm.vllanmto.
                          ELSE
                               aux_vlmais24 = aux_vlmais24 + craplcm.vllanmto.

                      END.
             END.
        ELSE
        IF   craphis.inhistor >= 11   AND    craphis.inhistor <= 15   THEN
             aux_vlstotal = aux_vlstotal - craplcm.vllanmto.
        ELSE
             DO:
                 glb_cdcritic = 83.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " CONTA = " + STRING(craplcm.nrdconta) +
                                   ">> log/proc_batch.log").
                 glb_cdcritic = 0.
                 LEAVE.
             END.

        CREATE cratarq. 
        ASSIGN cratarq.cdbccxlt = 997 
               cratarq.nrdolote = 1 
               cratarq.tpregist = 3           
               cratarq.inpessoa = IF   crapass.inpessoa = 3  THEN 2 
                                  ELSE crapass.inpessoa
               cratarq.nrcpfcgc = crapass.nrcpfcgc
               cratarq.cdagenci = crapass.cdagenci
               cratarq.nrdconta = INTEGER(SUBSTRING(STRING(crapass.nrdconta,
                                                             "99999999"),1,7))
               cratarq.nrdigcta = INTEGER(SUBSTRING(STRING(crapass.nrdconta,
                                                             "99999999"),8,1))
               cratarq.nmprimtl = crapass.nmprimtl
               cratarq.iniscpmf = IF   crapass.iniscpmf = 0  THEN  "N" 
                                  ELSE "S"
               cratarq.dtlanmto = craplcm.dtmvtolt
               cratarq.dtliblan = IF   AVAILABLE crapdpb   THEN 
                                       crapdpb.dtliblan
                                  ELSE craplcm.dtmvtolt
               cratarq.vllanmto = IF   craplcm.vllanmto < 0   THEN
                                       craplcm.vllanmto * -1  
                                  ELSE craplcm.vllanmto
               cratarq.cdhistor = craplcm.cdhistor
               cratarq.dsextrat = aux_dsextrat
               cratarq.nrdocmto = aux_nrdocmto.

               IF  (craphis.inhistor >= 1  AND  craphis.inhistor <= 5)   THEN 
                   cratarq.indebcre = "C".
               ELSE 
               IF  (craphis.inhistor >= 11 AND  craphis.inhistor <= 15)  THEN
                   cratarq.indebcre = "D".
    
    END.  /*  Fim do FOR EACH -- Leitura dos lancamentos  */
    /* fim registro 3 */

    CREATE cratarq. /*registro 5*/
    ASSIGN cratarq.cdbccxlt = 997 
           cratarq.nrdolote = 1 
           cratarq.tpregist = 5
           cratarq.inpessoa = IF   crapass.inpessoa = 3  THEN   2 
                              ELSE crapass.inpessoa
           cratarq.nrcpfcgc = crapass.nrcpfcgc
           cratarq.cdagenci = crapass.cdagenci
           cratarq.nrdconta = INTEGER(SUBSTRING(STRING(crapass.nrdconta,
                                                         "99999999"),1,7))
           cratarq.nrdigcta = INTEGER(SUBSTRING(STRING(crapass.nrdconta,
                                                         "99999999"),8,1))
           cratarq.nmprimtl = crapass.nmprimtl
           cratarq.vlmais24 = aux_vlmais24
           cratarq.vlmeno24 = aux_vlmeno24
           cratarq.vllimite = crapass.vllimcre
           cratarq.dtsldfin = glb_dtmvtolt 
     /*    aux_vlstotal = aux_vlstotal - cratarq.vlmais24 - cratarq.vlmeno24 */
           cratarq.vlsldfin = IF   aux_vlstotal < 0   THEN  aux_vlstotal * -1  
                              ELSE aux_vlstotal
           cratarq.insldfin = IF   aux_vlstotal < 0   THEN  "D" 
                              ELSE "C".
    /* fim registro 5 */
    
    CREATE cratarq. /*registro 9*/
    ASSIGN cratarq.cdbccxlt = 997 
           cratarq.nrdolote = 9999 
           cratarq.tpregist = 9.
    /* fim registro 9 */

    aux_nmarqimp = "extcc_" + STRING(crapcex.nrdconta) + "_" + 
                   STRING(DAY(glb_dtmvtolt), "99") + 
                   STRING(MONTH(glb_dtmvtolt), "99") + "_240.txt".

    /* fontes/crps_cnab.p --> cria arquivo*/
    RUN fontes/crps_cnab.p (aux_nmarqimp, "E").

    IF   crapcex.tpextrat = 3   THEN
         DO:
             FIND crapcem WHERE crapcem.cdcooper = glb_cdcooper      AND
                                crapcem.nrdconta = crapcex.nrdconta  AND
                                crapcem.idseqttl = 1                 AND
                                crapcem.cddemail = crapcex.cddemail  
                                NO-LOCK NO-ERROR.
              
             IF   NOT AVAILABLE crapcem   THEN
             DO:
                 NEXT.
             END.
         END.

    UNIX SILENT VALUE("mv arq/" + aux_nmarqimp + " salvar/" + aux_nmarqimp + 
                      " 2> /dev/null").

    IF   crapcex.tpextrat = 3   THEN
         DO:
            /* Move para diretorio converte para utilizar na BO */
            UNIX SILENT VALUE 
                       ("ux2dos " + "salvar/" + aux_nmarqimp + " > /usr/coop/" +
                        crapcop.dsdircop + "/converte/" + aux_nmarqimp +
                        " 2> /dev/null").
         
            /* envio de email */ 
            RUN sistema/generico/procedures/b1wgen0011.p
                PERSISTENT SET b1wgen0011.
         
            RUN enviar_email IN b1wgen0011
                   (INPUT glb_cdcooper,
                    INPUT glb_cdprogra,
                    INPUT crapcem.dsdemail,
                    INPUT '"EXTRATO C/C - PADRAO CNAB"',
                    INPUT aux_nmarqimp,
                    INPUT FALSE).

            DELETE PROCEDURE b1wgen0011.
         END.
    ELSE
    IF   crapcex.tpextrat = 4   THEN
         DO:
             /* Envia pela Nexxera */
             UNIX SILENT VALUE("cp salvar/" + aux_nmarqimp + 
                               " /usr/nexxera/envia/" + aux_nmarqimp + 
                               " 2> /dev/null").
         END.
         
END.

RUN fontes/fimprg.p.

PROCEDURE saldo_atual.

    aux_vlstotal = crapsld.vlsdmesa.
    aux_dtlimite = aux_dtinicio - DAY(aux_dtinicio).

    /*  Verifica se deve compor saldo anterior  */
    IF   DAY(aux_dtinicio) > 1   THEN
         DO:
             FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper       AND
                                    craplcm.nrdconta = crapsld.nrdconta   AND
                                    craplcm.dtmvtolt > aux_dtlimite       AND
                                    craplcm.dtmvtolt < aux_dtinicio       AND
                                    craplcm.cdhistor <> 289               AND
                                    MONTH(craplcm.dtmvtolt) =
                                    MONTH(aux_dtinicio)              
                                    USE-INDEX craplcm2 NO-LOCK:

                 FIND craphis NO-LOCK WHERE
                                   craphis.cdcooper = craplcm.cdcooper AND 
                                   craphis.cdhistor = craplcm.cdhistor NO-ERROR.        
                 IF   NOT AVAILABLE craphis   THEN
                      DO:
                          glb_cdcritic = 80.
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '" + 
                                            glb_dscritic + " CONTA = " + 
                                            STRING(craplcm.nrdconta) +
                                            ">> log/proc_batch.log").
                          glb_cdcritic = 0.
                          LEAVE.
                      END.

                 IF   craphis.inhistor >= 1  AND  craphis.inhistor <= 5   THEN
                      aux_vlstotal = aux_vlstotal + craplcm.vllanmto.
                 ELSE
                 IF   craphis.inhistor >= 11  AND  craphis.inhistor <= 15  THEN
                      aux_vlstotal = aux_vlstotal - craplcm.vllanmto.
                 ELSE
                      DO:
                          glb_cdcritic = 83.
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                            " - " + glb_cdprogra + "' --> '" + 
                                            glb_dscritic + " CONTA = " + 
                                            STRING(craplcm.nrdconta) +
                                            ">> log/proc_batch.log").
                          glb_cdcritic = 0.
                          LEAVE.
                      END.

             END.  /*  Fim do FOR EACH*/
         END.

END PROCEDURE.

/*............................................................................*/
