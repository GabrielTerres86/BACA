/* ............................................................................

   Programa: Fontes/crps364.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Deborah          
   Data    : Outubro/2003                      Ultima atualizacao: 31/07/2015

   Dados referentes ao programa:

   Frequencia: Diario                       
   Objetivo  : Executa pelo cron, a meia noite, diariamente
               Apura o saldo dos cashes e vira a data de movimento


   Alteracoes: 10/11/2003 - Aumentar campo de nome da cooperativa (Ze Eduardo).
   
               30/06/2005 - Alimentado campo cdcooper da tabela crapstf (Diego).

               04/10/2005 - Alterada leitura tabela crapcop(Mirtes)
               
               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               29/06/2007 - Tratar boletim de caixa PA 90(Internet) (David).
               
               05/06/2008 - Tratar historico 359(Eduardo)
               
               07/11/2008 - Troca do Histor. 359 p/ 767 (Estorno Debito) (Ze).
               
               02/10/2009 - Aumento na numeracao do lote: 3200 (Diego).
               
               14/06/2010 - Tratamento para o sistema TAA (Evandro).
               
               28/10/2010 - Acidionar históricos 918(Saque) e 920(Estorno)
                            devido ao TAA compartilhado (Henrique).
                            
               08/02/2011 - Substituido nome de arquivo de log de farol.log 
                            para cash.log (Elton).              
                            
               01/03/2011 - Ajuste na verificacao de dia util para Cecred, que
                            roda o processo na segunda-feira (David).
                            
               04/06/2012 - Adaptação dos fontes para projeto Oracle. Retirada
                            do prefixo "banco" (Guilherme Maba).
                          - Eliminar EXTENT vldmovto (Evandro).
                          
               21/01/2014 - Incluir VALIDATE crapstf, crapbcx (Lucas R.)
               
               21/03/2014 - Ajuste Oracle (Daniel).
               
               05/04/2014 - Criar crapstf e crapbcx somente se não existir
                            registros para a data (Guilherme).
                            
               04/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
               
               31/07/2015 - Ajuste para retirar o caminho absoluto na chamada
                            de fontes
                           (Adriano - SD 314469).
                           
............................................................................. */

DEF VAR aux_dtmvtolt AS CHAR FORMAT "x(22)"                            NO-UNDO.
DEF VAR aux_dsdircop AS CHAR FORMAT "x(20)"                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqdbo AS CHAR                                           NO-UNDO.

DEF VAR aux_dtmovime AS DATE FORMAT "99/99/9999"                       NO-UNDO.

DEF VAR aux_vlcredit AS DECI                                           NO-UNDO.
DEF VAR aux_vldebito AS DECI                                           NO-UNDO.
DEF VAR aux_vldsdini AS DECI                                           NO-UNDO.
DEF VAR aux_vldsdfin AS DECI                                           NO-UNDO.

DEF VAR glb_cdcooper AS INTE FORMAT "zz9"                              NO-UNDO.
DEF VAR aux_qtautent AS INTE                                           NO-UNDO.

DEF VAR h-b2crap13   AS HANDLE                                         NO-UNDO.
DEF VAR h-b1crap12   AS HANDLE                                         NO-UNDO.

DEF STREAM str_1.

glb_cdcooper = INT(OS-GETENV("CDCOOPER")).

IF   glb_cdcooper = ?   THEN
     glb_cdcooper = 0.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

INPUT STREAM str_1 THROUGH echo $EMPRESA 2> /dev/null NO-ECHO.

SET STREAM str_1 aux_dsdircop.

aux_dtmvtolt = STRING(TODAY,"99/99/9999") + " as " +
               STRING(TIME,"HH:MM:SS").
               
/* Executa somente se o dia anterior for util */

IF   glb_cdcooper = 3   THEN
     aux_dtmovime = TODAY.
ELSE
     aux_dtmovime = TODAY - 1.

IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmovime)))        OR
     CAN-FIND(crapfer WHERE 
              crapfer.cdcooper = glb_cdcooper     AND
              crapfer.dtferiad = aux_dtmovime)    THEN
     
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
                                      " - crps364 : Sistema sem data >> " +
                                      " /usr/coop/" +
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
   FOR EACH craptfn WHERE craptfn.cdcooper = glb_cdcooper   AND
                          craptfn.tpterfin = 6:
   
       /* Acha ultimo saldo */
       FIND crapstf WHERE
            crapstf.cdcooper = glb_cdcooper            AND
            crapstf.dtmvtolt = crapdat.dtmvtolt  AND
            crapstf.nrterfin = craptfn.nrterfin  NO-LOCK NO-ERROR.
      
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
                craplcm.cdcooper = glb_cdcooper                   AND
                craplcm.dtmvtolt = crapdat.dtmvtolt               AND 
                craplcm.cdagenci = craptfn.cdagenci               AND
               (craplcm.cdhistor = 316                            OR
                craplcm.cdhistor = 918)                           AND
                craplcm.cdbccxlt = 100                            AND
                craplcm.nrdolote = (320000 + craptfn.nrterfin)
                USE-INDEX craplcm3 NO-LOCK.

           aux_vldsdfin = aux_vldsdfin - craplcm.vllanmto.
       END.


       FOR EACH craplcm WHERE
                craplcm.cdcooper = glb_cdcooper                   AND
                craplcm.dtmvtolt = crapdat.dtmvtolt         AND
                craplcm.cdagenci = craptfn.cdagenci         AND
               (craplcm.cdhistor = 767                            OR
                craplcm.cdhistor = 920)                           AND
                craplcm.cdbccxlt = 100                            AND
                craplcm.nrdolote = (320000 + craptfn.nrterfin)
                USE-INDEX craplcm3 NO-LOCK.

            aux_vldsdfin = aux_vldsdfin + craplcm.vllanmto.
       END.
              
       /* Le lancamentos de suprimento e recolhimento */
       FOR EACH craplfn WHERE 
                craplfn.cdcooper = glb_cdcooper               AND
                craplfn.dtmvtolt = crapdat.dtmvtolt     AND 
                craplfn.nrterfin = craptfn.nrterfin     AND
               (craplfn.tpdtrans = 4                          OR  
                craplfn.tpdtrans = 5)                         NO-LOCK.
                
           IF   craplfn.tpdtrans = 4 THEN
                aux_vldsdfin = aux_vldsdfin + craplfn.vltransa.
           ELSE
                aux_vldsdfin = aux_vldsdfin - craplfn.vltransa.
       END.


       /* Fechamento somente para o sistema antigo.
          O sistema TAA faz fechamento on-line (b1wgen0025) */
       IF  NOT craptfn.flsistaa  THEN
           DO:

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
                                         STRING(crapdat.dtmvtolt,
                                                "99/99/9999") +
                                         " >> /usr/coop/" + aux_dsdircop + 
                                         "/log/cash.log").
                   END.
                   
              IF NOT CAN-FIND(crapstf WHERE
                              crapstf.cdcooper = crapcop.cdcooper AND
                              crapstf.dtmvtolt = crapdat.dtmvtopr AND
                              crapstf.nrterfin = craptfn.nrterfin) THEN
              DO:
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
              ELSE
              DO:
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") 
                                    + " - crps364" + 
                                    "' --> '" + 
                                    "Valor saldo inicial na tabela "
                                    + "crapstf ja havia sido apurado" 
                                    + " >> /usr/coop/" + 
                                    aux_dsdircop + 
                                    "/log/proc_batch.log").
              END.
           END.
   END.

   IF  crapcop.cdcooper <> 3   THEN
       DO:
           RUN boletim_caixa(INPUT 90).

           RUN boletim_caixa(INPUT 91).
       END.       
           
END.  /* Fim da transacao */

PROCEDURE proc_erro_fechamento_caixa:

    DEFINE INPUT PARAM par_cdagenci AS  INT         NO-UNDO.

    FIND FIRST craperr WHERE craperr.cdcooper = crapcop.cdcooper AND
                             craperr.cdagenci = par_cdagenci     AND
                             craperr.nrdcaixa = 900
                                   NO-LOCK NO-ERROR.

    IF   AVAILABLE craperr   THEN
         aux_dscritic = craperr.dscritic.
    ELSE
         aux_dscritic = "Erro no fechamento do caixa 900 do PA " + 
                        STRING(par_cdagenci) + ".".
                                                 
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - crps364" + 
                      "' --> '" + aux_dscritic + " >> /usr/coop/" + 
                      aux_dsdircop + "/log/cash.log").

END PROCEDURE.


