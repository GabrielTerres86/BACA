begin
 update craplap lap
   set lap.txaplmes = 111
 where progress_recid in (202897976, 201997623, 202921134,
                          192800509, 192608253, 192738047);
                         
 update craprda rda
    set rda.vlsltxmm = rda.vlsltxmx
  where rda.cdcooper = 2
    and rda.nrdconta = 616036
    and rda.nraplica = 26;
    
 update craprda rda
    set rda.vlsltxmm = rda.vlsltxmx
  where rda.cdcooper = 2
    and rda.nrdconta = 166480
    and rda.nraplica = 90;
    
 update craprda rda
    set rda.vlsltxmm = rda.vlsltxmx
  where rda.cdcooper = 2
    and rda.nrdconta = 636797
    and rda.nraplica = 86;
    
 update craprda rda
    set rda.vlsltxmm = rda.vlsltxmx
  where rda.cdcooper = 2
    and rda.nrdconta = 803367
    and rda.nraplica = 29;
    
 update craprda rda
    set rda.vlsltxmm = rda.vlsltxmx
  where rda.cdcooper = 2
    and rda.nrdconta = 199770
    and rda.nraplica = 66;
    
 update craprda rda
    set rda.vlsltxmm = rda.vlsltxmx
  where rda.cdcooper = 2
    and rda.nrdconta = 803367
    and rda.nraplica = 31;
    
 commit;
end;
