/* .............................................................................

   Programa: Fontes/lanrdai.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/94                     Ultima atualizacao: 01/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela lanrda.

   Alteracoes: 09/05/95 - Alimentar o campo craprda.dtsaqtot com ? na criacao
                          do craprda (Edson).

               25/09/95 - Tratar novos campos no craprda (Deborah).

               10/09/95 - Nao permitir inclusao de titulos com numeros maior que
                          499.999 (Odair).

               24/10/95 - Alterado para tratar craprda.dtsdrdan (Deborah).

               22/02/96 - Alterado para alimentar os campos do craprda:
                          qtmesext, dtiniext, dtfimext na criacao (Odair).

               22/11/96 - Alterado para tratar tpaplica (Odair).

               26/12/96 - Alterado para nao permitir aplicacoes RDCA60 depois
                          do dia 28 e nao exigir mais a taxa (Deborah).

               19/11/97 - Alterado para tratar RDCA 30 DIAS sem rendimento dia-
                          rio (Edson).

               16/02/98 - Alterado para guardar a CPMF a ser abonada (Deborah).

               17/02/98 - Alterado para avisar o usuario que tem mais de uma
                          aplicacao digitada no dia (Edson).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               09/11/98 - Tratar situacao em prejuizo (Deborah).

               25/01/99 - Tratar abono do IOF (Deborah).

               07/06/1999 - Tratar COMF (Deborah).

               24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               05/02/2001 - Aplicacoes apos o dia 28 do mes. (Eduardo).

               28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).

               26/03/2003 - Incluir tratamento da Concredi (Margarete).

               22/08/2003 - Tratamento para tipo de aplicacao = 5 (CECRED)
                            (Julio).

               24/10/2003 - Nao atualizar mais incalcul (Margarete).

               20/04/2004 - Tratar modo de impressao do extrato (Margarete).

               02/09/2004 - Incluido Flag Conta Investimento(Mirtes).
               
               09/09/2004 - Incluido Flag Debitar Conta Investimento (Evandro).
               
               04/07/2005 - Alimentado campo cdcooper das tabelas craplap
                            e craprda (Diego).

               15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                            de inicio, tab_dtiniabo (Margarete). 

               16/05/2005 - Quando dinheiro para aplicar vem da conta de
                            investimento nao tem cpmf (Margarete).
                            
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Andre

               24/09/2007 - Conversao de rotina ver_capital para BO
                            (Sidnei/Precise)
............................................................................ */

DEF        VAR tab_vllanmto     AS DECIMAL                           NO-UNDO.
DEF        VAR aux_vlalipmf     AS DECIMAL                           NO-UNDO.
DEF        VAR aux_cfrvipmf     AS DECIMAL                           NO-UNDO.
DEF        VAR aux_cdhislan     AS INTEGER                           NO-UNDO.
DEF        VAR tab_dtiniiof     AS DATE                              NO-UNDO.
DEF        VAR tab_dtfimiof     AS DATE                              NO-UNDO.
DEF        VAR tab_txiofrda     AS DECIMAL FORMAT "zzzzzzzz9,999999" NO-UNDO.

{ includes/var_online.i }

{ includes/var_lanrda.i }

{ includes/var_cpmf.i } 

{ sistema/generico/includes/var_internet.i }
DEF VAR h-b1wgen0001 AS HANDLE                                      NO-UNDO.

ASSIGN tel_nrdconta = 0
       tel_tpaplica = 0
       tel_nrdocmto = 0
       tel_flgctain = yes  
       tel_flgdebci = NO
       tel_vllanmto = 0
       tel_tpemiext = 2
       tel_nrseqdig = 1

       aux_cdhislan = 0.

