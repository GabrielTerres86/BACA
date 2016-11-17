/* .............................................................................

   Programa: Fontes/lantitc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                         Ultima atualizacao: 01/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela LANTIT.

   Alteracoes: 05/01/2001 - Tratar tipo de lote 21 (Deborah).

               08/01/2001 - Efetivar o convenio de arrecadacao de IPTU 
                            Blumenau no sistema. (Eduardo).

               30/03/2001 - Substituir o nome ciptu.p por verbar3.p.
                            (Eduardo)
                            
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
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

BARRA:

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0
                   tel_nrdconta = 0
                   tel_cdhistor = 0
                   tel_nmprimtl = ""
                   tel_dscodbar = ""
                   tel_dsdlinha = ""
                   tel_vldpagto = 0
                   tel_nrseqdig = 0
                   tel_reganter = "".

            DISPLAY tel_nrdconta tel_nmprimtl tel_dscodbar tel_dsdlinha 
                    tel_vldpagto tel_nrseqdig tel_cdhistor 
                    tel_nmprimtl tel_nrdconta WITH FRAME f_lantit.

            HIDE FRAME f_regant NO-PAUSE.
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
            aux_confirma = "S".
           
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               MESSAGE COLOR NORMAL "Listar o lote? (S/N):" UPDATE aux_confirma.

               LEAVE.
               
            END.  /*  Fim do DO WHILE TRUE  */

            IF   aux_confirma = "S"   THEN
                 DO:
                     RUN proc_lista.
                     tel_dscodbar = "".
                     NEXT.
                 END.
            
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

   DO WHILE TRUE:    

      FIND craptit WHERE craptit.cdcooper = glb_cdcooper   AND
                         craptit.dtmvtolt = tel_dtmvtolt   AND
                         craptit.cdagenci = tel_cdagenci   AND
                         craptit.cdbccxlt = tel_cdbccxlt   AND
                         craptit.nrdolote = tel_nrdolote   AND
                         craptit.dscodbar = tel_dscodbar   NO-LOCK NO-ERROR.
                           
      IF   NOT AVAILABLE craptit   THEN
           DO:
               glb_cdcritic = 90.
               LEAVE.
           END.

      FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                         craplot.dtmvtolt = tel_dtmvtolt   AND
                         craplot.cdagenci = tel_cdagenci   AND
                         craplot.cdbccxlt = tel_cdbccxlt   AND
                         craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE craplot   THEN
           glb_cdcritic = 60.
      ELSE
           DO:   
               IF   NOT CAN-DO("20,21",STRING(craplot.tplotmov,"99")) THEN
                    glb_cdcritic = 100.
           END.
                   
      IF   glb_cdcritic > 0   THEN
           LEAVE.

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

               FIND craplau WHERE craplau.cdcooper = glb_cdcooper       AND
                                  craplau.dtmvtolt = craptit.dtmvtolt   AND
                                  craplau.cdagenci = craptit.cdagenci   AND
                                  craplau.cdbccxlt = craptit.cdbccxlt   AND
                                  craplau.nrdolote = craptit.nrdolote   AND
                                  craplau.nrdctabb = craptit.nrdconta   AND
                                  craplau.nrdocmto = craptit.nrdocmto   
                                  NO-LOCK NO-ERROR.
                                  
               IF   NOT AVAILABLE craplau   THEN
                    DO:
                        glb_cdcritic = 679.
                        LEAVE.
                    END.

               tel_cdhistor = craplau.cdhistor.
           END.
      ELSE
           ASSIGN tel_nrdconta = 0
                  tel_cdhistor = 0
                  tel_nmprimtl = "".
                    
      ASSIGN tel_vldpagto = craptit.vldpagto
             tel_nrseqdig = craptit.nrseqdig
             tel_dscodbar = "".
      
      DISPLAY tel_cdhistor tel_nrdconta tel_nmprimtl WITH FRAME f_lantit.
 
      ASSIGN tel_dtdpagto = craplot.dtmvtopg
             tel_vlcompdb = craplot.vlcompdb
             tel_vlcompcr = craplot.vlcompcr
             tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb
             tel_vlinfocr = craplot.vlinfocr
             tel_qtinfoln = craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln.

      LEAVE.
        
   END.  /*  Fim do DO WHILE TRUE e da transacao  */

   IF   glb_cdcritic > 0   THEN
        NEXT.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_dsdlinha tel_vldpagto tel_nrseqdig
           tel_dscodbar tel_dtdpagto
           WITH FRAME f_lantit.

   HIDE FRAME f_lanctos.

END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

{ includes/proc_lantit.i }

PROCEDURE proc_lista:

    CLEAR FRAME f_lanctos ALL NO-PAUSE.

    ASSIGN aux_contador = 0
           aux_flgretor = FALSE
           aux_regexist = FALSE.
 
    FOR EACH craptit WHERE craptit.cdcooper = glb_cdcooper   AND
                           craptit.dtmvtolt = tel_dtmvtolt   AND
                           craptit.cdagenci = tel_cdagenci   AND
                           craptit.cdbccxlt = tel_cdbccxlt   AND
                           craptit.nrdolote = tel_nrdolote   
                           USE-INDEX craptit2 NO-LOCK:

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
        
        tel_dscodbar = craptit.dscodbar.

        RUN mostra_dados.

        DISPLAY tel_dsdlinha
                craptit.vldpagto 
                craptit.nrseqdig
                WITH FRAME f_lanctos.

        IF   aux_contador = 11   THEN
             aux_contador = 0.
        ELSE
             DOWN WITH FRAME f_lanctos.

    END.  /*  Fim do FOR EACH  */
    
    tel_dscodbar = "".
    
    IF   aux_regexist   AND
         KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN     
         PAUSE MESSAGE "Tecle <Entra> para encerrar".

    HIDE FRAME f_lanctos NO-PAUSE.

END PROCEDURE.

/* .......................................................................... */

