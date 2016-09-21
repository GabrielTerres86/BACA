/* ..........................................................................

   Programa: Includes/crps038_1.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/92.                         Ultima atualizacao: 08/12/93

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps038.p.
   Objetivo  : Gera cabecalho numero 1.

............................................................................. */

mex_registro = mex_indsalto + STRING(reg_cabmex01,"x(132)").

PUT STREAM str_1 mex_registro SKIP.

/* .......................................................................... */
