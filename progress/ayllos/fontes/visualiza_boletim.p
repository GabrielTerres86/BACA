/* .............................................................................

   Programa: Fontes/Visualiza_boletim.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Fevereiro/2001                   Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para mostrar na tela o BOLETIM DE CAIXA.

   Alteracoes:
............................................................................. */

{ includes/var_online.i }

{ includes/var_bcaixa.i }

ASSIGN glb_cdprogra = "bcaixa"
       glb_flgbatch = FALSE
       glb_cdcritic = 0.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   ENABLE edi_boletim  WITH FRAME fra_boletim.
   DISPLAY edi_boletim WITH FRAME fra_boletim.
   ASSIGN edi_boletim:READ-ONLY IN FRAME fra_boletim = YES.

   IF   edi_boletim:INSERT-FILE(aux_nmarqimp)   THEN
        DO:
            ASSIGN edi_boletim:cursor-line in frame fra_boletim = 1.
            WAIT-FOR GO OF edi_boletim IN FRAME fra_boletim. 
        END.
   ELSE   
        DO:
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_bcaixa.
            MESSAGE glb_dscritic.
            DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_nrdcaixa
                    WITH FRAME f_opcao.
            LEAVE.
        END.
  
END.

ASSIGN edi_boletim:SCREEN-VALUE = "".
CLEAR FRAME fra_boletim ALL.
HIDE FRAME fra_boletim NO-PAUSE.

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_opcao.
VIEW FRAME f_bcaixa.    
PAUSE(0).
/* .......................................................................... */
