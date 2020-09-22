update crapcon c 
   set c.cdhistor = 2515
 where c.cdempcon in (64,153,328,385)
   and c.cdsegmto = 5
   and c.cdhistor = 1154;
commit;
