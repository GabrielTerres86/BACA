/* .............................................................................

   Programa: Fontes/lantiti.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                     Ultima atualizacao: 13/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela LANTIT.

   Alteracoes: 24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               17/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               05/01/2001 - Tratar tipo de lote 21 (Deborah).

               08/01/2001 - Efetivar o convenio de arrecadacao de IPTU 
                            Blumenau no sistema. (Eduardo).

               30/03/2001 - Substituir o nome ciptu.p por verbar3.p.
                            (Eduardo).
   
               30/03/2001 - Acrescentar campo para o fator de vencimento no
                            codigo de barras. (Ze Eduardo).

               28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).
              
               13/09/2002 - Alterado para tratar o boletim de caixa (Edson).

               23/10/2002 - Pedir autenticacao quando caixa (Margarete).

               10/02/2004 - Efetuado controle por PAC(tabelas horario 
                            compel/titulo) (Mirtes)

               04/07/2005 - Alimentado campo cdcooper da tabela craptit e 
                            craplau (Diego).

               10/12/2005 - Atualiza craplau.nrdctitg (Magui).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada
                            do programa fontes/testa_boletim.p - SQLWorks - 
                            Fernando.
               
               24/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)
                            
               13/12/2013 - Inclusao de VALIDATE craptit e craplau (Carlos)

............................................................................. */

{ includes/var_online.i }

{ includes/var_lantit.i }

{ sistema/generico/includes/var_internet.i }
DEF VAR h-b1wgen0001 AS HANDLE                                      NO-UNDO.

FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                   craplot.dtmvtolt = tel_dtmvtolt   AND
                   craplot.cdagenci = tel_cdagenci   AND
                   craplot.cdbccxlt = tel_cdbccxlt   AND
                   craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE craplot   THEN
     RETURN.

ASSIGN tel_nmprimtl = ""
       tel_dsdlinha = ""
       tel_dscodbar = ""
       tel_reganter = ""
       tel_nrdconta = 0
       tel_vldpagto = 0
       tel_nrseqdig = craplot.nrseqdig + 1
       tel_dtdpagto = craplot.dtmvtopg
       aux_tplotmov = craplot.tplotmov.

