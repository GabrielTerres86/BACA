begin
  update tbseg_prestamista a set nrctremp = 0 where a.cdapolic = 246401;
  commit;
exception
  when others then
    dbms_output.put_line('Erro tbseg_prestamista: ' || sqlerrm);
    rollback;
end;
