/*
include para chamar a tela de erro

Alteracoes: 15/12/2008 - Ajuste para unificacao dos bancos de dados (Evandro).

*/

FIND FIRST craperr NO-LOCK  where
           craperr.cdcooper = crapcop.cdcooper AND
           craperr.cdagenci = INT(v_pac)   and
           craperr.nrdcaixa = INT(v_caixa) no-error.
  
IF AVAIL craperr THEN DO:
    {&out} "<script>window.open('mensagem.p','werro','height=220,width=400,scrollbars=yes,alwaysRaised=true')</script>".
           
END.

