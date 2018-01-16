-- ALTERAR O TIPO DO AMBIENTE DA TELA MIGRADA - TAB089
update craptel tel
  set tel.idambtel = 0 -- DEVERÁ SER 2 (apenas web) EM PROD
 where tel.nmdatela = 'TAB089';