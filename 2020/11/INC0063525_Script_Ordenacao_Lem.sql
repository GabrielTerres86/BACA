/*Correção da Ordenação dos Lançamentos da LEM*/

begin
 
update cecred.craplem l
   set l.progress_recid = CRAPLEM_SEQ.NEXTVAL,
       l.dthrtran = (select l.dthrtran
                      from craplem l
                     where l.cdcooper = 10
                       and l.nrdconta = 82317
                       and l.dtmvtolt = '06/10/2020' 
                       and l.cdhistor = 2306
                       and l.nrctremp = 16361) -- Atualizar hora conforme lançamento da taxa, necessário para ordenação correta.
 where l.cdcooper = 10
   and l.nrdconta = 82317
   and l.dtmvtolt = '06/10/2020' 
   and l.cdhistor = 1036
   and l.nrctremp = 16361;

for r1 in (select rowid from (
            select l.rowid
              from craplem l
             where l.cdcooper = 10
               and l.nrdconta = 82317
               and l.dtmvtolt >= '06/10/2020' 
               and l.cdhistor <> 1036
               and l.nrctremp = 16361
               order by progress_recid asc)) loop
   update cecred.craplem l
      set l.progress_recid = CRAPLEM_SEQ.NEXTVAL
    where l.rowid = r1.rowid;
   
end loop;
   commit;
exception
  when others then
    rollback;
end;

   
   
 
