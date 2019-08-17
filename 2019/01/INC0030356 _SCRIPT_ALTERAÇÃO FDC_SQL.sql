-- Created on 11/01/2019 by T0032011 
declare 
begin
begin
update crapfdc i
   set i.nrcheque = CAST(RPAD(i.nrcheque, 10, 9) AS INT)
 where i.progress_recid in (28794012, 28794015);
 
  exception 
  when others then 
  rollback;
  end;
  commit;
end;


