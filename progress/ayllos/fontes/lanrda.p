/* .............................................................................

   Programa: Fontes/lanrda.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/94                     Ultima atualizacao: 07/08/2007

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANRDA.

   Alteracoes: 02/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
             20/04/2004 - Tratar modo de impressao do extrato (Margarete). 
              
             02/09/2004 - Incluido Flag Conta Investimento(Mirtes).
             
             09/09/2004 - Incluido Flag Debitar Conta Investimento (Evandro).
             
             07/08/2007 - Critica lancamentos RDCA a partir de 2008(Guilherme).
............................................................................. */

{ includes/var_online.i }

{ includes/var_lanrda.i "NEW" }

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "I"
       tel_nrdconta = 0
       tel_tpaplica = 0
       tel_nrdocmto = 0
       tel_vllanmto = 0
       tel_tpemiext = 2
       tel_nrseqdig = 1
       tel_dtmvtolt = glb_dtmvtolt
       glb_cdcritic = 0
       aux_flgretor = FALSE.

IF   glb_nmtelant = "LOTE"   THEN
     ASSIGN tel_cdagenci = glb_cdagenci
            tel_cdbccxlt = glb_cdbccxlt
            tel_nrdolote = glb_nrdolote.

PAUSE(0).

DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_cdbccxlt
        tel_nrdolote tel_nrdconta tel_tpaplica 
        tel_nrdocmto tel_flgctain tel_flgdebci
        tel_vllanmto tel_tpemiext tel_nrseqdig WITH FRAME f_lanrda.

CLEAR FRAME f_regant NO-PAUSE.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   NOT aux_flgretor   THEN
           IF   tel_cdagenci <> 0   AND
                tel_cdbccxlt <> 0   AND
                tel_nrdolote <> 0   THEN
                LEAVE.

      NEXT-PROMPT tel_cdagenci WITH FRAME f_lanrda.

       
      UPDATE glb_cddopcao tel_cdagenci tel_cdbccxlt tel_nrdolote
             WITH FRAME f_lanrda.

      LEAVE.
   END.   /* END do  DO WHILE TRUE */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "LANRDA"   THEN
                 DO:
                     HIDE FRAME f_lanrda.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   ASSIGN  aux_flgretor = TRUE.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   
   IF   glb_cddopcao = "A" THEN
        DO:
            RUN fontes/lanrdaa.p.
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            RUN fontes/lanrdac.p.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            RUN fontes/lanrdae.p.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            IF   YEAR(glb_dtmvtolt) >= 2008   THEN
                 DO:
                     glb_cdcritic = 36.
                     RUN fontes/critic.p.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.
            RUN fontes/lanrdai.p.
        END.

   IF   glb_nmdatela = "LOTE"   THEN
        DO:
            HIDE FRAME f_lanrda.
            HIDE FRAME f_regant.
            HIDE FRAME f_lanctos.
            HIDE FRAME f_moldura.
            RETURN.                        /* Retorna a tela LOTE */
        END.
END.

/* .......................................................................... */
