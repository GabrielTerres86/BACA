/* .............................................................................

   Programa: Fontes/cmedep.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Agosto/2003.                    Ultima atualizacao: 03/11/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CMEDEP - Controle de movimentacao em 
               especie - depositos).

   Alteracoes: 25/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
   
               03/06/2011 - Retirar campos do destinatario (Gabriel). 
               
               03/11/2011 - Converter para BO , retirar controle para
                            voltar a tela LOTE  (Gabriel).
............................................................................. */

{ sistema/generico/includes/b1wgen0104tt.i }

{ includes/var_online.i }
{ includes/var_cmedep_1.i "NEW"}
{ includes/var_cmedep.i "NEW"}

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "I"
       glb_nmrotina = ""
       glb_cdcritic = 0       
       tel_dtmvtolt = glb_dtmvtolt
       aux_flgretor = FALSE.

IF   glb_nmtelant = "LOTE"   THEN
     ASSIGN tel_cdagenci = glb_cdagenci
            tel_cdbccxlt = glb_cdbccxlt
            tel_nrdolote = glb_nrdolote.

PAUSE(0).
     
DISPLAY glb_cddopcao 
        tel_dtmvtolt 
        tel_cdagenci
        tel_cdbccxlt 
        tel_nrdolote WITH FRAME f_opcao.

VIEW FRAME f_cmedep.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      CLEAR FRAME f_cmedep ALL NO-PAUSE.
      CLEAR FRAME f_opcao  ALL NO-PAUSE.
                      
      DISPLAY glb_cddopcao 
              tel_dtmvtolt 
              tel_cdagenci 
              tel_cdbccxlt
              tel_nrdolote WITH FRAME f_opcao.

      IF   NOT aux_flgretor   THEN
           IF   tel_cdagenci <> 0   AND
                tel_cdbccxlt <> 0   AND
                tel_nrdolote <> 0   THEN
                LEAVE.

      UPDATE glb_cddopcao WITH FRAME f_opcao.
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         IF   glb_cdcritic > 0   THEN
              DO:
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  glb_cdcritic = 0.
              END.
       
         UPDATE tel_dtmvtolt 
                tel_cdagenci
                tel_cdbccxlt
                tel_nrdolote WITH FRAME f_opcao.
         
         RUN sistema/generico/procedures/b1wgen0104.p 
                PERSISTENT SET h-b1wgen0104.
                                                                   
         RUN valida_lote IN h-b1wgen0104
                         (INPUT glb_cdcooper,
                          INPUT tel_dtmvtolt,
                          INPUT tel_cdagenci,
                          INPUT tel_cdbccxlt,
                          INPUT tel_nrdolote,
                         OUTPUT glb_cdcritic).

         DELETE PROCEDURE h-b1wgen0104.

         IF   glb_cdcritic <> 0   THEN
              NEXT.

         LEAVE.
         
      END.  /*  Fim do DO WHILE TRUE  */
    
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           NEXT.
           
      LEAVE.
   
   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CMEDEP"   THEN
                 DO:
                     HIDE FRAME f_cmedep.
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
           
   ASSIGN aux_flgretor = TRUE.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A" THEN                /*  Alteracao  */
        DO:
            RUN fontes/cmedepa.p.
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN                /*  Consulta  */
        DO:
            RUN fontes/cmedepc.p.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN              /*  Inclusao  */
        DO:
            RUN fontes/cmedepi.p.
        END.

   IF   glb_nmdatela = "LOTE"   THEN
        DO:
            HIDE FRAME f_cmedep.
            HIDE FRAME f_opcao.
            HIDE FRAME f_moldura.
            RETURN.                        /* Retorna a tela LOTE */
        END.
    
END.

/* .......................................................................... */

