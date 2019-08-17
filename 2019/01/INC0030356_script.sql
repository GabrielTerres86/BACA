-- Created on 10/01/2019 by T0032011 --INC0030356
declare

begin

  begin
    delete from crapfdc crapfdc
     where crapfdc.progress_recid in
           (36457883, 36457884, 36457890, 36457891);
  
  exception
    when others then
      rollback;
  end;
  commit;
end;
