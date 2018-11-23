/* .............................................................................

   Programa: Fontes/lantitr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Setembro/2000.                      Ultima atualizacao: 24/10/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de resgate da tela LANTIT.

   Alteracoes: 05/01/2001 - Tratar tipo de lote 21 (Deborah).

               09/01/2001 - Efetivar o convenio de arrecadacao de IPTU
                            Blumenau no sistema. (Eduardo).
                            
               30/03/2001 - Substituir o nome ciptu.p por verbar3.p.
                            (Eduardo).             

               10/02/2004 - Efetuado controle por PAC(tabelas horario 
                            compel/titulo) (Mirtes)

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               23/11/2009 - Alteracao Codigo Historico (Kbase). 
               
               19/10/2018 - PRJ450 - Regulatorios de Credito - centralizacao de 
                            estorno de lançamentos na conta corrente              
                            pc_estorna_lancto_prog (Fabio Adriano - AMcom).
............................................................................. */

{ includes/var_online.i }

{ includes/var_lantit.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0200tt.i }

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.

DEF VAR aux_cdcritic        AS INTE                                NO-UNDO.
DEF VAR aux_dscritic        AS CHAR                                NO-UNDO.

ASSIGN tel_nrdconta = 0
       tel_cdhistor = 0
       tel_nmprimtl = ""
       tel_dscodbar = ""
       tel_dsdlinha = ""
       tel_vldpagto = 0
       tel_nrseqdig = 0.

