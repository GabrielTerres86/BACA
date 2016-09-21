/* ............................................................................

   Programa: Fontes/crps258.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah          
   Data    : Maio/99                             Ultima atualizacao: 21/03/2014

   Dados referentes ao programa:

   Frequencia: Diario                       
   Objetivo  : Executa pelo cron, a meia noite, diariamente
               Apura o saldo dos cashes e vira a data de movimento

   Alteracoes: 20/12/1999 - Capturar da variavel de ambiente EMPRESA o direto-
                            rio de uso da cooperativa (Edson). 

               30/06/2005 - Alimentado campo cdcooper da tabela crapstf (Diego).

               04/10/2005 - Alterada leitura tabela crapcop(Mirtes)

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               16/01/2008 - Alterar para novo sistema de CASH - FOTON (Ze).
               
               07/11/2008 - Troca do Histor. 359 p/ 767 (Estorno Debito) (Ze).
               
               02/10/2009 - Aumento na numeracao do lote: 3200 (Diego).
               
               28/10/2010 - Inclusão dos historicos 918(Saque) e 920(Estorno)
                            devido ao TAA compartilhado (Henrique).
               
               28/02/2011 - Removida a chamada de  bloqueio e liberação do banco
                            farol;
                          - Substituido nome do arquivo de log de farol.log para
                            cash.log (Elton).
                            
               04/06/2012 - Adaptação dos fontes para projeto Oracle. Retirada
                            do prefixo "banco" (Guilherme Maba).
                          - Eliminar EXTENT vldmovto (Evandro).
                          
               20/01/2013 - Incluir VALIDATE crapstf (Lucas R.) 
               
               21/03/2014 - Ajuste Oracle (Daniel).
............................................................................. */

DEF VAR aux_dtmvtolt AS CHAR FORMAT "x(022)"                       NO-UNDO.
DEF VAR aux_dsdircop AS CHAR                                       NO-UNDO.
DEF VAR aux_dtmovime AS DATE FORMAT "99/99/9999"                   NO-UNDO.
DEF VAR aux_vldsdfin AS DECIMAL                                    NO-UNDO.
DEF VAR glb_cdcooper AS INT  FORMAT "zz9"                          NO-UNDO.

DEF STREAM str_1.


glb_cdcooper = INT(OS-GETENV("CDCOOPER")).

IF   glb_cdcooper = ?   THEN
     glb_cdcooper = 0.

FIND  crapcop WHERE
      crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

INPUT STREAM str_1 THROUGH echo $EMPRESA 2> /dev/null NO-ECHO.

SET STREAM str_1 aux_dsdircop.

aux_dtmvtolt = STRING(TODAY,"99/99/9999") + " as " +
               STRING(TIME,"HH:MM:SS").
               
/* Executa somente se o dia anterior for util */

aux_dtmovime = TODAY - 1.

IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmovime))) OR
     CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                            crapfer.dtferiad = aux_dtmovime) THEN
     QUIT.

