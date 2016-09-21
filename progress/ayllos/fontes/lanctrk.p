/* .............................................................................

   Programa: Fontes/lanctrk.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Daniel
   Data    : Abril/2010.                    Ultima atualizacao:  /  /

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela lanctr com datas anteriores.

   Alteracoes: 
............................................................................. */

{ includes/var_online.i }
{ includes/var_lanctr.i }

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

DO WHILE TRUE:

   RUN fontes/inicia.p.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lanctr.
               CLEAR FRAME f_lanctos ALL NO-PAUSE.
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote
                       WITH FRAME f_lanctr.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_nrdconta tel_nrctremp WITH FRAME f_lanctr.

      ASSIGN glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0.

      IF   tel_nrdconta = 0   THEN
           LEAVE.

      RUN fontes/digfun.p.

      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lanctr.
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

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                      craplot.dtmvtolt = tel_dtmvtolt   AND
                      craplot.cdagenci = tel_cdagenci   AND
                      craplot.cdbccxlt = tel_cdbccxlt   AND
                      craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.

   
    
   IF   NOT AVAILABLE craplot   THEN
        glb_cdcritic = 60.
   ELSE
        IF   craplot.tplotmov <> 4   THEN
             glb_cdcritic = 213.

   IF   glb_cdcritic > 0 THEN
        NEXT.

   ASSIGN tel_qtinfoln = craplot.qtinfoln
          tel_qtcompln = craplot.qtcompln
          tel_vlinfodb = craplot.vlinfodb
          tel_vlcompdb = craplot.vlcompdb
          tel_vlinfocr = craplot.vlinfocr
          tel_vlcompcr = craplot.vlcompcr
          tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
          tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
          tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

   IF   tel_nrdconta = 0   THEN
        DO:
            ASSIGN aux_flgerros = FALSE
                   aux_flgretor = FALSE
                   aux_regexist = FALSE
                   aux_contador = 0.

            CLEAR FRAME f_lanctr.
            HIDE FRAME f_regant.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.

            DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                    tel_cdbccxlt tel_nrdolote
                    tel_qtinfoln tel_vlinfodb tel_vlinfocr
                    tel_qtcompln tel_vlcompdb tel_vlcompcr
                    tel_qtdifeln tel_vldifedb tel_vldifecr
                    WITH FRAME f_lanctr.

            FOR EACH craplem WHERE craplem.cdcooper = glb_cdcooper   AND
                                   craplem.dtmvtolt = tel_dtmvtolt   AND
                                   craplem.cdagenci = tel_cdagenci   AND
                                   craplem.cdbccxlt = tel_cdbccxlt   AND
                                   craplem.nrdolote = tel_nrdolote
                                   NO-LOCK USE-INDEX craplem3:

                
                FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper       AND 
                                   crapepr.nrdconta = craplem.nrdconta   AND
                                   crapepr.nrctremp = craplem.nrctremp
                                   USE-INDEX crapepr2 NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE crapepr   THEN
                     DO:
                         glb_cdcritic = 356.
                         LEAVE.
                     END.

                ASSIGN aux_regexist = TRUE
                       aux_contador = aux_contador + 1.

                IF   aux_contador = 1   THEN
                     IF   aux_flgretor   THEN
                          DO:
                              PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                              CLEAR FRAME f_lanctos ALL NO-PAUSE.
                          END.
                     ELSE
                          aux_flgretor = TRUE.

                PAUSE (0).

                DISPLAY crapepr.nrdconta crapepr.nrctremp crapepr.cdfinemp
                        crapepr.cdlcremp crapepr.vlemprst crapepr.vlpreemp
                        WITH FRAME f_lanctos.

                IF   aux_contador = 3   THEN
                     aux_contador = 0.
                ELSE
                     DOWN WITH FRAME f_lanctos.

            END.  /*  Fim do FOR EACH  */

            IF   NOT aux_regexist   THEN
                 glb_cdcritic = 11.

            NEXT.
        END.

  

   FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper   AND
                      crapepr.dtmvtolt = tel_dtmvtolt   AND
                      crapepr.cdagenci = tel_cdagenci   AND
                      crapepr.cdbccxlt = tel_cdbccxlt   AND
                      crapepr.nrdolote = tel_nrdolote   AND
                      crapepr.nrdconta = tel_nrdconta   AND
                      crapepr.nrctremp = tel_nrctremp
                      USE-INDEX crapepr1 NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapepr   THEN
        DO:
            glb_cdcritic = 356.
            NEXT.
        END.

   FIND craplem WHERE craplem.cdcooper = glb_cdcooper   AND 
                      craplem.dtmvtolt = tel_dtmvtolt   AND
                      craplem.cdagenci = tel_cdagenci   AND
                      craplem.cdbccxlt = tel_cdbccxlt   AND
                      craplem.nrdolote = tel_nrdolote   AND
                      craplem.nrdconta = tel_nrdconta   AND
                      craplem.nrdocmto = tel_nrctremp
                      USE-INDEX craplem1 NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craplem   THEN
        DO:
            glb_cdcritic = 357.
            NEXT.
        END.

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

   HIDE FRAME f_lanctos NO-PAUSE.

END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
