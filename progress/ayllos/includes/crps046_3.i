/* ..........................................................................

   Programa: Includes/crps046_3.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/93.                       Ultima atualizacao: 03/12/93

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps046.p.
   Objetivo  : Gera cabecalho numero 3.

............................................................................. */

ASSIGN mex_indsalto = "0"
       mex_registro = mex_indsalto + STRING(reg_cabmex03,"x(132)").

PUT STREAM str_1 mex_registro SKIP.

/* .......................................................................... */
