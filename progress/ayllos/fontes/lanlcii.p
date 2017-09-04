/* .............................................................................

   Programa: fontes/lanlcii.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Setembro/2004.                 Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de INCLUSAO da tela LANLCI.

   Alteracoes: 03/02/2005 - Permitir transferencia entre Contas de Invest.
                            (Mirtes/Evandro).

               11/05/2005 - Validar o banco e a agencia (Edson).

               04/07/2005 - Alimentado campo cdcooper das tabelas crapchd,
                            craplci e crapsli (Diego).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               10/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               02/11/2005 - Uso da procedure digbbx.p para conversao de campo
                            inteiro para caracter (SQLWorks - Andre).

               30/11/2005 - Ajustes na conversao crapchq/crapfdc (Edson).
               
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Andre

               13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada 
                            do programa fontes/pedesenha.p - SQLWorks -
                            Fernando

               12/03/2007 - Nao deixar passar cheques nossos, nem BB nem
                            BANCOOB e usar o numero da conta para buscar o
                            associado (Evandro).
                            
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.
                            
               12/08/2008 - Unificacao dos bancos, incluido cdcooper na busca da
                            tabela crabhis(Guilherme).
                            
               23/11/2009 - Alteracao Codigo Historico (Kbase).
               
               19/10/2010 - Inicializacao dos novos campos crapchd - 
                            Compe por Imagem (Ze).
                            
               13/12/2013 - Inclusao de VALIDATE crapchd, craplci e crapsli 
                                                                      (Carlos)

               24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

..............................................................................*/

{ includes/var_online.i } 
{ includes/var_lanlci.i }

DEF VAR aux_dtrefere AS DATE                                        NO-UNDO.
DEF VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz,9"                 NO-UNDO.
DEF BUFFER crabass FOR crapass.

