/* .............................................................................

   Programa: Fontes/lancst.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                         Ultima atualizacao: 05/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANCST - Lancamentos de cheques em custodia.

   Alteracoes: 23/10/2000 - Incluir tratamento da opcao T - Troca data da
                            custodia (lote inteiro) - Edson
                            
               25/09/2001 - Alterado layout da tela para mostrar cheques por
                            tipo Credi, maiores e menores (Junior).

               20/03/2003 - Incluir tratamento da Concredi (Margarete).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               08/07/2010 - Tratamento para Compe 085 (Ze).
               
               15/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)
                            
               05/06/2014 - Adicionado opcao "L". (Reinert)                            
............................................................................. */

{ includes/var_online.i }

{ includes/var_lancst.i "NEW" }

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
        WITH FRAME f_lancst.

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

      UPDATE glb_cddopcao WITH FRAME f_lancst.
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
         IF   CAN-DO("D,R,T,X",glb_cddopcao)   THEN
              DO:
                  UPDATE tel_dtmvtolt tel_cdagenci tel_cdbccxlt tel_nrdolote
                         WITH FRAME f_lancst.
              END.
         ELSE             
              DO:
                  IF  glb_cddopcao = "L" THEN
                      DO:                        
                        LEAVE.
                      END.                      
                  ELSE
                  DO:
                      tel_dtmvtolt = glb_dtmvtolt.
    
                      DISPLAY tel_dtmvtolt WITH FRAME f_lancst.
                      
                      UPDATE tel_cdagenci tel_cdbccxlt tel_nrdolote
                             WITH FRAME f_lancst.
                  END.
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

         ASSIGN tel_qtinfoln = craplot.qtinfoln
                tel_qtcompln = craplot.qtcompln
                tel_vlinfodb = craplot.vlinfodb 
                tel_vlcompdb = craplot.vlcompdb
                tel_vlinfocr = craplot.vlinfocr  
                tel_vlcompcr = craplot.vlcompcr
                tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
                tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr

                tel_qtinfocc = craplot.qtinfocc
                tel_vlinfocc = craplot.vlinfocc
                tel_qtcompcc = craplot.qtcompcc
                tel_vlcompcc = craplot.vlcompcc
                tel_qtdifecc = craplot.qtinfocc - craplot.qtcompcc
                tel_vldifecc = craplot.vlinfocc - craplot.vlcompcc

                tel_qtinfoci = craplot.qtinfoci
                tel_vlinfoci = craplot.vlinfoci
                tel_qtcompci = craplot.qtcompci
                tel_vlcompci = craplot.vlcompci
                tel_qtdifeci = craplot.qtinfoci - craplot.qtcompci
                tel_vldifeci = craplot.vlinfoci - craplot.vlcompci

                tel_qtinfocs = craplot.qtinfocs
                tel_vlinfocs = craplot.vlinfocs
                tel_qtcompcs = craplot.qtcompcs
                tel_vlcompcs = craplot.vlcompcs
                tel_qtdifecs = craplot.qtinfocs - craplot.qtcompcs
                tel_vldifecs = craplot.vlinfocs - craplot.vlcompcs.
         
         DISPLAY tel_qtinfocc tel_vlinfocc tel_qtinfoci tel_vlinfoci
                 tel_qtinfocs tel_vlinfocs tel_qtcompcc tel_vlcompcc
                 tel_qtcompci tel_vlcompci tel_qtcompcs tel_vlcompcs
                 tel_qtdifecc tel_vldifecc tel_qtdifeci tel_vldifeci
                 tel_qtdifecs tel_vldifecs tel_cdcmpchq tel_cdbanchq
                 tel_cdagechq tel_nrddigc1 tel_nrctachq tel_nrddigc2
                 tel_nrcheque tel_nrddigc3 tel_vlcheque tel_nrseqdig
                 WITH FRAME f_lancst.
         
         LEAVE.
         
      END.  /*  Fim do DO WHILE TRUE  */
    
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           NEXT.
           
      LEAVE.
   
   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "LANCST"   THEN
                 DO:
                     HIDE FRAME f_lancst.
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
            RUN fontes/lancsta.p.
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN                /*  Consulta  */
        DO:
            RUN fontes/lancstc.p.
        END.
   ELSE
   IF   glb_cddopcao = "D"   THEN              /*  Resumo do lote digitado  */
        DO:
            RUN fontes/lancstd.p.
        END.
   ELSE
   IF   glb_cddopcao = "R"   THEN              /*  Resgate de cheque  */
        DO:
            RUN fontes/lancstr.p.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN              /*  Exclusao  */
        DO:
            RUN fontes/lancste.p.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN              /*  Inclusao  */
        DO:
            RUN fontes/lancsti.p.
        END.
   ELSE
   IF   glb_cddopcao = "T"   THEN              /*  Troca data da custodia  */
        DO:
            RUN fontes/lancstt.p.
        END.
   ELSE
   IF   glb_cddopcao = "X"   THEN              /*  Cancelamento de resgate  */
        DO:
            RUN fontes/lancstx.p.
        END.
   ELSE
   IF   glb_cddopcao = "L" THEN
        DO:
            HIDE FRAME f_lancst.
            HIDE FRAME f_regant.
            HIDE FRAME f_lanctos.
            RUN fontes/lancstl.p.
        END.
    
   IF   glb_nmdatela = "LOTE"   THEN
        DO:
            HIDE FRAME f_lancst.
            HIDE FRAME f_regant.
            HIDE FRAME f_lanctos.
            HIDE FRAME f_moldura.
            RETURN.                        /* Retorna a tela LOTE */
        END.
END.

/* .......................................................................... */

