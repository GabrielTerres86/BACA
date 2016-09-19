/* .............................................................................

   Programa: Fontes/cmesaq.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Agosto/2003.                    Ultima atualizacao: 03/06/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela cmesaq - Controle de movimentacao em 
               especie - saques).

   Alteracoes: 26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
   
               04/05/2010 - Ajustado programa para as movimentações em
                            espécie criadas na rotina 20 (a partir da
                            craptvl). (Fernando)  
                            
               03/06/2011 - Retirar campos do destinatario , retirar 
                            controle para voltar a tela LOTE (Gabriel).             
............................................................................. */

{ sistema/generico/includes/b1wgen0104tt.i }

{ includes/var_online.i }
{ includes/var_cmesaq_1.i "NEW"}
{ includes/var_cmesaq.i "NEW"}

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "I"
       glb_nmrotina = ""
       glb_cdcritic = 0
       
       tel_dtmvtolt = glb_dtmvtolt.

PAUSE(0).
     
DISPLAY glb_cddopcao 
        tel_dtmvtolt
        tel_tpdocmto
        WITH FRAME f_opcao.

VIEW FRAME f_cmesaq.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      CLEAR FRAME f_cmesaq ALL NO-PAUSE.
      CLEAR FRAME f_opcao  ALL NO-PAUSE.
                      
      DISPLAY glb_cddopcao 
              tel_dtmvtolt 
              tel_tpdocmto 
              WITH FRAME f_opcao.

      UPDATE glb_cddopcao WITH FRAME f_opcao.
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         UPDATE tel_dtmvtolt
                tel_tpdocmto
                WITH FRAME f_opcao.
         LEAVE.
         
      END.  /*  Fim do DO WHILE TRUE  */
    
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           NEXT.
           
      LEAVE.
   
   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "cmesaq"   THEN
                 DO:
                     HIDE FRAME f_cmesaq.
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A" THEN                /*  Alteracao  */
        DO:
            RUN fontes/cmesaqa.p.
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN                /*  Consulta  */
        DO:
            RUN fontes/cmesaqc.p.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN              /*  Inclusao  */
        DO:
            RUN fontes/cmesaqi.p.
        END.
END.

/* .......................................................................... */

