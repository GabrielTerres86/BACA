begin
  
update cecred.tbseg_prestamista t
   set t.tpregist = 0
 where t.cdcooper = 16
   and t.nrdconta = 99833557
   and t.nrctremp = 743965;
   
update cecred.crapseg s
   set s.cdsitseg = 5
  where s.cdcooper = 16
   and s.nrdconta = 99833557
   and s.nrctrseg = 441849;
   
commit;
end;