PROCEDURE boletim_caixa:

    DEFINE INPUT PARAM par_cdagenci AS  INT         NO-UNDO.

    /* Tratamento para boletim de caixa do PA 90 e 91 */

    /* Fechamento de caixa */ 
    ASSIGN aux_nmarqdbo = "dbo/b2crap13.p"
           aux_vldsdfin = 0
           aux_qtautent = 0
           aux_vldsdini = 0.


    RUN VALUE(aux_nmarqdbo) PERSISTENT SET h-b2crap13.

    IF   VALID-HANDLE(h-b2crap13)   THEN
         DO:
             DO WHILE TRUE:

                 FIND crapbcx WHERE 
                      crapbcx.cdcooper = crapcop.cdcooper       AND
                      crapbcx.dtmvtolt = crapdat.dtmvtolt AND
                      crapbcx.cdagenci = par_cdagenci           AND
                      crapbcx.nrdcaixa = 900                    AND
                      crapbcx.cdsitbcx = 1 
                      USE-INDEX crapbcx1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAILABLE crapbcx   THEN
                      DO:
                          IF   LOCKED crapbcx   THEN
                               DO:
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT.
                               END.
                          ELSE
                               DO:
                                   UNIX SILENT VALUE(
                                           "echo " + STRING(TIME,"HH:MM:SS") +
                                           " - crps364" + "' --> '" +
                                           "Boletim de caixa 900 do PA " +
                                           STRING(par_cdagenci) + "nao" +
                                           " encontrado." +
                                           " >> /usr/coop/" + aux_dsdircop +
                                           "/log/cash.log").
                                   LEAVE.
                               END.
                      END.

                 RUN disponibiliza-dados-boletim-caixa IN h-b2crap13 
                                                   (INPUT  crapcop.nmrescop,
                                                    INPUT  "996",
                                                    INPUT  par_cdagenci,
                                                    INPUT  900,
                                                    INPUT  ROWID(crapbcx),
                                                    INPUT  " ",
                                                    INPUT  NO, 
                                                    INPUT  "CRPS364",
                                                    OUTPUT aux_vlcredit,
                                                    OUTPUT aux_vldebito).

                 IF   RETURN-VALUE = "NOK"   THEN
                      RUN proc_erro_fechamento_caixa (INPUT par_cdagenci).
                 ELSE
                      DO:
                          aux_vldsdfin = aux_vlcredit - aux_vldebito.

                          IF   aux_vldsdfin <> 0   THEN
                               UNIX SILENT VALUE("echo " +
                                                 STRING(TIME,"HH:MM:SS") +
                                                 " - crps364" + "' --> '" +
                                                 "Diferenca caixa 900 " +
                                                 " PA " +
                                                 STRING(par_cdagenci) + " - " +
                                                 "R$" + 
                                                 TRIM(STRING(aux_vldsdfin,
                                                             "zzz,zzz,zz9.99")) +
                                                 " >> /usr/coop/" + 
                                                 aux_dsdircop + 
                                                 "/log/cash.log").
                      END.

                 ASSIGN aux_nmarqdbo = "dbo/b1crap12.p".

                 RUN VALUE(aux_nmarqdbo) PERSISTENT SET h-b1crap12.

                 IF   VALID-HANDLE(h-b1crap12)   THEN
                      DO:
                          RUN retorna-dados-fechamento IN h-b1crap12 
                                                      (INPUT  crapcop.nmrescop,
                                                       INPUT  "996",
                                                       INPUT  par_cdagenci,
                                                       INPUT  900,
                                                       OUTPUT aux_qtautent,
                                                       OUTPUT aux_vldsdini).

                          DELETE PROCEDURE h-b1crap12.

                          IF   RETURN-VALUE = "NOK"   THEN
                               RUN proc_erro_fechamento_caixa (INPUT par_cdagenci).
                      END.
                 ELSE
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                        " - crps364" + "' --> '" +
                                        "Handle Invalido para BO b1crap12." +
                                        " >> /usr/coop/" + aux_dsdircop + 
                                        "/log/cash.log").

                 ASSIGN crapbcx.cdsitbcx = 2
                        crapbcx.hrfecbcx = TIME
                        crapbcx.nrdlacre = 0
                        crapbcx.qtautent = aux_qtautent
                        crapbcx.vldsdfin = aux_vldsdfin.

                 LEAVE.

             END. /*** Fim do DO WHILE TRUE ***/

             DELETE PROCEDURE h-b2crap13.
         END.
    ELSE
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - crps364" + "' --> '" +
                           "Handle Invalido para BO b2crap13." +
                           " >> /usr/coop/" + aux_dsdircop + 
                           "/log/cash.log").

    /* Abertura do caixa */
    IF  NOT CAN-FIND(crapbcx WHERE
                     crapbcx.cdcooper = crapcop.cdcooper AND
                     crapbcx.dtmvtolt = crapdat.dtmvtopr AND
                     crapbcx.cdagenci = par_cdagenci     AND
                     crapbcx.nrdcaixa = 900              AND
                     crapbcx.nrseqdig = 1) THEN
    DO:
        CREATE crapbcx.
        ASSIGN crapbcx.cdcooper = crapcop.cdcooper 
               crapbcx.dtmvtolt = crapdat.dtmvtopr
               crapbcx.cdagenci = par_cdagenci
               crapbcx.nrdcaixa = 900
               crapbcx.nrseqdig = 1
               crapbcx.cdopecxa = "996"
               crapbcx.cdsitbcx = 1
               crapbcx.nrdlacre = 0
               crapbcx.nrdmaqui = 900
               crapbcx.qtautent = 0
               crapbcx.vldsdini = 0
               crapbcx.vldsdfin = 0
               crapbcx.hrabtbcx = TIME
               crapbcx.hrfecbcx = 0.
        VALIDATE crapbcx.
    END.
    ELSE
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") 
                          + " - crps364" + 
                          "' --> '" + 
                          "Ja foi criado controle de "
                          + " abertura do caixa para o"
                          + "PA " + STRING(par_cdagenci) 
                          + " >> /usr/coop/" + 
                          aux_dsdircop + 
                          "/log/proc_batch.log").
    END.

END PROCEDURE.

/* .......................................................................... */
