begin

update cecred.tbseg_prestamista
   set nrctrseg = 309663
 where cdcooper = 1
   and nrdconta = 6517544
   and nrproposta = '770351888920';
   
update cecred.tbseg_prestamista
   set nrctrseg = 309665
 where cdcooper = 1
   and nrdconta = 6517544
   and nrproposta = '770351888911';
   
update cecred.tbseg_prestamista
   set nrctrseg = 352116
 where cdcooper = 1
   and nrdconta = 6517544
   and nrproposta = '770351888938';
   
update cecred.tbseg_prestamista
   set nrctrseg = 352120
 where cdcooper = 1
   and nrdconta = 6517544
   and nrproposta = '770351888946';  
   
update cecred.crapseg
   set cdsitseg = 2,
       dtcancel = trunc(sysdate)
 where cdcooper = 1
   and nrdconta = 6517544
   and nrctrseg = 1152825
   and tpseguro = 4;     


commit;
end;
