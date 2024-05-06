begin

update cecred.tbseg_prestamista t
   set t.tpregist = 0
 where cdcooper = 11
   and nrdconta = 99198738
   and nrctrseg = 361651;
   
update cecred.crapseg s
   set s.cdsitseg = 5
 where cdcooper = 11
   and nrdconta = 99198738
   and nrctrseg = 361651
   and tpseguro = 4;     
   
commit;
end;   