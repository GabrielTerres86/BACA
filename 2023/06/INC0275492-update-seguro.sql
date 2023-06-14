begin

update cecred.crapseg
   set cdsitseg = 1,
       dtcancel = null
 where cdcooper = 6
   and nrdconta = 57770
   and nrctrseg = 102075
   and tpseguro = 4;
   
update cecred.tbseg_prestamista
   set tpregist = 3,
       dtrecusa = null,
       cdmotrec = null,
       tprecusa = null
 where cdcooper = 6
   and nrdconta = 57770
   and nrctrseg = 102075
   and nrctremp = 271200;

commit;
end;