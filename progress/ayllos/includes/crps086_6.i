/* ..........................................................................

   Programa: Includes/crps086_6.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                         Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps086.p.
   Objetivo  : Gera cabecalho numero 6.

............................................................................. */

ASSIGN mex_indsalto = "0"
       mex_registro = mex_indsalto + STRING(reg_cabmex06,"x(132)").

PUT STREAM str_1 mex_registro SKIP.

/* .......................................................................... */
