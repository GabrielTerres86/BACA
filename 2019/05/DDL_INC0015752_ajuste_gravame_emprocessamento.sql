/*
DDL_INC0015752 - Ajuste Gravames Viacredi
Ana Volles - 23/05/2019

Viacredi - lotes 3612 e 3574
Contas: 8588889 e 9597042
*/

begin 
--VIACREDI
  /* Processado com Critica */
  update crapbpr c
     set c.cdsitgrv = 3
   where c.cdcooper = 1
     and c.progress_recid in (5829063, 5752538);
 
  update crapgrv c
   set c.dtretgrv = trunc(sysdate)
   where c.cdcooper = 1
   and c.progress_recid in (4732241, 4656636)
   and c.dtretgrv is null;   

  commit;

exception
  
  when others then
  
    rollback;

end;
