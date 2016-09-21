/* ..........................................................................

   Programa: Includes/gerarazao_nul.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Outubro/2003.                    Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir asteristos nas linhas restantes das paginas.

............................................................................. */

DO WHILE aux_contlinh <= 84:

   PUT STREAM str_1 aux_novalinh + rel_linhastr FORMAT "x(132)" SKIP.
   aux_contlinh = aux_contlinh + 1.
   
END.

/*............................................................................*/