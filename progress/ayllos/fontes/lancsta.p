/* .............................................................................

   Programa: Fontes/lancsta.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                         Ultima atualizacao: 13/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela lancst.

   Alteracoes: 24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               11/06/2001 - Verifica parametros de custodia para a
                            conta favorecida (Edson).

               11/07/2001 - Alterado para adaptar o nome de campo (Edson).
               
               12/09/2001 - Tratar a alteracao de lancamentos por valores de 
                            cheque Credihering, Maiores e Menores (Junior).
                            
               25/09/2001 - Alterado layout da tela para mostrar cheques por
                            tipo Credi, maiores e menores (Junior).

               16/05/2005 - Tratamento Conta Integracao(Mirtes)

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
                 
               26/05/2009 - Impedir a alteracao para cheque TB tpcheque = 2
                            (Fernando).
                            
               29/11/2011 - Adicionado tratamento para não permitir data de 
                            liberação para último dia útil do Ano (Lucas).
                            
               20/08/2012 - Tratamento para Migracao Viacredi para AltoVale
                            - Bloqueio de Data na ult. semana do ano (Ze).
                            
               10/09/2012 - Projeto TIC - Gravação do campo anterior 
                           (Richard/Supero)
                           
               15/10/2012 - Tratamento para Migracao Alto Vale - alterar data
                            de 25/12 a 31/12 para 28/12 a 31/12 (Ze).
                            
               13/09/2013 - Tratamento para Migracao Viacredi - bloquear 
                            liberacao de cheque entre 27/12 a 06/01 (Ze).
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

               DISPLAY tel_dsdocmc7 WITH FRAME f_lancst.
                     
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
                      IF   tel_cdbanchq = 756            AND 
                           tel_cdagechq = aux_cdagebcb   THEN
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

        /*  Verifica parametros de custodia para a conta favorecida  */
      
        FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND 
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "CUSTOD"     AND
                           craptab.cdempres = 00           AND
                           craptab.cdacesso = STRING(crapass.nrdconta,
                                                     "9999999999")   AND
                           craptab.tpregist = 0 NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE craptab   THEN
             ASSIGN tab_intracst = 1        /*  Tratamento comp. CREDIHERING  */
                    tab_inchqcop = 1.
        ELSE
             ASSIGN tab_intracst = INT(SUBSTR(craptab.dstextab,01,01))
                    tab_inchqcop = INT(SUBSTR(craptab.dstextab,03,01)).
        
        IF   crapcst.inchqcop = 1   AND
             tab_inchqcop     = 1   THEN
             DO:
                 aux_nrdocmto = INT(STRING(crapcst.nrcheque,"999999") +
                                    STRING(crapcst.nrddigc3,"9")).

                 DO WHILE TRUE:

                    FIND craplau WHERE craplau.cdcooper  = glb_cdcooper     AND
                                       craplau.dtmvtolt  = crapcst.dtmvtolt AND
                                       craplau.cdagenci  = crapcst.cdagenci AND
                                       craplau.cdbccxlt  = crapcst.cdbccxlt AND
                                       craplau.nrdolote  = crapcst.nrdolote AND
                               DECIMAL(craplau.nrdctabb) = crapcst.nrctachq AND
                                       craplau.nrdocmto  = aux_nrdocmto
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
             END.
        ELSE
             RELEASE craplau.
             
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
               ant_vlcheque = crapcst.vlcheque

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
                tel_nrcheque tel_nrddigc3 tel_vlcheque
                tel_nrseqdig
                WITH FRAME f_lancst.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
 
           IF   glb_cdcritic > 0 THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                END.
        
           UPDATE /*  tel_nrcustod  tel_dtlibera --  NAO LIBERAR - EDSON  */    
                  tel_vlcheque WITH FRAME f_lancst
           
           EDITING:
           
              IF   FRAME-FIELD = "tel_dtlibera"   THEN
                   IF   craplot.dtmvtopg = ?   THEN
                        DO:
                            READKEY.
                            APPLY LASTKEY.
                        END.
                   ELSE
                        APPLY 13.
              ELSE
                   DO:
                       READKEY.
                        
                       IF   FRAME-FIELD = "tel_vlcheque"   THEN
                            IF   LASTKEY =  KEYCODE(".")   THEN
                                 APPLY 44.
                            ELSE
                                 APPLY LASTKEY.
                       ELSE
                            APPLY LASTKEY.
                   END.
                            
           END.  /*  Fim do EDITING  */

           glb_nrcalcul = tel_nrcustod.
                                    
           RUN fontes/digfun.p.
                  
           IF   NOT glb_stsnrcal   THEN
                DO:
                    glb_cdcritic = 8.
                    tel_nmcustod = "".
                    DISPLAY tel_nmcustod WITH FRAME f_lancst.
                    NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
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
                       DISPLAY tel_nmcustod WITH FRAME f_lancst.
                       NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
                       LEAVE.
                   END.
              
              IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                   DO:
                       glb_cdcritic = 695.
                       NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
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
                                NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
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
                           
                                DISPLAY tel_nrcustod WITH FRAME f_lancst.
                           
                                NEXT.
                            END.
                   END.

              IF   crapass.dtelimin <> ? THEN
                   DO:
                       glb_cdcritic = 410.
                       NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
                       LEAVE.
                   END.
                    
              LEAVE.
                   
           END.  /*  Fim do DO WHILE TRUE  */
               
           IF   glb_cdcritic > 0   THEN
                NEXT.

           tel_nmcustod = crapass.nmprimtl.
      
           DISPLAY tel_nmcustod WITH FRAME f_lancst.
      
           /*  Verifica a validade da data para liberacao dos 
               cheques em custodia  */
        
           IF   tel_dtlibera <= glb_dtmvtolt   OR
                tel_dtlibera  = ?              THEN
                DO:
                    glb_cdcritic = 13.
                    NEXT-PROMPT tel_dtlibera WITH FRAME f_lancst.
                    NEXT.
                END.
          
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
                    NEXT-PROMPT tel_dtlibera WITH FRAME f_lancst.
                    NEXT.
                END.

           
           /*  Nao permite data de liberação para último dia útil do Ano.  */

           RUN sistema/generico/procedures/b1wgen0015.p 
              PERSISTENT SET h-b1wgen0015.

           ASSIGN aux_dtdialim = DATE(12,31,YEAR(tel_dtlibera)).
           RUN retorna-dia-util IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                 INPUT FALSE,  /* Feriado */
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
                                  crapcst.vlcheque
               craplot.vlcompcr = craplot.vlcompcr + tel_vlcheque -
                                  crapcst.vlcheque 
               
               crapcst.vlchqant = crapcst.vlcheque 

               crapcst.nrdconta = tel_nrcustod
               crapcst.dtlibera = tel_dtlibera
               crapcst.vlcheque = tel_vlcheque

               tel_vlcompdb = craplot.vlcompdb
               tel_vlcompcr = craplot.vlcompcr
               tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
               tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

        /*  Le tabela com o valor dos cheques maiores  */

        FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "USUARI"       AND
                           craptab.cdempres = 11             AND
                           craptab.cdacesso = "MAIORESCHQ"   AND
                           craptab.tpregist = 1 NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE craptab   THEN
             tab_vlchqmai = 1.
        ELSE
             tab_vlchqmai = DECIMAL(SUBSTRING(craptab.dstextab,01,15)).

        IF   ant_vlcheque <> tel_vlcheque THEN
             
             IF   crapcst.inchqcop = 0 THEN

                  IF   ant_vlcheque >= tab_vlchqmai THEN
                       
                       IF   tel_vlcheque >= tab_vlchqmai THEN
                            craplot.vlcompcs = craplot.vlcompcs + tel_vlcheque 
                                               - ant_vlcheque.
                       ELSE
                            ASSIGN craplot.vlcompcs = craplot.vlcompcs -
                                                      ant_vlcheque
                                   craplot.qtcompcs = craplot.qtcompcs - 1
                                   craplot.vlcompci = craplot.vlcompci + 
                                                      tel_vlcheque
                                   craplot.qtcompci = craplot.qtcompci + 1.
                            
                  ELSE
                       IF   tel_vlcheque < tab_vlchqmai THEN
                            craplot.vlcompci = craplot.vlcompci + tel_vlcheque
                                               - ant_vlcheque.
                       ELSE
                            ASSIGN craplot.vlcompci = craplot.vlcompci - 
                                                      ant_vlcheque
                                   craplot.qtcompci = craplot.qtcompci - 1
                                   craplot.vlcompcs = craplot.vlcompcs + 
                                                      tel_vlcheque
                                   craplot.qtcompcs = craplot.qtcompcs + 1.

             ELSE
                  craplot.vlcompcc = craplot.vlcompcc + tel_vlcheque -
                                             ant_vlcheque.
        
        ASSIGN tel_qtdifecc = craplot.qtcompcc - craplot.qtinfocc
               tel_vldifecc = craplot.vlcompcc - craplot.vlinfocc
               tel_qtdifeci = craplot.qtcompci - craplot.qtinfoci
               tel_vldifeci = craplot.vlcompci - craplot.vlinfoci
               tel_qtdifecs = craplot.qtcompcs - craplot.qtinfocs
               tel_vldifecs = craplot.vlcompcs - craplot.vlinfocs
               tel_qtcompcc = craplot.qtcompcc
               tel_vlcompcc = craplot.vlcompcc
               tel_qtcompcs = craplot.qtcompcs
               tel_vlcompcs = craplot.vlcompcs
               tel_qtcompci = craplot.qtcompci
               tel_vlcompci = craplot.vlcompci.
               
        IF   AVAILABLE craplau   THEN
             craplau.vllanaut = crapcst.vlcheque.

        LEAVE.
        
     END.  /*  Fim do DO WHILE TRUE e da transacao  */

     IF   glb_cdcritic > 0   THEN
          NEXT.

     IF   tel_qtdifecc = 0  AND  
          tel_vldifecc = 0  AND 
          tel_qtdifeci = 0  AND
          tel_vldifeci = 0  AND
          tel_qtdifecs = 0  AND
          tel_vldifecs = 0  THEN
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

