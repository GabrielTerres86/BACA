begin
  update tbseg_prestamista p
     set p.tpregist = 1
   where p.cdcooper in (11, 14)
     and p.tpcustei = 0;
  commit;
end;
/
