begin
  update menumobile e
     set e.habilitado = 0, e.versaominimaapp = '3.0.0'
   where e.menupaiid = 1027
     and e.menumobileid = 1028;
  commit;
exception
  when others then
    dbms_output.put_line('Erro: ' || sqlerrm);
end;
/
