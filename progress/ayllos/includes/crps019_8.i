/* ..........................................................................

   Programa: Includes/crps019_8.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo
   Data    : Janeiro/2001.                       Ultima atualizacao: 17/01/2001

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps019.p.
   Objetivo  : Gera impressao sobre o historico de limite de credito.

............................................................................. */

aux_incremnt = 1.

DO WHILE  aux_dslimite[aux_incremnt] <> "":  
   
   ASSIGN mex_indsalto = " "
          mex_registro = mex_indsalto + 
                         STRING(aux_dslimite[aux_incremnt],"x(132)")
          aux_incremnt = aux_incremnt + 1.   
   
   PUT STREAM str_1 mex_registro SKIP.

END.
/* .......................................................................... */