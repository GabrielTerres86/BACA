begin
  update cecred.menumobile e
     set e.habilitado = 1, e.versaominimaapp = '2.38.0'
   where e.menupaiid = 1027
     and e.menumobileid = 1028;
  commit;
exception
  when others then
    dbms_output.put_line('Erro: ' || sqlerrm);
end;
/
