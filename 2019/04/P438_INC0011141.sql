/* Ajustes para permitir efetivar emprestimo, visto que ja foi aprovada e possui gravames */

update crapprp x
  set x.nrinfcad = 1
where x.cdcooper = 1
and x.nrdconta = 9705112
and x.nrctrato = 1471425;

commit;
