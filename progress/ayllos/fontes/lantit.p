/* .............................................................................

   Programa: Fontes/lantit.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                     Ultima atualizacao: 14/08/2007

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANTIT - Lancamentos de titulos compensaveis.

   Alteracoes: 10/01/2000 - Tratar tipo de lote 21 (Deborah).

               12/03/2001 - Incluir tratamento do boletim caixa (Margarete).

               10/02/2004 - Efetuado controle por PAC(tabelas horario 
                            compel/titulo) (Mirtes)

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               14/08/2007 - Hrtrtitulo lida antes do update cdagenci (Magui).
............................................................................. */

{ includes/var_online.i }

{ includes/var_lantit.i "NEW" }

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "I"
       glb_cdcritic = 0
       
       tel_dtmvtolt = glb_dtmvtolt
       tel_dsdlinha = ""
       tel_nmprimtl = ""
       tel_dtdpagto = ?
       tel_nrdconta = 0
       tel_vldpagto = 0
       tel_nrseqdig = 1

       aux_flgretor = FALSE.

IF   glb_nmtelant = "LOTE"   THEN
     ASSIGN tel_cdagenci = glb_cdagenci
            tel_cdbccxlt = glb_cdbccxlt
            tel_nrdolote = glb_nrdolote.

PAUSE(0).

DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_cdbccxlt tel_nrdolote 
        tel_nrdconta tel_nmprimtl tel_dsdlinha tel_vldpagto tel_nrseqdig
        tel_dtdpagto
        WITH FRAME f_lantit.

CLEAR FRAME f_regant NO-PAUSE.

/*  Acessa dados da cooperativa  */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_nmdatela = " ".
         RETURN.
     END.

aux_cdagebcb = crapcop.cdagebcb.

