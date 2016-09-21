/* .............................................................................

   Programa: fontes/visualiza_ficha_cadastral.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Eduardo
   Data    : Junho/2006                       Ultima atualizacao:   /   /

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para mostrar na tela a FICHA CADASTRAL.

   Alteracoes:

............................................................................. */

{ includes/var_online.i }
{ includes/var_contas.i }
{ includes/var_ficha_cadastral.i }

PAUSE 0.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   ENABLE edi_ficha WITH FRAME fra_ficha.
   DISPLAY edi_ficha WITH FRAME fra_ficha.
   ASSIGN edi_ficha:READ-ONLY IN FRAME fra_ficha = TRUE.
     
   IF   edi_ficha:INSERT-FILE(aux_nmarqimp)   THEN
        DO:
            ASSIGN edi_ficha:CURSOR-LINE IN FRAME fra_ficha = 1.
            WAIT-FOR GO OF edi_ficha IN FRAME fra_ficha. 
        END.
   ELSE   
        DO:
            RUN fontes/critic.p.
            BELL.
            CLEAR FRAME f_bcaixa.
            MESSAGE glb_dscritic.
            DISPLAY glb_cddopcao tel_nrdconta WITH FRAME f_opcao.
            LEAVE.
        END.
  
END.

HIDE MESSAGE NO-PAUSE.

ASSIGN aux_confirma = "N".
         
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
   MESSAGE "Imprimir a Ficha Cadastral ? (S)im/(N)ao:"  UPDATE aux_confirma.

   LEAVE.
            
END.  /*  Fim do DO WHILE TRUE  */
         
IF   aux_confirma = "S"  THEN     /* Imprimir ficha cadastral */
     DO:
         ASSIGN aux_tipconsu = FALSE.

         RUN fontes/impficha_cadastral.p.
     END.

ASSIGN edi_ficha:SCREEN-VALUE = "".

CLEAR FRAME fra_ficha ALL.

HIDE FRAME fra_ficha NO-PAUSE.

/* ..........................................................................*/
