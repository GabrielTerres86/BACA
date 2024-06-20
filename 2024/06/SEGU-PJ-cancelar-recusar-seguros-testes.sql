begin

update cecred.crapseg s
   set cdsitseg = 2,
       dtcancel = SYSDATE
 where cdcooper = 5 
   and nrdconta = 99955687 
   and nrctrseg = 147317;  
   
update cecred.tbseg_prestamista t
   set tpregist = 0
 where cdcooper = 5 
   and nrdconta = 99955687 
   and nrctremp = 148449;       
   
update cecred.crapseg s
   set cdsitseg = 5,
       dtcancel = SYSDATE
 where cdcooper = 5 
   and nrdconta = 99963531 
   and nrctrseg = 147319;  
   
update cecred.tbseg_prestamista t
   set tpregist = 0,
       dtrecusa = SYSDATE
 where cdcooper = 5 
   and nrdconta = 99963531 
   and nrctremp = 148451;  
   
commit;
end;   