DISPLAY tel_nrdconta tel_nmprimtl tel_dtdpagto tel_nrseqdig WITH FRAME f_lantit.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      HIDE FRAME f_autentica NO-PAUSE.
      
      ASSIGN tel_nrautdoc = 0.
      
      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      IF   craplot.cdbccxlt = 11   THEN                /*  Arrecadacao caixa  */
           DO:
               IF   craplot.tplotmov = 20 THEN
                    DO:
                        /*  Tabela com o horario limite para digitacao  */

                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                           craptab.nmsistem = "CRED"       AND
                                           craptab.tptabela = "GENERI"     AND
                                           craptab.cdempres = 0            AND
                                           craptab.cdacesso = "HRTRTITULO" AND
                                           craptab.tpregist = tel_cdagenci
                                           NO-LOCK NO-ERROR.

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
           END.
           
      IF   tel_dtdpagto <> ?   THEN
           DO:
               UPDATE tel_cdhistor tel_nrdconta WITH FRAME f_lantit.
      
               glb_nrcalcul = tel_nrdconta.
                                     
               RUN fontes/digfun.p.
                   
               IF   NOT glb_stsnrcal   THEN
                    DO:
                        glb_cdcritic = 8.
                        tel_nmprimtl = "".
                        DISPLAY tel_nmprimtl WITH FRAME f_lantit.
                        NEXT-PROMPT tel_nrdconta WITH FRAME f_lantit.
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
                                      craptrf.tptransa = 1 USE-INDEX craptrf1
                                      NO-LOCK NO-ERROR.

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
               
               IF   glb_cdcritic = 0   THEN 
               DO:
                    RUN sistema/generico/procedures/b1wgen0001.p
                        PERSISTENT SET h-b1wgen0001.
      
                    IF   VALID-HANDLE(h-b1wgen0001)   THEN
                    DO:
                         RUN ver_capital IN h-b1wgen0001
                                             (INPUT  glb_cdcooper,
                                              INPUT  tel_nrdconta,
                                              INPUT  0, /* cod-agencia */
                                              INPUT  0, /* nro-caixa   */
                                              0,        /* vllanmto */
                                              INPUT  glb_dtmvtolt,
                                              INPUT  "lantiti",
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
               END.                             
                                            
               IF   glb_cdcritic > 0   THEN
                    NEXT.
               
               tel_nmprimtl = crapass.nmprimtl.
      
               DISPLAY tel_nrdconta tel_nmprimtl WITH FRAME f_lantit.
           END.
      ELSE
           DO:
               ASSIGN tel_cdhistor = 0
                      tel_nmprimtl = "".

               DISPLAY tel_cdhistor tel_nmprimtl WITH FRAME f_lantit.
           
           END.

      BARRAS:

      /*  Pede o valor do titulo  */
                  
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
         UPDATE tel_vldpagto WITH FRAME f_lantit
            
         EDITING:
 
            READKEY.
                        
            IF   LASTKEY =  KEYCODE(".")   THEN
                 APPLY 44.
            ELSE
                 APPLY LASTKEY.
                           
         END.  /*  Fim do EDITING  */
            
         ASSIGN tel_nrautdoc = 0.
         IF   tel_cdbccxlt = 11   THEN
              DO:
                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                     craptab.nmsistem = "CRED"           AND
                                     craptab.tptabela = "CAIXA"          AND
                                     craptab.cdempres = craplot.cdagenci AND
                                     craptab.cdacesso = "AUTOMA"         AND
                                     craptab.tpregist = craplot.nrdcaixa 
                                     NO-LOCK NO-ERROR.
                                     
                  IF   AVAILABLE craptab   THEN
                       UPDATE tel_nrautdoc WITH FRAME f_autentica.
                  HIDE FRAME f_autentica NO-PAUSE.
              END.
              
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
            IF   glb_cdcritic > 0 THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     ASSIGN glb_cdcritic = 0
                            tel_dscodbar = "".
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

                     IF   craplot.tplotmov = 21 THEN  /*  IPTU Blumenau  */
                          RUN fontes/cdbarra3.p  (OUTPUT aux_nrdigver).
                     ELSE 
                          RUN fontes/digcbtit.p.
                  
                     IF   NOT glb_stsnrcal   THEN
                          DO:
                              glb_cdcritic = 8.
                              NEXT.
                          END.

                     IF   craplot.tplotmov <> 21 THEN  /*  Pref. Blumenau  */
                             RUN mostra_dados.
                 END.
            ELSE
                 DO:
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
                        IF   craplot.tplotmov = 21 THEN  /*  IPTU Blumenau  */
                             RUN fontes/verbar3.p (OUTPUT tel_dscodbar).
                        ELSE
                             RUN fontes/cbtit.p (OUTPUT tel_dscodbar).
                   
                        IF   LENGTH(tel_dscodbar) <> 44   THEN
                             LEAVE.

                        DISPLAY tel_dscodbar WITH FRAME f_lantit.

                        IF   craplot.tplotmov <> 21 THEN  /*  Pref. Blumenau  */
                             RUN mostra_dados.

                        LEAVE.
                   
                     END.  /*  Fim do DO WHILE TRUE  */
                  
                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                          NEXT.
                 END.

            IF   craplot.tplotmov = 21 THEN
                 RUN proc_titulos_IPTU.
            ELSE 
                 RUN proc_demais_titulos.

            IF   glb_cdcritic > 0   THEN
                 NEXT.
         
            LEAVE.
         
         END.  /*  Fim do DO WHILE TRUE  */
         
         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  
              NEXT.

         IF   tel_nrcampo5 <> 0   THEN
              DO: 
                  IF   craplot.tplotmov = 20  THEN
                       DO:           
                          ASSIGN tel_nrcampo6 = DECIMAL(SUBSTR(STRING(
                                         tel_nrcampo5, "99999999999999"),1,4))
                                 tel_nrcampo5 = DECIMAL(SUBSTR(STRING(
                                         tel_nrcampo5, "99999999999999"),5,10))
                                 tel_dtvencto = 10/07/1997 + tel_nrcampo6.

                             IF   (tel_nrcampo6 <> 0)  AND
                                  (glb_dtmvtolt > tel_dtvencto)   THEN
                                  DO: 
                                   IF   glb_dtmvtoan >= tel_dtvencto   THEN
                                        DO:
                                            glb_cdcritic = 013.
                                            RUN fontes/critic.p.
                                            BELL.
                                            MESSAGE glb_dscritic " = " 
                                                  STRING(tel_dtvencto,
                                                         "99/99/9999")
                                                         glb_dtmvtoan.
                                            glb_cdcritic = 0.
                                            NEXT.    
                                        END. 
                                  END.                                        
                       END.
                       
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
              END.   /*   Fim do IF   */
              
         IF   craplot.tplotmov = 20 THEN
              DO:
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
              END.
         
         DO TRANSACTION ON ERROR UNDO, LEAVE:
         
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
                    DO:   
                        IF   NOT CAN-DO("20,21",STRING(craplot.tplotmov,"99"))
                             THEN
                             glb_cdcritic = 100.
                    END.
                    
               LEAVE.
            
            END.   /*  Fim do DO WHILE TRUE  */
            
            IF   glb_cdcritic > 0   THEN
                 UNDO, NEXT BARRAS.

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
                 UNDO, NEXT BARRAS.

            CREATE craptit.
            ASSIGN craptit.dtmvtolt = craplot.dtmvtolt
                   craptit.cdagenci = craplot.cdagenci
                   craptit.cdbccxlt = craplot.cdbccxlt
                   craptit.nrdolote = craplot.nrdolote
                   craptit.cdbandst = IF   craplot.tplotmov = 21 THEN
                                           INT(SUBSTRING(tel_dscodbar,16,04))
                                      ELSE   
                                           INT(SUBSTRING(tel_dscodbar,01,03))
                   craptit.cddmoeda = IF   craplot.tplotmov = 21 THEN
                                           INT(SUBSTRING(tel_dscodbar,03,01))
                                      ELSE     
                                           INT(SUBSTRING(tel_dscodbar,04,01))
                   craptit.cdoperad = glb_cdoperad
                   craptit.dscodbar = tel_dscodbar
                   craptit.nrdvcdbr = tel_nrcampo4
                   craptit.tpdocmto = craplot.tplotmov 
                   craptit.vldpagto = tel_vldpagto
                   craptit.vltitulo = tel_nrcampo5 / 100
                   craptit.nrdconta = tel_nrdconta
                   craptit.nrautdoc = tel_nrautdoc 

                   craptit.dtdpagto = IF tel_nrdconta > 0   
                                         THEN craplot.dtmvtopg
                                         ELSE glb_dtmvtolt
                   
                   craptit.nrdocmto = TIME
                   craptit.cdopedev = ""
                   craptit.dtdevolu = ?

                   craptit.insittit = IF tel_nrdconta > 0
                                         THEN 0       /*  Programado    */
                                         ELSE 4       /*  Arrec. caixa  */
                                         
                   craptit.nrseqdig = craplot.nrseqdig + 1
                   craptit.cdcooper = glb_cdcooper
                   
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.vlcompcr = craplot.vlcompcr + tel_vldpagto
                   craplot.nrseqdig = craptit.nrseqdig
                   
                   tel_qtinfoln = craplot.qtinfoln
                   tel_qtcompln = craplot.qtcompln
                   tel_vlinfodb = craplot.vlinfodb 
                   tel_vlcompdb = craplot.vlcompdb
                   tel_vlinfocr = craplot.vlinfocr  
                   tel_vlcompcr = craplot.vlcompcr
                   tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                   tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
                   tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.
            VALIDATE craptit.

            IF   craptit.nrdconta > 0   THEN
                 DO:
                     CREATE craplau.
                     ASSIGN craplau.dtmvtolt = craptit.dtmvtolt
                            craplau.cdagenci = craptit.cdagenci
                            craplau.cdbccxlt = craptit.cdbccxlt
                            craplau.nrdolote = craptit.nrdolote
                            craplau.nrdconta = craptit.nrdconta
                            craplau.nrdocmto = craptit.nrdocmto
                            craplau.vllanaut = craptit.vldpagto
                            craplau.cdhistor = tel_cdhistor
                            craplau.nrseqdig = craptit.nrseqdig
                            craplau.nrdctabb = craptit.nrdconta
                            craplau.nrdctitg = 
                                    STRING(craptit.nrdconta,"99999999")
                            craplau.cdbccxpg = 011
                            craplau.dtmvtopg = craptit.dtdpagto    
                            craplau.tpdvalor = 1
                            craplau.insitlau = 1
                            craplau.cdcritic = 0
                            craplau.nrcrcard = 0
                            craplau.nrseqlan = 0
                            
                            craplau.cdseqtel = STRING(craptit.dtmvtolt,
                                                      "99/99/9999") + " " +
                                               STRING(craptit.cdagenci,
                                                      "999") + " " +
                                               STRING(craptit.cdbccxlt,
                                                      "999") + " " +
                                               STRING(craptit.nrdolote,
                                                      "999999") + " " +
                                               STRING(craptit.dscodbar,
                                                      "x(44)")
                            
                            craplau.dtdebito = ?
                            craplau.cdcooper = glb_cdcooper.
                     VALIDATE craplau.

                 END.

         END.  /*  Fim da transacao  */
         
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
                tel_vldpagto = 0
                tel_nrseqdig = craptit.nrseqdig + 1.
         
         DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
                 tel_qtcompln tel_vlcompdb tel_vlcompcr
                 tel_qtdifeln tel_vldifedb tel_vldifecr
                 tel_dscodbar tel_dsdlinha tel_vldpagto
                 tel_nrseqdig
                 WITH FRAME f_lantit.

         HIDE FRAME f_lanctos.

         DISPLAY tel_reganter WITH FRAME f_regant.

         IF   tel_dtdpagto <> ?   THEN
              LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */
      
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           IF   tel_nrdconta > 0   THEN
                NEXT.
           ELSE
                LEAVE.
                
   END.  /*  Fim do DO WHILE TRUE  */      
   
   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.
   
   LEAVE.

END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

{ includes/proc_lantit.i }

/* .......................................................................... */
       
PROCEDURE proc_titulos_IPTU:
 
   IF  (INTEGER(SUBSTRING(tel_dscodbar, 16, 4)) = 557)  AND   /* Prefeitura  */
       (INTEGER(SUBSTRING(tel_dscodbar, 02, 1)) = 1)    THEN  /* Cod. Segmto */
       DO:
           IF   CAN-FIND(craptit WHERE craptit.cdcooper = glb_cdcooper   AND
                                       craptit.dtmvtolt = tel_dtmvtolt   AND
                                       craptit.cdagenci = tel_cdagenci   AND
                                       craptit.cdbccxlt = tel_cdbccxlt   AND
                                       craptit.nrdolote = tel_nrdolote   AND
                                       craptit.dscodbar = tel_dscodbar)  THEN
                DO:
                    glb_cdcritic = 92.
                    RETURN.
                END.

           IF   CAN-FIND(craptit WHERE craptit.cdcooper = glb_cdcooper   AND
                                       craptit.dtmvtolt = tel_dtmvtolt   AND
                                       craptit.dscodbar = tel_dscodbar)  THEN
                DO:
                    glb_cdcritic = 456.
                    RETURN.
                END.

           IF   CAN-FIND(LAST craptit WHERE 
                              craptit.cdcooper = glb_cdcooper   AND
                              craptit.dscodbar = tel_dscodbar)  THEN
                DO:
                    glb_cdcritic = 675.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       aux_confirma = "N".

                       glb_cdcritic = 78.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                       glb_cdcritic = 0.
                       LEAVE.

                    END.  /*  Fim do DO WHILE TRUE  */

                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                         aux_confirma <> "S" THEN
                         DO:
                             glb_cdcritic = 79. /*
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.  */
                             RETURN.
                         END.
                END.

           tel_nrcampo5 = INTEGER(SUBSTRING(tel_dscodbar, 05, 11)).
       END.
  ELSE    
       DO:
           glb_cdcritic = 100.
           RETURN.
       END.

END PROCEDURE.

PROCEDURE proc_demais_titulos:

  IF   (aux_tplotmov = 20)                              AND   /* Tipo Lote   */
       (INTEGER(SUBSTRING(tel_dscodbar, 16, 4)) = 557)  AND   /* Prefeitura  */
       (INTEGER(SUBSTRING(tel_dscodbar, 02, 1)) = 1)    THEN  /* Cod. Segmto */
       DO:
           glb_cdcritic = 100.
           RETURN.
       END.
  ELSE     
       DO:
           IF   CAN-FIND(craptit WHERE craptit.cdcooper = glb_cdcooper   AND
                                       craptit.dtmvtolt = tel_dtmvtolt   AND
                                       craptit.cdagenci = tel_cdagenci   AND
                                       craptit.cdbccxlt = tel_cdbccxlt   AND
                                       craptit.nrdolote = tel_nrdolote   AND
                                       craptit.dscodbar = tel_dscodbar)  THEN
                DO:
                    glb_cdcritic = 92.
                    RETURN.
                END.

           IF   CAN-FIND(craptit WHERE craptit.cdcooper = glb_cdcooper   AND
                                       craptit.dtmvtolt = tel_dtmvtolt   AND
                                       craptit.dscodbar = tel_dscodbar)  THEN
                DO:
                    glb_cdcritic = 456.
                    RETURN.
                END.

           IF   CAN-FIND(LAST craptit WHERE 
                              craptit.cdcooper = glb_cdcooper   AND
                              craptit.dscodbar = tel_dscodbar)  THEN
                DO:
                    glb_cdcritic = 675.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       aux_confirma = "N".

                       glb_cdcritic = 78.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                       glb_cdcritic = 0.
                       LEAVE.

                    END.  /*  Fim do DO WHILE TRUE  */

                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                         aux_confirma <> "S" THEN
                         DO:
                             glb_cdcritic = 79.
                        /*   RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.  */
                             RETURN.
                         END.
                END.
 
            IF   craplot.dtmvtopg = ?  AND  craplot.tplotmov = 20 THEN 
                 DO:
                     /*  Verifica a hora somente para a arrecadacao caixa  */
                     
                     IF   TIME >= tab_hrlimite   THEN
                          DO:
                              glb_cdcritic = 676.
                              RETURN.
                          END.

                     IF   tab_intransm > 0   THEN
                          DO:
                              glb_cdcritic = 677.
                              RETURN.
                          END.
                 END.
       END.

END PROCEDURE.

