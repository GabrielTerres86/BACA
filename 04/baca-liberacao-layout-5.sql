begin
  update gnconve c
     set c.flgvlcpf = 1
   where c.nrlayout = 5;
  commit;
exception
  when others then
    rollback;
end;