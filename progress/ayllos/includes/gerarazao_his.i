/* ..........................................................................

   Programa: Includes/gerarazao_his.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 17/11/2003

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprime Titulo do historico.
   
               {1} -> Descricao do Historico.

   Alteracao : 17/11/2003 - Correcao na quebra de pagina (Julio)
............................................................................. */

IF   aux_contlinh > 79 THEN
     DO:
         { includes/gerarazao_nul.i }
         { includes/gerarazao_cab.i }
     END.
        
rel_hislinha = aux_pulalinh + 
               STRING(FILL(" ", 2) +
                      STRING(TRIM(STRING(rel_cdhistor, "zzz9")) + " - " +
                             STRING(rel_dshistor, "x(50)"), "x(57)") + 
                      FILL(" ", 45) +  "( D - "  +
                      STRING(rel_nrctadeb, "zzz9") + " )   ( C - " + 
                      STRING(rel_nrctacrd, "zzz9") + " )", "x(131)").
                                  
PUT STREAM str_1 rel_hislinha FORMAT "x(132)" SKIP.

aux_contlinh = aux_contlinh + 2.

/*............................................................................*/

