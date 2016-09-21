/* .............................................................................

   Programa: Fontes/lanbdc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                     Ultima atualizacao: 15/05/2012
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANBDC - Lancamentos de borderos de desconto de
                                       cheques.
                                       
   Alteracoes: 16/10/2003 - Tratamento da opcao de resgate de cheque descontado
                            (Edson).

               10/12/2005 - Usar glb_cdcooper para ler crapcop (Magui).
               
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               14/10/2008 - Criticar lotes com tipo <> 26 (Guilherme).
               
               08/07/2010 - Tratamento para Compe 085 (Ze).
               
               15/05/2012 - substituição do FIND craptab para os registros 
                            pela chamada do fontes ver_ctace.p
                            (Lucas R.)
............................................................................. */

{ includes/var_online.i }

{ includes/var_lanbdc.i "NEW" }

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "I"
       glb_cdcritic = 0
       
       tel_dtmvtolt = glb_dtmvtolt
       tel_nmcustod = ""
       tel_nrcustod = 0
       tel_cdcmpchq = 0
       tel_cdbanchq = 0
       tel_cdagechq = 0
       tel_nrddigc1 = 0
       tel_nrctachq = 0
       tel_nrddigc2 = 0
       tel_nrcheque = 0
       tel_nrddigc3 = 0
       tel_vlcheque = 0
       tel_nrseqdig = 1

       aux_flgretor = FALSE.

IF   glb_nmtelant = "LOTE"   THEN
     ASSIGN tel_cdagenci = glb_cdagenci
            tel_cdbccxlt = glb_cdbccxlt
            tel_nrdolote = glb_nrdolote.

PAUSE(0).

DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_cdbccxlt tel_nrdolote 
        tel_cdcmpchq tel_cdbanchq tel_cdagechq tel_nrddigc1 tel_nrctachq
        tel_nrddigc2 tel_nrcheque tel_nrddigc3 tel_vlcheque tel_nrseqdig
        tel_nrcustod tel_nmcustod
        WITH FRAME f_lanbdc.

CLEAR FRAME f_regant NO-PAUSE.

/*  Le tabela com as contas convenio do Banco do Brasil - Geral  */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 0,
                       OUTPUT aux_lscontas).

/*  Le tabela com as contas convenio do Banco do Brasil - talao normal */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 1,
                       OUTPUT aux_lsconta1).

/*  Le tabela com as contas convenio do Banco do Brasil - talao transf.*/

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 2,
                       OUTPUT aux_lsconta2).

/*  Le tabela com as contas convenio do Banco do Brasil - chq.salario */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 3,
                       OUTPUT aux_lsconta3).

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

ASSIGN aux_cdagebcb = crapcop.cdagebcb
       aux_cdagectl = crapcop.cdagectl
       aux_cdbcoctl = crapcop.cdbcoctl.

/* .......................................................................... */

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   NOT aux_flgretor   THEN
           IF   tel_cdagenci <> 0   AND
                tel_cdbccxlt <> 0   AND
                tel_nrdolote <> 0   THEN
                LEAVE.

      UPDATE glb_cddopcao WITH FRAME f_lanbdc.
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
         IF   CAN-DO("A,C,E,R",glb_cddopcao)   THEN
              DO:
                  UPDATE tel_dtmvtolt tel_cdagenci tel_cdbccxlt tel_nrdolote
                         WITH FRAME f_lanbdc.
              END.
         ELSE
              DO:
                  tel_dtmvtolt = glb_dtmvtolt.

                  DISPLAY tel_dtmvtolt WITH FRAME f_lanbdc.
                  
                  UPDATE tel_cdagenci tel_cdbccxlt tel_nrdolote
                         WITH FRAME f_lanbdc.
              END.
              
         FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                            craplot.dtmvtolt = tel_dtmvtolt   AND
                            craplot.cdagenci = tel_cdagenci   AND
                            craplot.cdbccxlt = tel_cdbccxlt   AND
                            craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.
        
         IF   NOT AVAILABLE craplot   THEN
              DO:
                  glb_cdcritic = 60.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  glb_cdcritic = 0.
                  NEXT.
              END.

         IF  craplot.tplotmov <> 26  THEN
             DO:
                 MESSAGE "Tipo de lote deve ser 26 - Borderos de Desconto" +
                         " de Cheques.".
                 NEXT.
             END.
         
         ASSIGN tel_qtinfoln = craplot.qtinfoln
                tel_qtcompln = craplot.qtcompln
                tel_vlinfodb = craplot.vlinfodb 
                tel_vlcompdb = craplot.vlcompdb
                tel_vlinfocr = craplot.vlinfocr  
                tel_vlcompcr = craplot.vlcompcr
                tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
                tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

         DISPLAY tel_qtinfoln tel_qtcompln tel_vlinfodb
                 tel_vlcompdb tel_vlinfocr tel_vlcompcr
                 tel_qtdifeln tel_vldifedb tel_vldifecr
                 tel_cdcmpchq tel_cdbanchq tel_cdagechq 
                 tel_nrddigc1 tel_nrctachq tel_nrddigc2
                 tel_nrcheque tel_nrddigc3 tel_vlcheque 
                 tel_nrseqdig
                 WITH FRAME f_lanbdc.
         
         LEAVE.
         
      END.  /*  Fim do DO WHILE TRUE  */
    
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           NEXT.
           
      LEAVE.
   
   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "lanbdc"   THEN
                 DO:
                     HIDE FRAME f_lanbdc.
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
            RUN fontes/lanbdca.p.
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN                /*  Consulta  */
        DO:
            RUN fontes/lanbdcc.p.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN              /*  Exclusao  */
        DO:
            RUN fontes/lanbdce.p.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN              /*  Inclusao  */
        DO:
            RUN fontes/lanbdci.p.
        END.
   ELSE
   IF   glb_cddopcao = "R"   THEN              /*  Resgate  */
        DO:
            RUN fontes/lanbdcr.p.
        END.
    
   IF   glb_nmdatela = "LOTE"   THEN
        DO:
            HIDE FRAME f_lanbdc.
            HIDE FRAME f_regant.
            HIDE FRAME f_lanctos.
            HIDE FRAME f_moldura.
            RETURN.                        /* Retorna a tela LOTE */
        END.
END.

/* .......................................................................... */

