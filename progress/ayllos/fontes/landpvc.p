/* .............................................................................

   Programa: Fontes/landpvc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/91.                     Ultima atualizacao: 13/11/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela LANDPV.

   Alteracoes: 13/06/94 - Alterado para ler a tabela com as contas convenio do
                          Banco do Brasil (Edson).

               29/09/94 - Alterado layout de tela e inclusao no campo Alinea
                          (Deborah/Edson).

               25/10/94 - Alterado para tratar o historico 78, do mesmo modo que
                          o 47 (Deborah).

               24/01/97 - Alterado para tratar o historico 191 da mesma forma
                          que o 47 (Deborah).

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).

             08/05/2001 - Tratamento da Compensacao Eletronica (Margarete).
               
             06/09/2001 - Incluir historico 386 (Margarete).
             
             26/09/2002 - Tratar os historicos 351, 024 e 027 para mostrar
                          o cdpesqbb. (Ze Eduardo).

             19/03/2003 - Incluir tratamento da Concredi (Margarete).

             07/04/2003 - Incluir tratamento do histor 399 (Margarete).
             
             27/06/2003 - Incluir 156 na descricao do historico (Ze).
             
             27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

             13/04/2007 - Aumentar campo nrdocmto (Magui)
             
             13/11/2014 - Removido display do campo tel_nrseqdig no frame 
                          f_landpv.
                          Motivo: Foi necessario voltar o tamanho do campo
                          de valor (tel_vllanmto) para o seu tamanho original.
                          (Chamado 175752) - (Fabricio)
............................................................................. */

