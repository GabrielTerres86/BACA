/* ..........................................................................

   Programa: Includes/crps086_2.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                         Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps086.p.
   Objetivo  : Gera cabecalho numero 2.

............................................................................. */

ASSIGN aux_nrdordem = aux_nrdordem + 1
       mex_indsalto = " "
       mex_registro = mex_indsalto + STRING(reg_cabmex02 +
                                     STRING(aux_nrdordem,"zzz,zz9"),"x(132)").

PUT STREAM str_1 mex_registro SKIP.

/* .......................................................................... */
