/* ..........................................................................

   Programa: Includes/gerarazao_dat.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir o total de lancamentos da data.

............................................................................. */

IF   aux_contlinh > 83   THEN
     DO:
         { includes/gerarazao_nul.i }
         { includes/gerarazao_cab.i }
     END.
          
PUT STREAM str_1 aux_pulalinh + 
                 STRING("TOTAL DO DIA ( " + 
                        STRING(aux_contdata,"99/99/9999") + " )" +
                        FILL(" ", 25) + FILL("-", 47) + ">  " + 
                        STRING(rel_ttdebdia, "zzz,zzz,zz9.99") + " " +
                        STRING(rel_ttcrddia, "zzz,zzz,zz9.99"), "x(131)")
                 FORMAT "x(132)"
                 SKIP.
 
aux_contlinh = aux_contlinh + 2.
/*.......................................................................... */
