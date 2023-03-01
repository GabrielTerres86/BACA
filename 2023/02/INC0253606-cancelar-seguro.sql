begin

update cecred.tbseg_prestamista
   set tpregist = 0
 where cdcooper	= 11
   and nrdconta	= 597945
   and nrctrseg	= 83501
   and nrproposta = '770349438020';

commit;

end;