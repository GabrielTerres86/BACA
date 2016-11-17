/* .............................................................................

   Programa: Fontes/lanbdce.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                         Ultima atualizacao: 08/07/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela lanbdc.

   Alteracoes: 01/03/2004 - Alterado para NAO permitr a exclusao de 
                            cheques quando o boletim ja estiver liberado 
                            (Edson).

               08/07/2004 - Nao atualizar os campos de cheques superiores
                            e inferiores (Margarete).

               24/09/2004 - Ajuste no controle do bordero liberado (Edson).

               16/05/2005 - Tratamento Conta Integracao(Mirtes)

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               08/07/2010 - Tratamento para Compe 085 (Ze).
............................................................................. */

{ includes/var_online.i }

{ includes/var_lanbdc.i }

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

/*  Capa de lote  */

FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                   craplot.dtmvtolt = tel_dtmvtolt   AND
                   craplot.cdagenci = tel_cdagenci   AND
                   craplot.cdbccxlt = tel_cdbccxlt   AND
                   craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE craplot   THEN
     RETURN.

IF   craplot.tplotmov <> 26   THEN
     RETURN.

ASSIGN aux_dtlibera = craplot.dtmvtopg
       tel_dtlibera = craplot.dtmvtopg.

FIND crapbdc WHERE crapbdc.cdcooper = glb_cdcooper     AND 
                   crapbdc.nrborder = craplot.cdhistor NO-LOCK NO-ERROR.
      
IF   NOT AVAILABLE crapbdc   THEN
     RETURN.
 
IF   crapbdc.insitbdc > 2   THEN    
     DO:
         MESSAGE "Boletim ja LIBERADO!".
         BELL.
         RETURN.
     END.

/*FIND crapass OF crapbdc NO-LOCK NO-ERROR.*/

FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                   crapass.nrdconta = crapbdc.nrdconta NO-LOCK NO-ERROR.

ASSIGN tel_nrcustod = crapass.nrdconta
       tel_nmcustod = crapass.nmprimtl
       tel_nrborder = craplot.cdhistor.

