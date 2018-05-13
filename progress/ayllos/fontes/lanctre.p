/* .............................................................................

   Programa: Fontes/lanctre.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 30/04/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela lanctr.

   Alteracoes: 01/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               09/11/98 - Tratar situacao em prejuizo (Deborah).

             24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                          titular (Eduardo).

             13/11/2003 - Incluido campo Nivel de Risco(Mirtes).

             21/06/2004 - Acessar Tabela Avalistas Terceiros(Mirtes)
             
             30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
              
             22/06/2009 - Excluir o crapsab quando o emprestimo for atrelado
                          a emissao de boletos (Fernando).
                          
             03/12/2009 - Voltar atras Rating quando excluir a operacao
                          (Gabriel)               
                          
             02/03/2012 - Adicionado critica para o novo tipo de contrato
                          b1wgen0134.p (Tiago).      
                          
             30/04/2015 - Criar a crapavl ja na proposta. Aqui nao e' mais
                          necessario deletar a mesma (Gabriel-RKAM).                    
............................................................................. */

{ includes/var_online.i }
{ includes/var_lanctr.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0043 AS HANDLE               NO-UNDO.
DEF VAR h-b1wgen0134 AS HANDLE               NO-UNDO.

ASSIGN tel_nrdconta = 0
       tel_nrctremp = 0
       tel_cdfinemp = 0
       tel_cdlcremp = 0
       tel_nivrisco = " "
       tel_vlemprst = 0
       tel_vlpreemp = 0
       tel_qtpreemp = 0
       tel_nrctaav1 = 0
       tel_nrctaav2 = 0
       tel_nrseqdig = 1                                                        
       tel_avalist1 = " "
       tel_avalist2 = " ".

EXCLUSAO:
DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lanctr.
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote
                       WITH FRAME f_lanctr.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_nrdconta tel_nrctremp WITH FRAME f_lanctr.

      ASSIGN glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0.

      RUN fontes/digfun.p.

      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanctr.
               NEXT.
           END.

      RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

      RUN valida_empr_tipo1 IN h-b1wgen0134
                               (INPUT glb_cdcooper,
                                INPUT tel_cdagenci,
                                INPUT 0,
                                INPUT tel_nrdconta,
                                INPUT tel_nrctremp,
                                OUTPUT TABLE tt-erro). 

      DELETE PROCEDURE h-b1wgen0134.   

      IF  RETURN-VALUE = "OK" THEN
          DO:
              glb_cdcritic = 946.
              NEXT-PROMPT tel_nrctremp WITH FRAME f_lanctr.
              NEXT.
          END.

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                         crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapass   THEN
           DO:
               glb_cdcritic = 9.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanctr.
               NEXT.
           END.

      IF   crapass.inpessoa = 1   THEN
           DO:
               FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper     AND
                                  crapttl.nrdconta = crapass.nrdconta AND
                                  crapttl.idseqttl = 1  NO-LOCK NO-ERROR.
                                  
               IF   AVAILABLE crapttl   THEN
                    ASSIGN aux_nrinssac = crapttl.nrcpfcgc.
           END.
      ELSE
           ASSIGN aux_nrinssac = crapass.nrcpfcgc. 
      
      IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
           DO:
               glb_cdcritic = 695.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanctr.
               NEXT.
           END.
      
      IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
           DO:
               glb_cdcritic = 95.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanctr.
               NEXT.
           END.

      IF   tel_nrctremp = 0   THEN
           DO:
               glb_cdcritic = 361.
               NEXT-PROMPT tel_nrctremp WITH FRAME f_lanctr.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        RETURN.  /* Volta pedir a opcao para o operador */

   DO TRANSACTION ON ENDKEY UNDO, LEAVE:

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

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic = 0   THEN
           DO:
               IF   craplot.tplotmov <> 4   THEN
                    DO:
                        glb_cdcritic = 213.
                        NEXT.
                    END.
           END.
      ELSE
           NEXT.

      ASSIGN tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      /* Verifica quantidade de emprestimos com emissao de boletos */
      FOR EACH crapepr WHERE crapepr.cdcooper = glb_cdcooper AND
                             crapepr.nrdconta = tel_nrdconta AND
                             crapepr.cdlcremp = tab_cdlcrbol NO-LOCK:

          ASSIGN aux_qtempres = aux_qtempres + 1.                 
      END. /* Fim do FOR EACH */
      
      DO aux_contador = 1 TO 10:

         FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper   AND 
                            crapepr.dtmvtolt = tel_dtmvtolt   AND
                            crapepr.cdagenci = tel_cdagenci   AND
                            crapepr.cdbccxlt = tel_cdbccxlt   AND
                            crapepr.nrdolote = tel_nrdolote   AND
                            crapepr.nrdconta = tel_nrdconta   AND
                            crapepr.nrctremp = tel_nrctremp
                            USE-INDEX crapepr1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE crapepr   THEN
              IF   LOCKED crapepr   THEN
                   DO:
                       glb_cdcritic = 114.
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   DO:
                       glb_cdcritic = 356.
                       NEXT-PROMPT tel_nrctremp WITH FRAME f_lanctr.
                   END.
         ELSE
              DO:
                  FIND FIRST craplem WHERE
                             craplem.cdcooper = glb_cdcooper      AND 
                             craplem.nrdconta = crapepr.nrdconta  AND
                             craplem.nrctremp = crapepr.nrctremp  AND
                             craplem.dtmvtolt = crapepr.dtmvtolt  AND
                             craplem.cdhistor <> 99
                             NO-LOCK NO-ERROR.

                  IF   AVAILABLE craplem   THEN
                       glb_cdcritic = 368.
                  ELSE
                       glb_cdcritic = 0.
              END.

         LEAVE.

      END.  /*  Fim do DO .. TO  */

      IF   glb_cdcritic > 0   THEN
           NEXT.

      DO WHILE TRUE:

         FIND craplem WHERE craplem.cdcooper = glb_cdcooper   AND 
                            craplem.dtmvtolt = tel_dtmvtolt   AND
                            craplem.cdagenci = tel_cdagenci   AND
                            craplem.cdbccxlt = tel_cdbccxlt   AND
                            craplem.nrdolote = tel_nrdolote   AND
                            craplem.nrdconta = tel_nrdconta   AND
                            craplem.nrdocmto = tel_nrctremp
                            USE-INDEX craplem1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craplem   THEN
              IF   LOCKED craplem   THEN
                   DO:
                       PAUSE 2 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   glb_cdcritic = 90.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic > 0    THEN
           NEXT.

     FIND crawepr WHERE crawepr.cdcooper = glb_cdcooper AND 
                        crawepr.nrdconta = tel_nrdconta AND
                        crawepr.nrctremp = tel_nrctremp NO-LOCK NO-ERROR.
                        
     IF  AVAIL crawepr THEN
         ASSIGN tel_nivrisco = crawepr.dsnivris.

      ASSIGN tel_cdfinemp = crapepr.cdfinemp
             tel_cdlcremp = crapepr.cdlcremp
             tel_vlemprst = crapepr.vlemprst
             tel_vlpreemp = crapepr.vlpreemp
             tel_qtpreemp = crapepr.qtpreemp
             tel_nrctaav1 = crapepr.nrctaav1
             tel_nrctaav2 = crapepr.nrctaav2
             tel_flgpagto = crapepr.flgpagto
             tel_dtdpagto = crapepr.dtdpagto
             tel_nrseqdig = craplem.nrseqdig.

      ASSIGN tel_avalist1 = " "
             tel_avalist2 = " ".
                       
      IF  AVAIL crawepr THEN    /* Novos Contratos */
          DO:
              FOR EACH crapavt WHERE  
                       crapavt.cdcooper = glb_cdcooper     AND 
                       crapavt.tpctrato = 1                AND /* Emprestimo */
                       crapavt.nrdconta = crawepr.nrdconta AND
                       crapavt.nrctremp = crawepr.nrctremp NO-LOCK:

                  IF  crawepr.nrctaav1 = 0 AND 
                      tel_avalist1     = " " THEN
                      tel_avalist1   = "CPF " + STRING(crapavt.nrcpfcgc).
                  ELSE  
                  IF  crawepr.nrctaav2 = 0 AND
                      tel_avalist2     = " " THEN
                      tel_avalist2   = "CPF " + STRING(crapavt.nrcpfcgc).
               END.         
          
               IF  tel_avalist1     = " " AND
                   tel_nrctaav1     = 0   THEN
                   ASSIGN tel_avalist1 = crawepr.dscpfav1.
               
               IF  tel_avalist2     = " " AND
                   tel_nrctaav2     = 0   THEN
                   ASSIGN tel_avalist2 = crawepr.dscpfav2.
          END.     

      DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
              tel_qtcompln tel_vlcompdb tel_vlcompcr
              tel_qtdifeln tel_vldifedb tel_vldifecr
              tel_cdfinemp tel_cdlcremp
              tel_nivrisco 
              tel_vlemprst
              tel_vlpreemp tel_qtpreemp tel_flgpagto
              tel_dtdpagto tel_nrctaav1 tel_nrctaav2
              tel_nrseqdig
              tel_avalist1
              tel_avalist2
              WITH FRAME f_lanctr.

      RUN fontes/confirma.p (INPUT  "",
                             OUTPUT aux_confirma).

      IF   aux_confirma <> "S"   THEN
           NEXT.

      /* Caso o emprestimo for atrelado a boletos, excluir crapsab */
      IF   tel_cdlcremp = tab_cdlcrbol   THEN
           DO: 
              /* Se ter 2 ou mais emprestimos com emissao de boletos para 
                 a mesma conta, nao excluir o crapsab */
              IF   aux_qtempres < 2   THEN
                   DO:
                      EMPTY TEMP-TABLE cratsab.

                      CREATE cratsab.
                      ASSIGN cratsab.cdcooper = glb_cdcooper
                             cratsab.nrdconta = tab_nrctabol
                             cratsab.nrinssac = aux_nrinssac.
                     
                      RUN sistema/generico/procedures/b1crapsab.p PERSISTENT
                          SET h-b1crapsab.
                                      
                      IF  VALID-HANDLE(h-b1crapsab)  THEN
                          DO:
                              ASSIGN glb_dscritic = "".
                                      
                              RUN exclui_sacado IN h-b1crapsab 
                                                  (INPUT TABLE cratsab,
                                                   OUTPUT glb_dscritic).
                          END.

                      DELETE PROCEDURE h-b1crapsab.
              
                      IF  glb_dscritic <> ""  THEN
                          DO:
                             MESSAGE glb_dscritic.
                             PAUSE 3 NO-MESSAGE.
                             UNDO, RETURN.
                          END.
                   END.

                   ASSIGN aux_nrinssac = 0
                          aux_qtempres = 0.
           END.

      
      ASSIGN craplot.vlcompdb = craplot.vlcompdb - crapepr.vlemprst
             craplot.qtcompln = craplot.qtcompln - 1

             tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      DELETE crapepr.
      DELETE craplem.

      RUN sistema/generico/procedures/b1wgen0043.p 
                                PERSISTEN SET h-b1wgen0043.

      RUN volta-atras-rating IN h-b1wgen0043 (INPUT  glb_cdcooper,
                                              INPUT  0,
                                              INPUT  0,
                                              INPUT  glb_cdoperad,
                                              INPUT  glb_dtmvtolt,
                                              INPUT  glb_dtmvtopr,
                                              INPUT  tel_nrdconta,
                                              INPUT  90, /* Emprestimo */
                                              INPUT  tel_nrctremp,
                                              INPUT  1,
                                              INPUT  1,
                                              INPUT  glb_nmdatela,
                                              INPUT  glb_inproces,
                                              INPUT  FALSE,
                                              OUTPUT TABLE tt-erro).
      DELETE PROCEDURE h-b1wgen0043.

      IF   RETURN-VALUE <> "OK"   THEN
           DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.
              
               IF   AVAILABLE tt-erro   THEN
                    DO:
                        MESSAGE tt-erro.dscritic.
                        PAUSE 3 NO-MESSAGE.
                        UNDO, NEXT EXCLUSAO.
                    END.

           END.

      ASSIGN tel_nrdconta = 0
             tel_nrctremp = 0
             tel_cdfinemp = 0
             tel_cdlcremp = 0
             tel_vlemprst = 0
             tel_vlpreemp = 0
             tel_qtpreemp = 0
             tel_nrctaav1 = 0
             tel_nrctaav2 = 0
             tel_avalist1 = " "
             tel_avalist2 = " ".

   END.   /* Fim da transacao */

   RELEASE craplot.

   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  AND  tel_vldifecr = 0   THEN
        DO:
            glb_nmdatela = "LOTE".
            RETURN.                        /* Volta ao lanctr.p */
        END.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_nrdconta tel_nrctremp tel_cdfinemp
           tel_cdlcremp
           tel_nivrisco 
           tel_vlemprst tel_vlpreemp
           tel_qtpreemp tel_nrctaav1 tel_nrctaav2
           tel_nrseqdig
           tel_avalist1
           tel_avalist2
           WITH FRAME f_lanctr.

   HIDE FRAME f_lanctos.

END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

