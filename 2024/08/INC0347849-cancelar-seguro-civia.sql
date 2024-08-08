begin

update cecred.crapseg s
   set s.cdsitseg = 2,
       s.dtcancel = trunc(sysdate),
       s.cdmotcan = 4
 where cdcooper = 13 
   and nrdconta = 80971270
   and nrctrseg = 631897; 
   
update cecred.tbseg_prestamista t
   set t.tpregist = 0
 where cdcooper = 13 
   and nrdconta = 80971270
   and nrctrseg = 631897
   and nrctremp = 369110;  
   
commit;
end;   