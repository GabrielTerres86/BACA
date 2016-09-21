/* .............................................................................

   Programa: Includes/lanauti.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/91.                     Ultima atualizacao: 10/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela LANAUT.

   Alteracoes: 21/06/95 - Alterado para as novas rotinas da tela (Edson).

               18/07/95 - Alterado para nao permitir data superior a 30 dias
                          (Deborah).

               12/08/96 - Alterado para tratar historico com debito na folha
                          de pagamento (Edson).

               27/08/96 - Alterado para gerar o aviso (historicos com debito
                          ha folha) na data do aviso de emprestimo (Deborah).

               16/04/97 - Alterado para incluir novos campos no craplau
                          (Deborah).

               17/07/97 - Tratar avs.dtmvtolt dependendo do emp.tpconven
                          (Odair)

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               22/01/98 - Alterado para gerar cdsecext para Ceval Jaragua com
                          zeros (Deborah).

               24/03/98 - Cancelada a alteracao anterior (Deborah).

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               09/11/98 - Tratar situacao em prejuizo (Deborah). 

               26/03/99 - Mostar associados em CL (Odair)

               17/01/2000 - Tratar tpdebemp 3 (Deborah). 
                
               24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               20/08/2001 - Tratar onze posicoes no numero do documento (Edson).

               28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).

               18/12/2003 - Alterado para NAO permitir data de pagamento para
                            o dia 31/12 de qualquer ano (Edson).

               02/02/2005 - Nao permitir historicos extra-caixa (Edson).

               06/07/2005 - Alimentado campo cdcooper das tabelas craplau e
                            crapavs (Diego).

               10/12/2005 - Atualizar craplau.nrdctitg (Magui).

               23/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               24/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)
                            
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               01/09/2008 - Alteracao cdempres (Kbase IT) - Eduardo Silva.
               
               16/03/2010 - Utilizar <F7> no campo do historico (Gabriel).
               
               10/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)              
............................................................................. */
               
{ sistema/generico/includes/var_internet.i }
DEF VAR h-b1wgen0001 AS HANDLE                                        NO-UNDO.

DEF   VAR  ant_nrdconta  AS      INT                                  NO-UNDO.
DEF   VAR  aux_flgexist  AS      LOGICAL                              NO-UNDO.

FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                   craplot.dtmvtolt = tel_dtmvtolt   AND
                   craplot.cdagenci = tel_cdagenci   AND
                   craplot.cdbccxlt = tel_cdbccxlt   AND
                   craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craplot   THEN
     DO:                
         glb_cdcritic = 60.
         RUN fontes/critic.p.
         CLEAR FRAME f_lanaut.
         DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                 tel_cdbccxlt tel_nrdolote tel_nrseqdig
                 WITH FRAME f_lanaut.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         NEXT.
     END.

ASSIGN lot_cdhistor = craplot.cdhistor
       lot_cdbccxpg = craplot.cdbccxpg
       lot_dtmvtopg = craplot.dtmvtopg
       tel_nrseqdig = 1.