glb_cdcritic = 0.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   DISPLAY tel_nrseqdig WITH FRAME f_lanlci.
   
   UPDATE tel_cdhistor
          tel_nrctainv
          tel_nrdocmto 
          tel_vllanmto 
          WITH FRAME f_lanlci.
          
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
   
   IF  (tel_cdhistor = 485   OR   tel_cdhistor = 486 OR
        tel_cdhistor = 647)                          AND   
        tel_cdbccxlt <> 100    THEN
        DO:
            glb_cdcritic = 689.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            RETURN.
        END.
   ELSE
   IF   tel_cdhistor = 487   AND   tel_cdbccxlt <> 11   THEN
        DO:
            glb_cdcritic = 689.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            RETURN.
        END.

   FIND craphis WHERE
        craphis.cdcooper = glb_cdcooper AND
        craphis.cdhistor = tel_cdhistor NO-LOCK NO-ERROR.
   IF   NOT AVAILABLE craphis   THEN
        DO:
            glb_cdcritic = 93.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            RETURN.
        END.

   IF   craphis.tplotmov <> 29  THEN
        DO:
            glb_cdcritic = 94.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            RETURN.
        END.

   ASSIGN aux_nrdconta = crapass.nrdconta.
 
   /* Digitar Conta Investimento Destino */
   IF  tel_cdhistor = 647 THEN 
       DO:
           /* verifica se ha valor suficiente a ser transferido na CI */
           FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper           AND
                              crapsli.nrdconta  = aux_nrdconta           AND
                        MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt)    AND
                         YEAR(crapsli.dtrefere) = YEAR(glb_dtmvtolt)  
                              NO-LOCK NO-ERROR.
                              
           IF   NOT AVAILABLE crapsli             OR
                crapsli.vlsddisp < tel_vllanmto   THEN
                DO:
                    glb_cdcritic = 717.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    NEXT.
                END.
           
           DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
               tel_nrctainv_dest = 0.
               
               IF   glb_cdcritic <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        ASSIGN glb_cdcritic = 0.
                    END.    

               UPDATE tel_nrctainv_dest WITH FRAME f_destino.
               
               /* verifica o DV da conta investimento */
               glb_nrcalcul = tel_nrctainv_dest.

               RUN fontes/digfun.p.
               IF   NOT glb_stsnrcal   THEN
                    DO:
                        glb_cdcritic = 8.
                        NEXT.
                    END.
        
               /* se o dv esta correto procura o associado */
               glb_nrcalcul = tel_nrctainv_dest - 600000000.
   
               RUN fontes/digfun.p.
   
               FIND crabass WHERE crabass.cdcooper = glb_cdcooper        AND
                                  crabass.nrdconta = INT(glb_nrcalcul)
                                  NO-LOCK NO-ERROR.
                                  
               IF   NOT AVAILABLE crabass                   OR
                    crabass.nrctainv <> tel_nrctainv_dest   THEN
                    DO:
                       glb_cdcritic = 127.
                       NEXT.
                    END.
               ELSE
			     DO:
				    FOR FIRST crapttl FIELDS(nrcpfcgc)
					                  WHERE crapttl.cdcooper = crapass.cdcooper AND
									        crapttl.nrdconta = crapass.nrdconta AND
											crapttl.idseqttl = 2
											NO-LOCK:

					   ASSIGN aux_nrcpfcgc1 = crapttl.nrcpfcgc.

					END.

					FOR FIRST crapttl FIELDS(nrcpfcgc)
					                  WHERE crapttl.cdcooper = crabass.cdcooper AND
									        crapttl.nrdconta = crabass.nrdconta AND
											crapttl.idseqttl = 2
											NO-LOCK:

					   ASSIGN aux_nrcpfcgc2 = crapttl.nrcpfcgc.

					END.

               IF   NOT (crapass.nrcpfcgc = crabass.nrcpfcgc OR
                            crapass.nrcpfcgc = aux_nrcpfcgc2)    OR
                       NOT (aux_nrcpfcgc1    = aux_nrcpfcgc2     OR
                            aux_nrcpfcgc1    = crabass.nrcpfcgc) THEN
                    DO:
                       glb_cdcritic = 755.
                       NEXT.
                    END.
               ELSE
               IF   crapass.nrctainv = crabass.nrctainv   THEN
                    DO:
                       glb_cdcritic = 121.
                       NEXT.
						  END.

                    END.

               LEAVE.     
           END.
           
           HIDE FRAME f_destino.
       END.
       
   IF   tel_cdhistor = 486   THEN
        DO:
            FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper          AND
                               crapsli.nrdconta  = aux_nrdconta          AND
                         MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt)   AND
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
                                           STRING(tel_nrctainv,"zz,zzz,zzz,9") +
                                           " Valor: " +
                                           STRING(tel_vllanmto,
                                                  "zzz,zzz,zzz,zz9.99") +
                                           " >> log/lanlci.log").
                          END.
                     ELSE
                          NEXT.
                 END.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:         
   
      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.    
      
      /* verifica se o numero do documento e valido */
      DO WHILE TRUE:

         IF   CAN-FIND(craplci WHERE craplci.cdcooper = glb_cdcooper   AND
                                     craplci.nrdconta = aux_nrdconta   AND
                                     craplci.dtmvtolt = glb_dtmvtolt   AND
                                     craplci.cdagenci = tel_cdagenci   AND
                                     craplci.cdbccxlt = tel_cdbccxlt   AND
                                     craplci.nrdolote = tel_nrdolote   AND
                                     craplci.nrdocmto = tel_nrdocmto)  THEN
             DO:
                  glb_cdcritic = 92.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  glb_cdcritic = 0.
                  UPDATE tel_nrdocmto WITH FRAME f_lanlci.
                  NEXT.
              END.
         LEAVE.
      END.
   
      /* Busca o lote */
      FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                         craplot.dtmvtolt = glb_dtmvtolt   AND
                         craplot.cdagenci = tel_cdagenci   AND 
                         craplot.cdbccxlt = tel_cdbccxlt   AND 
                         craplot.nrdolote = tel_nrdolote   AND
                         craplot.tplotmov = 29 
                         EXCLUSIVE-LOCK NO-ERROR.
                     
      IF   tel_cdhistor = 487   THEN
           DO:
              /* busca dados da cooperativa */
              FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                                 NO-LOCK NO-ERROR.
        
              IF   NOT AVAILABLE crapcop THEN
                   DO:
                       glb_cdcritic = 651.
                       NEXT.
                   END.
               
              /*  Verifica o horario de corte  */
              FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                 craptab.nmsistem = "CRED"         AND
                                 craptab.tptabela = "GENERI"       AND
                                 craptab.cdempres = 0              AND
                                 craptab.cdacesso = "HRTRCOMPEL"   AND
                                 craptab.tpregist = tel_cdagenci 
                                 NO-LOCK NO-ERROR.

              IF   NOT AVAILABLE craptab   THEN
                   DO:
                       glb_cdcritic = 676.
                       NEXT.
                   END.

              IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN
                   DO:
                       glb_cdcritic = 676.
                       NEXT.
                   END.
              
              IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN
                   DO:
                       FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                          craptab.nmsistem = "CRED"         AND
                                          craptab.tptabela = "GENERI"       AND
                                          craptab.cdempres = 0              AND
                                          craptab.cdacesso = "EXETRUNCAGEM" AND
                                          craptab.tpregist = tel_cdagenci   
                                          NO-LOCK NO-ERROR.
                   
                       IF   NOT AVAILABLE craptab THEN
                            DO:
                                glb_cdcritic = 677.
                                NEXT.
                            END.
                       ELSE
                            IF   craptab.dstextab = "NAO" THEN
                                 DO:
                                     glb_cdcritic = 677.
                                     NEXT.
                                 END.
                   END.
              
              ASSIGN aux_cdagebcb = crapcop.cdagebcb
                     tel_vlcompel = tel_vllanmto
                     tel_dsdocmc7 = "".

              CLEAR FRAME f_regant ALL.
              HIDE FRAME f_regant NO-PAUSE.
        
              CMC-7:

              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
                 IF   glb_cdcritic <> 0   THEN
                      DO:
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          ASSIGN glb_cdcritic = 0.
                      END.    
          
                 UPDATE tel_vlcompel WITH FRAME f_compel
            
                 EDITING:
            
                    READKEY.
                            
                    IF   LASTKEY =  KEYCODE(".")   THEN
                         APPLY 44.
                    ELSE
                         APPLY LASTKEY.
                           
                 END.  /*  Fim do EDITING  */
         
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                    IF   glb_cdcritic <> 0 THEN
                         DO:
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             ASSIGN glb_cdcritic = 0
                                    tel_dsdocmc7 = "".
                         END.
      
                    ASSIGN aux_flgchqex = NO.
            
                    UPDATE tel_dsdocmc7 WITH FRAME f_compel
             
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
        
                             RUN fontes/dig_cmc7.p (INPUT  tel_dsdocmc7,
                                                    OUTPUT glb_nrcalcul,
                                                    OUTPUT aux_lsdigctr).
                  
                             IF   glb_nrcalcul > 0                 OR
                                  NUM-ENTRIES(aux_lsdigctr) <> 3   THEN
                                  DO:
                                      glb_cdcritic = 666.
                                      NEXT.
                                  END.
                     
                             FIND w-compel WHERE w-compel.dsdocmc7 =
                                                  TRIM(tel_dsdocmc7) NO-ERROR.
                                                  
                             IF   AVAILABLE w-compel   THEN
                                  DO:
                                      IF   tel_vlcompel < tab_vlchqmai   THEN
                                           aux_tpdmovto = 2.
                                      ELSE
                                           aux_tpdmovto = 1.
                           
                                      ASSIGN aux_vlttcomp = aux_vlttcomp -
                                                            w-compel.vlcompel
                                             w-compel.vlcompel = tel_vlcompel
                                             w-compel.tpdmovto = aux_tpdmovto
                                             aux_flgchqex      = YES.
                                  END.
                        
                             RUN mostra_dados.
                         END.
                    ELSE
                         DO:
                             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
                                RUN fontes/cmc7.p (OUTPUT tel_dsdocmc7).
                            
                                IF   LENGTH(tel_dsdocmc7) <> 34   THEN
                                     LEAVE.
                          
                                DISPLAY tel_dsdocmc7 WITH FRAME f_compel.
                     
                                FIND w-compel WHERE w-compel.dsdocmc7 = 
                                                 TRIM(tel_dsdocmc7) NO-ERROR.
                                                 
                                IF   AVAILABLE w-compel   THEN
                                     DO:
                                         IF   tel_vlcompel < tab_vlchqmai  THEN
                                              aux_tpdmovto = 2.
                                         ELSE
                                              aux_tpdmovto = 1.
                    
                                         ASSIGN aux_vlttcomp = aux_vlttcomp -
                                                           w-compel.vlcompel
                                                w-compel.vlcompel = tel_vlcompel
                                                w-compel.tpdmovto = aux_tpdmovto
                                                aux_flgchqex      = YES.
                                     END.

                                RUN fontes/dig_cmc7.p (INPUT  tel_dsdocmc7,
                                                    OUTPUT glb_nrcalcul,
                                                    OUTPUT aux_lsdigctr).
                  
                                RUN mostra_dados.
                        
                                LEAVE.
                   
                             END.  /*  Fim do DO WHILE TRUE  */
                  
                             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                                  NEXT.
                         END.
                  
                    /* verifica se o cheque e da cooperativa */
                    
                         /* BANCOOB */
                    IF  (tel_cdbanchq = 756                 AND
                         tel_cdagechq = crapcop.cdagebcb)             OR
                         
                        (CAN-DO(aux_lsconta1,STRING(tel_nrctabdb)))   OR

                         /* BANCO DO BRASIL - Agencia s/ digito */
                        (tel_cdbanchq = 1                   AND
                         tel_cdagechq = INT(SUBSTRING(STRING(crapcop.cdagedbb),
                                        1,LENGTH(STRING(crapcop.cdagedbb))
                                        - 1)))                        THEN
                        DO:
                            glb_cdcritic = 712.
                            NEXT.
                        END.
                    
                    IF   glb_cdcritic > 0   THEN
                         NEXT.

                    IF   tel_vlcompel < tab_vlchqmai   THEN
                         aux_tpdmovto = 2.
                    ELSE
                         aux_tpdmovto = 1.

                    /*  Verifica se ja existe o lancamento  */
               
                    IF   CAN-FIND(crapchd WHERE 
                                  crapchd.cdcooper = glb_cdcooper          AND
                                  crapchd.dtmvtolt = tel_dtmvtolt          AND
                                  crapchd.cdcmpchq = tel_cdcmpchq          AND
                                  crapchd.cdbanchq = tel_cdbanchq          AND
                                  crapchd.cdagechq = tel_cdagechq          AND
                                  crapchd.nrctachq = (IF aux_nrctcomp > 0
                                                      THEN tel_nrctabdb
                                                      ELSE tel_nrctachq)   AND
                                  crapchd.nrcheque = tel_nrcheque)         THEN
                         DO:
                             glb_cdcritic = 92.
                             NEXT.
                         END.
                 
                    LEAVE.
         
                 END.  /*  Fim do DO WHILE TRUE  */
         
                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                      NEXT.
              
                 FIND w-compel WHERE w-compel.dsdocmc7 = TRIM(tel_dsdocmc7)
                                     NO-ERROR.
                                     
                 IF   NOT AVAILABLE w-compel   THEN
                      DO:
                          CREATE w-compel.
                          ASSIGN aux_maischeq      = aux_maischeq + 1
                                 aux_nrsqcomp      = aux_nrsqcomp + 1
                                 w-compel.dsdocmc7 = tel_dsdocmc7
                                 w-compel.cdcmpchq = tel_cdcmpchq
                                 w-compel.cdbanchq = tel_cdbanchq
                                 w-compel.cdagechq = tel_cdagechq
                                 w-compel.nrddigc1 = tel_nrddigc1   
                                 w-compel.nrctaaux = aux_nrctcomp
                                 w-compel.nrctachq = tel_nrctachq
                                 w-compel.nrctabdb = tel_nrctabdb
                                 w-compel.nrddigc2 = tel_nrddigc2            
                                 w-compel.nrcheque = tel_nrcheque      
                                 w-compel.nrddigc3 = tel_nrddigc3            
                                 w-compel.vlcompel = tel_vlcompel
                                 w-compel.dtlibcom = tel_dtlibcom
                                 w-compel.lsdigctr = aux_lsdigctr
                                 w-compel.tpdmovto = aux_tpdmovto
                                 w-compel.cdtipchq = INTE(SUBSTRING(
                                                          tel_dsdocmc7,20,1))
                                 w-compel.nrseqdig = aux_nrsqcomp.
                          IF   aux_nrtalchq <> 0   THEN
                               ASSIGN w-compel.nrtalchq = aux_nrtalchq
                                      w-compel.nrposchq = glb_nrposchq.
                          ELSE
                               IF   aux_nrdocchq <> 0   THEN
                                    ASSIGN w-compel.nrdocmto = aux_nrdocchq.
              
                      END.
                         
                 ASSIGN aux_vlttcomp = aux_vlttcomp + tel_vlcompel
                        tel_dsdocmc7 = ""
                        tel_vlcompel = 0.
                 DISPLAY tel_vlcompel tel_dsdocmc7 WITH FRAME f_compel.       
                 PAUSE(0).

                 IF   aux_vlttcomp = tel_vllanmto   THEN
                      LEAVE.
                   
              END. /* Fim do DO WHILE TRUE CMC-7 */
           
              FIND FIRST w-compel NO-LOCK NO-ERROR.
              IF   AVAILABLE w-compel   THEN
                   FIND crabhis WHERE crabhis.cdcooper = glb_cdcooper AND
                                      crabhis.cdhistor = 487 NO-LOCK NO-ERROR.

              FOR EACH w-compel NO-LOCK:
         
                  FIND crapchd WHERE crapchd.cdcooper = glb_cdcooper        AND
                                     crapchd.dtmvtolt = tel_dtmvtolt        AND
                                     crapchd.cdcmpchq = w-compel.cdcmpchq   AND
                                     crapchd.cdbanchq = w-compel.cdbanchq   AND
                                     crapchd.cdagechq = w-compel.cdagechq   AND
                                     crapchd.nrctachq = w-compel.nrctachq   AND
                                     crapchd.nrcheque = w-compel.nrcheque  
                                     USE-INDEX crapchd1 NO-LOCK NO-ERROR.
                                     
                  IF   AVAILABLE crapchd   THEN                   
                       DO:
                           ASSIGN glb_cdcritic = 92.
                           NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                           LEAVE.        
                       END.
            
                  CREATE crapchd.
                  ASSIGN crapchd.cdagechq = w-compel.cdagechq
                         crapchd.cdagenci = tel_cdagenci
                         crapchd.cdbanchq = w-compel.cdbanchq
                         crapchd.cdbccxlt = tel_cdbccxlt
                         crapchd.nrdocmto = tel_nrdocmto
                         crapchd.cdcmpchq = w-compel.cdcmpchq
                         crapchd.cdoperad = glb_cdoperad
                         crapchd.cdsitatu = 1
                         crapchd.dsdocmc7 = w-compel.dsdocmc7
                         crapchd.dtmvtolt = tel_dtmvtolt
                         crapchd.inchqcop = IF w-compel.nrctaaux > 0 THEN 1 
                                                                     ELSE 0
                         crapchd.insitchq = 0
                         crapchd.cdtipchq = w-compel.cdtipchq
                         crapchd.nrcheque = w-compel.nrcheque
                         crapchd.nrctachq = IF crapchd.inchqcop = 1 THEN
                                               w-compel.nrctabdb
                                            ELSE w-compel.nrctachq
                         crapchd.nrdconta = aux_nrdconta
                   
                         crapchd.nrddigc1 = w-compel.nrddigc1
                         crapchd.nrddigc2 = w-compel.nrddigc2
                         crapchd.nrddigc3 = w-compel.nrddigc3
                   
                         crapchd.nrddigv1 = INT(ENTRY(1,w-compel.lsdigctr))
                         crapchd.nrddigv2 = INT(ENTRY(2,w-compel.lsdigctr))
                         crapchd.nrddigv3 = INT(ENTRY(3,w-compel.lsdigctr))
                  
                         crapchd.nrdolote = tel_nrdolote
                         crapchd.nrseqdig = w-compel.nrseqlcm
                         crapchd.nrterfin = 0
                         crapchd.tpdmovto = w-compel.tpdmovto
                         crapchd.vlcheque = w-compel.vlcompel
                         crapchd.cdcooper = glb_cdcooper
                         crapchd.insitprv = 0
                         crapchd.nrprevia = 0
                         crapchd.hrprevia = 0.
                  VALIDATE crapchd.

              END.
           END.

