/* .............................................................................

   Programa: Fontes/lanbdca.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                         Ultima atualizacao: 13/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela lanbdc.

   Alteracoes: 01/03/2004 - Alterado para NAO permitr a alteracao de 
                            cheques quando o boletim ja estiver liberado 
                            (Edson).

               08/07/2004 - Nao atualizar os campos de cheques superiores
                            e inferiores (Margarete).

               24/09/2004 - Ajuste no controle do bordero liberado (Edson).

               16/05/2005 - Tratamento Conta Integracao(Mirtes)

               26/01/2006 - Unificacao dos bancos - SQLWorks - Fernando
               
               26/05/2009 - Impedir a alteracao para cheque TB tpcheque = 2
                           (Fernando).
                           
               08/07/2010 - Tratamento para Compe 085 (Ze).
               
               29/11/2011 -  Alterações para não permitir data de liberação 
                            para último dia útil do Ano (Lucas).
                            
               20/08/2012 - Tratamento para Migracao Viacredi para AltoVale
                            - Bloqueio de Data na ult. semana do ano (Ze).
                            
               10/09/2012 - Projeto TIC - Gravagco do campo anterior 
                            (Richard/Supero)  
                            
               15/10/2012 - Tratamento para Migracao Alto Vale - alterar data
                            de 25/12 a 31/12 para 28/12 a 31/12 (Ze).
                            
               13/09/2013 - Tratamento para Migracao Viacredi - bloquear 
                            liberacao de cheque entre 27/12 a 06/01 (Ze).
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

FIND crapbdc WHERE crapbdc.cdcooper = glb_cdcooper  AND 
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

             Run mostra_dados.

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

   FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper AND
                      crapfdc.cdbanchq = tel_cdbanchq AND
                      crapfdc.cdagechq = tel_cdagechq AND
                      crapfdc.nrctachq = tel_nrctachq AND
                      crapfdc.nrcheque = tel_nrcheque NO-LOCK NO-ERROR.

   IF   AVAILABLE crapfdc   THEN
        IF   crapfdc.tpcheque = 2  THEN
             DO:
                MESSAGE "Nao e permitido alterar para cheque TB.".
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
               tab_inchqcop = 1.
        
        IF   crapcdb.inchqcop = 1   AND
             tab_inchqcop     = 1   THEN
             DO:
                 aux_nrdocmto = INT(STRING(crapcdb.nrcheque,"999999") +
                                    STRING(crapcdb.nrddigc3,"9")).

                 DO WHILE TRUE:

                    FIND craplau WHERE 
                         craplau.cdcooper = glb_cdcooper       AND
                         craplau.dtmvtolt = crapcdb.dtmvtolt   AND
                         craplau.cdagenci = crapcdb.cdagenci   AND
                         craplau.cdbccxlt = crapcdb.cdbccxlt   AND
                         craplau.nrdolote = crapcdb.nrdolote   AND
                DECIMAL(craplau.nrdctabb) = crapcdb.nrctachq   AND
                         craplau.nrdocmto = aux_nrdocmto
                         USE-INDEX craplau1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF   NOT AVAILABLE craplau   THEN
                         IF   LOCKED craplau   THEN
                              DO:
                                  PAUSE 2 NO-MESSAGE.
                                  NEXT.
                              END.
                      
                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */
             END.
        ELSE
             RELEASE craplau.
             
        ASSIGN tel_nmcustod = crapass.nmprimtl
               tel_vlcheque = crapcdb.vlcheque
               tel_dtlibera = crapcdb.dtlibera
               tel_nrcustod = crapcdb.nrdconta
               tel_nrseqdig = crapcdb.nrseqdig
               tel_vlcompdb = craplot.vlcompdb
               tel_vlcompcr = craplot.vlcompcr
               tel_qtcompln = craplot.qtcompln
               tel_vlinfodb = craplot.vlinfodb
               tel_vlinfocr = craplot.vlinfocr
               tel_qtinfoln = craplot.qtinfoln
               tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
               tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
               tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
               
               tel_nrborder = craplot.cdhistor
               
               ant_vlcheque = crapcdb.vlcheque.

         DISPLAY tel_qtinfoln tel_qtcompln tel_vlinfodb
                 tel_vlcompdb tel_vlinfocr tel_vlcompcr
                 tel_qtdifeln tel_vldifedb tel_vldifecr
                 tel_cdcmpchq tel_cdbanchq tel_cdagechq 
                 tel_nrddigc1 tel_nrctachq tel_nrddigc2
                 tel_nrcheque tel_nrddigc3 tel_vlcheque 
                 tel_nrseqdig tel_nrborder
                 WITH FRAME f_lanbdc.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
 
           IF   glb_cdcritic > 0 THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                END.
        
           UPDATE tel_vlcheque WITH FRAME f_lanbdc
           
           EDITING:
           
               READKEY.
                        
               IF   FRAME-FIELD = "tel_vlcheque"   THEN
                    IF   LASTKEY =  KEYCODE(".")   THEN
                         APPLY 44.
                    ELSE
                         APPLY LASTKEY.
               ELSE
                    APPLY LASTKEY.
                            
           END.  /*  Fim do EDITING  */

           glb_nrcalcul = tel_nrcustod.
                                    
           RUN fontes/digfun.p.
                  
           IF   NOT glb_stsnrcal   THEN
                DO:
                    glb_cdcritic = 8.
                    tel_nmcustod = "".
                    DISPLAY tel_nmcustod WITH FRAME f_lanbdc.
                    NEXT-PROMPT tel_nrcustod WITH FRAME f_lanbdc.
                    NEXT.
                END.
           
           DO WHILE TRUE:
               
              /*  Verifica se o associado esta cadastrado  */
      
              FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                                 crapass.nrdconta = tel_nrcustod 
                                 NO-LOCK NO-ERROR.
      
              IF   NOT AVAILABLE crapass   THEN
                   DO:
                       glb_cdcritic = 9.
                       tel_nmcustod = "".
                       DISPLAY tel_nmcustod WITH FRAME f_lanbdc.
                       NEXT-PROMPT tel_nrcustod WITH FRAME f_lanbdc.
                       LEAVE.
                   END.
              
              IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                   DO:
                       glb_cdcritic = 695.
                       NEXT-PROMPT tel_nrcustod WITH FRAME f_lanbdc.
                       LEAVE.
                   END.
              
              IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
                   DO:
                       FIND FIRST craptrf WHERE
                                  craptrf.cdcooper = glb_cdcooper     AND
                                  craptrf.nrdconta = crapass.nrdconta AND
                                  craptrf.tptransa = 1 USE-INDEX craptrf1
                                  NO-LOCK NO-ERROR.

                       IF   NOT AVAILABLE craptrf THEN
                            DO:
                                glb_cdcritic = 95.
                                NEXT-PROMPT tel_nrcustod WITH FRAME f_lanbdc.
                                LEAVE.
                            END.
                       ELSE
                            DO:
                                glb_cdcritic = 156.
                                RUN fontes/critic.p.

                                MESSAGE glb_dscritic 
                                        STRING(tel_nrcustod,"zzzz,zzz,9")
                                        "para o numero" 
                                        STRING(craptrf.nrsconta,"zzzz,zzz,9").

                                ASSIGN tel_nrcustod = craptrf.nrsconta
                                       glb_cdcritic = 0.
                           
                                DISPLAY tel_nrcustod WITH FRAME f_lanbdc.
                           
                                NEXT.
                            END.
                   END.

              IF   crapass.dtelimin <> ? THEN
                   DO:
                       glb_cdcritic = 410.
                       NEXT-PROMPT tel_nrcustod WITH FRAME f_lanbdc.
                       LEAVE.
                   END.
                    
              LEAVE.
                   
           END.  /*  Fim do DO WHILE TRUE  */
               
           IF   glb_cdcritic > 0   THEN
                NEXT.

           tel_nmcustod = crapass.nmprimtl.
      
           DISPLAY tel_nmcustod WITH FRAME f_lanbdc.
      
           /*  Verifica a validade da data para liberacao dos 
               cheques em custodia  */
           /*
           IF   tel_dtlibera <= glb_dtmvtolt   OR
                tel_dtlibera  = ?              THEN
                DO:
                    glb_cdcritic = 13.
                    NEXT-PROMPT tel_dtlibera WITH FRAME f_lanbdc.
                    NEXT.
                END.
           */

           /*  Tratamento especifico para Migracao Viacredi para Viacredi */
           IF   glb_cdcooper = 2           AND
                tel_dtlibera >= 12/27/2013 AND
                tel_dtlibera <= 01/06/2014 AND
               (tel_cdagenci = 02          OR
                tel_cdagenci = 04          OR
                tel_cdagenci = 06          OR
                tel_cdagenci = 07          OR
                tel_cdagenci = 11)         THEN
                DO:
                    glb_cdcritic = 13.
                    NEXT-PROMPT tel_dtlibera WITH FRAME f_lanbdc.
                    NEXT.
                END.

           /*  Nao permite data de liberação para último dia útil do Ano.  */

           RUN sistema/generico/procedures/b1wgen0015.p 
           PERSISTENT SET h-b1wgen0015.

           ASSIGN aux_dtdialim = DATE(12,31,YEAR(tel_dtlibera)).
           RUN retorna-dia-util IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                 INPUT FALSE,  /** Feriado **/
                                                 INPUT TRUE, /** Anterior **/
                                                 INPUT-OUTPUT aux_dtdialim).
           DELETE PROCEDURE h-b1wgen0015.

           IF   aux_dtdialim = tel_dtlibera THEN 
                DO:
                    glb_cdcritic = 13.
                    NEXT.
                END.

           LEAVE.
           
        END.  /*  Fim do DO WHILE TRUE  */
 
        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
             NEXT CMC-7.

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

        ASSIGN craplot.vlcompdb = craplot.vlcompdb + tel_vlcheque -
                                  crapcdb.vlcheque
               craplot.vlcompcr = craplot.vlcompcr + tel_vlcheque -
                                  crapcdb.vlcheque 
              
               crapcdb.vlchqant = crapcdb.vlcheque

               crapcdb.nrdconta = tel_nrcustod
               crapcdb.dtlibera = tel_dtlibera
               crapcdb.vlcheque = tel_vlcheque

               tel_vlcompdb = craplot.vlcompdb
               tel_vlcompcr = craplot.vlcompcr
               tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
               tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.
        
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
        
        IF   AVAILABLE craplau   THEN
             craplau.vllanaut = crapcdb.vlcheque.

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
              RETURN.                        /*  Volta ao lanbdc.p  */
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

