/* ..........................................................................

   Programa: Includes/crps086_5.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                         Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps086.p.
   Objetivo  : Gera cabecalho numero 5.

............................................................................. */

ASSIGN mex_indsalto = " "
       mex_registro = mex_indsalto + STRING(reg_cabmex05,"x(132)").

PUT STREAM str_1 mex_registro SKIP.

/* .......................................................................... */
