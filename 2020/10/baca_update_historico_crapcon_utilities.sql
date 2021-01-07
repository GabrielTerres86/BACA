update crapcon c 
   set c.cdhistor = 3361
 where c.cdhistor = 1154
   and c.tparrecd = 1 
   and not (c.cdempcon in (64,153,328,385) and c.cdsegmto = 5);   
commit;
