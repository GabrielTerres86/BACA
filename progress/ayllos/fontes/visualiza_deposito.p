/* .............................................................................

   Programa: Fontes/Visualiza_deposito.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Edson
   Data    : Novmebro/2004                       Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para mostrar na tela os DEPOSITOS ACOLHIDOS NO CAIXA.

   Alteracoes:

............................................................................. */

{ includes/var_online.i }

{ includes/var_bcaixa.i }

ASSIGN glb_cdprogra = "bcaixa"
       glb_flgbatch = FALSE
       glb_cdcritic = 0.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   ENABLE edi_fitacx  WITH FRAME fra_fitacx.
   DISPLAY edi_fitacx WITH FRAME fra_fitacx.
   ASSIGN edi_fitacx:READ-ONLY IN FRAME fra_fitacx = YES.

   IF   edi_fitacx:INSERT-FILE(aux_nmarqimp)   THEN
        DO:
            ASSIGN edi_fitacx:cursor-line in frame fra_fitacx = 1.
            WAIT-FOR GO OF edi_fitacx IN FRAME fra_fitacx. 
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

ASSIGN edi_fitacx:SCREEN-VALUE = "".
CLEAR FRAME fra_fitacx ALL.
HIDE FRAME fra_fitacx NO-PAUSE.

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_opcao.
VIEW FRAME f_bcaixa.    
PAUSE(0).

/* .......................................................................... */
