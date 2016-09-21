/* ..........................................................................

   Programa: Includes/gerarazao_tot.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir o total do historico.

............................................................................. */

IF   aux_contlinh > 84   THEN
     DO:
         { includes/gerarazao_cab.i }
     END.

IF   NOT aux_histcred   THEN
     rel_vllamnto = "12".
ELSE
     rel_vllamnto = "27".

rel_hislinha = STRING("  TOTAL HISTORICO ( " +
               TRIM(STRING(rel_cdhistor, "zzz9")) + " - " + 
               STRING(TRIM(rel_dshistor) + " )", "x(52)") +
               FILL(" ", 12 - LENGTH(STRING(rel_cdhistor))) +
               FILL("=", INT(rel_vllamnto)) + ">  " +
               STRING(rel_ttlanmto, "zzz,zzz,zz9.99"),"x(131)").

IF   rel_cdhistor < 9998   THEN
     PUT STREAM str_1 aux_novalinh + rel_hislinha FORMAT "x(132)" SKIP.
ELSE
     PUT STREAM str_1 aux_pulalinh + rel_hislinha FORMAT "x(132)" SKIP.

aux_contlinh = aux_contlinh + 1.
/* .......................................................................... */