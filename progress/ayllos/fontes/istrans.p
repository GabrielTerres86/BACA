/* .............................................................................

   Programa: fontes/istrans.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */
/* istrans.p */

DEFINE VARIABLE istrans AS LOGICAL INITIAL yes.

DO ON ERROR UNDO:
  istrans = no.
  UNDO, LEAVE.
END.

/* Se a variavel foi desfeita dentro DO ON ERROR, entao uma */
/* transacao foi ativada quando esse procedimento foi chamado. */
/* Use argumento para identificar de onde foi chamada. */


IF istrans
THEN  MESSAGE "Transacao ativa em" "{1}".
ELSE  MESSAGE "Transacao nao ativa em" "{1}".
