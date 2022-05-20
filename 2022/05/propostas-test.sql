begin
  
update tbseg_nrproposta a
set a.dhseguro = null
where not exists
      (select 1
      from crawseg x
      where x.nrproposta = a.nrproposta)
and not exists
      (select 1
      from tbseg_prestamista x
      where x.nrproposta = a.nrproposta)
and a.dhseguro is not null;

commit;

end;