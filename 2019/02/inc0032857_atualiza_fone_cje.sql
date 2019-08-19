-- INC0032857 - Solicitação de novo cartão não funciona
update crapcje e
   set e.nrfonemp = '0'
 where e.cdcooper = 1
   and e.nrdconta = 2642280;

commit;
