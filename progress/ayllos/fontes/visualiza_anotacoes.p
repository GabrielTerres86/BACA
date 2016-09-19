/* .............................................................................

   Programa: Fontes/Visualiza_anotacoes.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Fevereiro/2001                   Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para mostrar na tela as ANOTACOES.

   Alteracoes:

............................................................................. */

{ includes/var_online.i }

{ includes/var_anota.i }

ASSIGN glb_cdprogra = "anota"
       glb_flgbatch = FALSE
       glb_cdcritic = 0.

PAUSE 0.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   ENABLE edi_anota  WITH FRAME fra_anota.
   DISPLAY edi_anota WITH FRAME fra_anota.
   ASSIGN edi_anota:READ-ONLY IN FRAME fra_anota = YES.

   IF   edi_anota:INSERT-FILE(aux_nmarqimp)   THEN
        DO:
            ASSIGN edi_anota:cursor-line in frame fra_anota = 1.
            WAIT-FOR GO OF edi_anota IN FRAME fra_anota. 
        END.
   ELSE   
        DO:
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_bcaixa.
            MESSAGE glb_dscritic.
            DISPLAY glb_cddopcao tel_nrdconta tel_nmprimtl WITH FRAME f_opcao.
            LEAVE.
        END.
  
END.

IF   aux_recidobs = 0   THEN
     DO:
         HIDE MESSAGE NO-PAUSE.

         aux_confirma = "N".
         
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
            MESSAGE "Imprimir as anotacoes? S/N:" UPDATE aux_confirma.

            LEAVE.
            
         END.  /*  Fim do DO WHILE TRUE  */
         
         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   /*   F4 OU FIM   */
              aux_confirma <> "S"                  THEN
              .
         ELSE
              DO:
                  ASSIGN aux_recidobs = 0
                         aux_tipconsu = no.

                  RUN fontes/impanotacoes.p.
              END.
     END.
     
ASSIGN edi_anota:SCREEN-VALUE = "".

CLEAR FRAME fra_anota ALL.

HIDE FRAME fra_anota NO-PAUSE.

/* .......................................................................... */