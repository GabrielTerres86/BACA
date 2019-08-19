begin
  begin
  
    update crapfdc i
       set i.nrcheque = cast(substr(i.nrcheque, 1, 1) as int)
     where i.progress_recid in (28794015, 28794012);
  exception
    when others then
    
      rollback;
    
  end;
  begin
  
    update crapneg i
       set i.cdagechq = 103
     where i.progress_recid in (6975092, 6928206, 6761057, 6780367);
  
  exception
    when others then
    
      rollback;
    
  end;

  commit;

end;