/* caso o usuario tenha teclado "F4" ou "END" apaga os cheques ja incluidos */
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
           DO:
               ASSIGN aux_vlttcomp = 0.
            
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

               CLEAR FRAME f_lanlci.
               RETURN.
           END.
   
      /* Cria lancamento conta investimento */
      IF   NOT CAN-FIND(craplci WHERE craplci.cdcooper = glb_cdcooper    AND
                                      craplci.dtmvtolt = glb_dtmvtolt    AND
                                      craplci.cdagenci = tel_cdagenci    AND
                                      craplci.cdbccxlt = tel_cdbccxlt    AND
                                      craplci.nrdolote = tel_nrdolote    AND
                                      craplci.nrdconta = aux_nrdconta    AND
                                      craplci.nrdocmto = tel_nrdocmto)   THEN
           DO:                 
               CREATE craplci.
               ASSIGN craplci.dtmvtolt = glb_dtmvtolt
                      craplci.cdagenci = tel_cdagenci
                      craplci.cdbccxlt = tel_cdbccxlt
                      craplci.nrdolote = tel_nrdolote
                      craplci.nrdconta = aux_nrdconta
                      craplci.nrdocmto = tel_nrdocmto
                      craplci.vllanmto = tel_vllanmto 
                      craplci.nrseqdig = tel_nrseqdig
                      craplci.cdcooper = glb_cdcooper.
               VALIDATE craplci.

           END.
      ELSE
           DO:
               glb_cdcritic = 92.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               RETURN.
           END.

      /*--- Atualizar Saldo Conta Investimento */
      FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper           AND
                         crapsli.nrdconta  = aux_nrdconta           AND
                   MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt)    AND
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
           ASSIGN /*craplot.qtinfoln = craplot.qtinfoln + 1*/
                  craplot.qtcompln = craplot.qtcompln + 1
                  craplot.nrseqdig = craplot.nrseqdig + 1
                  craplot.vlcompcr = craplot.vlcompcr + tel_vllanmto
                  /*craplot.vlinfocr = craplot.vlinfocr + tel_vllanmto*/
                  craplci.cdhistor = 485
                  crapsli.vlsddisp = crapsli.vlsddisp + tel_vllanmto.
      ELSE
      IF   tel_cdhistor = 486  OR
           tel_cdhistor = 647 THEN
           DO:
               ASSIGN /*craplot.qtinfoln = craplot.qtinfoln + 1*/
                      craplot.qtcompln = craplot.qtcompln + 1
                      craplot.nrseqdig = craplot.nrseqdig + 1
                      craplot.vlcompdb = craplot.vlcompdb + tel_vllanmto
                      /*craplot.vlinfodb = craplot.vlinfodb + tel_vllanmto*/
                      craplci.cdhistor = tel_cdhistor
                      crapsli.vlsddisp = crapsli.vlsddisp - tel_vllanmto.

               IF   tel_cdhistor = 647   THEN
                    DO:
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

                       /* Cria Lancamento Cconta Investimento Destino */
                       CREATE craplci.
                       ASSIGN craplci.dtmvtolt = glb_dtmvtolt
                              craplci.cdagenci = tel_cdagenci
                              craplci.cdbccxlt = tel_cdbccxlt
                              craplci.nrdolote = tel_nrdolote
                              craplci.nrdconta = crabass.nrdconta
                              craplci.nrdocmto = tel_nrdocmto
                              craplci.vllanmto = tel_vllanmto 
                              craplci.nrseqdig = tel_nrseqdig 
                              craplci.cdhistor = 648  /* credito transf. */
                              craplci.cdcooper = glb_cdcooper.
                              crapsli.vlsddisp = crapsli.vlsddisp +
                                                            tel_vllanmto.
                       VALIDATE craplci.

                    END.
           END.
      ELSE
      IF   tel_cdhistor = 487   THEN
           ASSIGN /*craplot.qtinfoln = craplot.qtinfoln + 1*/
                  craplot.qtcompln = craplot.qtcompln + 1
                  craplot.nrseqdig = craplot.nrseqdig + 1
                  craplot.vlcompcr = craplot.vlcompcr + tel_vllanmto
                  /*craplot.vlinfocr = craplot.vlinfocr + tel_vllanmto*/
                  craplci.cdhistor = 487
                  crapsli.vlsddisp = crapsli.vlsddisp + tel_vllanmto.
               
      /* para exibir o registro anterior */
      ASSIGN tel_reganter[6] = tel_reganter[5]  
             tel_reganter[5] = tel_reganter[4]
             tel_reganter[4] = tel_reganter[3]
             tel_reganter[3] = tel_reganter[2]
             tel_reganter[2] = tel_reganter[1]

             tel_reganter[1] = STRING(tel_cdhistor,"zzz9")            + " "  +
                               STRING(tel_nrctainv,"zz,zzz,zzz,9")    + " "  +
                               STRING(tel_nrdocmto,"zz,zzz,zzz,zzz,zz9") 
                               + " "  +
                               STRING(tel_vllanmto,"zzz,zzz,zzz,zz9.99") + 
                               "        "  + STRING(tel_nrseqdig,"zz,zz9")
          
             tel_cdhistor = 0
             tel_nrctainv = 0
             tel_nrdocmto = 0
             tel_vllanmto = 0
             tel_nrseqdig = craplot.nrseqdig
             
             tel_qtinfoln = craplot.qtinfoln   
             tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   
             tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   
             tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.
             
      LEAVE.
   END. /* fim DO WHILE TRUE */

   RELEASE crapsli.
   RELEASE craplci.
   RELEASE craplot.

   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  AND  tel_vldifecr = 0   THEN
        DO:
            glb_nmdatela = "LOTE".
            RETURN.                        /* Volta para a lanlci */
        END.

   DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3]
           tel_reganter[4] tel_reganter[5] tel_reganter[6]
           WITH FRAME f_regant.

   DISPLAY tel_qtinfoln  tel_vlinfodb  tel_vlinfocr
           tel_qtcompln  tel_vlcompdb  tel_vlcompcr
           tel_qtdifeln  tel_vldifedb  tel_vldifecr  WITH FRAME f_lanlci.

