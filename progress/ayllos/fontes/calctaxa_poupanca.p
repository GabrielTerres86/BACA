/* .............................................................................
   Programa: Fontes/calctaxa_poupanca.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Magui
   Data    : Setembro/2006                   Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular o valor da poupanca diaria e mensal para comparar
               com a do cdi.

............................................................................. */

{ includes/var_batch.i }
{ includes/var_faixas_ir.i "NEW"}

DEF INPUT  PARAMETER aux_qtdiaute AS INTE                 NO-UNDO.
DEF INPUT  PARAMETER aux_vlmoefix LIKE crapmfx.vlmoefix   NO-UNDO.
DEF OUTPUT PARAMETER aux_txmespop AS DECIMAL DECIMALS 6   NO-UNDO.
DEF OUTPUT PARAMETER aux_txdiapop AS DECIMAL DECIMALS 6   NO-UNDO.


ASSIGN aux_txmespop = ROUND(aux_vlmoefix / (1 - (aux_perirtab[1] / 100)),6)
       aux_txdiapop = ROUND(((EXP(1 + (aux_txmespop / 100),
                                              1 / aux_qtdiaute) - 1) * 100),6).
/* .......................................................................... */
