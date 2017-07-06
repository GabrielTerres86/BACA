/* .............................................................................

   Programa: Fontes/lanempi.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 16/02/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela lanemp.

   Alteracoes: 21/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               06/03/95 - Alterado para alimentar no craplem txjurepr e dtpagemp
                          (Odair).

               11/06/96 - Alterado para alimentar o valor da prestacao no
                          craplem quando houver pagamento (Edson).

               29/01/97 - Alterar a ordem dos campos Contrato Documento (Odair)

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               09/11/98 - Tratar situacao em prejuizo (Deborah). 
               
             24/10/2000 - Desmembrar a critica 95 conforme a situacao do 
                          titular (Eduardo).

             02/07/2001 - Tratamento do prejuizo (Margarete).

             28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).

             08/05/2002 - Qdo prejuizo criticas de valores lancados (Margarete)
             
             06/10/2003 - Corrigir critica do histor 391 (Margarete).
             
             04/07/2005 - Alimentado campo cdcooper da tabela craplem (Diego).
             
             30/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

             24/09/2007 - Conversao de rotina ver_capital para BO 
                          (Sidnei/Precise)
                          
             09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                          glb_cdcooper) no "find" da tabela CRAPHIS.   
                        - Kbase IT Solutions - Eduardo Silva.
                        
             31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
             
             06/07/2009 - Nao permitir lancamentos para emprestimos com emissao
                          de boletos (Fernando).
                        - Comentado a alteracao do fernando e incluso
                          numero de boleto(Guilherme).

             23/11/2009 - Alteracao Codigo Historico (Kbase). 
             
             29/12/2009 - Bloquear Hist. 382, 383, 390 e 391 quando emprestimo
                          nao estiver em prejuizo (David).
                          
             17/05/2010 - Desativar Rating quando quitado o emprestimo
                         (Gabriel).
                         
             14/09/2011 - Tratamento historico 277. Numero do documento deve 
                          ser igual ao numero do contrato de emprestimo (Irlan)
                          
             06/12/2011 - Critica lancamento do historico 349 se periodo
                          no risco 'H' for menor do que 6 meses (Elton).

			 05/03/2012 - Validacao do novo tipo de emprestimo (tipo 1) e
                          Verificacao dos novos historicos (Tiago). 
                          
             03/11/2014 - Incluso tratamento para Transferencia Prejuizo 
                          novos contratos (Daniel/Oscar).

             02/12/2014 - Inclusao da chamada da solicita_baixa_automatica
                          (Guilherme/SUPERO)
                          
             26/01/2015 - Alterado o formato do campo nrctremp para 8 
                          caracters (Kelvin - 233714)
             
             06/03/2015 - Incluido nova mensagem ao criticar historico inválido 
                          SD - 255247 (Kelvin)

             16/03/2015 - Alterado o formato do campo nrdocmto para 10
                          posicoes. (Jaison/Gielow - SD: 263692)
                          
             08/10/2015 - Adicionado mais informacoes no log no momento do pagamento
                             das parcelas de emprestimo. SD 317004 (Kelvin)
                          
             06/11/2015 - Adicionado tratamento para pagamento de emprestimos por
                          boleto. (Reinert)   
                          
             15/08/2016 - Controlar o preenchimento da data de pagamento do prejuízo,
                          no momento da liquidaçao do mesmo. (Renato Darosci - M176)
                          
             23/09/2016 - Inclusao da verificacao de contrato de acordo (Jean Michel).             
                          
			 31/10/2016 - Adicionado tratamento para casos onde o valor de prejuizo
			              foi gravado como negativo na base. Chamado 533531

			 10/01/2017 - Correcao no abono de prejuizo, verifica se o valor foi armazenado negativo
			              e transforma em positivo se necessario, em alguns casos estava duplicando o valor.
						  Andrey (Mouts) - Chamado 568416

             16/02/2017 - Alteracao de aux_flgativo para aux_flgretativo. (Jaison/James)
                          
............................................................................. */

{ includes/var_online.i }
{ includes/var_lanemp.i }

