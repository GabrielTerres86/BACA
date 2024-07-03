begin

update cecred.crapseg s
   set s.cdsitseg = 5,
       s.dtcancel = trunc(sysdate)
 where cdcooper = 5
   and nrdconta = 99939932
   and nrctrseg = 147361;
   
update cecred.tbseg_prestamista s
   set s.tpregist = 0,
       s.dtrecusa = trunc(sysdate),
       s.tprecusa = 8
 where cdcooper = 5
   and nrdconta = 99939932
   and nrctrseg = 147361;
   
commit;
end;   