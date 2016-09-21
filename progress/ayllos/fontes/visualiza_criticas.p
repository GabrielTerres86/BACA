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

DEF SHARED VAR aux_nmarqimp AS CHAR                    NO-UNDO.

/* variaveis para a opcao visualizar */
DEF BUTTON btn-ok     LABEL "Sair".
DEF VAR edi_criticas   AS CHAR VIEW-AS EDITOR SIZE 80 BY 11
                     /* SCROLLBAR-VERTICAL  */ PFCOLOR 0.     

DEF FRAME fra_criticas 
    edi_criticas  
HELP "<F4> ou <END> p/finalizar e <PAGE UP> ou <PAGE DOWN> p/navegar" 
    WITH SIZE 76 BY 11 ROW 10 COLUMN 3 USE-TEXT NO-BOX NO-LABELS OVERLAY.

ASSIGN glb_cdprogra = "sumlot"
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
        DO: /******  Magui testes 
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_bcaixa.
            MESSAGE glb_dscritic.
            DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_nrdcaixa
                    WITH FRAME f_opcao.
            *******/
            LEAVE.
        END.
  
END.

ASSIGN edi_criticas:SCREEN-VALUE = "".
CLEAR FRAME fra_criticas ALL.
HIDE FRAME fra_criticas NO-PAUSE.

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_opcao.
VIEW FRAME f_bcaixa.    
PAUSE(0).
/* .......................................................................... */
