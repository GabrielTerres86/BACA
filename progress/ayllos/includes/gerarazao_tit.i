/* ..........................................................................

   Programa: Includes/gerarazao_tit.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Outubro/2003.                    Ultima atualizacao: 09/08/2013

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir o titulo dos lancamentos.

   Alteracao : 17/11/2003 - Correcao na quebra de pagina (Julio).
    
               24/02/2011 - Ajuste no layout do titulo (Henrique).
               
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
............................................................................. */

IF   aux_contlinh > 81   THEN
     DO:                              
         { includes/gerarazao_nul.i }
         { includes/gerarazao_cab.i }
     END.

PUT STREAM str_1 
           aux_pulalinh + 
           STRING(FILL(" ", 8 ) + "DATA HIST PA   NRD.CONTA NOME" +
                  FILL(" ", 36) + "DOCUMENTO CTA.DEB. CTA.CRED. " +
                  "  VALOR DEBITO  VALOR CREDITO", "x(131)")
                  FORMAT "x(132)"                
                  SKIP.
                  
PUT STREAM str_1 
           aux_novalinh + 
           STRING(FILL(" ", 2) + "---------- ---- --- ---------- " +
                  FILL("-", 29) + " " + "------------------- -------- ---------"
                   + " -------------- --------------", "x(131)")
                  FORMAT "x(132)" 
                  SKIP.
                  
aux_contlinh = aux_contlinh + 3.
/* .......................................................................... */
