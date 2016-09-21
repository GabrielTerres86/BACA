/* .............................................................................

   Programa: Fontes/lantita.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                     Ultima atualizacao: 13/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela LANTIT.

   Alteracoes:  24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                             titular (Eduardo).

                05/01/2001 - Tratar tipo de lote 21 (Deborah).

                09/01/2001 - Efetivar o convenio de arrecadacao de IPTU
                             Blumenau no sistema. (Eduardo). 

                30/03/2001 - Substituir o nome ciptu.p por verbar3.p.
                             (Eduardo).

                13/09/2002 - Alterado para tratar boletim de caixa (Edson).

               10/02/2004 - Efetuado controle por PAC(tabelas horario 
                            compel/titulo) (Mirtes)

               10/12/2005 - Atualizar craplau.nrdctitg (Magui).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada 
                            do programa fontes/testa_boletim.p - SQLWorks - 
                            Fernando.
............................................................................. */

{ includes/var_online.i }

{ includes/var_lantit.i }

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

   IF   tel_cdbccxlt = 11 and aux_tplotmov = 20 THEN  /*  Arrec. caixa  */
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
                 RUN fontes/cdbarra3.p  (OUTPUT aux_nrdigver).
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
               IF   NOT CAN-DO("20,21",STRING(craplot.tplotmov,"99"))THEN
                    glb_cdcritic = 100.
           END.

      IF   glb_cdcritic > 0   THEN
           LEAVE.
      
      IF   craplot.nrdcaixa > 0   THEN
           RUN fontes/testa_boletim.p (INPUT  glb_cdcooper,
                                       INPUT  craplot.dtmvtolt,
                                       INPUT  craplot.cdagenci,
                                       INPUT  craplot.cdbccxlt,
                                       INPUT  craplot.nrdolote,
                                       INPUT  craplot.nrdcaixa,
                                       INPUT  craplot.cdopecxa,
                                       OUTPUT glb_cdcritic).
                                                   
      IF   glb_cdcritic > 0   THEN
           LEAVE.
      
      IF   craplot.dtmvtopg = ? AND craplot.tplotmov = 20  THEN
           DO:
               /*  Verifica a hora somente para a arrecadacao caixa  */
                     
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
           DO:
               ASSIGN tel_nrdconta = 0
                      tel_cdhistor = 0
                      tel_nmprimtl = "".

               RELEASE craplau.
           END.       
             
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
              tel_dsdlinha tel_nrseqdig tel_dscodbar
              WITH FRAME f_lantit.

      IF   craptit.nrdconta > 0   THEN
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
              IF   glb_cdcritic > 0 THEN
                   DO:
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0.
                   END.
              
              UPDATE tel_cdhistor tel_nrdconta tel_vldpagto WITH FRAME f_lantit
           
              EDITING:
           
                 READKEY.
                        
                 IF   FRAME-FIELD = "tel_vldpagto"   THEN
                      IF   LASTKEY =  KEYCODE(".")   THEN
                           APPLY 44.
                      ELSE
                           APPLY LASTKEY.
                 ELSE
                      APPLY LASTKEY.
                             
              END.  /*  Fim do EDITING  */

              glb_nrcalcul = tel_nrdconta.
                                     
              IF   aux_tplotmov = 21 THEN 
                   DO: 
                       RUN fontes/cdbarra3.p  (OUTPUT aux_nrdigver). 
                       tel_nrcampo5 = INTEGER(SUBSTRING(
                                              STRING(glb_nrcalcul), 05, 11)).
                   END.
              ELSE
                   RUN fontes/digfun.p.  
                   
              IF   NOT glb_stsnrcal   THEN
                   DO:
                       glb_cdcritic = 8.
                       tel_nmprimtl = "".
                       DISPLAY tel_nmprimtl WITH FRAME f_lantit.
                       NEXT-PROMPT tel_nrdconta WITH FRAME f_lantit.
                       NEXT.
                   END.

              IF   tel_nrcampo5 <> 0   THEN
                   IF   tel_nrcampo5 / 100 <> tel_vldpagto   THEN
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       
                               MESSAGE "O valor digitado esta diferente"
                                       "do valor codificado.".

                               aux_confirma = "S".
      
                               glb_cdcritic = 78.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE COLOR NORMAL glb_dscritic
                                                    UPDATE aux_confirma.
                               glb_cdcritic = 0.
                          
                               LEAVE.

                            END.  /*  Fim do DO WHILE TRUE  */

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
                        END.

              IF   NOT CAN-FIND(crapban WHERE crapban.cdbccxlt =
                       INT(SUBSTR(STRING(tel_nrcampo1,"99999,99999"),1,3))) THEN
                   DO:
                       glb_cdcritic = 57.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic "Codigo:" 
                          INT(SUBSTR(STRING(tel_nrcampo1,"99999,99999"),1,3)).
 
                       glb_cdcritic = 0.
                       NEXT.    
                   END.

              DO WHILE TRUE:
               
                 /*  Verifica se o associado esta cadastrado  */
      
                 FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                    crapass.nrdconta = tel_nrdconta
                                    NO-LOCK NO-ERROR.
      
                 IF   NOT AVAILABLE crapass   THEN
                      DO:
                          glb_cdcritic = 9.
                          tel_nmprimtl = "".
                          DISPLAY tel_nmprimtl WITH FRAME f_lantit.
                          NEXT-PROMPT tel_nrdconta WITH FRAME f_lantit.
                          LEAVE.
                      END.
               
                 IF   crapass.dtelimin <> ? THEN
                      DO:
                          glb_cdcritic = 410.
                          NEXT-PROMPT tel_nrdconta WITH FRAME f_lantit.
                          LEAVE.
                      END.
              
                 IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                      DO:
                          glb_cdcritic = 695.
                          NEXT-PROMPT tel_nrdconta WITH FRAME f_lantit.
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
                                   NEXT-PROMPT tel_nrdconta 
                                               WITH FRAME f_lantit.
                                   LEAVE.
                               END.
                          ELSE
                               DO:
                                   glb_cdcritic = 156.
                                   RUN fontes/critic.p.
                                   MESSAGE glb_dscritic 
                                           STRING(tel_nrdconta,"zzzz,zzz,9")
                                           "para o numero" 
                                           STRING(craptrf.nrsconta,
                                                  "zzzz,zzz,9").

                                   ASSIGN tel_nrdconta = craptrf.nrsconta
                                          glb_cdcritic = 0.
                                   NEXT.
                               END.
                      END.

                 LEAVE.
                   
              END.  /*  Fim do DO WHILE TRUE  */
               
              IF   glb_cdcritic > 0   THEN
                   NEXT.

              tel_nmprimtl = crapass.nmprimtl.
      
              DISPLAY tel_nrdconta tel_nmprimtl WITH FRAME f_lantit.

              LEAVE.
      
           END.  /*  Fim do DO WHILE TRUE  */
      ELSE
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
              UPDATE tel_vldpagto WITH FRAME f_lantit
           
              EDITING:
           
                 READKEY.
                        
                 IF   LASTKEY =  KEYCODE(".")   THEN
                      APPLY 44.
                 ELSE
                      APPLY LASTKEY.
                            
              END.  /*  Fim do EDITING  */
      
              IF   tel_nrcampo5 <> 0   THEN
                   IF   tel_nrcampo5 / 100 <> tel_vldpagto   THEN
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       
                               MESSAGE "O valor digitado esta diferente"
                                       "do valor codificado.".

                               aux_confirma = "N".
      
                               glb_cdcritic = 78.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE COLOR NORMAL glb_dscritic 
                                                    UPDATE aux_confirma.
                               glb_cdcritic = 0.
                          
                               LEAVE.

                            END.  /*  Fim do DO WHILE TRUE  */

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
                        END.
            
              LEAVE.
      
           END.  /*  Fim do DO WHILE TRUE  */

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
           NEXT BARRAS.

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

      ASSIGN craplot.vlcompcr = craplot.vlcompcr + tel_vldpagto -
                                craptit.vldpagto
              
             craptit.vldpagto = tel_vldpagto
             
             tel_vlcompdb = craplot.vlcompdb
             tel_vlcompcr = craplot.vlcompcr
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.
             
      IF   AVAILABLE craplau   THEN 
           ASSIGN craptit.nrdconta = tel_nrdconta
                  craplau.nrdconta = tel_nrdconta
                  craplau.nrdctabb = tel_nrdconta
                  craplau.nrdctitg = STRING(tel_nrdconta,"99999999")
                  craplau.cdhistor = tel_cdhistor
                  craplau.vllanaut = tel_vldpagto.
          
      LEAVE.
        
   END.  /*  Fim do DO WHILE TRUE e da transacao  */

   IF   glb_cdcritic > 0   THEN
        NEXT.

   IF   tel_qtdifeln = 0   AND  
        tel_vldifedb = 0   AND 
        tel_vldifecr = 0   THEN
        DO:
            RUN proc_lista_lote.

            glb_nmdatela = "LOTE".
            RETURN.                        /*  Volta ao lantit.p  */
        END.

   ASSIGN tel_reganter[2] = tel_reganter[1]

          tel_reganter[1] = STRING(tel_dsdlinha,"x(56)") +      
                            STRING(tel_vldpagto,"zzzzzz,zz9.99") + " " +
                            STRING(tel_nrseqdig,"zzzz9")

          tel_dscodbar = ""
          tel_dsdlinha = ""
          tel_nmprimtl = ""
          tel_vldpagto = 0
          tel_cdhistor = 0
          tel_nrdconta = 0
          tel_nrseqdig = 0.
         
   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_dscodbar tel_dsdlinha tel_vldpagto
           tel_nrseqdig tel_cdhistor tel_nrdconta
           tel_nmprimtl
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

