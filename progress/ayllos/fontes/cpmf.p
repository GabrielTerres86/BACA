/* .............................................................................

   Programa: Fontes/ipmf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/93.                          Ultima atualizacao: 27/05/1999

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela IPMF.

   Alteracoes: 27/05/1999 - Reedicao do CPMF (Deborah).
............................................................................. */

{ includes/var_online.i }

{ includes/var_cpmf.i } 

DEF        VAR tel_vlcalcul AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tel_vldoipmf AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tel_vlliquid AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tel_cfrvipmf AS DECIMAL FORMAT "zzz,zzz,zz9.999999"   NO-UNDO.

DEF        VAR aux_stimeout AS INT                                   NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

FORM SKIP(5)
     tel_vlcalcul AT 17 LABEL "Valor a calcular" AUTO-RETURN
                              HELP "Informe o valor a calcular da CPMF."
     SKIP(1)
     tel_vldoipmf AT 20 LABEL "Valor da CPMF"
     SKIP(1)
     tel_vlliquid AT 20 LABEL "Valor liquido"
     SKIP(1)
     tel_cfrvipmf AT 17 LABEL "Valor do redutor"
     SKIP(4)
     WITH ROW 4 NO-LABELS SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80
          FRAME f_ipmf.

glb_cddopcao = "C".

{ includes/cpmf.i }

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_vlcalcul WITH FRAME f_ipmf

      EDITING:

         aux_stimeout = 0.

         DO WHILE TRUE:

            READKEY PAUSE 1.

            IF   LASTKEY = -1   THEN
                 DO:
                     aux_stimeout = aux_stimeout + 1.

                     IF   aux_stimeout > glb_stimeout   THEN
                          QUIT.

                     NEXT.
                 END.

            IF   FRAME-FIELD = "tel_vlcalcul"   THEN
                 IF   LASTKEY =  KEYCODE(".")   THEN
                      APPLY 44.
                 ELSE
                      APPLY LASTKEY.
            ELSE
                 APPLY LASTKEY.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

      END.  /*  Fim do EDITING  */

      IF   aux_cddopcao <> glb_cddopcao   THEN
           DO:
               { includes/acesso.i}
               aux_cddopcao = glb_cddopcao.
           END.

      ASSIGN tel_vlliquid = TRUNCATE(tel_vlcalcul * tab_txrdcpmf,2)
             tel_vldoipmf = tel_vlcalcul - tel_vlliquid
             tel_cfrvipmf = tab_txrdcpmf.  

      DISPLAY tel_vldoipmf tel_vlliquid tel_cfrvipmf WITH FRAME f_ipmf.

   END.  /*  Fim do WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "CPMF"   THEN
                 DO:
                     HIDE FRAME f_ipmf.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