{ includes/var_online.i }
{ includes/var_landpv.i }

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_nrdctabb tel_nrdocmto WITH FRAME f_landpv.

      ASSIGN glb_nrcalcul = tel_nrdctabb
             aux_nrdctabb = tel_nrdctabb
             aux_nrdocmto = tel_nrdocmto
             glb_cdcritic = 0.

      IF   tel_nrdctabb = 0  THEN
           LEAVE.

      RUN fontes/digfun.p.
      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdctabb WITH FRAME f_landpv.
           END.
      ELSE
           IF   tel_nrdocmto = 0   THEN
                DO:
                    glb_cdcritic = 22.
                    NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                END.
           ELSE
                DO:
                    IF   NOT CAN-DO(aux_lscontas,STRING(tel_nrdctabb))   THEN
                         DO:
                             FIND crapass WHERE
                                  crapass.cdcooper = glb_cdcooper   AND
                                  crapass.nrdconta = tel_nrdctabb
                                  NO-LOCK NO-ERROR.

                             IF   NOT AVAILABLE crapass   THEN
                                  DO:
                                      glb_cdcritic = 9.
                                      NEXT-PROMPT tel_nrdctabb
                                                  WITH FRAME f_landpv.
                                  END.
                         END.
                END.

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_landpv.
               ASSIGN glb_cddopcao = aux_cddopcao
                      tel_dtmvtolt = aux_dtmvtolt
                      tel_cdagenci = aux_cdagenci
                      tel_cdbccxlt = aux_cdbccxlt
                      tel_nrdolote = aux_nrdolote
                      tel_nrdctabb = aux_nrdctabb
                      tel_nrdocmto = aux_nrdocmto.
                      
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_nrdctabb
                       tel_nrdocmto WITH FRAME f_landpv.
                       
               MESSAGE glb_dscritic.
               NEXT.
           END.

      LEAVE.

   END.

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
        IF   craplot.tplotmov <> 1   THEN
             glb_cdcritic = 100.

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_landpv NO-PAUSE.
            ASSIGN glb_cddopcao = aux_cddopcao
                   tel_dtmvtolt = aux_dtmvtolt
                   tel_cdagenci = aux_cdagenci
                   tel_cdbccxlt = aux_cdbccxlt
                   tel_nrdolote = aux_nrdolote
                   tel_nrdctabb = aux_nrdctabb
                   tel_nrdocmto = aux_nrdocmto.
                   
            DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                    tel_cdbccxlt tel_nrdolote tel_nrdctabb
                    tel_nrdocmto WITH FRAME f_landpv.
                    
            MESSAGE glb_dscritic.
            NEXT.
        END.

   ASSIGN tel_qtinfoln = craplot.qtinfoln
          aux_qtinfoln = tel_qtinfoln
          tel_qtcompln = craplot.qtcompln
          aux_qtcompln = tel_qtcompln
          tel_vlinfodb = craplot.vlinfodb
          aux_vlinfodb = tel_vlinfodb
          tel_vlcompdb = craplot.vlcompdb
          aux_vlcompdb = tel_vlcompdb
          tel_vlinfocr = craplot.vlinfocr
          aux_vlinfocr = tel_vlinfocr
          tel_vlcompcr = craplot.vlcompcr
          aux_vlcompcr = tel_vlcompcr
          tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
          aux_qtdifeln = tel_qtdifeln
          tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
          aux_vldifedb = tel_vldifedb
          tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
          aux_vldifecr = tel_vldifecr.

   IF   tel_nrdctabb = 0   THEN
        DO:
            ASSIGN aux_flgerros = FALSE
                   aux_flgretor = FALSE
                   aux_regexist = FALSE
                   aux_contador = 0.

            /* SUBSTITUICAO AO PUT SCREEN */
            CLEAR FRAME f_landpv.
            HIDE FRAME f_regant.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            /***********/

            DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                    tel_cdbccxlt tel_nrdolote
                    tel_qtinfoln tel_vlinfodb tel_vlinfocr
                    tel_qtcompln tel_vlcompdb tel_vlcompcr
                    tel_qtdifeln tel_vldifedb tel_vldifecr
                    WITH FRAME f_landpv.
            /*********
            PUT SCREEN ROW 14 COLUMN 4 FILL(" ",74).
            HIDE FRAME f_regant.

            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            **********/

            FIND FIRST crapchd WHERE crapchd.cdcooper = glb_cdcooper   AND
                                     crapchd.dtmvtolt = tel_dtmvtolt   AND
                                     crapchd.cdagenci = tel_cdagenci   AND
                                     crapchd.cdbccxlt = tel_cdbccxlt   AND
                                     crapchd.nrdolote = tel_nrdolote   
                                     USE-INDEX crapchd3 NO-LOCK NO-ERROR.

            IF   AVAILABLE crapchd   THEN
                 DO:
                     aux_confirma = "N".
            
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                        MESSAGE COLOR NORMAL 
                                "Listar os cheques vinculados a depositos?"
                                "(S/N):" UPDATE aux_confirma.
                                    
                        LEAVE.
            
                     END.  /*  Fim do DO WHILE TRUE  */
            
                     IF   aux_confirma = "S"   THEN
                          DO:
                              RUN proc_lista.
                     
                              NEXT.
                          END.
                 END.
                 
            FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper   AND
                                   craplcm.dtmvtolt = tel_dtmvtolt   AND
                                   craplcm.cdagenci = tel_cdagenci   AND
                                   craplcm.cdbccxlt = tel_cdbccxlt   AND
                                   craplcm.nrdolote = tel_nrdolote   NO-LOCK
                                   USE-INDEX craplcm3:

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

                IF   LOOKUP(STRING(craplcm.cdhistor),"2,3,4,6") <> 0   THEN
                     DO:
                         FIND crapdpb WHERE
                              crapdpb.cdcooper = glb_cdcooper       AND
                              crapdpb.dtmvtolt = craplcm.dtmvtolt   AND
                              crapdpb.cdagenci = craplcm.cdagenci   AND
                              crapdpb.cdbccxlt = craplcm.cdbccxlt   AND
                              crapdpb.nrdolote = craplcm.nrdolote   AND
                              crapdpb.nrdconta = craplcm.nrdconta   AND
                              crapdpb.nrdocmto = craplcm.nrdocmto   NO-LOCK
                              USE-INDEX crapdpb1 NO-ERROR.

                         IF   NOT AVAILABLE crapdpb   THEN
                              DO:
                                  glb_cdcritic = 82.
                                  aux_flgerros = TRUE.
                                  LEAVE.
                              END.

                         tel_dtliblan = crapdpb.dtliblan.
                     END.
                ELSE
                     tel_dtliblan = ?.

                tel_cdalinea = IF  CAN-DO("24,27,47,78,156,191,351,399",
                                          STRING(craplcm.cdhistor))
                                  THEN INTEGER(craplcm.cdpesqbb)
                                  ELSE 0.

                PAUSE (0).

                DISPLAY craplcm.cdhistor craplcm.nrdctabb craplcm.nrdocmto
                        craplcm.vllanmto tel_dtliblan     tel_cdalinea
                        craplcm.cdbanchq craplcm.cdagechq
                        WITH FRAME f_lanctos.

                IF   aux_contador = 6   THEN
                     aux_contador = 0.
                ELSE
                     DOWN WITH FRAME f_lanctos.
            END.

            IF   NOT aux_regexist   THEN
                 glb_cdcritic = 11.

            IF   glb_cdcritic > 0 THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     CLEAR FRAME f_landpv NO-PAUSE.
                     ASSIGN glb_cddopcao = aux_cddopcao
                            tel_dtmvtolt = aux_dtmvtolt
                            tel_cdagenci = aux_cdagenci
                            tel_cdbccxlt = aux_cdbccxlt
                            tel_nrdolote = aux_nrdolote
                            tel_nrdctabb = aux_nrdctabb
                            tel_nrdocmto = aux_nrdocmto.
                            
                     DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                             tel_cdbccxlt tel_nrdolote tel_nrdctabb
                             tel_nrdocmto WITH FRAME f_landpv.
                             
                     MESSAGE glb_dscritic.
                     NEXT.
                 END.
            NEXT.
        END.

   FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper   AND
                      craplcm.dtmvtolt = tel_dtmvtolt   AND
                      craplcm.cdagenci = tel_cdagenci   AND
                      craplcm.cdbccxlt = tel_cdbccxlt   AND
                      craplcm.nrdolote = tel_nrdolote   AND
                      craplcm.nrdctabb = tel_nrdctabb   AND
                      craplcm.nrdocmto = tel_nrdocmto   NO-LOCK
                      USE-INDEX craplcm1 NO-ERROR.     

   IF   NOT AVAILABLE craplcm   THEN
        glb_cdcritic = 90.
   ELSE
        DO:
            ASSIGN tel_cdhistor = craplcm.cdhistor
                   tel_vllanmto = craplcm.vllanmto
                   tel_cdalinea = IF  CAN-DO("24,27,47,78,156,191,351,399",
                                      STRING(craplcm.cdhistor))
                                  THEN INTEGER(craplcm.cdpesqbb)
                                  ELSE 0.

            IF   LOOKUP(STRING(craplcm.cdhistor),"2,3,4,6") <> 0   THEN
                 DO:
                     FIND crapdpb WHERE crapdpb.cdcooper = glb_cdcooper     AND
                                        crapdpb.dtmvtolt = tel_dtmvtolt     AND
                                        crapdpb.cdagenci = tel_cdagenci     AND
                                        crapdpb.cdbccxlt = tel_cdbccxlt     AND
                                        crapdpb.nrdolote = tel_nrdolote     AND
                                        crapdpb.nrdconta = craplcm.nrdconta AND
                                        crapdpb.nrdocmto = tel_nrdocmto
                                        USE-INDEX crapdpb1 NO-LOCK NO-ERROR.

                     IF   NOT AVAILABLE crapdpb   THEN
                          glb_cdcritic = 82.
                     ELSE
                          tel_dtliblan = crapdpb.dtliblan.
                 END.
            ELSE
                 tel_dtliblan = ?.
        END.

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_landpv.
            ASSIGN glb_cddopcao = aux_cddopcao
                   tel_dtmvtolt = aux_dtmvtolt
                   tel_cdagenci = aux_cdagenci
                   tel_cdbccxlt = aux_cdbccxlt
                   tel_nrdolote = aux_nrdolote
                   tel_nrdctabb = aux_nrdctabb
                   tel_nrdocmto = aux_nrdocmto.
            DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                    tel_cdbccxlt tel_nrdolote tel_nrdctabb
                    tel_nrdocmto WITH FRAME f_landpv.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_cdhistor tel_nrdctabb tel_nrdocmto
           tel_vllanmto tel_dtliblan tel_cdalinea
           WITH FRAME f_landpv.

   /*** Tratamento da Compensacao Eletronica ***/
   
   IF   craplcm.cdhistor = 3   OR
        craplcm.cdhistor = 4   OR
        craplcm.cdhistor = 372 OR 
        craplcm.cdhistor = 386 THEN
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
           HIDE MESSAGE NO-PAUSE.
           PAUSE(0).
           
           OPEN QUERY bcrapchd-q 
                FOR EACH  crapchd WHERE crapchd.cdcooper = glb_cdcooper     AND
                                        crapchd.dtmvtolt = craplcm.dtmvtolt AND
                                        crapchd.cdagenci = craplcm.cdagenci AND
                                        crapchd.cdbccxlt = craplcm.cdbccxlt AND
                                        crapchd.nrdolote = craplcm.nrdolote AND
                                        crapchd.nrseqdig = craplcm.nrseqdig
                                        USE-INDEX crapchd3 NO-LOCK.
                                        
           ENABLE bcrapchd-b WITH FRAME f_consulta_compel.

           WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
              
        END.
   CLEAR FRAME f_consulta_compel ALL.
   HIDE FRAME f_consulta_compel NO-PAUSE.
   
   /********************************************/
