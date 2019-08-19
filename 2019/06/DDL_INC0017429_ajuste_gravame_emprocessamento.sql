/*
DDL_INC0017429 - Ajuste Gravames CREDIFOZ
Ana Volles - 07/06/2019

Viacredi - lote 3072
Conta: 479667
*/

begin 
  /* Processado com Critica */
  update crapbpr c
     set c.cdsitgrv = 3
   where c.cdcooper = 11
     and c.progress_recid in (5869518);
 
  update crapgrv c
   set c.dtretgrv = trunc(sysdate)
   where c.cdcooper = 11
   and c.progress_recid in (4782112)
   and c.dtretgrv is null;   

  commit;

exception
  
  when others then
  
    rollback;

end;