DISPLAY tel_nrcustod tel_nmcustod tel_nrborder WITH FRAME f_lanbdc.

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
      
   UPDATE tel_dsdocmc7 WITH FRAME f_lanbdc
         
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

               DISPLAY tel_dsdocmc7 WITH FRAME f_lanbdc.
                     
               RUN mostra_dados.

               IF   glb_cdcritic > 0   THEN
                    NEXT.
                  
               LEAVE.
                  
            END.  /*  Fim do DO WHILE TRUE  */
                  
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                 NEXT.
        END.

   FIND crapbdc WHERE crapbdc.cdcooper = glb_cdcooper     AND 
                      crapbdc.nrborder = craplot.cdhistor NO-LOCK NO-ERROR.
      
   IF   NOT AVAILABLE crapbdc   THEN
        RETURN.
 
   IF   crapbdc.insitbdc > 2   THEN    
        DO:
            MESSAGE "Boletim ja LIBERADO!".
            BELL.
            RETURN.
        END.
     
     DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:    

        FIND crapcdb WHERE crapcdb.cdcooper = glb_cdcooper   AND 
                           crapcdb.dtmvtolt = tel_dtmvtolt   AND
                           crapcdb.cdagenci = tel_cdagenci   AND
                           crapcdb.cdbccxlt = tel_cdbccxlt   AND
                           crapcdb.nrdolote = tel_nrdolote   AND
                           crapcdb.cdcmpchq = tel_cdcmpchq   AND
                           crapcdb.cdbanchq = tel_cdbanchq   AND
                           crapcdb.cdagechq = tel_cdagechq   AND
                           crapcdb.nrctachq = tel_nrctachq   AND
                           crapcdb.nrcheque = tel_nrcheque
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                           
        IF   NOT AVAILABLE crapcdb   THEN
             IF   LOCKED crapcdb   THEN
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
                                                WITH FRAME f_lanbdc.
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
                 IF   craplot.tplotmov <> 26   THEN
                      glb_cdcritic = 100.
             END.
                   
        IF   glb_cdcritic > 0   THEN
             LEAVE.

        FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND 
                           crapass.nrdconta = crapcdb.nrdconta NO-LOCK NO-ERROR.
      
        IF   NOT AVAILABLE crapass   THEN
             DO:
                 glb_cdcritic = 9.
                 LEAVE.
             END.

        ASSIGN tab_intracst = 1        /*  Tratamento comp. CREDIHERING  */
               tab_inchqcop = 1

               tel_nmcustod = crapass.nmprimtl
               tel_nrborder = craplot.cdhistor
               tel_vlcheque = crapcdb.vlcheque
               tel_dtlibera = crapcdb.dtlibera
               tel_nrcustod = crapcdb.nrdconta
               tel_vlcompdb = craplot.vlcompdb
               tel_vlcompcr = craplot.vlcompcr
               tel_qtcompln = craplot.qtcompln
               tel_vlinfodb = craplot.vlinfodb
               tel_vlinfocr = craplot.vlinfocr
               tel_qtinfoln = craplot.qtinfoln
               tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
               tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
               tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln.
               
       DISPLAY tel_qtinfoln tel_qtcompln tel_vlinfodb
               tel_vlcompdb tel_vlinfocr tel_vlcompcr
               tel_qtdifeln tel_vldifedb tel_vldifecr
               tel_cdcmpchq tel_cdbanchq tel_cdagechq 
               tel_nrddigc1 tel_nrctachq tel_nrddigc2
               tel_nrcheque tel_nrddigc3 tel_vlcheque 
               tel_nrseqdig tel_nrborder tel_dtlibera
               WITH FRAME f_lanbdc.
        
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

        ASSIGN craplot.vlcompdb = craplot.vlcompdb - crapcdb.vlcheque
               craplot.vlcompcr = craplot.vlcompcr - crapcdb.vlcheque
               craplot.qtcompln = craplot.qtcompln - 1
              
               tel_vlcompdb = craplot.vlcompdb
               tel_vlcompcr = craplot.vlcompcr
               tel_qtcompln = craplot.qtcompln
               
               tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
               tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
               tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
               
               aux_nrdocmto = INT(STRING(crapcdb.nrcheque,"999999") +
                                  STRING(crapcdb.nrddigc3,"9")).

        DO WHILE TRUE:
        
           FIND craplau WHERE craplau.cdcooper = glb_cdcooper       AND 
                              craplau.dtmvtolt = crapcdb.dtmvtolt   AND
                              craplau.cdagenci = crapcdb.cdagenci   AND
                              craplau.cdbccxlt = crapcdb.cdbccxlt   AND
                              craplau.nrdolote = crapcdb.nrdolote   AND
                     DECIMAL(craplau.nrdctabb) = crapcdb.nrctachq   AND
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
             DELETE craplau.
             
        DELETE crapcdb.
        
        DO WHILE TRUE:
                 
           FIND crapbdc WHERE crapbdc.cdcooper = glb_cdcooper AND 
                              crapbdc.nrborder = craplot.cdhistor
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
           IF   NOT AVAILABLE crapbdc   THEN
                IF   LOCKED crapbdc   THEN
                     DO:
                         PAUSE 2 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     UNDO, RETURN.
                                  
           crapbdc.insitbdc = 1.                      /*  Em estudo  */
                 
           LEAVE.
           
        END.  /*  Fim do DO WHILE TRUE  */
        
        LEAVE.
        
     END.  /*  Fim do DO WHILE TRUE e da transacao  */

     RELEASE crapbdc.
     
     IF   glb_cdcritic > 0   THEN
          NEXT.

     IF   tel_qtdifeln = 0  AND  
          tel_vldifecr = 0  AND 
          tel_vldifedb = 0  THEN
          DO:
              glb_nmdatela = "LOTE".
              RETURN.                      /*  Volta ao lanbdc.p  */
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
         
    DISPLAY tel_qtinfoln tel_qtcompln tel_vlinfodb
            tel_vlcompdb tel_vlinfocr tel_vlcompcr
            tel_qtdifeln tel_vldifedb tel_vldifecr
            tel_cdcmpchq tel_cdbanchq tel_cdagechq 
            tel_nrddigc1 tel_nrctachq tel_nrddigc2
            tel_nrcheque tel_nrddigc3 tel_vlcheque 
            tel_nrseqdig
            WITH FRAME f_lanbdc.

    HIDE FRAME f_lanctos.

    DISPLAY tel_reganter[1] tel_reganter[2] WITH FRAME f_regant.

END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

{ includes/proc_lanbdc.i }

/* .......................................................................... */

