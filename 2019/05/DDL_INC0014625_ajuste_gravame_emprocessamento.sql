/*
DDL_INC0014625 - Ajuste Gravames Alto Vale
Ana Volles - 06/05/2019

ALTO VALE - são os lotes 2782, 2781 e 2759 
cc 41536-7 contrato 109588

select c.cdsitgrv, c.* from crapbpr c
 where c.cdcooper = 16
   and c.nrdconta = 415367
   and c.nrctrpro = 109588
   and c.cdsitgrv = 1;

select c.dtretgrv, c.* from crapgrv c 
 where c.cdcooper = 16
   and c.nrdconta = 415367
   and c.nrctrpro = 109588
   and c.nrseqlot = 2786
   and c.dtretgrv is null;
*/
begin 

  /* Processado com Critica */
  update crapbpr c
     set c.cdsitgrv = 3
   where c.cdcooper = 16
     and c.nrdconta = 415367
     and c.nrctrpro = 109588
     and c.cdsitgrv = 1;
   
  update crapgrv c
     set c.dtretgrv = trunc(sysdate)
   where c.cdcooper = 16
     and c.nrdconta = 415367
     and c.nrctrpro = 109588
     and c.nrseqlot = 2786
     and c.dtretgrv is null;

  commit;

exception
  
  when others then
  
    rollback;

end;
