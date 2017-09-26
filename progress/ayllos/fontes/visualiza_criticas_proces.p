/* .............................................................................

   Programa: Fontes/Visualiza_criticas.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Margarete
   Data    : Junho/2004                   Ultima atualizacao: 05/09/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para mostrar na tela as CRITICAS DA SUMLOT.

   Alteracoes: 05/09/2017 - Nao esconder o conteudo da tela quando exibir a mensagem 
                            de confirmacao (Lucas Ranghetti #665982)
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

VIEW FRAME f_cmd.
PAUSE(0).
/* .......................................................................... */