DO TRANSACTION ON ERROR UNDO, RETURN.

   DO WHILE TRUE:

      /* Alimenta data dos cashes */
      
      FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE crapdat   THEN
           IF   LOCKED crapdat   THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE   
                DO:
                    UNIX SILENT VALUE("echo " + aux_dtmvtolt + 
                                      " - crps258 : Sistema sem data " +
                                      " >> /usr/coop/" +
                                      aux_dsdircop + "/log/cash.log").
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
      ELSE
           crapdat.dtmvtocd = crapdat.dtmvtopr.
           
      LEAVE.

   END.


   /* Troca numero sequencial */
   
   FIND CRAPSQU WHERE NMTABELA = 'CRAPNSU' 
                  AND NMDCAMPO = 'NRSEQUNI'
                  AND DSDCHAVE = TRIM(STRING(glb_cdcooper))
                  EXCLUSIVE-LOCK NO-ERROR.

   IF AVAIL(CRAPSQU) THEN
       ASSIGN CRAPSQU.NRSEQATU = 0.
                                   
   aux_vldsdfin = 0.
   
   /* Apura saldo de cada cash */
   
   FOR EACH craptfn WHERE craptfn.cdcooper = glb_cdcooper    AND
                          craptfn.tpterfin = 6:
   
       /* Acha ultimo saldo */
       
       FIND crapstf WHERE 
            crapstf.cdcooper = glb_cdcooper             AND
            crapstf.dtmvtolt = crapdat.dtmvtolt   AND
            crapstf.nrterfin = craptfn.nrterfin   NO-LOCK NO-ERROR.
      
       IF   AVAILABLE crapstf THEN
            aux_vldsdfin = crapstf.vldsdini.
       
       ELSE
            DO:
                craptfn.insensor[8] = 1.
                UNIX SILENT VALUE("echo " + aux_dtmvtolt + 
                                  " - crps258 : Cash " + 
                                  STRING(craptfn.nrterfin) +
                                  " sem registro de saldo >> /usr/coop/" +
                                  aux_dsdircop + "/log/cash.log").
                NEXT.
            END.
        
       /* Le lancamentos de saque */
       
       FOR EACH craplcm WHERE 
                craplcm.cdcooper = glb_cdcooper            AND
                craplcm.dtmvtolt = crapdat.dtmvtolt  AND 
                craplcm.cdagenci = craptfn.cdagenci  AND
                craplcm.cdbccxlt = 100                     AND
                craplcm.nrdolote = (320000 + craptfn.nrterfin)
                USE-INDEX craplcm3 NO-LOCK.
                
           IF   craplcm.cdhistor = 316 OR
                craplcm.cdhistor = 918 THEN
                aux_vldsdfin = aux_vldsdfin - craplcm.vllanmto.
       END.
       
       /* Le lancamentos de saque */
       
       FOR EACH craplcm WHERE 
                craplcm.cdcooper = glb_cdcooper            AND
                craplcm.dtmvtolt = crapdat.dtmvtolt  AND 
                craplcm.cdagenci = craptfn.cdagenci  AND
                craplcm.cdbccxlt = 100                     AND
                craplcm.nrdolote = (320000 + craptfn.nrterfin)
                USE-INDEX craplcm3 NO-LOCK:
                
           IF   craplcm.cdhistor = 767  OR
                craplcm.cdhistor = 920 THEN
                aux_vldsdfin = aux_vldsdfin + craplcm.vllanmto.
       END.


       /* Le lancamentos de suprimento e recolhimento */
       
       FOR EACH craplfn WHERE 
                craplfn.cdcooper = glb_cdcooper            AND
                craplfn.dtmvtolt = crapdat.dtmvtolt  AND 
                craplfn.nrterfin = craptfn.nrterfin  AND
               (craplfn.tpdtrans = 4                       OR  
                craplfn.tpdtrans = 5)                      NO-LOCK.
                
           IF   craplfn.tpdtrans = 4 THEN
                aux_vldsdfin = aux_vldsdfin + craplfn.vltransa.
           ELSE
                aux_vldsdfin = aux_vldsdfin - craplfn.vltransa.
               
       END.
       
       /* Confere saldos para atualizar sensor de diferenca */
         
       IF   (aux_vldsdfin = (craptfn.vltotcas[1] + 
                             craptfn.vltotcas[2] +
                             craptfn.vltotcas[3] +
                             craptfn.vltotcas[4] +
                             craptfn.vltotcas[5])) AND
            (aux_vldsdfin = crapstf.vldsdfin)      THEN
            craptfn.insensor[8] = 0.
       ELSE
            DO:
                craptfn.insensor[8] = 1.
                UNIX SILENT VALUE("echo " + aux_dtmvtolt + 
                                  " - crps258 : Cash " + 
                                  STRING(craptfn.nrterfin) +
                                  " com diferenca no saldo do dia " +
                                  STRING(crapdat.dtmvtolt,"99/99/9999") +
                                  " >> /usr/coop/" + aux_dsdircop + 
                                  "/log/cash.log").
            END.
            

       /* Cria saldo inicial do dia seguinte */
       
       CREATE crapstf.
       ASSIGN crapstf.dtmvtolt = crapdat.dtmvtopr
              crapstf.nrterfin = craptfn.nrterfin
              crapstf.vldsdini = (craptfn.vltotcas[1] + 
                                        craptfn.vltotcas[2] +
                                        craptfn.vltotcas[3] +
                                        craptfn.vltotcas[4] +
                                        craptfn.vltotcas[5])
              crapstf.vldsdfin = crapstf.vldsdini
              crapstf.cdcooper = crapcop.cdcooper.

       VALIDATE crapstf.
   END.
   
END.  /* Fim da transacao */

/* .......................................................................... */

