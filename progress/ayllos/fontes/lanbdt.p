/* .............................................................................

   Programa: Fontes/lanbdt.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Setembro/2008.                  Ultima atualizacao: 09/07/2012
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANBDT - Lancamentos de borderos de desconto de
                                       titulos.
                                       
   Alteracoes: 29/06/2009 - Incluir opcao "A"
                          - Logar opcoes "E" e "A" (Guilherme).
                          
               09/07/2012 - Tratamento para a variável 'tel_tpcobran' 
                            retornar Tipo de Cobrança (Lucas).

............................................................................. */

{ includes/var_online.i }

{ sistema/generico/includes/b1wgen0030tt.i }
{ includes/var_lanbdt.i "NEW" }

VIEW FRAME f_moldura.

PAUSE 0.

ON  VALUE-CHANGED OF tel_tpcobran IN FRAME f_lanbdt
    DO:
        IF  FRAME-VALUE = "s" OR
            FRAME-VALUE = "S" THEN
            ASSIGN tel_tpcobran = "SEM REGISTRO"
                   aux_tpcobran = "S".
          
        IF  FRAME-VALUE = "r" OR 
            FRAME-VALUE = "R" THEN
            ASSIGN tel_tpcobran = "REGISTRADA"
                   aux_tpcobran = "R".
          
        IF  FRAME-VALUE = "t" OR
            FRAME-VALUE = "T" THEN
            ASSIGN tel_tpcobran = "TODOS"
                   aux_tpcobran = "T".
                            
        DISPLAY tel_tpcobran WITH FRAME f_lanbdt.
        NEXT-PROMPT tel_tpcobran WITH FRAME f_lanbdt.
    END.

ASSIGN glb_cddopcao = "I"
       glb_cdcritic = 0
       
       tel_dtmvtolt = glb_dtmvtolt
       tel_nmcustod = ""
       tel_nrcustod = 0.

DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_cdbccxlt tel_nrdolote 
        tel_nrcustod tel_nmcustod tel_tpcobran
        WITH FRAME f_lanbdt.

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

/* .......................................................................... */

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN tel_qtinfoln = 0
             tel_qtcompln = 0
             tel_vlinfodb = 0
             tel_vlcompdb = 0
             tel_vlinfocr = 0
             tel_vlcompcr = 0
             tel_qtdifeln = 0
             tel_vldifedb = 0
             tel_vldifecr = 0
             tel_nrcustod = 0
             tel_nmcustod = ""
             tel_nrborder = 0
             tel_tpcobran = "".

      DISPLAY tel_qtinfoln tel_qtcompln tel_vlinfodb tel_vlcompdb tel_vlinfocr
              tel_vlcompcr tel_qtdifeln tel_vldifedb tel_vldifecr
              tel_nrcustod tel_nmcustod tel_nrborder tel_tpcobran WITH FRAME f_lanbdt.
      
      UPDATE glb_cddopcao WITH FRAME f_lanbdt.
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         IF   CAN-DO("C,E,R,A",glb_cddopcao)   THEN
              DO:
                  UPDATE tel_dtmvtolt tel_cdagenci 
                         tel_cdbccxlt tel_nrdolote
                         WITH FRAME f_lanbdt.
              END.
         ELSE
              DO:
                  tel_dtmvtolt = glb_dtmvtolt.

                  DISPLAY tel_dtmvtolt WITH FRAME f_lanbdt.
                  
                  UPDATE tel_cdagenci tel_cdbccxlt tel_nrdolote
                         WITH FRAME f_lanbdt.
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
            IF   CAPS(glb_nmdatela) <> "LANBDT"   THEN
                 DO:
                     HIDE FRAME f_lanbdt.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
   
   ASSIGN glb_cdbccxlt = tel_cdbccxlt       
          glb_nrdolote = tel_nrdolote.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.
  
   IF   glb_cddopcao = "C" THEN                /*  Consulta  */
        DO:
            RUN fontes/lanbdtc.p.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN              /*  Exclusao  */
        DO:
            RUN fontes/lanbdte.p.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN              /*  Inclusao  */
        DO:
            RUN fontes/lanbdti.p.
        END.
   ELSE
   IF   glb_cddopcao = "R"   THEN              /*  Resgate  */
        DO:
            RUN fontes/lanbdtr.p.
        END.
   IF   glb_cddopcao = "A"   THEN              /*  Alterar  */
        DO:
            RUN fontes/lanbdta.p.
        END.        
    
END.

/* .......................................................................... */
