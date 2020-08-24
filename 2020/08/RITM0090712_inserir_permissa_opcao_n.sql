declare
  cursor cr_crapope is
    select co.cdoperad, co.cdcooper
      from crapope co
     where co.cdcooper = 11
       and co.cdsitope = 1
       and co.cdoperad <> '1';
  rw_crapope cr_crapope%rowtype;
begin
  for rw_crapope in cr_crapope loop
    begin
      insert into crapace
        (nmdatela,
         cddopcao,
         cdoperad,
         nmrotina,
         cdcooper,
         nrmodulo,
         idevento,
         idambace)
      values
        ('MATRIC',
         'N',
         rw_crapope.cdoperad,
         ' ',
         rw_crapope.cdcooper,
         1,
         0,
         2);
    exception
      when others then
        null;
    end;
  end loop;
  commit;
end;
