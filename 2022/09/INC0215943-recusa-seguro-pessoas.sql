begin

begin

update cecred.crapseg p 
   set dtfimvig  = trunc(sysdate),
       dtcancel  = trunc(sysdate),
       cdsitseg  = 5,
       cdopeexc  = 1,
       cdageexc  = 1,
       dtinsexc  = trunc(sysdate),
       cdopecnl  = 1
 where cdcooper  = 1 
   and nrdconta  = 8526370 
   and nrctrseg  = 1018727
   and tpseguro  = 4; 
   
update cecred.crapseg p 
   set dtfimvig  = trunc(sysdate),
       dtcancel  = trunc(sysdate),
       cdsitseg  = 5,
       cdopeexc  = 1,
       cdageexc  = 1,
       dtinsexc  = trunc(sysdate),
       cdopecnl  = 1
 where cdcooper = 1 
   and nrdconta = 8526370 
   and nrctrseg = 1018729
   and tpseguro = 4; 

end;

commit;

end;