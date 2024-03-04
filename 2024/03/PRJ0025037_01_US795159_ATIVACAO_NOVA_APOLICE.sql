Declare
begin    
    update cecred.tbseg_nrproposta p set p.dhseguro = sysdate where p.dhseguro is null and p.tpcustei = 1;
  end loop;
  commit;
exception
  when others then   
    null;
end;
