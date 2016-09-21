/* .............................................................................

   Programa: Fontes/bordero.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003                          Ultima atualizacao: 21/06/2004

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar BORDEROS DE LIMITE DE DESCONTO DE CHEQUES
               para a tela ATENDA.

   Alteracoes: 09/01/2004 - Alterado para mostrar os borderos em ordem
                            decrescente de numero do bordero (Edson).

               21/06/2004 - Alterado para implementar a rotina bordero_lst.p
                            (Edson).
                            
............................................................................. */

{ includes/var_online.i }

{ includes/var_atenda.i }

{ includes/var_bordero.i "NEW" }

RUN fontes/bordero_lst.p.

RUN fontes/bordero_1.p.

/* .......................................................................... */

