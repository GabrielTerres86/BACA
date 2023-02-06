begin

update cecred.crapseg 
   set dtfimvig  = to_date(trunc(sysdate),'dd/mm/yyyy'),
       dtcancel  = to_date(trunc(sysdate),'dd/mm/yyyy'),
       cdsitseg  = 5,
       cdopeexc  = 1,
       cdageexc  = 1,
       dtinsexc  = to_date(trunc(sysdate),'dd/mm/yyyy'),
       cdopecnl  = 1
 where cdcooper  = 1
   and nrdconta  = 1847406
   and nrctrseg  = 1196186
   and tpseguro  = 4;  
   
update cecred.crapseg 
   set dtfimvig  = to_date(trunc(sysdate),'dd/mm/yyyy'),
       dtcancel  = to_date(trunc(sysdate),'dd/mm/yyyy'),
       cdsitseg  = 5,
       cdopeexc  = 1,
       cdageexc  = 1,
       dtinsexc  = to_date(trunc(sysdate),'dd/mm/yyyy'),
       cdopecnl  = 1
 where cdcooper  = 1
   and nrdconta  = 11766344
   and nrctrseg  = 1218719
   and tpseguro  = 4;   
   
update cecred.tbseg_prestamista
   set tpregist = 0,
	   cdmotrec = 154,
       tprecusa = 'Ajuste via script INC0246337',
       dtrecusa = to_date(trunc(sysdate),'dd/mm/yyyy')
 where cdcooper = 1
   and nrdconta = 11766344
   and nrctrseg = 1218719;    

commit;

end;