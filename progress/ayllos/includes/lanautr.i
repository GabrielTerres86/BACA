/* .............................................................................

   Programa: Includes/lanautr.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2001.                  Ultima atualizacao: 12/12/2008   

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de Resgate da tela LANAUT.

   Alteracoes: 24/01/2006 -  Unificacao dos Bancos - SQLWorks - Fernando

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise) 
                            
               01/09/2008 - Alteracao cdempres (Kbase IT) - Eduardo Silva.

               12/12/2008 - Critica quando historico de Seguro AUTO (586)
                            (Gabriel).
                            
               23/11/2009 - Alteracao Codigo Historico (Kbase).
............................................................................. */

glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lanaut.
               DISPLAY glb_cddopcao tel_dtmvtolt
                       tel_cdagenci tel_cdbccxlt tel_nrdolote
                       tel_nrdconta tel_nrdocmto WITH FRAME f_lanaut.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_nrdconta tel_nrdocmto WITH FRAME f_lanaut.

      ASSIGN glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0.

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

                       IF   AVAIL crapttl THEN
                            ASSIGN aux_cdempres = crapttl.cdempres.
                   END.
              ELSE
                   DO:
                       FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
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
               NEXT.
           END.

     /* FIND crapemp OF crapass NO-LOCK NO-ERROR. */
      FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper     AND
                         crapemp.cdempres = aux_cdempres     NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapemp THEN
           DO:
               glb_cdcritic = 40.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanaut.
               NEXT.
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

      IF   glb_cdcritic > 0 THEN
           NEXT.

      IF   craplot.cdhistor = 586   THEN
           DO:
               MESSAGE "Nao eh possivel resgatar debitos programados no" 
                       "seguro AUTO.".
               NEXT.
           END.
      
      ASSIGN tel_qtinfoln = craplot.qtinfoln
             tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb
             tel_vlcompdb = craplot.vlcompdb
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb.
 
      DO aux_contador = 1 TO 10:

         FIND craplau WHERE craplau.cdcooper = glb_cdcooper   AND
                            craplau.dtmvtolt = tel_dtmvtolt   AND
                            craplau.cdagenci = tel_cdagenci   AND
                            craplau.cdbccxlt = tel_cdbccxlt   AND
                            craplau.nrdolote = tel_nrdolote   AND
                            craplau.nrdctabb = tel_nrdconta   AND
                            craplau.nrdocmto = tel_nrdocmto
                            USE-INDEX craplau1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craplau   THEN
              IF   LOCKED craplau   THEN
                   DO:
                       glb_cdcritic = 114.
                       PAUSE 2 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   DO:
                       glb_cdcritic = 90.
                       LEAVE.
                   END.

         FIND craphis NO-LOCK WHERE 
                               craphis.cdcooper = craplau.cdcooper AND 
                               craphis.cdhistor = craplau.cdhistor NO-ERROR.

         IF   NOT AVAILABLE craphis   THEN
              DO:
                  glb_cdcritic = 83.
                  LEAVE.
              END.

         IF  (craphis.indebfol =  0   AND
              craplau.insitlau <> 1)  OR
             (craphis.indebfol = 1    AND
              craplau.insitlau <> 3)  THEN
              glb_cdcritic = 103.

         IF   craplau.dtdebito <> ?   THEN
              DO:
                  glb_cdcritic = 670.
              END.
              
         LEAVE.

      END.  /*  Fim do DO .. TO  */

      IF   glb_cdcritic > 0 THEN
           NEXT.

      ASSIGN tel_cdhistor = craplau.cdhistor
             tel_vllanaut = craplau.vllanaut
             tel_cdbccxpg = craplau.cdbccxpg
             tel_dtmvtopg = craplau.dtmvtopg
             tel_nrseqdig = craplau.nrseqdig.

      DISPLAY tel_qtinfoln tel_vlinfodb tel_qtcompln tel_vlcompdb
              tel_qtdifeln tel_vldifedb tel_cdhistor tel_nrdconta
              tel_nrdocmto tel_vllanaut tel_cdbccxpg tel_dtmvtopg
              tel_nrseqdig
              WITH FRAME f_lanaut.

      PAUSE 0.
      
      DISPLAY SKIP(1)
              " ATENCAO! Esta operacao NAO tem volta! "
              SKIP(1)
              WITH ROW 9 CENTERED OVERLAY color message FRAME f_sem_volta.
    
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         aux_confirma = "N".

         glb_cdcritic = 78.
         RUN fontes/critic.p.
         BELL.
         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         glb_cdcritic = 0.
         LEAVE.

      END.

      HIDE FRAME f_sem_volta NO-PAUSE.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
           aux_confirma <> "S" THEN
           DO:
               glb_cdcritic = 79.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               NEXT.
           END.

      IF   craphis.inavisar = 1    THEN
           DO:
               DO WHILE TRUE:

                  IF   craphis.indebfol = 1   THEN
                       FIND crapavs WHERE
                            crapavs.cdcooper = glb_cdcooper       AND 
                            crapavs.dtmvtolt = (IF crapemp.tpconven = 1
                                                   THEN crapemp.dtavsemp
                                                   ELSE aux_dtmvtolt ) AND
                            crapavs.cdempres = aux_cdempres       AND
                            crapavs.cdagenci = crapass.cdagenci   AND
                            crapavs.cdsecext = crapass.cdsecext   AND
                            crapavs.nrdconta = craplau.nrdconta   AND
                            crapavs.dtdebito = ?                  AND
                            crapavs.cdhistor = craplau.cdhistor   AND
                            crapavs.nrdocmto = craplau.nrdocmto
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                  ELSE
                       FIND crapavs WHERE
                            crapavs.cdcooper = glb_cdcooper       AND
                            crapavs.dtmvtolt = craplau.dtmvtolt   AND
                            crapavs.cdempres = 0                  AND
                            crapavs.cdagenci = crapass.cdagenci   AND
                            crapavs.cdsecext = crapass.cdsecext   AND
                            crapavs.nrdconta = craplau.nrdconta   AND
                            crapavs.dtdebito = craplau.dtmvtopg   AND
                            crapavs.cdhistor = craplau.cdhistor   AND
                            crapavs.nrdocmto = craplau.nrdocmto
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapavs   THEN
                       IF   LOCKED crapavs   THEN
                            DO:
                                PAUSE 2 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            glb_cdcritic = 448.
                  ELSE
                       DELETE crapavs.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   glb_cdcritic > 0   THEN
                    NEXT.
           END.

      IF   craphis.indebcre = "D"   THEN
           ASSIGN craplot.vlcompdb = craplot.vlcompdb - tel_vllanaut
                  craplot.vlinfodb = craplot.vlinfodb - tel_vllanaut
                  craplot.qtinfoln = craplot.qtinfoln - 1
                  craplot.qtcompln = craplot.qtcompln - 1.
      ELSE
      IF   craphis.indebcre = "C"   THEN
           ASSIGN craplot.vlcompcr = craplot.vlcompcr - tel_vllanaut
                  craplot.vlinfocr = craplot.vlinfocr - tel_vllanaut
                  craplot.qtinfoln = craplot.qtinfoln - 1
                  craplot.qtcompln = craplot.qtcompln - 1.

      ASSIGN tel_qtinfoln = craplot.qtinfoln
             tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb
             tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr
             tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      DELETE craplau.

      UNIX SILENT VALUE("echo " + 
                         STRING(glb_dtmvtolt,"99/99/9999") +
                         " " +
                         STRING(TIME,"HH:MM:SS") +
                         " Oper.: " +
                         STRING(glb_nmoperad,"x(10)") +
                         " - Ref. Resgate Docto Histor.: " +
                         STRING(tel_cdhistor,"9999") +
                         " Conta: " +
                         STRING(tel_nrdconta,"zzzz,zzz,9") +
                         " Docto.: " +
                         STRING(tel_nrdocmto,"zzzz,zzz,zz9") +
                         " Valor " + 
                         STRING(tel_vllanaut,"zzz,zzz,zz9.99") +
                        " >> log/lanaut.log").

   END.   /*  Fim da transacao.  */

   RELEASE craplot.

   ASSIGN tel_cdhistor = 0  tel_nrdconta = 0  tel_nrdocmto = 0
          tel_vllanaut = 0  tel_cdbccxpg = 0 tel_dtmvtopg = ?.

   DISPLAY tel_qtinfoln tel_vlinfodb
           tel_qtcompln tel_vlcompdb
           tel_qtdifeln tel_vldifedb
           tel_cdhistor tel_nrdconta tel_nrdocmto
           tel_vllanaut tel_cdbccxpg tel_dtmvtopg
           WITH FRAME f_lanaut.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

