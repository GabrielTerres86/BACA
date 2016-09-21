/* ..........................................................................

   Programa: Includes/gerarazao_cab.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 06/11/2007

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Gera cabecalho da pagina.
   
   Atualizacoes : 26/01/2004 - Alteracao no titulo de DIARIO AUXILIAR para
                               RAZAO AUXILIAR (Julio).
                  21/11/2005 - Alterar razao para diario(Mirtes)
                  
                  06/11/2007 - Acerto no numero de pagina, estouro de campo (Ze)
............................................................................. */

rel_contapag = rel_contapag + 1.

rel_cablinha = aux_novapagi + FILL(" ", 65 - INT(LENGTH(rel_nmcooper) / 2)) +
                              STRING(rel_nmcooper, "x(131)").
PUT STREAM str_1 rel_cablinha FORMAT "x(132)" SKIP.
aux_contlinh = 1.

rel_cablinha = aux_novalinh + 
               FILL(" ", 65 - INT(LENGTH(TRIM("DIARIO AUXILIAR DE " +
                                               rel_tpdrazao)) / 2)) +
               STRING("DIARIO AUXILIAR DE " + rel_tpdrazao, "x(131)").
PUT STREAM str_1 rel_cablinha FORMAT "x(132)" SKIP.
aux_contlinh = aux_contlinh + 1.

rel_cablinha = aux_novalinh + STRING(FILL(" ", 49) + "PERIODO: " + 
                              STRING(aux_dtperini,"99/99/9999") + " a " +      
                              STRING(aux_dtperfim, "99/99/9999") +
                              FILL(" ", 37) + "PAGINA: " + 
                              STRING(rel_contapag, "99999")
                              , "x(131)").
PUT STREAM str_1 rel_cablinha FORMAT "x(132)" SKIP.
aux_contlinh = aux_contlinh + 1.

PUT STREAM str_1 aux_novalinh + rel_linhpont FORMAT "x(132)" SKIP.
aux_contlinh = aux_contlinh + 2.

/* .......................................................................... */