END.

PROCEDURE mostra_dados:

    glb_cdcritic = 666.

    tel_cdbanchq = INT(SUBSTRING(tel_dsdocmc7,02,03)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
    
    tel_cdagechq = INT(SUBSTRING(tel_dsdocmc7,05,04)) NO-ERROR.
 
    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
     
    tel_cdcmpchq = INT(SUBSTRING(tel_dsdocmc7,11,03)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
 
    tel_nrcheque = INT(SUBSTRING(tel_dsdocmc7,14,06)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
                                                 
    tel_nrctachq = DECIMAL(SUBSTRING(tel_dsdocmc7,23,10)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         RETURN.

    tel_nrctabdb = IF tel_cdbanchq = 1 
                      THEN DECIMAL(SUBSTRING(tel_dsdocmc7,25,08))
                      ELSE DECIMAL(SUBSTRING(tel_dsdocmc7,23,10)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
     
    glb_cdcritic = 0.
    
    /*  Calcula primeiro digito de controle  */
                  
    glb_nrcalcul = DECIMAL(STRING(tel_cdcmpchq,"999") +
                           STRING(tel_cdbanchq,"999") +
                           STRING(tel_cdagechq,"9999") + "0").
                                  
    RUN fontes/digfun.p.
                  
    tel_nrddigc1 = INT(SUBSTRING(STRING(glb_nrcalcul),
                                 LENGTH(STRING(glb_nrcalcul)))).    
                   
    /*  Calcula segundo digito de controle  */

    glb_nrcalcul = tel_nrctachq * 10.
                                         
    RUN fontes/digfun.p.
                  
    tel_nrddigc2 = INT(SUBSTRING(STRING(glb_nrcalcul),
                                 LENGTH(STRING(glb_nrcalcul)))).    
 
    /*  Calcula terceiro digito de controle  */

    glb_nrcalcul = tel_nrcheque * 10.
                                         
    RUN fontes/digfun.p.
                  
    ASSIGN tel_nrddigc3 = INT(SUBSTRING(STRING(glb_nrcalcul),
                          LENGTH(STRING(glb_nrcalcul))))
           tel_vlcheque = tel_vlcompel
           tel_dtlibcom = tel_dtliblan.                  

    /*  Verifica se o banco existe .......................................... */
    
    FIND crapban WHERE crapban.cdbccxlt = tel_cdbanchq NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapban   THEN
         DO:
             glb_cdcritic = 57.
             RETURN.
         END.

    /*  Verifica se a agencia existe ........................................ */

    FIND crapagb WHERE crapagb.cddbanco = tel_cdbanchq   AND
                       crapagb.cdageban = tel_cdagechq NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapagb   THEN
         DO:
             glb_cdcritic = 15.
             RETURN.
         END.
 
    /*  Mostra os dados lidos  */
                  
    CLEAR FRAME f_lanctos_compel ALL.
    ASSIGN aux_qtlincom = 0.
    IF   NOT aux_flgchqex   THEN
         DO:
             ASSIGN aux_qtlincom = 1.
             DISPLAY tel_cdcmpchq 
                     tel_cdbanchq
                     tel_cdagechq 
                     tel_nrddigc1
                     tel_nrctabdb
                     tel_nrddigc2 
                     tel_nrcheque
                     tel_nrddigc3
                     tel_vlcheque
                     tel_dtlibcom
                     WITH FRAME f_lanctos_compel.
             DOWN WITH FRAME f_lanctos_compel.
         END.
    
    FOR EACH w-compel NO-LOCK USE-INDEX compel2:
    
        DISPLAY w-compel.cdcmpchq @ tel_cdcmpchq 
                w-compel.cdbanchq @ tel_cdbanchq
                w-compel.cdagechq @ tel_cdagechq 
                w-compel.nrddigc1 @ tel_nrddigc1
                w-compel.nrctabdb @ tel_nrctabdb
                w-compel.nrddigc2 @ tel_nrddigc2 
                w-compel.nrcheque @ tel_nrcheque
                w-compel.nrddigc3 @ tel_nrddigc3
                w-compel.vlcompel @ tel_vlcheque
                w-compel.dtlibcom @ tel_dtlibcom
                WITH FRAME f_lanctos_compel.
        DOWN WITH FRAME f_lanctos_compel.
        ASSIGN aux_qtlincom = aux_qtlincom + 1.
        IF   aux_qtlincom = 5   THEN
             LEAVE.
    END.
         
END PROCEDURE.

/*...........................................................................*/
