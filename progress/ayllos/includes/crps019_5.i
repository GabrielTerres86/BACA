/* ..........................................................................

   Programa: Includes/crps019_5.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                       Ultima atualizacao: 03/12/93

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps019.p.
   Objetivo  : Gera cabecalho numero 5.

............................................................................. */

ASSIGN mex_indsalto = " "
       mex_registro = mex_indsalto + STRING(reg_cabmex05,"x(132)").

PUT STREAM str_1 mex_registro SKIP.

/* .......................................................................... */
