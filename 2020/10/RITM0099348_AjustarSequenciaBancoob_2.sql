-- ** Viacredi
-- Net
update crapcon c
   set c.nrseqint = 570
 where c.cdempcon = 296
   and c.cdsegmto = 4
   and c.cdcooper = 1
/
--
commit
/
