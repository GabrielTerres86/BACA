/* ..............................................................................

Procedure: controle_foco.p 
Objetivo : Controle para manter o foco do windows
Autor    : Evandro
Data     : Maio 2010


Ultima alteração:

............................................................................... */

DEFINE  INPUT PARAMETER par_ativafoc    AS LOGICAL      INIT NO     NO-UNDO.


/* O script VBS que controla o foco, somente "puxa" foco quando o titulo
   estiver como " Autoatendimento" para nao mexer no foco de um campo quando
   estiver sendo digitada alguma informacao */
IF  par_ativafoc   THEN
    CURRENT-WINDOW:TITLE = " Autoatendimento".
ELSE
    CURRENT-WINDOW:TITLE = "Autoatendimento".

/* ........................................................................... */


