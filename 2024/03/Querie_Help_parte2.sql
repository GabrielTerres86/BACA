select rda.cdcooper, rda.nrdconta, rda.nraplica, rda.insaqtot, rda.vlsdrdca
        ,rda.vlsltxmx
        ,rda.vlsltxmm, rda.*
  from craprda rda, crapcop cop
where rda.cdcooper = cop.cdcooper
   and round(vlsltxmx,2) <= 0
   and insaqtot = 0
   and tpaplica in (7,8)
   and cop.FLGATIVO = 1;  
