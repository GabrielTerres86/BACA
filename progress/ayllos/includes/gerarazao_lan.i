/* ..........................................................................

   Programa: Includes/gerarazao_lan.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 03/04/2012

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir o lancamento do associado.

               {1} -> Nome do Associado
               
   Alteracao : 24/02/2011 - Ajuste no layout do titulo (Henrique).           
   
               03/04/2012 - Ajuste para impressao de valor negativo (David).
               
............................................................................. */

IF   aux_contlinh > 84   THEN
     DO:
         { includes/gerarazao_cab.i }
         { includes/gerarazao_tit.i }       
     END. 

IF  rel_vllandeb = 0   THEN
    rel_vllamnto = FILL(" ", 15) + STRING(rel_vllancrd, "zzzzzz,zz9.99-").
ELSE
    rel_vllamnto = STRING(rel_vllandeb, "zzzzzz,zz9.99-").

PUT STREAM str_1 aux_novalinh + 
                 STRING(FILL(" ", 2) + 
                        STRING(rel_dtlanmto, "99/99/9999") + " " +
                        STRING(rel_cdhistor, "zzz9") + " " +
                        STRING(rel_cdagenci, "zz9") + " " + 
                        STRING(rel_nrdconta, "zzzz,zz9,9") + " " +
                        STRING({1}, "x(29)") + " " +
                        STRING(rel_nrdocmto, "zzzzzzzzzzzzzzzzzz9") + " " +
                        STRING(rel_nrctadeb, "zzzz9999") + " "+ 
                        STRING(rel_nrctacrd, "zzzzz9999") + " "+            
                        STRING(rel_vllamnto, "x(30)"), "x(131)")
                 FORMAT "x(132)"
                 SKIP.
                 
aux_contlinh = aux_contlinh + 1.
/* .......................................................................... */