DISPLAY tel_nrseqdig WITH FRAME f_lanaut.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic = 0 THEN
           ASSIGN tel_cdhistor = lot_cdhistor
                  tel_cdbccxpg = lot_cdbccxpg
                  tel_dtmvtopg = lot_dtmvtopg.

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               CLEAR FRAME f_lanaut.
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_nrseqdig
                       WITH FRAME f_lanaut.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_cdhistor tel_nrdconta tel_nrdocmto
             tel_vllanaut tel_dtmvtopg tel_cdbccxpg
             WITH FRAME f_lanaut

      EDITING:

          READKEY.

          IF   FRAME-FIELD = "tel_cdhistor"  THEN
               DO:
                   IF   LASTKEY = KEYCODE("F7")  THEN
                        DO:
                            RUN fontes/zoom_historicos.p (INPUT glb_cdcooper,
                                                          INPUT TRUE,
                                                          INPUT 0,
                                                          OUTPUT tel_cdhistor).

                            DISPLAY tel_cdhistor
                                    WITH FRAME f_lanaut.
                        END.
                   ELSE
                        APPLY LASTKEY.
               END.
          ELSE
          IF   FRAME-FIELD = "tel_vllanaut"   THEN
               IF   LASTKEY =  KEYCODE(".")   THEN
                    APPLY 44.
               ELSE
                    APPLY LASTKEY.
          ELSE
               APPLY LASTKEY.

      END.  /*  Fim do EDITING  */

      IF   tel_dtmvtopg > (glb_dtmvtolt + 30)   THEN
           DO:
               glb_cdcritic = 013.
               NEXT-PROMPT tel_dtmvtopg WITH FRAME f_lanaut.
               NEXT.
           END.

      /*  Nao permite data de pagamento para 31/12  */

      IF   MONTH(tel_dtmvtopg) = 12   AND
           DAY(tel_dtmvtopg)   = 31   THEN
           DO:
               glb_cdcritic = 13.
               NEXT-PROMPT tel_dtmvtopg WITH FRAME f_lanaut.
               NEXT.
           END.
      
      FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND
                         craphis.cdhistor = tel_cdhistor NO-LOCK NO-ERROR.
      
      IF   NOT AVAILABLE craphis   THEN
           DO:
               glb_cdcritic = 93.
               NEXT-PROMPT tel_cdhistor WITH FRAME f_lanaut.
               NEXT.
           END.

      IF   craphis.indebfol <> 1   THEN
           DO:
               IF   craphis.tplotmov <> 1     OR
                    craphis.indebcre <> "D"   OR
                    craphis.inhistor <> 11    OR
                    craphis.indebcta <> 1     THEN
                    DO:
                        glb_cdcritic = 94.
                        NEXT-PROMPT tel_cdhistor WITH FRAME f_lanaut.
                        NEXT.
                    END.
           END.
      ELSE
           DO:
               IF   tel_dtmvtopg <> aux_dtultdia   THEN
                    DO:
                        glb_cdcritic = 13.
                        NEXT-PROMPT tel_dtmvtopg WITH FRAME f_lanaut.
                        NEXT.
                    END.
           END.

      IF   NOT CAN-DO("2,3",STRING(craphis.tpctbcxa))   AND
           tel_cdbccxlt = 911                           THEN
           DO:
               glb_cdcritic = 689.
               NEXT-PROMPT tel_cdhistor WITH FRAME f_lanaut.
               NEXT.
           END.

      glb_nrcalcul = tel_nrdconta.
      RUN fontes/digfun.p.
      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
               NEXT.
           END.

      IF   tel_nrdocmto = 0   THEN
           DO:
               glb_cdcritic = 22.
               NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanaut.
               NEXT.
           END.

      ASSIGN ant_nrdconta = tel_nrdconta
             aux_flgexist = FALSE.

      DO WHILE TRUE:

         FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                            crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

         IF  AVAILABLE crapass  THEN
             DO:
                 IF   crapass.inpessoa = 1   THEN 
                      DO:
                          FIND crapttl WHERE 
                               crapttl.cdcooper = glb_cdcooper       AND
                               crapttl.nrdconta = crapass.nrdconta   AND
                               crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                          IF   AVAIL crapttl  THEN
                               ASSIGN aux_cdempres = crapttl.cdempres.
                      END.
                 ELSE
                      DO:
                          FIND crapjur WHERE 
                               crapjur.cdcooper = glb_cdcooper  AND
                               crapjur.nrdconta = crapass.nrdconta
                               NO-LOCK NO-ERROR.

                          IF   AVAIL crapjur  THEN
                               ASSIGN aux_cdempres = crapjur.cdempres.
                      END.
             END.

         IF   NOT AVAILABLE crapass   THEN
              DO:
                  glb_cdcritic = 9.
                  NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
                  LEAVE.
              END.

         IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
              DO:
                  glb_cdcritic = 695.
                  NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
                  LEAVE.
              END.
         
         IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
              DO:
                  FIND FIRST craptrf WHERE 
                             craptrf.cdcooper = glb_cdcooper     AND
                             craptrf.nrdconta = crapass.nrdconta AND
                             craptrf.tptransa = 1
                             USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craptrf THEN
                       DO:
                           glb_cdcritic = 95.
                           NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
                           LEAVE.
                       END.
                  ELSE
                       DO:
                           ASSIGN aux_flgexist = TRUE
                                  tel_nrdconta = craptrf.nrsconta.
                           NEXT.
                       END.
              END.

         IF   aux_flgexist AND glb_cdcritic = 0  THEN
              DO:
                  glb_cdcritic = 156.
                  RUN fontes/critic.p.

                  MESSAGE glb_dscritic STRING(ant_nrdconta,"zzzz,zzz,9")
                          "para o numero" STRING(tel_nrdconta,"zzzz,zzz,9").

                  BELL.

                  glb_cdcritic = 0.
              END.

         IF   craphis.indebfol = 1   THEN
              DO:
                /*  FIND crapemp OF crapass NO-LOCK NO-ERROR. */
                FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
                                   crapemp.cdempres = aux_cdempres
                                   NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE crapemp   THEN
                       DO:
                           glb_cdcritic = 40.
                           NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
                           LEAVE.
                       END.

                  IF   NOT CAN-DO("2,3",STRING(crapemp.tpdebemp,"9")) THEN
                       DO:
                           glb_cdcritic = 445.
                           NEXT-PROMPT tel_cdhistor WITH FRAME f_lanaut.
                           LEAVE.
                       END.

                  IF   crapemp.inavsemp <> 0   THEN
                       DO:
                           glb_cdcritic = 507.
                           NEXT-PROMPT tel_cdhistor WITH FRAME f_lanaut.
                           LEAVE.
                       END.
              END.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic = 0   THEN
           DO:
          
               RUN sistema/generico/procedures/b1wgen0001.p
                   PERSISTENT SET h-b1wgen0001.
      
               IF   VALID-HANDLE(h-b1wgen0001)   THEN
               DO:
                    RUN ver_capital IN h-b1wgen0001(INPUT  glb_cdcooper,
                                                    INPUT  tel_nrdconta,
                                                    INPUT  0, /* cod-agencia */
                                                    INPUT  0, /* nro-caixa   */
                                                    0,        /* vllanmto */
                                                    INPUT  glb_dtmvtolt,
                                                    INPUT  "lanauti",
                                                    INPUT  1, /* AYLLOS */
                                                    OUTPUT TABLE tt-erro).
                    /* Verifica se houve erro */
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF   AVAILABLE tt-erro   THEN
                    DO:
                         ASSIGN glb_cdcritic = tt-erro.cdcritic
                                glb_dscricpl = tt-erro.dscritic.
                    END.
                    DELETE PROCEDURE h-b1wgen0001.
               END.
               /************************************/
                                             
               IF   glb_cdcritic > 0   THEN
                    NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
           END.

      IF   glb_cdcritic > 0 THEN
           NEXT.

      IF   craphis.inautori = 1   THEN
           DO:
               FIND crapatr WHERE crapatr.cdcooper = glb_cdcooper   AND
                                  crapatr.nrdconta = tel_nrdconta   AND
                                  crapatr.cdhistor = tel_cdhistor   AND
                                  crapatr.cdrefere = tel_nrdocmto
                                  USE-INDEX crapatr1 NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapatr   THEN
                    DO:
                        glb_cdcritic = 446.
                        NEXT-PROMPT tel_cdhistor WITH FRAME f_lanaut.
                        NEXT.
                    END.

               IF   crapatr.dtfimatr <> ?   THEN
                    DO:
                        glb_cdcritic = 447.
                        NEXT-PROMPT tel_cdhistor WITH FRAME f_lanaut.
                        NEXT.
                    END.
           END.

      IF   CAN-FIND(craplau WHERE craplau.cdcooper = glb_cdcooper   AND
                                  craplau.dtmvtolt = tel_dtmvtolt   AND
                                  craplau.cdagenci = tel_cdagenci   AND
                                  craplau.cdbccxlt = tel_cdbccxlt   AND
                                  craplau.nrdolote = tel_nrdolote   AND
                                  craplau.nrdctabb = tel_nrdconta   AND
                                  craplau.nrdocmto = tel_nrdocmto
                                  USE-INDEX craplau1)   THEN
           DO:
               glb_cdcritic = 92.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
               NEXT.
           END.

      IF   CAN-FIND(crapavs WHERE crapavs.cdcooper = glb_cdcooper       AND
                                  crapavs.dtmvtolt = tel_dtmvtolt       AND
                                  crapavs.cdempres = 0                  AND
                                  crapavs.cdagenci = tel_cdagenci       AND
                                  crapavs.cdsecext = crapass.cdsecext   AND
                                  crapavs.nrdconta = tel_nrdconta       AND
                                  crapavs.dtdebito = tel_dtmvtopg       AND
                                  crapavs.cdhistor = tel_cdhistor       AND
                                  crapavs.nrdocmto = tel_nrdocmto   
                                  USE-INDEX crapavs1)   THEN
           DO:
               glb_cdcritic = 622.
               NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanaut.
               NEXT.
           END.
      
      IF   crapass.dtdemiss <> ?   THEN
           DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  aux_confirma = "N".

                  glb_cdcritic = 449.
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

      FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper     AND
                         crapsld.nrdconta = crapass.nrdconta NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapass   THEN
           DO:
               glb_cdcritic = 10.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
               NEXT.
           END.

      IF   crapsld.dtdsdclq <> ?   THEN
           DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  aux_confirma = "N".

                  glb_cdcritic = 633.
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
        LEAVE.   /* Volta pedir a opcao para o operador */

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
         ELSE
         IF   craplot.tplotmov <> 12   THEN
              glb_cdcritic = 132.
         
         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic > 0   THEN
           NEXT.

      CREATE craplau.
      ASSIGN craplau.dtmvtolt = craplot.dtmvtolt
             craplau.cdagenci = craplot.cdagenci
             craplau.cdbccxlt = craplot.cdbccxlt
             craplau.nrdolote = craplot.nrdolote
             craplau.nrdconta = tel_nrdconta
             craplau.nrdctabb = tel_nrdconta
             craplau.nrdctitg = STRING(tel_nrdconta,"99999999")
             craplau.nrdocmto = tel_nrdocmto
             craplau.vllanaut = tel_vllanaut
             craplau.cdhistor = tel_cdhistor
             craplau.nrseqdig = craplot.nrseqdig + 1
             craplau.cdbccxpg = tel_cdbccxpg
             craplau.dtmvtopg = tel_dtmvtopg
             craplau.tpdvalor = 1
             craplau.insitlau = IF craphis.indebfol = 1 THEN 3 ELSE 1
             craplau.cdcritic = 0
             craplau.dtdebito = ?
             craplau.nrcrcard = 0
             craplau.nrseqlan = 0
             craplau.cdcooper = glb_cdcooper

             craplot.nrseqdig = craplot.nrseqdig + 1
             craplot.qtcompln = craplot.qtcompln + 1

             tel_qtinfoln = craplot.qtinfoln
             tel_qtcompln = craplot.qtcompln
             tel_nrseqdig = craplau.nrseqdig.
      VALIDATE craplau.
      IF   craphis.indebcre = "D"   THEN
           ASSIGN craplot.vlcompdb = craplot.vlcompdb + tel_vllanaut
                  tel_vlinfodb     = craplot.vlinfodb
                  tel_vlcompdb     = craplot.vlcompdb
                  tel_qtdifeln     = craplot.qtcompln - craplot.qtinfoln
                  tel_vldifedb     = craplot.vlcompdb - craplot.vlinfodb.
      ELSE
      IF   craphis.indebcre = "C"   THEN
           ASSIGN craplot.vlcompcr = craplot.vlcompcr + tel_vllanaut
                  tel_vlinfocr     = craplot.vlinfocr
                  tel_vlcompcr     = craplot.vlcompcr
                  tel_qtdifeln     = craplot.qtcompln - craplot.qtinfoln
                  tel_vldifecr     = craplot.vlcompcr - craplot.vlinfocr.

      IF   craphis.inavisar = 1   THEN
           DO:
               CREATE crapavs.
               ASSIGN crapavs.cdagenci = crapass.cdagenci
                      crapavs.cdsecext = crapass.cdsecext
                      crapavs.cdhistor = craplau.cdhistor
                      crapavs.nrdconta = craplau.nrdconta
                      crapavs.nrdocmto = craplau.nrdocmto
                      crapavs.vllanmto = craplau.vllanaut
                      crapavs.nrseqdig = craplau.nrseqdig
                      crapavs.vldebito = 0
                      crapavs.vlestdif = 0
                      crapavs.insitavs = 0
                      crapavs.flgproce = false
                      crapavs.cdcooper = glb_cdcooper.

               IF   craphis.indebfol = 1   THEN
                    ASSIGN crapavs.tpdaviso = 1
                           crapavs.dtdebito = ?
                           crapavs.cdempres = aux_cdempres
                           crapavs.dtrefere = tel_dtmvtopg
                           crapavs.dtmvtolt = IF crapemp.tpconven = 1
                                                 THEN  crapemp.dtavsemp
                                                 ELSE  aux_dtmvtolt.
               ELSE
                    ASSIGN crapavs.tpdaviso = 2
                           crapavs.dtdebito = craplau.dtmvtopg
                           crapavs.cdempres = 0
                           crapavs.dtrefere = craplau.dtmvtolt
                           crapavs.dtmvtolt = craplau.dtmvtolt.
              VALIDATE crapavs.
           END.

   END.   /* Fim da transacao */

   IF   tel_qtdifeln = 0   AND   tel_vldifedb = 0   THEN
        DO:
            HIDE FRAME f_lanaut.
            HIDE FRAME f_regant.
            HIDE FRAME f_lanctos.
            HIDE FRAME f_moldura.
            glb_nmdatela = "LOTE".
            RETURN.
        END.

   ASSIGN tel_reganter[6] = tel_reganter[5]
          tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3]
          tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1]

          tel_reganter[1] = STRING(tel_cdhistor,"zz9")                + "  " +
                            STRING(tel_nrdconta,"zzzz,zzz,9")         + " " +
                            STRING(tel_nrdocmto,"zz,zzz,zzz,zzz,zz9") + " " +
                            STRING(tel_vllanaut,"zzz,zzz,zzz,zz9.99") + "  " +
                            STRING(tel_dtmvtopg,"99/99/9999")         + "  " +
                            STRING(tel_cdbccxpg,"zz9")                + " " +
                            STRING(tel_nrseqdig,"zz,zz9")

          tel_nrdconta = 0
          tel_nrdocmto = 0

          tel_nrseqdig = craplot.nrseqdig + 1.

   DISPLAY tel_qtinfoln  tel_vlinfodb  tel_vlinfocr
           tel_qtcompln  tel_vlcompdb  tel_vlcompcr
           tel_qtdifeln  tel_vldifedb  tel_vldifecr
           tel_cdhistor  tel_nrdconta  tel_nrdocmto
           tel_vllanaut  tel_cdbccxpg  tel_dtmvtopg
           tel_nrseqdig
           WITH FRAME f_lanaut.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3]
           tel_reganter[4] tel_reganter[5] tel_reganter[6]
           WITH FRAME f_regant.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

