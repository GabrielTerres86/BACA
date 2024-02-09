begin
  
update cecred.crapseg s 
   set s.cdsitseg = 2
 where s.cdcooper = 16
   and s.nrdconta = 99648296
   and s.nrctrseg IN (441771,441778);
   
update cecred.tbseg_prestamista t
   set t.tpregist = 0
 where t.cdcooper = 16
   and t.nrdconta = 99648296
   and t.nrctrseg IN (441771,441778); 
   
commit;
end;     