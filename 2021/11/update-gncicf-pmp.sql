begin

update gncpicf f 
  set f.flgenvio = 0
where f.tpregist = 2 
  and f.flgenvio = 1;

commit;
end;
