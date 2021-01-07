declare
  cursor cr_craptel is
    select rowid
      from craptel c
     where c.nmdatela = 'MATRIC'
       and trim(c.nmrotina) is null;
  rw_craptel cr_craptel%rowtype;
begin
  for rw_craptel in cr_craptel loop
    update craptel c
       set c.cdopptel = c.cdopptel || ',N',
           c.lsopptel = c.lsopptel || ',ADMISSAO SIMPLIFICADA'
     where rowid = rw_craptel.rowid;
  end loop;
  commit;
end;
