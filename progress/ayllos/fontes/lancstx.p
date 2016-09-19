/* .............................................................................

   Programa: Fontes/lancstx.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                         Ultima atualizacao: 08/07/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de cancelamento de devolucao da tela lancst.

   Alteracoes: 11/07/2001 - Alterado para adaptar o nome de campo (Edson).
   
               25/09/2001 - Alterado layout da tela para mostrar cheques por
                            tipo Credi, maiores e menores (Junior). 
                            
               03/11/2003 - Tratamento para cheques descontados (Julio).

               16/05/2005 - Tratamento Conta Integracao(Mirtes)
               
               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               08/07/2010 - Tratamento para Compe 085 (Ze).
............................................................................. */

{ includes/var_online.i }

{ includes/var_lancst.i }

{ includes/proc_conta_integracao.i }

ASSIGN tel_nmcustod = ""
       tel_dtlibera = ?
       tel_nrcustod = 0
       tel_cdcmpchq = 0
       tel_cdbanchq = 0
       tel_cdagechq = 0
       tel_nrddigc1 = 0
       tel_nrctachq = 0
       tel_nrddigc2 = 0
       tel_nrcheque = 0
       tel_nrddigc3 = 0
       tel_vlcheque = 0
       tel_nrseqdig = 1.

CMC-7:
      
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0
                   tel_dsdocmc7 = "".
        END.
      
   UPDATE tel_dsdocmc7 WITH FRAME f_lancst
         
   EDITING:
            
      READKEY.
       
      IF   NOT CAN-DO(aux_lsvalido,KEYLABEL(LASTKEY))   THEN
           DO:
               glb_cdcritic = 666.
               NEXT.
           END.

      IF   KEYLABEL(LASTKEY) = "G"   THEN
           APPLY KEYCODE(":").
      ELSE
           APPLY LASTKEY.
  
   END.  /*  Fim do EDITING  */
         
   HIDE MESSAGE NO-PAUSE.
       
   IF   TRIM(tel_dsdocmc7) <> ""   THEN
        DO:
            IF   LENGTH(tel_dsdocmc7) <> 34            OR
                 SUBSTRING(tel_dsdocmc7,01,1) <> "<"   OR
                 SUBSTRING(tel_dsdocmc7,10,1) <> "<"   OR
                 SUBSTRING(tel_dsdocmc7,21,1) <> ">"   OR
                 SUBSTRING(tel_dsdocmc7,34,1) <> ":"   THEN
                 DO:
                     glb_cdcritic = 666.
                     NEXT.
                 END.
            
            RUN mostra_dados.

            IF   glb_cdcritic > 0   THEN
                 NEXT.
        END.
   ELSE
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               RUN fontes/cmc7.p (OUTPUT tel_dsdocmc7).
                     
               IF   LENGTH(tel_dsdocmc7) <> 34   THEN
                    APPLY "END-ERROR".

               DISPLAY tel_dsdocmc7 WITH FRAME f_lancst.
                     
               RUN mostra_dados.

               IF   glb_cdcritic > 0   THEN
                    NEXT.
                   
               LEAVE.
                  
            END.  /*  Fim do DO WHILE TRUE  */
                  
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                 NEXT.
        END.
     
     DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:    

        FIND crapcst WHERE crapcst.cdcooper = glb_cdcooper   AND 
                           crapcst.dtmvtolt = tel_dtmvtolt   AND
                           crapcst.cdagenci = tel_cdagenci   AND
                           crapcst.cdbccxlt = tel_cdbccxlt   AND
                           crapcst.nrdolote = tel_nrdolote   AND
                           crapcst.cdcmpchq = tel_cdcmpchq   AND
                           crapcst.cdbanchq = tel_cdbanchq   AND
                           crapcst.cdagechq = tel_cdagechq   AND
                           crapcst.nrctachq = tel_nrctachq   AND
                           crapcst.nrcheque = tel_nrcheque
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                           
        IF   NOT AVAILABLE crapcst   THEN
             IF   LOCKED crapcst   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      IF  (tel_cdbanchq = 756            AND 
                           tel_cdagechq = aux_cdagebcb)  OR
                          (tel_cdbanchq = aux_cdbcoctl   AND
                           tel_cdagechq = aux_cdagectl)  THEN
                           DO:
                               FIND FIRST craptrf WHERE
                                    craptrf.cdcooper = glb_cdcooper      AND 
                                    craptrf.nrdconta = INT(tel_nrctachq) AND
                                    craptrf.tptransa = 1 
                                    USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                               IF   AVAILABLE craptrf THEN
                                    DO:
                                        tel_nrctachq = craptrf.nrsconta.
                                        DISPLAY tel_nrctachq
                                                WITH FRAME f_lancst.
                                        NEXT.
                                    END.
                           END.
 
                      glb_cdcritic = 90.
                      LEAVE.
                  END.

        FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                           craplot.dtmvtolt = tel_dtmvtolt   AND
                           craplot.cdagenci = tel_cdagenci   AND
                           craplot.cdbccxlt = tel_cdbccxlt   AND
                           craplot.nrdolote = tel_nrdolote
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE craplot   THEN
             IF   LOCKED craplot   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  glb_cdcritic = 60.
        ELSE
             DO:   
                 IF   craplot.tplotmov <> 19   THEN
                      glb_cdcritic = 100.
             END.
                   
        IF   glb_cdcritic > 0   THEN
             LEAVE.

        FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND 
                           crapass.nrdconta = crapcst.nrdconta NO-LOCK NO-ERROR.
      
        IF   NOT AVAILABLE crapass   THEN
             DO:
                 glb_cdcritic = 9.
                 LEAVE.
             END.

        ASSIGN tel_nmcustod = crapass.nmprimtl
               tel_vlcheque = crapcst.vlcheque
               tel_dtlibera = crapcst.dtlibera
               tel_nrcustod = crapcst.nrdconta
               tel_nrseqdig = crapcst.nrseqdig
               
               tel_vlcompdb = craplot.vlcompdb
               tel_vlcompcr = craplot.vlcompcr
               tel_qtcompln = craplot.qtcompln
               tel_vlinfodb = craplot.vlinfodb
               tel_vlinfocr = craplot.vlinfocr
               tel_qtinfoln = craplot.qtinfoln
               tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
               tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
               tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln

               tel_qtinfocc = craplot.qtinfocc
               tel_vlinfocc = craplot.vlinfocc
               tel_qtcompcc = craplot.qtcompcc
               tel_vlcompcc = craplot.vlcompcc
               tel_qtdifecc = craplot.qtinfocc - craplot.qtcompcc
               tel_vldifecc = craplot.vlinfocc - craplot.vlcompcc

               tel_qtinfoci = craplot.qtinfoci
               tel_vlinfoci = craplot.vlinfoci
               tel_qtcompci = craplot.qtcompci
               tel_vlcompci = craplot.vlcompci
               tel_qtdifeci = craplot.qtinfoci - craplot.qtcompci
               tel_vldifeci = craplot.vlinfoci - craplot.vlcompci

               tel_qtinfocs = craplot.qtinfocs
               tel_vlinfocs = craplot.vlinfocs
               tel_qtcompcs = craplot.qtcompcs
               tel_vlcompcs = craplot.vlcompcs
               tel_qtdifecs = craplot.qtinfocs - craplot.qtcompcs
               tel_vldifecs = craplot.vlinfocs - craplot.vlcompcs.

        DISPLAY tel_qtinfocc tel_vlinfocc tel_qtcompcc
                tel_vlcompcc tel_qtdifecc tel_vldifecc
                tel_qtinfoci tel_vlinfoci tel_qtcompci
                tel_vlcompci tel_qtdifeci tel_vldifeci
                tel_qtinfocs tel_vlinfocs tel_qtcompcs
                tel_vlcompcs tel_qtdifecs tel_vldifecs
                tel_cdcmpchq tel_cdbanchq tel_cdagechq
                tel_nrddigc1 tel_nrctachq tel_nrddigc2
                tel_nrcheque tel_nrddigc3 tel_nrcustod 
                tel_nmcustod tel_dtlibera tel_vlcheque
                tel_nrseqdig
                WITH FRAME f_lancst.
                
        /* Cheques com situacao 5 NAO podem ser desfeita a devolucao  - Edson */                
                                               /*  0 = A PROCESSAR  */
        IF   (crapcst.insitchq <> 1)   THEN    /*  1 = DEVOLVIDO    */
                                               /*  2 = JA LIBERADO  */
             DO:                               /*  5 = DESCONTADO   */        
                 IF   crapcst.insitchq = 0    THEN
                      glb_cdcritic = 671.
                 ELSE
                      glb_cdcritic = 670.

                 NEXT CMC-7.
             END.        

        IF   crapcst.dtlibera <= glb_dtmvtolt   THEN
             DO:                        
                 glb_cdcritic = 13.
                 NEXT CMC-7.
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
                 NEXT CMC-7.
             END.

        aux_nrdocmto = INT(STRING(crapcst.nrcheque,"999999") +
                           STRING(crapcst.nrddigc3,"9")).

        DO WHILE TRUE:
        
           FIND craplau WHERE craplau.cdcooper = glb_cdcooper       AND 
                              craplau.dtmvtolt = crapcst.dtmvtolt   AND
                              craplau.cdagenci = crapcst.cdagenci   AND
                              craplau.cdbccxlt = crapcst.cdbccxlt   AND
                              craplau.nrdolote = crapcst.nrdolote   AND
                     DECIMAL(craplau.nrdctabb) = crapcst.nrctachq   AND
                              craplau.nrdocmto = aux_nrdocmto
                              USE-INDEX craplau1 EXCLUSIVE-LOCK 
                              NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE craplau   THEN
                IF   LOCKED craplau   THEN
                     DO:
                         PAUSE 2 NO-MESSAGE.
                         NEXT.
                     END.
                      
           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */
        
        IF   AVAILABLE craplau   THEN
             ASSIGN craplau.dtdebito = ?
                    craplau.insitlau = 1.

        ASSIGN crapcst.dtdevolu = ? 
               crapcst.cdopedev = ""
               crapcst.insitchq = 0.
        
        LEAVE.
        
     END.  /*  Fim do DO WHILE TRUE e da transacao  */

     IF   glb_cdcritic > 0   THEN
          NEXT.

     IF   tel_qtdifeln = 0  AND  
          tel_vldifedb = 0  AND 
          tel_vldifecr = 0   THEN
          DO:
              glb_nmdatela = "LOTE".
              RETURN.                        /*  Volta ao lancst.p  */
          END.

     ASSIGN tel_reganter[2] = tel_reganter[1]

            tel_reganter[1] = STRING(tel_cdcmpchq,"zz9") + " " +
                              STRING(tel_cdbanchq,"zz9") + " " +
                              STRING(tel_cdagechq,"zzz9") + "  " +
                              STRING(tel_nrddigc1,"9") + " " +
                              STRING(tel_nrctachq,"zzz,zzz,zzz,9") + "  " +
                              STRING(tel_nrddigc2,"9") + " " +
                              STRING(tel_nrcheque,"zzz,zz9") + "  " +
                              STRING(tel_nrddigc3,"9") + "    " +
                              STRING(tel_vlcheque,"zzz,zzz,zzz,zz9.99") +
                              "   " +
                              STRING(tel_nrseqdig,"zz,zz9")

            tel_dsdocmc7 = ""
            tel_cdcmpchq = 0
            tel_cdbanchq = 0 
            tel_cdagechq = 0
            tel_nrddigc1 = 0
            tel_nrctachq = 0
            tel_nrddigc2 = 0
            tel_nrcheque = 0
            tel_nrddigc3 = 0
            tel_vlcheque = 0.

    DISPLAY tel_qtinfocc tel_vlinfocc tel_qtcompcc
            tel_vlcompcc tel_qtdifecc tel_vldifecc
            tel_qtinfoci tel_vlinfoci tel_qtcompci
            tel_vlcompci tel_qtdifeci tel_vldifeci
            tel_qtinfocs tel_vlinfocs tel_qtcompcs
            tel_vlcompcs tel_qtdifecs tel_vldifecs
            tel_cdcmpchq tel_cdbanchq tel_cdagechq
            tel_nrddigc1 tel_nrctachq tel_nrddigc2
            tel_nrcheque tel_nrddigc3 tel_vlcheque
            tel_nrseqdig
            WITH FRAME f_lancst.

     HIDE FRAME f_lanctos.

     DISPLAY tel_reganter[1] tel_reganter[2] WITH FRAME f_regant.

END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

{ includes/proc_lancst.i }

/* .......................................................................... */

