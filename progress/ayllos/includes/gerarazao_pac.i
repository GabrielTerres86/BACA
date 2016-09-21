/* ..........................................................................

   Programa: Includes/gerarazao_pac.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 09/08/2013

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir o total de lancamentos do PAC.

   Alteracao : Inclusao do tratamento para imprimir asteriscos ao final da
               pagina (Julio).

               03/02/2006 - Unificacao dos bancos - Eder
               
               009/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
............................................................................. */

IF   aux_contlinh > 82   THEN
     DO:
         { includes/gerarazao_nul.i }
         { includes/gerarazao_cab.i }         
     END.
ELSE
     DO:     
         IF   NOT aux_histcred   THEN
              PUT STREAM str_1 aux_novalinh + STRING(FILL(" ", 102) + 
                               FILL("-", 14), "x(131)") FORMAT "x(132)" SKIP. 
         ELSE
              PUT STREAM str_1 aux_novalinh + STRING(FILL(" ", 118) + 
                               FILL("-", 14), "x(131)") FORMAT "x(132)" SKIP. 

         aux_contlinh = aux_contlinh + 1.
     END.
     
FIND crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                   crapage.cdagenci = rel_cdagenci  NO-LOCK NO-ERROR.

IF   AVAILABLE crapage   THEN
     rel_nmextage = crapage.nmextage.
ELSE
     rel_nmextage = "".

IF   NOT aux_histcred   THEN
     rel_vllamnto = STRING(rel_ttlanage, "zzz,zzz,zz9.99").
ELSE
     rel_vllamnto = FILL(" ", 15) + STRING(rel_ttlanage, "zzz,zzz,zz9.99").
     
PUT STREAM str_1 aux_novalinh + 
                 STRING("    TOTAL PA  ( " + 
                        STRING(TRIM(STRING(rel_cdagenci,"zz9")) + " - " +
                               TRIM(rel_nmextage) + " )  ", "x(40)") +  
                        FILL(" ", 14) + FILL("-", 13) + ">   " +
                        STRING(rel_nrctadeb, "zzz9") + "      " +
                        STRING(rel_nrctacrd, "zzz9") + " " +
                        STRING(rel_vllamnto, "x(30)"), "x(131)")
                 FORMAT "x(132)"
                 SKIP.
 
aux_contlinh = aux_contlinh + 1.
/*.......................................................................... */

