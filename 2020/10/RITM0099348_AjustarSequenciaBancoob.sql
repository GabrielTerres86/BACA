-- ** Viacredi
-- Oi TV
update crapcon c
   set c.nrseqint = 3
 where c.cdempcon = 369
   and c.cdsegmto = 4
   and c.cdcooper = 1
/
-- Nextel
update crapcon c
   set c.nrseqint = 5
 where c.cdempcon = 89
   and c.cdsegmto = 4
   and c.cdcooper = 1
/
-- Vivo Telefônica
update crapcon c
   set c.nrseqint = 21
 where c.cdempcon = 82
   and c.cdsegmto = 4
   and c.cdcooper = 1
/
-- ** Acredicoop
-- Nextel
update crapcon c
   set c.nrseqint = 6
 where c.cdempcon = 89
   and c.cdsegmto = 4
   and c.cdcooper = 2
/
-- ** Transpocred
-- Copel PR
update crapcon c
   set c.nrseqint = 2
 where c.cdempcon = 111
   and c.cdsegmto = 3
   and c.cdcooper = 9
/
--
commit
/
