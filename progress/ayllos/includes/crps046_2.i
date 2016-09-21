/* ..........................................................................

   Programa: Includes/crps046_2.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/93.                       Ultima atualizacao: 03/12/93

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps046.p.
   Objetivo  : Gera cabecalho numero 2.

............................................................................. */

ASSIGN aux_nrdordem = aux_nrdordem + 1
       mex_indsalto = "0"
       mex_registro = mex_indsalto + STRING(reg_cabmex02 +
				     STRING(aux_nrdordem,"z,zz9"),"x(132)").

PUT STREAM str_1 mex_registro SKIP.

/* .......................................................................... */
