/*
DDL_INC0017429 - Ajuste Gravames CREDIFOZ
Ana Volles - 07/06/2019

Viacredi - lote 3072
Conta: 479667
*/

begin 
  /* Processado com Critica */
  update crapbpr c
     set c.cdsitgrv = 1
   where c.cdcooper = 11
     and c.progress_recid in (5869518);
 
  update crapgrv c
   set c.dtretgrv = NULL
   where c.cdcooper = 11
   and c.progress_recid in (4782112);

  commit;

exception
  
  when others then
  
    rollback;

end;