/* .......................................................................... */

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   NOT aux_flgretor   THEN
           IF   tel_cdagenci <> 0   AND
                tel_cdbccxlt <> 0   AND
                tel_nrdolote <> 0   THEN
                LEAVE.

      UPDATE glb_cddopcao WITH FRAME f_lantit.
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         IF   glb_cdcritic > 0   THEN
              DO:
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  glb_cdcritic = 0.
              END.
       
         IF   CAN-DO("D,M,R,X",glb_cddopcao)   THEN
              DO:
                  UPDATE tel_dtmvtolt tel_cdagenci tel_cdbccxlt tel_nrdolote
                         WITH FRAME f_lantit.
              END.
         ELSE
              DO:
                  tel_dtmvtolt = glb_dtmvtolt.
                  DISPLAY tel_dtmvtolt WITH FRAME f_lantit.
                  
                  UPDATE tel_cdagenci tel_cdbccxlt tel_nrdolote
                         WITH FRAME f_lantit.
              END.
       
         FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                            craplot.dtmvtolt = tel_dtmvtolt   AND
                            craplot.cdagenci = tel_cdagenci   AND
                            craplot.cdbccxlt = tel_cdbccxlt   AND
                            craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.
        
         IF   NOT AVAILABLE craplot   THEN
              DO:
                  glb_cdcritic = 60.
                  NEXT.
              END.

         IF   NOT CAN-DO("C,M",glb_cddopcao)   AND
              tel_cdbccxlt = 11     AND
              craplot.nrdcaixa > 0  AND
              tel_cdagenci <> 11    THEN  /* boletim de caixa -   EDSON PAC1 */ 
              DO:
                  FIND LAST crapbcx WHERE 
                            crapbcx.cdcooper = glb_cdcooper     AND
                            crapbcx.dtmvtolt = glb_dtmvtolt     AND
                            crapbcx.cdagenci = craplot.cdagenci AND
                            crapbcx.nrdcaixa = craplot.nrdcaixa AND
                            crapbcx.cdopecxa = craplot.cdopecxa
                            USE-INDEX crapbcx2 NO-LOCK NO-ERROR.
                            
                  IF   NOT AVAILABLE crapbcx    THEN
                       DO:
                           ASSIGN glb_cdcritic = 701. 
                           NEXT.
                       END. 
                 ELSE
                       IF   crapbcx.cdsitbcx = 2   THEN
                            DO:
                                ASSIGN glb_cdcritic = 698.
                                NEXT.
                            END.               
              END.

         ASSIGN tel_qtinfoln = craplot.qtinfoln
                tel_qtcompln = craplot.qtcompln
                tel_vlinfodb = craplot.vlinfodb 
                tel_vlcompdb = craplot.vlcompdb
                tel_vlinfocr = craplot.vlinfocr  
                tel_vlcompcr = craplot.vlcompcr
                tel_dtdpagto = craplot.dtmvtopg
                tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
                tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
                aux_tplotmov = craplot.tplotmov.

         DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
                 tel_qtcompln tel_vlcompdb tel_vlcompcr
                 tel_qtdifeln tel_vldifedb tel_vldifecr
                 tel_dtdpagto
                 WITH FRAME f_lantit.
         
         /*  Tabela com o horario limite para digitacao  */
         FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                            craptab.nmsistem = "CRED"       AND
                            craptab.tptabela = "GENERI"     AND
                            craptab.cdempres = 0            AND
                            craptab.cdacesso = "HRTRTITULO" AND
                            craptab.tpregist = tel_cdagenci NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craptab   THEN
              ASSIGN tab_intransm = 1
                     tab_hrlimite = 64800.           /*  18:00 horas  */
         ELSE
              ASSIGN tab_intransm = INT(SUBSTRING(craptab.dstextab,1,1))
                     tab_hrlimite = INT(SUBSTRING(craptab.dstextab,3,5)).
         
         IF   craplot.dtmvtopg = ?   AND   craplot.tplotmov = 20 AND
              NOT CAN-DO("C,M",glb_cddopcao)   THEN
              DO:
                  /*  Verifica a hora somente para a arrecadacao caixa  */
                     
                  IF   TIME >= tab_hrlimite   THEN
                       DO:
                           glb_cdcritic = 676.
                           NEXT.
                       END.
                  
                  IF   tab_intransm > 0   THEN
                       DO:
                           glb_cdcritic = 677.
                           NEXT.
                       END.
              END.
         
         LEAVE.
         
      END.  /*  Fim do DO WHILE TRUE  */
    
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           NEXT.
           
      LEAVE.
   
   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "LANTIT"   THEN
                 DO:
                     HIDE FRAME f_lantit.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   ASSIGN aux_dtmvtolt = tel_dtmvtolt
          aux_cdagenci = tel_cdagenci
          aux_cdbccxlt = tel_cdbccxlt
          aux_nrdolote = tel_nrdolote
          aux_flgretor = TRUE.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A" THEN                /*  Alteracao  */
        DO:
            RUN fontes/lantita.p.
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN                /*  Consulta  */
        DO:
            RUN fontes/lantitc.p.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN              /*  Exclusao  */
        DO:
            RUN fontes/lantite.p.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN              /*  Inclusao  */
        DO:
            RUN fontes/lantiti.p.
        END.
   ELSE
   IF   glb_cddopcao = "M"   THEN              /*  Impressao do lote  */
        DO:
            RUN proc_lista_lote.
        END.
   ELSE
   IF   glb_cddopcao = "R"   THEN              /*  Resgate  */
        DO:
            RUN fontes/lantitr.p.
        END.
   ELSE
   IF   glb_cddopcao = "X"   THEN              /*  Cancelamento de resgate  */
        DO:
            RUN fontes/lantitx.p.
        END.
     
   IF   glb_nmdatela = "LOTE"   THEN
        DO:
            HIDE FRAME f_lantit.
            HIDE FRAME f_regant.
            HIDE FRAME f_lanctos.
            HIDE FRAME f_moldura.
            RETURN.                        /* Retorna a tela LOTE */
        END.
END.

/* .......................................................................... */

{ includes/proc_lantit.i }

/* .......................................................................... */

