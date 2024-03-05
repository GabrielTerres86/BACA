begin
update cecred.tbseg_prestamista t
   set t.tpregist = 0
where t.cdcooper = 16
   and t.nrdconta = 99056291
   and t.nrctrseg = 371721
   and t.nrctremp = 466721;
   
update cecred.crapseg s
   set s.cdsitseg = 5
  where s.cdcooper = 16
   and s.nrdconta = 99056291
   and s.nrctrseg = 371721;
commit;
end;