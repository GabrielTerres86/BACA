/* .............................................................................

   Programa: Fontes/listatel.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah\Edson
   Data    : Maio/93.                            Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas (on-line)
   Objetivo  : Mostrar a lista de lay-out's  de telas do sistema.

............................................................................. */

{ includes/listel.i NEW }

DEF SHARED VAR shr_dslistel AS CHAR                                 NO-UNDO.

MESSAGE "Aguarde...".

INPUT THROUGH ls layout/*.T* NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   s_chextent = s_chextent + 1.
   SET s_chlist[s_chextent] FORMAT "x(25)".

END.  /*  Fim do DO WHILE TRUE  */

INPUT CLOSE.

HIDE MESSAGE NO-PAUSE.

ASSIGN s_row      = 5
       s_column   = 52
       s_hide     = TRUE
       s_title    = " Telas "
       s_dbfilenm = ""
       s_multiple = FALSE
       s_chextent = s_chextent - 1.

RUN fontes/listel.p.

IF   s_chcnt = 0   THEN
     shr_dslistel = "".
ELSE
     shr_dslistel = s_chlist[s_choice[s_chcnt]].

/* .......................................................................... */
