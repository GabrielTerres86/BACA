-- INC0034387 - Deletar cartao criado errado na base de dados
delete crawcrd d
 where d.cdcooper = 13
   and d.nrdconta = 116572
   and d.nrctrcrd = 50686;
   
commit;
