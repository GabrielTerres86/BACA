/* ..........................................................................

   Programa: Includes/crps019_10.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Agosto/2001.                       Ultima atualizacao: 
   
   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps019.p.
   Objetivo  : Gera cabecalho numero 10.

............................................................................. */

ASSIGN mex_registro = mex_indsalto + STRING(reg_cabmex10,"x(132)").

PUT STREAM str_1 mex_registro SKIP.

/* .......................................................................... */
