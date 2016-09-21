/* ..........................................................................

   Programa: Includes/gerarazao_dtl.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir cabecalho de inicio de lancamentos por data.

............................................................................. */

IF   aux_contlinh = 0   THEN
     DO:
         { includes/gerarazao_cab.i }     
     END.
ELSE
IF   aux_contlinh >= 76   THEN
     DO:
         { includes/gerarazao_nul.i }
         { includes/gerarazao_cab.i }
     END.
ELSE
     DO:
         PUT STREAM str_1 aux_novalinh + rel_linhpont FORMAT "x(132)" SKIP.
         aux_contlinh = aux_contlinh + 1.
     END.
     
PUT STREAM str_1 aux_novalinh + 
                 STRING("LANCAMENTOS DO DIA " + 
                        STRING(aux_contdata,"99/99/9999"), "x(131)")
                 FORMAT "x(132)"
                 SKIP.

PUT STREAM str_1 aux_novalinh + rel_linhpont FORMAT "x(132)" SKIP.
 
aux_contlinh = aux_contlinh + 2.

/*.......................................................................... */