DISPLAY tel_flgctain tel_flgdebci WITH FRAME f_lanrda.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
            /*   CLEAR FRAME f_lanrda.  */
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_nrseqdig
                       WITH FRAME f_lanrda.

               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper AND
                         crapmfx.dtmvtolt = glb_dtmvtolt AND
                         crapmfx.tpmoefix = 2 
                         USE-INDEX crapmfx1 NO-LOCK NO-ERROR.

          IF   NOT AVAILABLE crapmfx THEN
               DO:
                  glb_cdcritic = 140.
                  RUN fontes/critic.p.
                  MESSAGE glb_dscritic + " UFIR ".
                  glb_cdcritic = 0.
                  BELL.
                  RETURN.
               END.

      IF   glb_dtmvtolt > 01/22/1997 AND glb_dtmvtolt < 01/24/1999 THEN
           ASSIGN aux_cfrvipmf = glb_cfrvipmf
                  aux_vlalipmf = glb_vlalipmf.
      ELSE
           ASSIGN aux_cfrvipmf = 1
                  aux_vlalipmf = 0.

      { includes/cpmf.i } 
      
      /*  Tabela com a taxa do IOF */

      FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                         craptab.nmsistem = "CRED"             AND
                         craptab.tptabela = "USUARI"           AND
                         craptab.cdempres = 11                 AND
                         craptab.cdacesso = "CTRIOFRDCA"       AND
                         craptab.tpregist = 1
                         USE-INDEX craptab1 NO-LOCK NO-ERROR.

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
             tab_txiofrda = IF   glb_dtmvtolt >= tab_dtiniiof AND
                                 glb_dtmvtolt <= tab_dtfimiof 
                                 THEN DECIMAL(SUBSTR(craptab.dstextab,23,16))
                                 ELSE 0.

      FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                         craptab.nmsistem = "CRED"        AND
                         craptab.tptabela = "USUARI"      AND
                         craptab.cdempres = 11            AND
                         craptab.cdacesso = "VLREFERDCA"  AND
                         craptab.tpregist = 001           NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE craptab THEN
           DO:
              glb_cdcritic = 596.
              RUN fontes/critic.p.
              MESSAGE glb_dscritic.
              glb_cdcritic = 0.
              BELL.
              RETURN.
           END.

      tab_vllanmto = DECIMAL(craptab.dstextab).

      UPDATE tel_tpaplica tel_nrdconta tel_nrdocmto tel_flgdebci tel_vllanmto
             tel_tpemiext WITH FRAME f_lanrda

      EDITING:

         READKEY.

         IF   FRAME-FIELD = "tel_vllanmto"   THEN
              IF   LASTKEY =  KEYCODE(".")   THEN
                   APPLY 44.
              ELSE
                   APPLY LASTKEY.
         ELSE
              APPLY LASTKEY.

      END.  /*  Fim do EDITING  */

      ASSIGN glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0.

      RUN fontes/digfun.p.

      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                         crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapass   THEN
           DO:
               glb_cdcritic = 9.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.

      IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
           DO:
               glb_cdcritic = 695.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.
      
      IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
           DO:
               glb_cdcritic = 95.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.

      IF   crapass.dtelimin <> ?    THEN
           DO:
               glb_cdcritic = 410.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.

                                            
      RUN sistema/generico/procedures/b1wgen0001.p
          PERSISTENT SET h-b1wgen0001.
      
      IF  VALID-HANDLE(h-b1wgen0001)   THEN
          DO:
              RUN ver_capital IN h-b1wgen0001(INPUT  glb_cdcooper,
                                              INPUT  tel_nrdconta,
                                              INPUT  0, /* cod-agencia */
                                              INPUT  0, /* nro-caixa   */
                                              0,        /* vllanmto */
                                              INPUT  glb_dtmvtolt,
                                              INPUT  "lanrdai",
                                              INPUT  1, /* AYLLOS */
                                              OUTPUT TABLE tt-erro).
              /* Verifica se houve erro */
              FIND FIRST tt-erro NO-LOCK  NO-ERROR.

              IF   AVAILABLE tt-erro   THEN
              DO:
                   ASSIGN glb_cdcritic = tt-erro.cdcritic
                          glb_dscricpl = tt-erro.dscritic.
              END.
              DELETE PROCEDURE h-b1wgen0001.
          END.
          /************************************/

      IF   glb_cdcritic > 0   THEN
           DO:
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.
      
      /* Critica para nao permitir esse tipo de aplicacao - nao esta em uso */

      IF   tel_tpaplica = 6 OR 
           (tel_tpaplica = 5 AND glb_cdcooper = 3)  THEN
           DO:
               glb_cdcritic = 346.
               NEXT-PROMPT tel_tpaplica WITH FRAM f_lanrda.
               NEXT.
           END.

      IF   tel_nrdocmto = 0  OR tel_nrdocmto > 499999 THEN
           DO:
               glb_cdcritic = 425.
               NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanrda.
               NEXT.
           END.

      IF   tel_vllanmto = 0   THEN
           DO:
               glb_cdcritic = 269.
               NEXT-PROMPT tel_vllanmto WITH FRAME f_lanrda.
               NEXT.
           END.

      IF  (tel_tpaplica = 3   AND   tel_vllanmto > tab_vllanmto)  OR
          (tel_tpaplica = 6   AND   tel_vllanmto <  tab_vllanmto)  THEN
           DO:
               glb_cdcritic = 269.
               NEXT-PROMPT tel_vllanmto WITH FRAME f_lanrda.
               NEXT.
           END.

      IF   CAN-FIND(craplap WHERE craplap.cdcooper = glb_cdcooper   AND
                                  craplap.dtmvtolt = tel_dtmvtolt   AND
                                  craplap.cdagenci = tel_cdagenci   AND
                                  craplap.cdbccxlt = tel_cdbccxlt   AND
                                  craplap.nrdolote = tel_nrdolote   AND
                                  craplap.nrdconta = tel_nrdconta   AND
                                  craplap.nrdocmto = tel_nrdocmto
                                  USE-INDEX craplap1)               THEN
           DO:
               glb_cdcritic =  92.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.

       IF  CAN-FIND(craprda WHERE craprda.cdcooper = glb_cdcooper   AND
                                  craprda.dtmvtolt = tel_dtmvtolt   AND
                                  craprda.cdagenci = tel_cdagenci   AND
                                  craprda.cdbccxlt = tel_cdbccxlt   AND
                                  craprda.nrdolote = tel_nrdolote   AND
                                  craprda.nrdconta = tel_nrdconta   AND
                                  craprda.nraplica = tel_nrdocmto
                                  USE-INDEX craprda1)      OR
           CAN-FIND(craprda WHERE craprda.cdcooper = glb_cdcooper   AND
                                  craprda.nrdconta = tel_nrdconta   AND
                                  craprda.nraplica = tel_nrdocmto
                                  USE-INDEX craprda2)  THEN
           DO:
               glb_cdcritic =  92.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanrda.
               NEXT.
           END.

      /*  Verifica se o associado fez outra aplicacao no dia  */

      IF   CAN-FIND(FIRST craprda WHERE craprda.cdcooper = glb_cdcooper  AND
                                        craprda.nrdconta = tel_nrdconta  AND
                                        craprda.dtmvtolt = glb_dtmvtolt) THEN
           DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  ASSIGN aux_confirma = "N"
                         glb_cdcritic = 599.

                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  glb_cdcritic = 0.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S"                  THEN
                    DO:
                        glb_cdcritic = 79.
                        NEXT.
                    END.
           END.
           
      /* critica para comparar o saldo da conta investimento */
      IF   tel_flgdebci = YES   THEN
           DO:
               FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper         AND
                                  crapsli.nrdconta  = tel_nrdconta         AND
                            MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt)  AND
                             YEAR(crapsli.dtrefere) = YEAR(glb_dtmvtolt)
                                  NO-LOCK NO-ERROR.
               
               IF   AVAILABLE crapsli   THEN
                    DO:                                                
                        IF   crapsli.vlsddisp >= tel_vllanmto   THEN
                             LEAVE.
                    END.
                    
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  ASSIGN aux_confirma = "N"
                         glb_cdcritic = 78.
                         MESSAGE "Saldo CI menor que valor aplicado.".
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                         glb_cdcritic = 0.
                         LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                     aux_confirma <> "S"                  THEN
                     DO:
                         glb_cdcritic = 79.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         NEXT.
                     END.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        RETURN.  /* Volta pedir a opcao para o operador */

   DO TRANSACTION:

      DO WHILE TRUE:

         FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                            craplot.dtmvtolt = tel_dtmvtolt   AND
                            craplot.cdagenci = tel_cdagenci   AND
                            craplot.cdbccxlt = tel_cdbccxlt   AND
                            craplot.nrdolote = tel_nrdolote
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craplot   THEN
              IF   LOCKED craplot   THEN
                   DO:
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   glb_cdcritic = 60.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic = 0   THEN
           DO:
               IF   craplot.tplotmov <> 10   THEN
                    DO:
                        glb_cdcritic = 100.
                        NEXT.
                    END.
           END.
      ELSE
           NEXT.

      DO WHILE TRUE:

         IF   tel_tpaplica = 3 THEN
              DO:
                  FIND craptrd WHERE craptrd.cdcooper = glb_cdcooper AND
                                     craptrd.dtiniper = glb_dtmvtolt AND
                                     craptrd.tptaxrda = 1            AND
                                     craptrd.incarenc = 0            AND
                                     craptrd.vlfaixas = 0
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE craptrd   THEN
                       IF   LOCKED craptrd   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            glb_cdcritic = 347.
              END.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic > 0   THEN
           NEXT.

      IF   tel_tpaplica = 3 THEN
           aux_dtfimper = craptrd.dtfimper.
      ELSE                                                   /*  tipo 5 ou 6  */
           DO:
               ASSIGN aux_dtfimper = IF   MONTH(glb_dtmvtolt) = 12 THEN
                                          DATE(1,DAY(glb_dtmvtolt),
                                                 YEAR(glb_dtmvtolt) + 1)
                                     ELSE
                                          DATE(MONTH(glb_dtmvtolt) + 1,
                                               DAY(glb_dtmvtolt),
                                               YEAR(glb_dtmvtolt)) NO-ERROR.
           
               IF   ERROR-STATUS:ERROR THEN
                    IF   MONTH(glb_dtmvtolt) = 11 THEN  
                         aux_dtfimper = DATE(1, 1, (YEAR(glb_dtmvtolt) + 1)).
                    ELSE
                         IF   MONTH(glb_dtmvtolt) = 12 THEN
                              aux_dtfimper = DATE(2, 1, 
                                                  (YEAR(glb_dtmvtolt) + 1)).
                         ELSE
                              aux_dtfimper = DATE((MONTH(glb_dtmvtolt) + 2),
                                                   1, YEAR(glb_dtmvtolt)).
           
           END.
      
      IF   tel_tpaplica     = 3   AND
           craptrd.txofidia = 0   AND
           craptrd.txprodia = 0   THEN
           DO:
               glb_cdcritic = 427.
               NEXT.
           END.

      IF   tel_tpaplica = 3   THEN            /*  RDCA 30 DIAS COM REND. DIA  */
           aux_cdhislan = 113.
      ELSE
      IF   tel_tpaplica = 5   THEN            /*  RDCA 60 DIAS  */
           aux_cdhislan = 176.
      ELSE
      IF   tel_tpaplica = 6   THEN            /*  RDCA 30 DIAS SEM REND. DIA  */
           aux_cdhislan = 262.

      CREATE craplap.
      ASSIGN craplap.cdagenci = craplot.cdagenci
             craplap.cdbccxlt = craplot.cdbccxlt
             craplap.dtmvtolt = craplot.dtmvtolt
             craplap.nrdolote = craplot.nrdolote
             craplap.nrdconta = tel_nrdconta
             craplap.cdhistor = aux_cdhislan
             craplap.nraplica = tel_nrdocmto
             craplap.nrdocmto = tel_nrdocmto
             craplap.nrseqdig = craplot.nrseqdig + 1
             craplap.vllanmto = tel_vllanmto
             craplap.dtrefere = aux_dtfimper
             craplap.txaplica = 0
             craplap.txaplmes = 0
             craplap.cdcooper = glb_cdcooper.

      CREATE craprda.
      ASSIGN tel_nrseqdig     = craplot.nrseqdig + 1
             craprda.dtmvtolt = craplot.dtmvtolt
             craprda.cdagenci = craplot.cdagenci
             craprda.cdbccxlt = craplot.cdbccxlt
             craprda.nrdolote = craplot.nrdolote
             craprda.nrdconta = tel_nrdconta
             craprda.nraplica = tel_nrdocmto
             
             craprda.flgctain = tel_flgctain
             craprda.flgdebci = tel_flgdebci
             
             craprda.dtiniper = glb_dtmvtolt
             craprda.dtfimper = aux_dtfimper
             craprda.dtcalcul = glb_dtmvtolt
             craprda.inaniver = 0
             craprda.incalmes = 0
             craprda.insaqtot = 0
             craprda.dtsaqtot = ?
             craprda.tpemiext = tel_tpemiext
             craprda.vlaplica = tel_vllanmto
             craprda.vlsdrdca = tel_vllanmto
             craprda.qtaplmfx = tel_vllanmto / crapmfx.vlmoefix
             craprda.vlabcpmf = IF  tel_flgdebci = YES THEN
                                    0
                                ELSE    
                                IF tab_indabono = 0 AND
                                   tab_dtiniabo <= craprda.dtmvtolt THEN
                                   TRUNCATE(tel_vllanmto * tab_txcpmfcc,2)
                                ELSE craprda.vlabcpmf
                                   
             craprda.vlabdiof = IF tab_indabono = 0 AND
                                   tab_dtiniabo <= craprda.dtmvtolt THEN
                                   TRUNCATE(tel_vllanmto * tab_txiofrda,2)
                                ELSE craprda.vlabdiof
             
             craprda.qtrgtmfx = 0
             craprda.vlsdrdan = 0
             craprda.dtsdrdan = glb_dtmvtolt
             craprda.cdageass = crapass.cdagenci
             craprda.cdsecext = crapass.cdsecext
             craprda.qtmesext = 0
             craprda.dtiniext = craprda.dtiniper
             craprda.dtfimext = craprda.dtiniper
             craprda.tpaplica = tel_tpaplica
             craprda.cdcooper = glb_cdcooper

             craplot.nrseqdig = tel_nrseqdig
             craplot.qtcompln = craplot.qtcompln + 1

             craplot.vlcompcr = craplot.vlcompcr + tel_vllanmto.


      ASSIGN tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      IF   glb_cdcritic > 0   THEN
           NEXT.

   END.   /* Fim da transacao */

   RELEASE craptrd.
   RELEASE craplot.
   RELEASE craplap.
   RELEASE craprda.

   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  AND  tel_vldifecr = 0   THEN
        DO:
            glb_nmdatela = "LOTE".
            RETURN.                        /* Volta ao lanrda.p */
        END.

   ASSIGN tel_reganter[6] = tel_reganter[5] tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3] tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1].

   IF  tel_flgctain = YES THEN
       ASSIGN aux_flgctain = "S".
   ELSE
       ASSIGN aux_flgctain = "N".
       
   IF   tel_flgdebci = YES   THEN
        ASSIGN aux_flgdebci = "S".
   ELSE
        ASSIGN aux_flgdebci = "N".
       
   ASSIGN tel_reganter[1] = STRING(tel_tpaplica,"9")    + "     " +
                            STRING(tel_nrdconta,"zzzz,zzz,9")    + "     " +
                            STRING(tel_nrdocmto,"zzz,zz9")       + "   " +
                            aux_flgctain + "      " +
                            aux_flgdebci + "      " +
                            STRING(tel_vllanmto,"zzz,zzz,zz9.99")
                            + "      " +
                            STRING(tel_tpemiext,"9") + " " +
                            STRING(tel_nrseqdig,"zz,zz9")

          tel_nrdconta = 0
          tel_nrdocmto = 0
          tel_tpaplica = 0
          tel_vllanmto = 0
          tel_nrseqdig = tel_nrseqdig + 1
          tel_flgdebci = no.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_nrdconta tel_nrdocmto tel_vllanmto
           tel_nrseqdig tel_flgdebci WITH FRAME f_lanrda.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3] tel_reganter[4]
           tel_reganter[5] tel_reganter[6] WITH FRAME f_regant.

END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
