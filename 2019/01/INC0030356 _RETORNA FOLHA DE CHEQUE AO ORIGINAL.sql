begin
  begin
    update crapfdc i
       set i.nrcheque = SUBSTR(i.nrcheque, 1, 1)
     where i.progress_recid in (28794012, 28794015);
  exception
    when others then
      rollback;
  end;
  commit;
end;
