/* .............................................................................

   Programa: Fontes/loteo.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/2000.                    Ultima atualizacao: 30/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de associar um CAIXA ao lote da tela LOTE.

   Alteracao : 16/02/2005 - Nao permitir para tipo de Lote <> 1 (Mirtes)

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 
............................................................................. */

{ includes/var_online.i }

{ includes/var_lote.i }

IF   tel_cdagenci = 11   THEN  /* boletim de caixa -   EDSON PAC1 */ 
     RETURN.

TRANS_O:

DO TRANSACTION ON ERROR UNDO TRANS_O, NEXT:

   DO aux_contador = 1 TO 10:

      FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                         craplot.dtmvtolt = tel_dtmvtolt   AND
                         craplot.cdagenci = tel_cdagenci   AND
                         craplot.cdbccxlt = tel_cdbccxlt   AND
                         craplot.nrdolote = tel_nrdolote
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE  craplot   THEN
           IF   LOCKED craplot   THEN
                DO:
                    glb_cdcritic = 84.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                DO:
                    glb_cdcritic = 60.
                    CLEAR FRAME f_lote.
                END.
      ELSE
           glb_cdcritic = 0.

      LEAVE.

   END.  /*  Fim do DO .. TO  */

   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

   IF  craplot.tplotmov <> 1 THEN 
       DO:
           ASSIGN glb_cdcritic = 62.
           RUN fontes/critic.p.
           BELL.
           MESSAGE glb_dscritic.
           glb_cdcritic = 0.
           NEXT.
       END.

   ASSIGN tel_qtinfoln = craplot.qtinfoln
          tel_vlinfodb = craplot.vlinfodb
          tel_vlinfocr = craplot.vlinfocr
          tel_qtcompln = craplot.qtcompln
          tel_vlcompdb = craplot.vlcompdb
          tel_vlcompcr = craplot.vlcompcr
          tel_tplotmov = craplot.tplotmov
          tel_dtmvtopg = craplot.dtmvtopg
          tel_cdhistor = craplot.cdhistor
          tel_cdbccxpg = craplot.cdbccxpg

          tel_nrdcaixa = craplot.nrdcaixa
          tel_cdopecxa = craplot.cdopecxa

          tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
          tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
          tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

   DISPLAY tel_dtmvtolt tel_qtinfoln tel_vlinfodb 
           tel_vlinfocr tel_qtcompln tel_qtdifeln 
           tel_vlcompdb tel_vldifedb tel_vlcompcr 
           tel_vldifecr tel_tplotmov
           WITH FRAME f_lote.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      PAUSE 0.

      UPDATE tel_nrdcaixa tel_cdopecxa WITH FRAME f_caixa.

      IF   craplot.nrdcaixa > 0   THEN
           DO:
               FIND LAST crapbcx WHERE crapbcx.cdcooper = glb_cdcooper       AND
                                       crapbcx.dtmvtolt = glb_dtmvtolt       AND
                                       crapbcx.cdagenci = tel_cdagenci       AND
                                       crapbcx.nrdcaixa = craplot.nrdcaixa   AND
                                       crapbcx.cdopecxa = craplot.cdopecxa  
                                       NO-LOCK NO-ERROR. 
 
               IF   NOT AVAILABLE crapbcx   THEN
                    DO:
                        glb_cdcritic = 701.
                        NEXT.
                    END.

               IF   crapbcx.cdsitbcx <> 1   THEN
                    DO:
                        glb_cdcritic = 699.
                        NEXT.
                    END.
           END.
      
      IF   NOT CAN-FIND(crapope WHERE crapope.cdcooper = glb_cdcooper    AND
                                      crapope.cdoperad = tel_cdopecxa)   THEN
           DO:
               glb_cdcritic = 67.
               NEXT-PROMPT tel_cdopecxa WITH FRAME f_caixa.
               NEXT.
           END.

      FIND LAST crapbcx WHERE crapbcx.cdcooper = glb_cdcooper   AND
                              crapbcx.dtmvtolt = glb_dtmvtolt   AND
                              crapbcx.cdagenci = tel_cdagenci   AND
                              crapbcx.nrdcaixa = tel_nrdcaixa   AND
                              crapbcx.cdopecxa = tel_cdopecxa  
                              NO-LOCK NO-ERROR. 
 
      IF   NOT AVAILABLE crapbcx   THEN
           DO:
               glb_cdcritic = 701.
               NEXT.
           END.

      IF   crapbcx.cdsitbcx <> 1   THEN
           DO:
               glb_cdcritic = 699.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            HIDE FRAME f_caixa NO-PAUSE.
            RETURN.
        END.

   ASSIGN craplot.nrdcaixa = tel_nrdcaixa
          craplot.cdopecxa = tel_cdopecxa

          tel_qtinfoln     = 0
          tel_vlinfodb     = 0
          tel_vlinfocr     = 0
          tel_tplotmov     = 0
          tel_dtmvtopg     = ?
          tel_cdbccxpg     = 0
          tel_cdhistor     = 0.

END.   /* Fim da transacao  --  TRANS_O  */

IF   glb_cdcritic > 0   THEN
     DO:
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
     END.

RELEASE craplot.

CLEAR FRAME f_lote NO-PAUSE.

ASSIGN tel_cdagenci = 0
       tel_cdbccxlt = 0
       tel_nrdolote = 0.

/* .......................................................................... */