{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0001 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0043 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0134 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0171 AS HANDLE                                      NO-UNDO.

DEF VAR aux_vlrsaldo AS DEC                                         NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.

ASSIGN tel_cdhistor = 0  tel_nrdconta = 0  tel_nrctremp = 0
       tel_nrdocmto = 0  tel_vllanmto = 0  tel_nrseqdig = 1.

INCLUSAO:
DO WHILE TRUE:

   RUN fontes/inicia.p.

   glb_dscritic = "".

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0 OR glb_dscritic <> "" THEN
           DO:
               IF   glb_dscritic = "" THEN
                    RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lanemp.               
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote
                       WITH FRAME f_lanemp.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_cdhistor tel_nrdconta 
                          tel_nrdocmto
                          tel_nrctremp 
                          tel_vllanmto WITH FRAME f_lanemp

      EDITING:

         READKEY.

         IF   FRAME-FIELD = "tel_vllanmto"   THEN
              IF   LASTKEY =  KEYCODE(".")   THEN
                   APPLY 44.
              ELSE
                   APPLY LASTKEY.
         ELSE
         IF  FRAME-FIELD = "tel_nrdocmto"   THEN
             IF  INPUT tel_cdhistor = 277  THEN
                DO:
                    NEXT-PROMPT tel_nrctremp WITH FRAME f_lanemp.
                    NEXT.
                END.
             ELSE
                 APPLY LASTKEY.
         ELSE
         IF  FRAME-FIELD = "tel_nrctremp"   THEN
             IF  INPUT tel_cdhistor = 277  THEN
                DO:
                    APPLY LASTKEY. 
                    tel_nrdocmto:SCREEN-VALUE = tel_nrctremp:SCREEN-VALUE.
                END.
             ELSE
                 APPLY LASTKEY.
         ELSE

            APPLY LASTKEY.

      END.  /*  Fim do EDITING  */

      ASSIGN glb_cdcritic = 0
             glb_dscritic = "".

      /* buscar ultimo boleto do contratos */
      FOR EACH tbepr_cobranca FIELDS (cdcooper nrdconta_cob nrcnvcob nrboleto nrctremp)
         WHERE tbepr_cobranca.cdcooper = glb_cdcooper AND
               tbepr_cobranca.nrdconta = tel_nrdconta AND    
               tbepr_cobranca.nrctremp = tel_nrctremp
               NO-LOCK    
               BY tbepr_cobranca.nrboleto DESC:
          
              /* verificar se o boleto do contrato está em aberto */
              FOR FIRST crapcob FIELDS (dtvencto vltitulo)
                  WHERE crapcob.cdcooper = tbepr_cobranca.cdcooper
                    AND crapcob.nrdconta = tbepr_cobranca.nrdconta_cob
                    AND crapcob.nrcnvcob = tbepr_cobranca.nrcnvcob
                    AND crapcob.nrdocmto = tbepr_cobranca.nrboleto
                    AND crapcob.incobran = 0 NO-LOCK:
     
                  ASSIGN glb_cdcritic = 0
                         glb_dscritic = "Boleto do contrato " + STRING(tbepr_cobranca.nrctremp) + 
                                        " em aberto." +      
                                        " Vencto " + STRING(crapcob.dtvencto,"99/99/9999") +      
                                        " R$ " + TRIM(STRING(crapcob.vltitulo, "zzz,zzz,zz9.99-")) + ".".    
                  LEAVE.    

              END.          
     
              /* verificar se o boleto do contrato está em pago, pendente de processamento */
              FOR FIRST crapcob FIELDS (dtvencto vltitulo dtdpagto)
                  WHERE crapcob.cdcooper = tbepr_cobranca.cdcooper
                    AND crapcob.nrdconta = tbepr_cobranca.nrdconta_cob
                    AND crapcob.nrcnvcob = tbepr_cobranca.nrcnvcob
                    AND crapcob.nrdocmto = tbepr_cobranca.nrboleto
                    AND crapcob.incobran = 5 NO-LOCK:
     
                      FOR FIRST crapret      
                          WHERE crapret.cdcooper = crapcob.cdcooper    
                            AND crapret.nrdconta = crapcob.nrdconta     
                            AND crapret.nrcnvcob = crapcob.nrcnvcob     
                            AND crapret.nrdocmto = crapcob.nrdocmto     
                            AND crapret.cdocorre = 6     
                            AND crapret.dtocorre = crapcob.dtdpagto     
                            AND crapret.flcredit = 0     
                            NO-LOCK:    
     
                          /* gerar mensagem de crítica abaixo */     
                          ASSIGN glb_cdcritic = 0
                                 glb_dscritic = "Boleto do contrato " + STRING(tbepr_cobranca.nrctremp) + 
                                                " esta pago pendente de processamento." +       
                                                " Vencto " + STRING(crapcob.dtvencto,"99/99/9999") +      
                                                " R$ " + TRIM(STRING(crapcob.vltitulo, "zzz,zzz,zz9.99-")) + ".".    
                          LEAVE.
         
                      END.
              END.
     
      END.
        
      IF  glb_cdcritic <> 0 OR glb_dscritic <> "" THEN
          NEXT.

      FIND craphis WHERE
           craphis.cdcooper = glb_cdcooper AND      
           craphis.cdhistor = tel_cdhistor NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE craphis   THEN
           DO:
               glb_cdcritic = 93.
               NEXT-PROMPT tel_cdhistor WITH FRAME f_lanemp.
               NEXT.
           END.

      IF tel_cdhistor <> 382 AND 
         tel_cdhistor <> 383 AND
         tel_cdhistor <> 390 AND
         tel_cdhistor <> 391 THEN
      DO:

          RUN sistema/generico/procedures/b1wgen0134.p 
                           PERSISTENT SET h-b1wgen0134.
                      
          RUN valida_empr_tipo1 IN h-b1wgen0134
                                  (INPUT  glb_cdcooper,
                                   INPUT  tel_cdagenci,
                                   INPUT  0,
                                   INPUT  tel_nrdconta,
                                   INPUT  tel_nrctremp,             
                                   OUTPUT TABLE tt-erro).                                
          DELETE PROCEDURE h-b1wgen0134.
          
          IF  RETURN-VALUE = "OK" THEN
              DO:
                ASSIGN glb_cdcritic = 946.
                NEXT-PROMPT tel_cdagenci WITH FRAME f_lanemp.
                NEXT.    
              END.
      END.
      
      RUN sistema/generico/procedures/b1wgen0134.p
                          PERSISTENT SET h-b1wgen0134.
                          
      RUN valida_historico IN h-b1wgen0134(INPUT tel_cdhistor).
      DELETE PROCEDURE h-b1wgen0134.
                                         
      IF   RETURN-VALUE = "OK" THEN
           DO:
               MESSAGE "Historico nao permitido.".
               PAUSE 3 NO-MESSAGE.
               NEXT.
           END.

      IF   craphis.tplotmov <> 5   THEN
           DO:
               glb_cdcritic = 94.
               NEXT-PROMPT tel_cdhistor WITH FRAME f_lanemp.
               NEXT.
           END.


      ASSIGN glb_nrcalcul = tel_nrdconta
             aux_indebcre = craphis.indebcre
             aux_inhistor = craphis.inhistor
             aux_vlrpagos = 0
             aux_vlacresc = 0.

      RUN fontes/digfun.p.
      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanemp.
               NEXT.
           END.

      IF   tel_nrdocmto = 0   THEN
           DO:
               glb_cdcritic = 22.
               NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanemp.
               NEXT.
           END.

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                         crapass.nrdconta = tel_nrdconta     NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapass   THEN
           DO:
               glb_cdcritic = 9.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanemp.
               NEXT.
           END.

      IF   crapass.inpessoa = 1   THEN 
           DO:
               FIND crapttl WHERE 
                    crapttl.cdcooper = glb_cdcooper       AND
                    crapttl.nrdconta = crapass.nrdconta   AND
                    crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
                    
               IF   AVAIL crapttl  THEN
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
              
      IF   tel_cdhistor = 277 THEN
           IF  tel_nrdocmto <> tel_nrctremp  THEN
                DO:
                   MESSAGE "Num. documento deve ser igual ao Num. do contrato de emprestimo".
                   glb_cdcritic = 0.
                   NEXT-PROMPT tel_nrctremp WITH FRAME f_lanemp.
                   NEXT.
                END.

      RUN sistema/generico/procedures/b1wgen0001.p
          PERSISTENT SET h-b1wgen0001.
      
      IF  VALID-HANDLE(h-b1wgen0001)   THEN
          DO:
              RUN ver_capital IN h-b1wgen0001(INPUT  glb_cdcooper,
                                              INPUT  tel_nrdconta,
                                              INPUT  0, /* cod-agencia */
                                              INPUT  0, /* nro-caixa   */
                                              0,        /* vllanmto */
                                              INPUT  glb_dtmvtolt,
                                              INPUT  "lanempi",
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

      IF   glb_cdcritic > 0   THEN
           DO:
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanemp.
               NEXT.
           END.

      IF   CAN-FIND(craplem WHERE craplem.cdcooper = glb_cdcooper   AND
                                  craplem.dtmvtolt = tel_dtmvtolt   AND
                                  craplem.cdagenci = tel_cdagenci   AND
                                  craplem.cdbccxlt = tel_cdbccxlt   AND
                                  craplem.nrdolote = tel_nrdolote   AND
                                  craplem.nrdconta = tel_nrdconta   AND
                                  craplem.nrdocmto = tel_nrdocmto
                                  USE-INDEX craplem1)               THEN
           DO:
               glb_cdcritic = 92.
               NEXT-PROMPT tel_nrdocmto WITH FRAME f_lanemp.
               NEXT.
           END.

      /*  Leitura do dia do pagamento da empresa  */

      FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                         craptab.nmsistem = "CRED"            AND
                         craptab.tptabela = "GENERI"          AND
                         craptab.cdempres = 00                AND
                         craptab.cdacesso = "DIADOPAGTO"      AND
                         craptab.tpregist = aux_cdempres  NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE craptab   THEN
           DO:
               glb_cdcritic = 55.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic "DIA DO PAGTO DA EMPRESA" aux_cdempres.
               glb_cdcritic = 0.
               NEXT.
           END.

      IF   CAN-DO("1,3,4",STRING(crapass.cdtipsfx))   THEN
           tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,4,2)). /* Mensal */
      ELSE
           tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,7,2)). /* Horis. */

      /*  Verifica se a data do pagamento da empresa cai num dia util  */

      tab_dtcalcul = DATE(MONTH(glb_dtmvtolt),tab_diapagto,YEAR(glb_dtmvtolt)).

      DO WHILE TRUE:

         IF   WEEKDAY(tab_dtcalcul) = 1   OR
              WEEKDAY(tab_dtcalcul) = 7   THEN
              DO:
                  tab_dtcalcul = tab_dtcalcul + 1.
                  NEXT.
              END.

         FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                            crapfer.dtferiad = tab_dtcalcul  NO-LOCK NO-ERROR.

         IF   AVAILABLE crapfer   THEN
              DO:
                  tab_dtcalcul = tab_dtcalcul + 1.
                  NEXT.
              END.

         tab_diapagto = DAY(tab_dtcalcul).

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      /* Verifica se ha contratos de acordo */            
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
      
      RUN STORED-PROCEDURE pc_verifica_situacao_acordo
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper
                                            ,INPUT tel_nrdconta
                                            ,INPUT tel_nrctremp
											,INPUT 3
                                            ,0 /* pr_flgretativo */
                                            ,0 /* pr_flgretquitado */
                                            ,0 /* pr_flgretcancelado */
                                            ,0
                                            ,"").

      CLOSE STORED-PROC pc_verifica_situacao_acordo
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

      ASSIGN glb_cdcritic = 0
             glb_dscritic = ""
             glb_cdcritic = pc_verifica_situacao_acordo.pr_cdcritic WHEN pc_verifica_situacao_acordo.pr_cdcritic <> ?
             glb_dscritic = pc_verifica_situacao_acordo.pr_dscritic WHEN pc_verifica_situacao_acordo.pr_dscritic <> ?
             aux_flgretativo   = INT(pc_verifica_situacao_acordo.pr_flgretativo)
             aux_flgretquitado = INT(pc_verifica_situacao_acordo.pr_flgretquitado).
      
      IF glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0.
            NEXT.
        END.
      ELSE IF glb_dscritic <> ? AND glb_dscritic <> "" THEN
        DO:
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0.
            NEXT.
        END.
      /* Fim verifica se ha contratos de acordo */
      
      IF aux_flgretativo = 1 THEN
         DO:
             ASSIGN flg_next = TRUE.
             MESSAGE "Lancamento nao permitido, emprestimo em acordo.".
             NEXT.
         END.

       /* Se estiver QUITADO */
      IF aux_flgretquitado = 1 THEN
         DO:
             ASSIGN flg_next = TRUE.
             MESSAGE "Lancamento nao permitido, contrato liquidado atraves de acordo.".
             NEXT.
         END.   

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        RETURN.  /* Volta pedir a opcao para o operador */

   DO TRANSACTION:

      DO WHILE TRUE:

         FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                            craplot.dtmvtolt = tel_dtmvtolt   AND
                            craplot.cdagenci = tel_cdagenci   AND
                            craplot.cdbccxlt = tel_cdbccxlt   AND
                            craplot.nrdolote = tel_nrdolote   EXCLUSIVE-LOCK
                            NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craplot   THEN
              IF   LOCKED craplot   THEN
                   DO:
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   glb_cdcritic = 60.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic = 0   THEN
           DO:
               IF   craplot.tplotmov <> 5   THEN
                    DO:
                        glb_cdcritic = 213.
                        NEXT.
                    END.

               DO WHILE TRUE:

                  FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper   AND
                                     crapepr.nrdconta = tel_nrdconta   AND
                                     crapepr.nrctremp = tel_nrctremp
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapepr   THEN
                       IF   LOCKED crapepr   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            DO:
                                glb_cdcritic = 356.
                                NEXT-PROMPT tel_nrctremp WITH FRAME f_lanemp.
                            END.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   glb_cdcritic = 0   THEN 
                    DO:
                        IF   crapepr.inliquid > 0   AND
                             crapepr.inprejuz = 0   AND
                             aux_indebcre = "C"     THEN
                             DO:
                                 glb_cdcritic = 358.
                                 NEXT-PROMPT tel_nrctremp WITH FRAME f_lanemp.
                                 NEXT.
                             END.
                    END.
               ELSE
                    NEXT.
                   
               /* Guardar o valor de saldo de prejuizo (Renato Darosci - 15/08/2016) */ 
               ASSIGN ant_vlsdprej = crapepr.vlsdprej.
                   
               IF   tab_inusatab           AND
                    crapepr.inliquid = 0   THEN
                    DO:
                        FIND craplcr WHERE
                             craplcr.cdcooper = glb_cdcooper     AND
                             craplcr.cdlcremp = crapepr.cdlcremp 
                             NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE craplcr   THEN
                             DO:
                                 glb_cdcritic = 363.
                                 NEXT.
                             END.
                        ELSE
                             aux_txdjuros = craplcr.txdiaria.
                    END.
               ELSE
                    aux_txdjuros = crapepr.txjuremp.

               IF   crapepr.inprejuz = 0   THEN
                    DO:
                        IF   tel_cdhistor = 382   OR
                             tel_cdhistor = 383   OR
                             tel_cdhistor = 390   OR
                             tel_cdhistor = 391   THEN
                             DO:
                                 glb_cdcritic = 93.
                                 NEXT-PROMPT tel_cdhistor WITH FRAME f_lanemp.
                                 NEXT.
                             END.
                    END.
               ELSE
                    DO:
                        IF   tel_cdhistor     <> 382 /*pag.prej.orig*/
                        AND  tel_cdhistor     <> 383 /*abono prejuizo*/
                        AND  tel_cdhistor     <> 390 /*acrescimos*/
                        AND  tel_cdhistor     <> 391   THEN /*pag.prejuizo*/
                             DO:
                                 glb_cdcritic = 93.
                                 NEXT-PROMPT tel_cdhistor WITH FRAME f_lanemp.
                                 NEXT.
                             END. 
                      
                        FOR EACH craplem WHERE 
                                 craplem.cdcooper = glb_cdcooper       AND
                                 craplem.nrdconta = crapepr.nrdconta   AND
                                 craplem.nrctremp = crapepr.nrctremp   AND
                                 (craplem.cdhistor = 382               OR
                                  craplem.cdhistor = 390)               
                                 NO-LOCK:
                                 
                            IF   craplem.cdhistor = 382   THEN
                                 ASSIGN aux_vlrpagos = aux_vlrpagos +
                                                           craplem.vllanmto.
                            ELSE
                                 ASSIGN aux_vlacresc = aux_vlacresc +
                                                           craplem.vllanmto.
                        END.                               
                        

                        IF   tel_cdhistor = 382   AND
                             aux_vlrpagos = crapepr.vlprejuz   THEN 
                             DO:
                                 glb_cdcritic = 93.
                                 NEXT-PROMPT tel_cdhistor WITH FRAME f_lanemp. 
                                 NEXT.
                             END.
                        
                        IF   tel_cdhistor = 382   AND
                             tel_vllanmto > 
                                 ( (crapepr.vlprejuz + crapepr.vlttmupr + crapepr.vlttjmpr) - aux_vlrpagos )   THEN 
                             DO:
                                 glb_cdcritic = 269.
                                 NEXT-PROMPT tel_vllanmto WITH FRAME f_lanemp. 
                                 NEXT.
                             END.


                        IF   tel_cdhistor = 391   AND
                             aux_vlrpagos <> ( crapepr.vlprejuz + crapepr.vlttmupr + crapepr.vlttjmpr) THEN 
                             DO:
                                 glb_cdcritic = 93.
                                 NEXT-PROMPT tel_cdhistor WITH FRAME f_lanemp. 
                                 NEXT.
                             END.
 
                        
                        IF   tel_cdhistor = 391   AND
                             tel_vllanmto > ((crapepr.vlsdprej + crapepr.vlttmupr + crapepr.vlttjmpr) +
                                            aux_vlacresc )       THEN 
                             DO:
                                 glb_cdcritic = 269.
                                 NEXT-PROMPT tel_vllanmto WITH FRAME f_lanemp. 
                                 NEXT.
                             END.
                    END.

                    
               /* Linha utilizada para boletos via internet */
               FIND craplcr WHERE craplcr.cdcooper = crapepr.cdcooper AND
                                  craplcr.cdlcremp = crapepr.cdlcremp AND
                                  craplcr.cdusolcr = 3
                                  NO-LOCK NO-ERROR.
                                  
               IF AVAIL craplcr THEN
                  DO:
                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                        UPDATE tel_nrboleto WITH FRAME f_nrboleto.
                
                        FIND crapcob WHERE 
                             crapcob.cdcooper = crapepr.cdcooper AND
                             crapcob.nrctasac = crapepr.nrdconta AND
                             crapcob.nrctremp = crapepr.nrctremp AND
                             crapcob.nrdocmto = tel_nrboleto
                             NO-LOCK NO-ERROR.
                                   
                        IF  AVAIL crapcob  THEN
                            DO:
                                IF  crapcob.dtdbaixa = ?  THEN
                                    DO:
                                        flg_next = TRUE.
                                        MESSAGE "O boleto deve estar baixado.".
                                        NEXT-PROMPT tel_nrctremp 
                                                    WITH FRAME f_lanemp.
                                    END.
                            END.
                        ELSE
                            DO:
                                flg_next = TRUE.
                                MESSAGE "Boleto nao encontrado.".
                                NEXT-PROMPT tel_nrctremp WITH FRAME f_lanemp.
                            END.
                        
                        LEAVE.
                    END.

    
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                        flg_next  THEN
                        DO:
                            HIDE FRAME f_nrboleto.
                            NEXT.
                        END.

                  END.
               
               ASSIGN aux_nrdconta = crapepr.nrdconta
                      aux_nrctremp = crapepr.nrctremp
                      aux_vlsdeved = crapepr.vlsdeved
                      aux_vljuracu = crapepr.vljuracu
                      aux_inliquid = crapepr.inliquid
                      aux_dtultpag = crapepr.dtultpag

                      aux_dtcalcul = ?

                      aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,
                                             YEAR(glb_dtmvtolt)) +
                                             4) - DAY(DATE(MONTH(glb_dtmvtolt),
                                             28,YEAR(glb_dtmvtolt)) + 4)).

               IF   crapepr.inprejuz = 0   THEN
                    DO:
                        { includes/lelem.i } 
                            /* Rotina para calculo do saldo devedor */
                    END.

               
               /************** Lancamento de Prejuizo ***************/
               IF   tel_cdhistor = 349   THEN
                    DO:
                       IF  tel_vllanmto <> aux_vlsdeved   THEN   
                           DO:
                              glb_cdcritic = 269.
                              NEXT-PROMPT tel_vllanmto WITH FRAME f_lanemp.
                              NEXT.
                           END.
                       
                       /******* Comentado em 18/04/2012 - Elton ********
                       FIND craptab WHERE  craptab.cdcooper = glb_cdcooper AND
                                           craptab.nmsistem = "CRED"       AND
                                           craptab.tptabela = "USUARI"     AND
                                           craptab.cdempres = 11           AND
                                           craptab.cdacesso = "RISCOBACEN" AND
                                           craptab.tpregist = 000 NO-LOCK NO-ERROR.
                       
                       FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
        
        
                       ASSIGN   aux_dtrefere = crapdat.dtultdma.
                                aux_vlr_arrasto = DEC(SUBSTRING(craptab.dstextab,3,9)).
        
                                                      
                       FIND LAST crapris WHERE  crapris.cdcooper = glb_cdcooper AND
                                                crapris.nrdconta = tel_nrdconta AND 
                                                crapris.dtrefere = aux_dtrefere AND 
                                                crapris.inddocto = 1            AND 
                                                crapris.vldivida > aux_vlr_arrasto /*Valor arrasto*/
                                                NO-LOCK NO-ERROR.
        
                       IF  NOT AVAIL crapris THEN   
                           FIND LAST crapris WHERE crapris.cdcooper = glb_cdcooper AND
                                                   crapris.nrdconta = tel_nrdconta AND 
                                                   crapris.dtrefere = aux_dtrefere AND 
                                                   crapris.inddocto = 1 NO-LOCK NO-ERROR.
                     
                       IF   AVAIL crapris THEN
                            DO:    /** Critica se risco nao for 'H' ou se 
                                   'H' com menos de 180 dias de atraso**/
                               IF   (crapris.innivris < 9)      OR
                                    (crapris.innivris >= 9      AND
                                    (glb_dtmvtolt - crapris.dtdrisco) < 180) THEN
                                    DO:
                                        glb_cdcritic = 944.
                                        NEXT-PROMPT tel_cdhistor WITH FRAME f_lanemp.
                                        NEXT.
                                    END.
                            END.
                     ************** Fim comentario - Elton **************/    
                    END.
           END.
      ELSE
           NEXT.

      CREATE craplem.
      ASSIGN tel_nrseqdig     = craplot.nrseqdig + 1
             craplem.dtmvtolt = tel_dtmvtolt
             craplem.cdagenci = tel_cdagenci
             craplem.cdbccxlt = tel_cdbccxlt
             craplem.nrdolote = tel_nrdolote
             craplem.nrdconta = tel_nrdconta
             craplem.nrctremp = tel_nrctremp
             craplem.nrdocmto = tel_nrdocmto
             craplem.vllanmto = tel_vllanmto
             craplem.cdhistor = tel_cdhistor
             craplem.nrseqdig = tel_nrseqdig
             craplem.txjurepr = IF crapepr.inprejuz <> 0 THEN 0
                                ELSE aux_txdjuros
             craplem.dtpagemp = tab_dtcalcul

             craplem.vlpreemp = crapepr.vlpreemp
             craplem.cdcooper = glb_cdcooper

             craplot.nrseqdig = tel_nrseqdig
             craplot.qtcompln = craplot.qtcompln + 1.

      /*** Log lancamento para prejuizo ***/
      IF  tel_cdhistor = 349 THEN
          RUN gera_log_prejuizo.
      
      IF CAN-DO("95",STRING(tel_cdhistor))  THEN 
          DO:
              RUN proc_gerar_log (INPUT glb_cdcooper, 
                                  INPUT glb_cdoperad,
                                  INPUT "",
                                  INPUT "AYLLOS",
                                  INPUT "Pag. Emp/Fin Nr: " + STRING(tel_nrctremp) + " Cred. Contrato",
                                  INPUT TRUE,
                                  INPUT 1,
                                  INPUT "LANEMP",
                                  INPUT tel_nrdconta,
                                 OUTPUT aux_nrdrowid).
                                   
              RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                       INPUT "vlpagpar", 
                                       INPUT STRING(tel_vllanmto),
                                       INPUT STRING(tel_vllanmto)).
          END.
      
      /******* Magui tratamento do prejuizo 02/07/2001 ***/
      IF   crapepr.inprejuz <> 0   THEN
           DO:
               IF aux_indebcre = "D"   THEN
                  ASSIGN crapepr.vlsdprej = crapepr.vlsdprej +
                                                    tel_vllanmto.
               ELSE 
               IF aux_indebcre = "C"   THEN
                  DO:
                      IF crapepr.tpemprst = 1 AND 
                         CAN-DO("382,383",STRING(tel_cdhistor)) THEN
                         DO:
                             ASSIGN aux_vlrsaldo = tel_vllanmto.

                             /* 1o Valor de Multa    */
                             IF (crapepr.vlttmupr - crapepr.vlpgmupr) >= aux_vlrsaldo THEN
                                 ASSIGN crapepr.vlpgmupr = crapepr.vlpgmupr + 
                                                           aux_vlrsaldo
                                        aux_vlrsaldo     = 0.
                             ELSE     
                                ASSIGN aux_vlrsaldo      = aux_vlrsaldo - 
                                                           (crapepr.vlttmupr - crapepr.vlpgmupr)
                                        crapepr.vlpgmupr = crapepr.vlpgmupr + 
                                                           (crapepr.vlttmupr - crapepr.vlpgmupr).
                                   
                             /* 2o Valor de Mora     */
                             IF aux_vlrsaldo > 0 THEN
                                DO:
                                    IF (crapepr.vlttjmpr - crapepr.vlpgjmpr) >= aux_vlrsaldo THEN
                                       ASSIGN crapepr.vlpgjmpr = crapepr.vlpgjmpr + 
                                                                 aux_vlrsaldo
                                              aux_vlrsaldo = 0.
                                   ELSE
                                      ASSIGN aux_vlrsaldo     = aux_vlrsaldo - 
                                                                (crapepr.vlttjmpr - crapepr.vlpgjmpr)
                                             crapepr.vlpgjmpr = crapepr.vlpgjmpr + 
                                                                (crapepr.vlttjmpr - crapepr.vlpgjmpr).
                                END. /* END IF aux_vlrsaldo > 0 THEN */

                        
                                /* 3o Valor em Prejuizo */
                             IF aux_vlrsaldo > 0 THEN
								                DO:
									                IF crapepr.vlsdprej < 0 THEN
										                DO:
											                ASSIGN crapepr.vlsdprej = (crapepr.vlsdprej * -1) -
															                                   aux_vlrsaldo.
								                    END.
									                ELSE
										                DO:
                                ASSIGN crapepr.vlsdprej = crapepr.vlsdprej - 
                                                          aux_vlrsaldo.
									                  END.
								                  END.
                         END. /* END crapepr.tpemprst = 1  */
                      ELSE  
                         DO:
							                    IF crapepr.vlsdprej < 0 THEN
								                    DO:
									                    ASSIGN crapepr.vlsdprej = (crapepr.vlsdprej * -1) -
                                                                tel_vllanmto.
								                    END.
							                    ELSE
								                    DO:
                             ASSIGN crapepr.vlsdprej = crapepr.vlsdprej -
                                                       tel_vllanmto.
                         END.
                                  END.
                  END. /* END IF aux_indebcre = "C"   THEN */
                  
               /* Setar a data de liquidaçao do prejuízo (Renato Darosci - 15/08/2016) */
               IF ant_vlsdprej > 0 AND crapepr.vlsdprej = 0 THEN
                   ASSIGN crapepr.dtliqprj = glb_dtmvtolt.
                  
           END. /* END IF   crapepr.inprejuz <> 0   THEN */
      ELSE  
           DO:                                                   
               IF   tel_cdhistor = 349   THEN 
                    ASSIGN crapepr.vlprejuz = crapepr.vlprejuz +
                                                      tel_vllanmto
                           crapepr.vlsdprej = crapepr.vlsdprej +
                                                      tel_vllanmto
                           crapepr.inprejuz = 1
                           crapepr.dtprejuz = glb_dtmvtolt
                           crapepr.vlsdevat = 0. 
                                                      
               IF   aux_indebcre = "D"   THEN
                    ASSIGN crapepr.inliquid = IF 
                                          (aux_vlsdeved + tel_vllanmto) > 0
                                          THEN 0
                                          ELSE 1.
               ELSE
                    IF   aux_indebcre = "C"   THEN
                      ASSIGN crapepr.dtultpag = tel_dtmvtolt
                             crapepr.txjuremp = aux_txdjuros
                             crapepr.inliquid = IF 
                                     (aux_vlsdeved - tel_vllanmto) > 0
                                           THEN 0
                                           ELSE 1.

               RUN sistema/generico/procedures/b1wgen0043.p
                                     PERSISTENT SET h-b1wgen0043.


               /* Verificar se tem que ativar/desativar Rating da operacao */
               RUN verifica_contrato_rating IN h-b1wgen0043
                                  (INPUT glb_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT glb_cdoperad,
                                   INPUT glb_dtmvtolt,
                                   INPUT glb_dtmvtopr,
                                   INPUT crapepr.nrdconta,
                                   INPUT 90,
                                   INPUT crapepr.nrctremp,
                                   INPUT 1,
                                   INPUT 1,
                                   INPUT glb_nmdatela,
                                   INPUT glb_inproces,
                                   INPUT FALSE,
                                   OUTPUT TABLE tt-erro).

               DELETE PROCEDURE h-b1wgen0043.

               IF   RETURN-VALUE <> "OK"   THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF   AVAIL tt-erro   THEN
                             MESSAGE tt-erro.dscritic.

                        UNDO, NEXT INCLUSAO.
                    END.

               IF  crapepr.inliquid = 1 /* Marcado para Liquidar e Sem prejuizo */
               AND crapepr.inprejuz = 0 THEN DO:
                   RUN sistema/generico/procedures/b1wgen0171.p
                       PERSISTENT SET h-b1wgen0171.
    
                   RUN solicita_baixa_automatica  IN h-b1wgen0171
                               (INPUT glb_cdcooper,
                                INPUT crapepr.nrdconta,
                                INPUT crapepr.nrctremp,
                                INPUT glb_dtmvtolt,
                                OUTPUT TABLE tt-erro).
    
                   DELETE PROCEDURE h-b1wgen0171.
               END.

           END. /* Fim Sem prejuizo */
          
      IF   aux_indebcre = "C"   THEN
           ASSIGN craplot.vlcompcr = craplot.vlcompcr + tel_vllanmto.
      ELSE
           IF   aux_indebcre = "D"   THEN
                ASSIGN craplot.vlcompdb = craplot.vlcompdb + tel_vllanmto.

      ASSIGN tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

   END.   /* Fim da transacao */

   RELEASE craplot.
   RELEASE craplem.
   RELEASE crapepr.

   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  AND  tel_vldifecr = 0   THEN
        DO:
            glb_nmdatela = "LOTE".
            RETURN.                        /* Volta ao lanemp.p */
        END.

   ASSIGN tel_reganter[6] = tel_reganter[5]  tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3]  tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1]

          tel_reganter[1] = STRING(tel_cdhistor,"zzz9")               + "  "  +
                            STRING(tel_nrdconta,"zzzz,zzz,9")         + "   " +
                            STRING(tel_nrdocmto,"z,zzz,zzz,zz9")         + "  " +
                            STRING(tel_nrctremp,"zz,zzz,zz9")          + "   " +
                            STRING(tel_vllanmto,"zzz,zzz,zzz,zz9.99") + "   " +
                            STRING(tel_nrseqdig,"zz,zz9").

   ASSIGN tel_cdhistor = 0  tel_nrdconta = 0  tel_nrctremp = 0
          tel_nrdocmto = 0  tel_vllanmto = 0  tel_nrseqdig = tel_nrseqdig + 1.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_cdhistor tel_nrdconta tel_nrdocmto
           tel_nrctremp tel_vllanmto tel_nrseqdig
           WITH FRAME f_lanemp.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3]
           tel_reganter[4] tel_reganter[5] tel_reganter[6]
           WITH FRAME f_regant.

END.   /*  Fim do DO WHILE TRUE  */


PROCEDURE gera_log_prejuizo:

  UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                STRING(TIME,"HH:MM:SS") + 
                " - INCLUSAO DE LANCAMENTO" + "'-->'" +
                " Operador: " + glb_cdoperad +
                " Hst: " + STRING(craplem.cdhistor) +
                " Conta: " + TRIM(STRING(craplem.nrdconta,
                                         "zz,zzz,zzz,z")) + 
                " Doc: " + STRING(craplem.nrdocmto) +
                " Valor: " + TRIM(STRING(craplem.vllanmto,
                                         "zzzzzz,zzz,zz9.99")) +
                " Lote: " + TRIM(STRING(craplem.nrdolote,"zzz,zz9")) + 
                " PA: " + STRING(craplem.cdagenci,"999") + 
                " Banco/Caixa: " + STRING(craplem.cdbccxlt,"999") + 
                " >> log/lanemp.log").


END PROCEDURE.


/* .......................................................................... */
