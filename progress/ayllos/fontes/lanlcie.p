/* .............................................................................

   Programa: fontes/lanlcie.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Setembro/2004.                      Ultima atualizacao: 12/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de EXCLUSAO da tela LANLCI.

   Alteracoes: 03/02/2005 - Permitir transferencia entre Contas de Invest.
                            (Mirtes/Evandro).

               04/07/2005 - Alimentado campo cdcooper da tabela crapsli (Diego).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Andre

               13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada
                            do programa fontes/pedesenha.p - SQLWorks - Fernando

               12/03/2007 - Usar o numero da conta para buscar o associado
                            (Evandro).
                            
               12/12/2013 - Inclusao de VALIDATE crapsli (Carlos)

.............................................................................*/
{ includes/var_online.i } 
{ includes/var_lanlci.i }

DEF VAR aux_dtrefere AS DATE                                        NO-UNDO.
DEF VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz,9"                 NO-UNDO.

DEF BUFFER crablci FOR craplci.
DEF BUFFER crabass FOR crapass.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   UPDATE tel_nrctainv tel_nrdocmto WITH FRAME f_lanlci.
   
   /* verifica o DV da conta */
   glb_nrcalcul = tel_nrctainv.

   RUN fontes/digfun.p.
   IF   NOT glb_stsnrcal   THEN
        DO:
            glb_cdcritic = 8.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT-PROMPT tel_nrctainv WITH FRAME f_lanlci.
            NEXT.
        END.

   /* se o dv esta correto procura o associado */
   glb_nrcalcul = tel_nrctainv - 600000000.

   RUN fontes/digfun.p.
   
   FIND crapass WHERE crapass.cdcooper = glb_cdcooper        AND
                      crapass.nrdconta = INT(glb_nrcalcul)
                      NO-LOCK NO-ERROR.
                      
   IF   NOT AVAILABLE crapass               OR
        crapass.nrctainv <> tel_nrctainv   THEN
        DO:
            glb_cdcritic = 9.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT-PROMPT tel_nrctainv WITH FRAME f_lanlci.
            NEXT.
        END.
   
   ASSIGN aux_nrdconta = crapass.nrdconta.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:   
  
      /* busca o lote */
      FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                         craplot.dtmvtolt = glb_dtmvtolt   AND
                         craplot.cdagenci = tel_cdagenci   AND 
                         craplot.cdbccxlt = tel_cdbccxlt   AND 
                         craplot.nrdolote = tel_nrdolote   AND
                         craplot.tplotmov = 29             
                         EXCLUSIVE-LOCK NO-ERROR.
                      
      /* busca lancamento conta investimento */
      FIND craplci WHERE craplci.cdcooper = glb_cdcooper    AND
                         craplci.dtmvtolt = glb_dtmvtolt    AND
                         craplci.cdagenci = tel_cdagenci    AND
                         craplci.cdbccxlt = tel_cdbccxlt    AND
                         craplci.nrdolote = tel_nrdolote    AND
                         craplci.nrdconta = aux_nrdconta    AND
                         craplci.nrdocmto = tel_nrdocmto 
                         EXCLUSIVE-LOCK NO-ERROR.

      IF   NOT AVAILABLE craplci    OR
           craplci.cdhistor = 648   THEN
           DO:
               glb_cdcritic = 90.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               RETURN.
           END.
        
      ASSIGN tel_cdhistor = craplci.cdhistor
             tel_vllanmto = craplci.vllanmto.
          
      DISPLAY  tel_cdhistor  tel_vllanmto  WITH FRAME f_lanlci.
        
      IF   (tel_cdhistor = 485   OR   tel_cdhistor = 487)   THEN
           DO:
               FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper        AND
                                  crapsli.nrdconta  = aux_nrdconta        AND
                            MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt) AND
                             YEAR(crapsli.dtrefere) = YEAR(glb_dtmvtolt)  
                                  NO-LOCK NO-ERROR.

               IF   (NOT AVAILABLE crapsli)                   OR
                    (crapsli.vlsddisp - tel_vllanmto < 0)     THEN
                    DO:
                
                        MESSAGE "ATENCAO! O saldo da CONTA DE INVESTIMENTO" 
                                "ficara NEGATIVO!"       VIEW-AS ALERT-BOX.
                                  
                        RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                                INPUT 2, 
                                                OUTPUT aut_flgsenha,
                                                OUTPUT aut_cdoperad).
                                                                              
                        IF   aut_flgsenha    THEN
                             DO:
                                UNIX SILENT VALUE("echo " + 
                                            STRING(glb_dtmvtolt,"99/99/9999") +
                                            " - " +
                                            STRING(TIME,"HH:MM:SS") +
                                            " - AUTORIZACAO - CONTA " + 
                                            "DE INVESTIMENTO" + 
                                            "' --> '" +
                                            " Operador: " + aut_cdoperad +
                                            " Conta Inv.: " +
                                            STRING(tel_nrctainv,"zz,zzz,zzz,9")                                             + " Valor: " +
                                            STRING(tel_vllanmto,
                                                   "zzz,zzz,zzz,zz9.99") +
                                            " >> log/lanlci.log").
                            END.
                        ELSE
                            LEAVE.
                    END.
           END.
           
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         aux_confirma = "N".
         glb_cdcritic = 78.
         RUN fontes/critic.p.
         BELL.
         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         glb_cdcritic = 0.
         LEAVE.
      END.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
           aux_confirma <> "S" THEN
           DO:
               glb_cdcritic = 79.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               LEAVE.
           END.
      
      /*--- Atualizar Saldo Conta Investimento */
      FIND crapsli WHERE crapsli.cdcooper = glb_cdcooper         AND
                         crapsli.nrdconta = aux_nrdconta         AND
                  MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt)  AND
                   YEAR(crapsli.dtrefere) = YEAR(glb_dtmvtolt)   
                        EXCLUSIVE-LOCK NO-ERROR.

      IF  NOT AVAIL crapsli THEN
          DO:
             ASSIGN aux_dtrefere = 
                  ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                    DAY(DATE(MONTH(glb_dtmvtolt),28,
                    YEAR(glb_dtmvtolt)) + 4)).
           
             CREATE crapsli.
             ASSIGN crapsli.dtrefere = aux_dtrefere
                    crapsli.nrdconta = aux_nrdconta
                    crapsli.cdcooper = glb_cdcooper.
             VALIDATE crapsli.
          END.

      IF   tel_cdhistor = 485   THEN
           ASSIGN /*craplot.qtinfoln = craplot.qtinfoln - 1*/
                  craplot.qtcompln = craplot.qtcompln - 1
                  craplot.nrseqdig = craplot.nrseqdig - 1
                  craplot.vlcompcr = craplot.vlcompcr - tel_vllanmto
                  /*craplot.vlinfocr = craplot.vlinfocr - tel_vllanmto*/
                  crapsli.vlsddisp = crapsli.vlsddisp - tel_vllanmto.
      ELSE
      IF   tel_cdhistor = 486   OR
           tel_cdhistor = 647   THEN
           DO:
               ASSIGN /*craplot.qtinfoln = craplot.qtinfoln - 1*/
                      craplot.qtcompln = craplot.qtcompln - 1
                      craplot.nrseqdig = craplot.nrseqdig - 1
                      craplot.vlcompdb = craplot.vlcompdb - tel_vllanmto
                      /*craplot.vlinfodb = craplot.vlinfodb - tel_vllanmto*/
                      crapsli.vlsddisp = crapsli.vlsddisp + tel_vllanmto.

               IF   tel_cdhistor = 647   THEN
                    DO:
                       /* Busca o lancamento da Conta Inv. Destino */
                       FIND crablci WHERE 
                            crablci.cdcooper  = glb_cdcooper       AND
                            crablci.dtmvtolt  = craplci.dtmvtolt   AND
                            crablci.cdagenci  = craplci.cdagenci   AND
                            crablci.cdbccxlt  = craplci.cdbccxlt   AND
                            crablci.nrdolote  = craplci.nrdolote   AND
                            crablci.nrdocmto  = craplci.nrdocmto   AND
                            crablci.vllanmto  = craplci.vllanmto   AND
                            crablci.nrseqdig  = craplci.nrseqdig   AND
                            crablci.cdhistor  = 648                AND
                            crablci.nrdconta <> craplci.nrdconta
                            EXCLUSIVE-LOCK NO-ERROR.

                       IF   NOT AVAILABLE crablci   THEN
                            DO:
                                glb_cdcritic = 90.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                RETURN.
                            END.
                            
                       FIND crabass WHERE crabass.cdcooper = glb_cdcooper AND
                                          crabass.nrdconta = crablci.nrdconta
                                          NO-LOCK NO-ERROR.
                       
                       /*--- Atualizar Saldo Conta Investimento Destino ---*/
                       FIND crapsli WHERE 
                            crapsli.cdcooper  = glb_cdcooper         AND
                            crapsli.nrdconta  = crabass.nrdconta     AND
                      MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt)  AND
                       YEAR(crapsli.dtrefere) = YEAR(glb_dtmvtolt)
                            EXCLUSIVE-LOCK NO-ERROR.

                       IF  NOT AVAIL crapsli THEN
                           DO:
                              ASSIGN aux_dtrefere =
                                           ((DATE(MONTH(glb_dtmvtolt),28,
                                                 YEAR(glb_dtmvtolt)) + 4) -
                                             DAY(DATE(MONTH(glb_dtmvtolt),28,
                                                 YEAR(glb_dtmvtolt)) + 4)).
           
                              CREATE crapsli.
                              ASSIGN crapsli.dtrefere = aux_dtrefere
                                     crapsli.nrdconta = crabass.nrdconta
                                     crapsli.cdcooper = glb_cdcooper.
                              VALIDATE crapsli.
                           END.

                       IF   (crapsli.vlsddisp - tel_vllanmto) < 0   THEN
                            DO:
                                MESSAGE "A Conta de Investimentos de Destino"
                                        "ficara negativa.".
                                MESSAGE "Impossivel continuar!!!".
                                UNDO, RETURN.
                            END.
                       
                       ASSIGN crapsli.vlsddisp = crapsli.vlsddisp -
                                                    tel_vllanmto.
                                                    
                       DELETE crablci.
                    END.
           END.                      
      ELSE     
      IF   tel_cdhistor = 487   THEN
           DO:
               ASSIGN /*craplot.qtinfoln = craplot.qtinfoln - 1*/
                      craplot.qtcompln = craplot.qtcompln - 1
                      craplot.nrseqdig = craplot.nrseqdig - 1
                      craplot.vlcompcr = craplot.vlcompcr - tel_vllanmto
                      /*craplot.vlinfocr = craplot.vlinfocr - tel_vllanmto*/
                      crapsli.vlsddisp = crapsli.vlsddisp - tel_vllanmto.
                   
               FOR EACH crapchd WHERE crapchd.cdcooper = glb_cdcooper   AND
                                      crapchd.dtmvtolt = tel_dtmvtolt   AND
                                      crapchd.cdagenci = tel_cdagenci   AND 
                                      crapchd.cdbccxlt = tel_cdbccxlt   AND 
                                      crapchd.nrdolote = tel_nrdolote   AND 
                                      crapchd.nrdconta = aux_nrdconta   AND 
                                      crapchd.nrdocmto = tel_nrdocmto
                                      USE-INDEX crapchd3 EXCLUSIVE-LOCK:

                   DELETE crapchd.                                   
               END.
           END.
               
      ASSIGN tel_cdhistor = 0
             tel_nrctainv = 0
             tel_nrdocmto = 0
             tel_vllanmto = 0
             tel_qtinfoln = craplot.qtinfoln   
             tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   
             tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   
             tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.
      
      IF   craplot.qtinfoln = 0   AND   craplot.qtcompln = 0   AND
           craplot.vlcompcr = 0   AND   craplot.vlinfocr = 0   AND
           craplot.vlcompdb = 0   AND   craplot.vlinfodb = 0   THEN
           DELETE craplot.
        
      DELETE craplci.
   
      LEAVE.
      
   END. /* fim DO WHILE TRUE */
   
   RELEASE  craplci.
   RELEASE  craplot.
   RELEASE  crapsli.
   
   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  AND  tel_vldifecr = 0   THEN
        DO:
            glb_nmdatela = "LOTE".
            RETURN.                        /* Volta para a lanlci */
        END.

   DISPLAY tel_qtinfoln  tel_vlinfodb  tel_vlinfocr
           tel_qtcompln  tel_vlcompdb  tel_vlcompcr
           tel_qtdifeln  tel_vldifedb  tel_vldifecr  WITH FRAME f_lanlci.

   HIDE  tel_cdhistor  tel_vllanmto  IN FRAME f_lanlci.

END.
/*...........................................................................*/
