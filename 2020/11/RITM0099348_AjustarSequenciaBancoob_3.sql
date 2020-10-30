-- Net
update crapcon c
   set c.nrseqint = decode(c.cdcooper,
                           2, 280,
                           5, 30,
                           6, 172,
                           9, 35,
                           12, 41,
                           13, 11)
 where c.cdempcon = 296
   and c.cdsegmto = 4
   and c.cdcooper in (2, 5, 6, 9, 12, 13)
/
commit
/
