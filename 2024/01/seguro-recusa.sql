begin
  
update cecred.tbseg_prestamista t
   set t.tpregist = 0
 where t.cdcooper = 16
   and t.nrdconta = 96459727
   and t.nrctremp = 743962;
   
update cecred.crapseg s
   set s.cdsitseg = 5
  where s.cdcooper = 16
   and s.nrdconta = 96459727
   and s.nrctrseg = 441843;
   
commit;
end;