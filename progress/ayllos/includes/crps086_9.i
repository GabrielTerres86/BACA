/* ..........................................................................

   Programa: Includes/crps086_4.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Julho/2001.                         Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps086.p.
   Objetivo  : Gera cabecalho numero 9.

............................................................................. */

ASSIGN mex_indsalto = "0"
       mex_registro = mex_indsalto + STRING(reg_cabmex09,"x(132)").

PUT STREAM str_1 mex_registro SKIP.

/* .......................................................................... */
