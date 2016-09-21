/* .............................................................................

   Programa: Fontes/Visualiza_fitacx.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Edson/Margarete
   Data    : Dezembro/2002                       Ultima atualizacao: 19/12/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para mostrar na tela a FITA DE CAIXA.

   Alteracoes: 19/12/2011 - Modificado a tela para aparecer com BROWSE e nao
                            mais como um campo EDITOR.
............................................................................. */

{ includes/var_online.i }

{ includes/var_bcaixa.i }

ASSIGN glb_cdprogra = "bcaixa"
       glb_flgbatch = FALSE
       glb_cdcritic = 0.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    INPUT STREAM str_2 FROM VALUE (aux_nmarqimp) NO-ECHO.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

      ASSIGN aux_nrsequen = aux_nrsequen + 1. 

      CREATE tt-linhfita.

      ASSIGN tt-linhfita.nrsequen = aux_nrsequen
             tt-linhfita.deslinha = aux_setlinha.
    END.

    INPUT STREAM str_2 CLOSE.

    OPEN QUERY q-linhfita FOR EACH tt-linhfita.
    UPDATE     b-linhfita WITH FRAME fra_linhfita. 

    WAIT-FOR GO OF b-linhfita IN FRAME fra_linhfita. 
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
