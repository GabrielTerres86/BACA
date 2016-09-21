/* .............................................................................

   Programa: Fontes/Visualiza_criticas.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Margarete
   Data    : Junho/2004                   Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para mostrar na tela as CRITICAS DA SUMLOT.

   Alteracoes:
............................................................................. */

{ includes/var_online.i }

{ includes/var_proces.i }

ASSIGN glb_cdprogra = "PROCES"
       glb_flgbatch = FALSE
       glb_cdcritic = 0.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   ENABLE edi_criticas  WITH FRAME fra_criticas.
   DISPLAY edi_criticas WITH FRAME fra_criticas.
   ASSIGN edi_criticas:READ-ONLY IN FRAME fra_criticas = YES.

   IF   edi_criticas:INSERT-FILE(aux_nmarqimp)   THEN
        DO:
            ASSIGN edi_criticas:cursor-line in frame fra_criticas = 1.
            WAIT-FOR GO OF edi_criticas IN FRAME fra_criticas. 
        END.
   ELSE   
        DO: 
            LEAVE.
        END.
  
END.

ASSIGN edi_criticas:SCREEN-VALUE = "".
CLEAR FRAME fra_criticas ALL.
HIDE FRAME fra_criticas NO-PAUSE.

VIEW FRAME f_cmd.
PAUSE(0).
/* .......................................................................... */
