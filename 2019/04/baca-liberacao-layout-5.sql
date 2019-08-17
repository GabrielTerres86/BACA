begin
  update gnconve c
     set c.flgvlcpf = 1
   where c.nrlayout = 5;
  update gnconve c
     set c.flgvlcpf = 0
   where c.nrlayout = 4;
  commit;
exception
  when others then
    rollback;
end;