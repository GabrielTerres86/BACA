/* ..........................................................................

   Programa: Includes/crps019_7.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                       Ultima atualizacao: 03/12/93

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps019.p.
   Objetivo  : Gera a linha de detalhe.

............................................................................. */

ASSIGN mex_indsalto = " "
       mex_registro = mex_indsalto + STRING(reg_lindetal,"x(132)").

PUT STREAM str_1 mex_registro SKIP.

/* .......................................................................... */