END.

/* .......................................................................... */

PROCEDURE proc_lista:
    
    FORM crapchd.nrdconta FORMAT "zzzz,zzz,9"         LABEL "Conta Dep."
         crapchd.cdcmpchq FORMAT "zz9"                LABEL "Cmp"
         crapchd.cdbanchq FORMAT "zz9"                LABEL "Bco"
         crapchd.cdagechq FORMAT "zzz9"               LABEL "Ag."
         crapchd.nrddigc1 FORMAT "9"                  LABEL "C1"
         crapchd.nrctachq FORMAT "zzz,zzz,zzz,9"      LABEL "Conta"
         crapchd.nrddigc2 FORMAT "9"                  LABEL "C2"
         crapchd.nrcheque FORMAT "zzz,zz9"            LABEL "Cheque"
         crapchd.nrddigc3 FORMAT "9"                  LABEL "C3"
         crapchd.vlcheque FORMAT "zzz,zzz,zz9.99"     LABEL "Valor"
         crapchd.nrseqdig FORMAT "zz,zz9"             LABEL "Seq." 
         WITH ROW 8 COLUMN 3 OVERLAY NO-LABEL NO-BOX 11 DOWN FRAME f_lcompel.

    CLEAR FRAME f_lcompel ALL NO-PAUSE.

    ASSIGN aux_contador = 0
           aux_flgretor = FALSE
           aux_regexist = FALSE.
 
    FOR EACH crapchd WHERE crapchd.cdcooper = glb_cdcooper   AND
                           crapchd.dtmvtolt = tel_dtmvtolt   AND
                           crapchd.cdagenci = tel_cdagenci   AND
                           crapchd.cdbccxlt = tel_cdbccxlt   AND
                           crapchd.nrdolote = tel_nrdolote   NO-LOCK
                           USE-INDEX crapchd3 BY crapchd.nrseqdig:

        ASSIGN aux_regexist = TRUE
               aux_contador = aux_contador + 1.

        IF   aux_contador = 1   THEN
             IF   aux_flgretor   THEN
                  DO:
                      PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                      CLEAR FRAME f_lcompel ALL NO-PAUSE.
                  END.
             ELSE
                  aux_flgretor = TRUE.

        PAUSE (0).

        DISPLAY crapchd.cdcmpchq  crapchd.cdbanchq 
                crapchd.cdagechq  crapchd.nrddigc1
                crapchd.nrctachq  crapchd.nrddigc2
                crapchd.nrcheque  crapchd.nrddigc3
                crapchd.vlcheque  crapchd.nrseqdig
                crapchd.nrdconta
                WITH FRAME f_lcompel.

        IF   aux_contador = 11   THEN
             aux_contador = 0.
        ELSE
             DOWN WITH FRAME f_lcompel.

    END.  /*  Fim do FOR EACH  */

    IF   aux_regexist   AND
         KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN     
         PAUSE MESSAGE "Tecle <Entra> para encerrar".

    HIDE FRAME f_lcompel NO-PAUSE.

END PROCEDURE.

/* .......................................................................... */