BARRAS:

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0
                   tel_nrdconta = 0
                   tel_nmprimtl = ""
                   tel_dscodbar = ""
                   tel_dsdlinha = ""
                   tel_vldpagto = 0
                   tel_nrseqdig = 0
                   tel_reganter = "".

            DISPLAY tel_nrdconta tel_nmprimtl tel_dscodbar tel_dsdlinha 
                    tel_vldpagto tel_nrseqdig WITH FRAME f_lantit.        

            HIDE FRAME f_regant NO-PAUSE.
        END.
      
   IF   tel_cdbccxlt = 11 AND aux_tplotmov = 20 THEN /*  Arrecadacao caixa  */
        DO:
            /*  Tabela com o horario limite para digitacao  */

            FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "GENERI"     AND
                               craptab.cdempres = 0            AND
                               craptab.cdacesso = "HRTRTITULO" AND
                               craptab.tpregist = tel_cdagenci NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 676.
                     LEAVE.
                 END.

            IF   TIME >= INT(SUBSTRING(craptab.dstextab,3,5))   THEN
                 DO:
                     glb_cdcritic = 676.
                     LEAVE.
                 END.

            IF   INT(SUBSTRING(craptab.dstextab,1,1)) > 0   THEN
                 DO:
                     glb_cdcritic = 677.
                     LEAVE.
                 END.
        END.
        
   UPDATE tel_dscodbar WITH FRAME f_lantit
         
   EDITING:
            
      READKEY.
      
      IF   NOT CAN-DO(aux_lsvalido,KEYLABEL(LASTKEY))   THEN
           DO:
               glb_cdcritic = 666.
               NEXT.
           END.
   
      APPLY LASTKEY.
  
   END.  /*  Fim do EDITING  */
         
   HIDE MESSAGE NO-PAUSE.
       
   IF   TRIM(tel_dscodbar) <> ""   THEN
        DO:
            IF   LENGTH(tel_dscodbar) <> 44   THEN
                 DO:
                     glb_cdcritic = 666.
                     NEXT.
                 END.

            glb_nrcalcul = DECIMAL(tel_dscodbar).
   
            IF   aux_tplotmov = 21 THEN  /*  IPTU Blumenau  */
                 RUN fontes/cdbarra3.p (OUTPUT aux_nrdigver).
            ELSE 
                 RUN fontes/digcbtit.p.
                  
            IF   NOT glb_stsnrcal   THEN
                 DO:
                     glb_cdcritic = 8.
                     NEXT.
                 END.

            RUN mostra_dados.
        END.
   ELSE
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
               IF   aux_tplotmov = 21 THEN  /*  IPTU Blumenau  */
                    RUN fontes/verbar3.p (OUTPUT tel_dscodbar).
               ELSE
                    RUN fontes/cbtit.p (OUTPUT tel_dscodbar).
                   
               IF   LENGTH(tel_dscodbar) <> 44   THEN
                    LEAVE.
               
               DISPLAY tel_dscodbar WITH FRAME f_lantit.
               
               RUN mostra_dados.
         
               LEAVE.
                  
            END.  /*  Fim do DO WHILE TRUE  */
                  
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                 NEXT.
        END.

   DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE:

      FIND craptit WHERE craptit.cdcooper = glb_cdcooper   AND
                         craptit.dtmvtolt = tel_dtmvtolt   AND
                         craptit.cdagenci = tel_cdagenci   AND
                         craptit.cdbccxlt = tel_cdbccxlt   AND
                         craptit.nrdolote = tel_nrdolote   AND
                         craptit.dscodbar = tel_dscodbar 
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                           
      IF   NOT AVAILABLE craptit   THEN
           IF   LOCKED craptit   THEN
                DO:
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                DO:
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
               IF   NOT CAN-DO("20,21",STRING(craplot.tplotmov,"99")) THEN
                    glb_cdcritic = 100.
           END.

      IF   glb_cdcritic > 0   THEN
           LEAVE.
                   
      IF   (craplot.dtmvtopg = ?              OR
           craplot.dtmvtopg = glb_dtmvtolt)   AND
           (craplot.tplotmov = 20)            THEN
           DO:
               /*  Verifica a hora  */
                     
               IF   TIME >= tab_hrlimite   THEN
                    DO:
                        glb_cdcritic = 676.
                        LEAVE.
                    END.

               IF   tab_intransm > 0   THEN
                    DO:
                        glb_cdcritic = 677.
                        LEAVE.
                    END.
           END.
      
      IF   craptit.nrdconta > 0   THEN
           DO:
               /*FIND crapass OF craptit NO-LOCK NO-ERROR.*/
               FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                  crapass.nrdconta = craptit.nrdconta
                                  NO-LOCK NO-ERROR.
      
               IF   NOT AVAILABLE crapass   THEN
                    DO:
                        glb_cdcritic = 9.
                        LEAVE.
                    END.

               ASSIGN tel_nrdconta = craptit.nrdconta
                      tel_nmprimtl = crapass.nmprimtl.

               DO WHILE TRUE:
               
                  FIND craplau WHERE craplau.cdcooper = glb_cdcooper       AND
                                     craplau.dtmvtolt = craptit.dtmvtolt   AND
                                     craplau.cdagenci = craptit.cdagenci   AND
                                     craplau.cdbccxlt = craptit.cdbccxlt   AND
                                     craplau.nrdolote = craptit.nrdolote   AND
                                     craplau.nrdctabb = craptit.nrdconta   AND
                                     craplau.nrdocmto = craptit.nrdocmto   
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                  
                  IF   NOT AVAILABLE craplau   THEN
                       IF   LOCKED craplau   THEN
                            DO:
                                PAUSE 2 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            glb_cdcritic = 679.
                  ELSE
                       tel_cdhistor = craplau.cdhistor.
                       
                  LEAVE.
               
               END.  /*  Fim do DO WHILE TRUE  */

               IF   glb_cdcritic > 0   THEN
                    LEAVE.
           END.
      ELSE
           ASSIGN tel_nrdconta = 0
                  tel_cdhistor = 0
                  tel_nmprimtl = "".
                    
      ASSIGN tel_vldpagto = craptit.vldpagto
             tel_nrseqdig = craptit.nrseqdig
             tel_dscodbar = "".
      
      DISPLAY tel_cdhistor tel_nrdconta tel_nmprimtl WITH FRAME f_lantit.
 
      ASSIGN tel_vlcompdb = craplot.vlcompdb
             tel_vlcompcr = craplot.vlcompcr
             tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb
             tel_vlinfocr = craplot.vlinfocr
             tel_qtinfoln = craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln.

      DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
              tel_qtcompln tel_vlcompdb tel_vlcompcr
              tel_qtdifeln tel_vldifedb tel_vldifecr
              tel_dsdlinha tel_vldpagto tel_nrseqdig
              tel_dscodbar
              WITH FRAME f_lantit.

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
               NEXT BARRAS.
           END.

      IF   AVAILABLE craplau   THEN
           DO:
               FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper       AND
                                      craplcm.nrdconta = craplau.nrdconta   AND
                                      craplcm.dtmvtolt = glb_dtmvtolt       AND
                                      craplcm.nrdolote = 4600               AND
                                      craplcm.nrdocmto = craplau.nrdocmto   AND
                                      craplcm.cdhistor = craplau.cdhistor   AND
                                      craplcm.vllanmto = craplau.vllanaut
                                      USE-INDEX craplcm2 EXCLUSIVE-LOCK:
                                      
                   DO WHILE TRUE:
                   
                      FIND craplot WHERE craplot.cdcooper = glb_cdcooper     AND
                                         craplot.dtmvtolt = craplcm.dtmvtolt AND
                                         craplot.cdagenci = craplcm.cdagenci AND
                                         craplot.cdbccxlt = craplcm.cdbccxlt AND
                                         craplot.nrdolote = craplcm.nrdolote
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                       
                      IF   NOT AVAILABLE craplot   THEN
                           IF   LOCKED craplot   THEN
                                DO:
                                    PAUSE 2 NO-MESSAGE.
                                    NEXT.
                                END.
                           ELSE
                                DO:
                                    glb_cdcritic = 60.
                                    NEXT BARRAS.
                                END.

                      LEAVE.
                   
                   END.  /*  Fim do DO WHILE TRUE  */
                   
                   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                     " - RESGATE DE TITULO PROGRAMADO -" +
                                     " Conta " + STRING(craplcm.nrdconta,
                                                        "zzzz,zzz,9") + 
                                     " Hst " + STRING(craplcm.cdhistor,"zzz9") +
                                     " Doc " + STRING(craplcm.nrdocmto,
                                                      "zzz,zzz,zzz,zz9") +
                                     " Valor " + STRING(craplcm.vllanmto,
                                                        "zzz,zzz,zz9.99") +
                                     " Pesquisa " + craplcm.cdpesqbb +
                                     " >> log/titulos.log").
                   
                   
                   ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                          craplot.vlcompdb = craplot.vlcompdb -
                                                     craplcm.vllanmto.
                   
                   

                   IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                       RUN sistema/generico/procedures/b1wgen0200.p PERSISTENT SET h-b1wgen0200.
                                      
                   RUN estorna_lancamento_conta IN h-b1wgen0200 
                       (INPUT craplcm.cdcooper               /* par_cdcooper */
                       ,INPUT craplcm.dtmvtolt               /* par_dtmvtolt */
                       ,INPUT craplcm.cdagenci               /* par_cdagenci*/
                       ,INPUT craplcm.cdbccxlt               /* par_cdbccxlt */
                       ,INPUT craplcm.nrdolote               /* par_nrdolote */
                       ,INPUT craplcm.nrdctabb               /* par_nrdctabb */
                       ,INPUT craplcm.nrdocmto               /* par_nrdocmto */
                       ,INPUT craplcm.cdhistor               /* par_cdhistor */           
                       ,INPUT craplcm.nrctachq               /* par_nrctachq */
                       ,INPUT craplcm.nrdconta               /* par_nrdconta */
                       ,INPUT craplcm.cdpesqbb               /* par_cdpesqbb */
                       ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                       ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                    
                   IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:   
                      glb_cdcritic = aux_cdcritic.
                      glb_dscritic = aux_dscritic.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      glb_cdcritic = 0.
                      LEAVE.
                   END. 
                    
                   IF  VALID-HANDLE(h-b1wgen0200) THEN
                       DELETE PROCEDURE h-b1wgen0200.
                   
               END.  /*  Fim do FOR EACH  --  craplcm  */
               
               ASSIGN craplau.dtdebito = glb_dtmvtolt
                      craplau.insitlau = 3.
           END.
           
      ASSIGN craptit.dtdevolu = glb_dtmvtolt 
             craptit.cdopedev = glb_cdoperad
             craptit.insittit = 1.

      LEAVE.
        
   END.  /*  Fim do DO WHILE TRUE e da transacao  */

   IF   glb_cdcritic > 0   THEN
        NEXT.

   IF   tel_qtdifeln = 0   AND  
        tel_vldifedb = 0   AND 
        tel_vldifecr = 0   THEN
        DO:
            glb_nmdatela = "LOTE".
            RETURN.                        /*  Volta ao lantit.p  */
        END.

   ASSIGN tel_reganter[2] = tel_reganter[1]

          tel_reganter[1] = STRING(tel_dsdlinha,"x(56)") +      
                            STRING(tel_vldpagto,"zzzzzz,zz9.99") + " " +
                            STRING(tel_nrseqdig,"zzzz9")

          tel_dscodbar = ""
          tel_nmprimtl = ""
          tel_dsdlinha = ""
          tel_vldpagto = 0
          tel_cdhistor = 0
          tel_nrdconta = 0
          tel_nrseqdig = 0.
         
   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_dscodbar tel_dsdlinha tel_vldpagto
           tel_nrseqdig tel_nmprimtl tel_nrdconta
           tel_cdhistor
           WITH FRAME f_lantit.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter WITH FRAME f_regant.

END.   /*  Fim do DO WHILE TRUE  */

IF   glb_cdcritic > 0 THEN
     DO:
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
     END.

/* .......................................................................... */

{ includes/proc_lantit.i }

/* .......................................................................... */

