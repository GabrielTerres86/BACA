update crapcns a
   set a.dtcancel = '05/03/2021', a.cdsitcns = 'DES', a.flgativo = 0
 where a.cdcooper = 7
   and a.NRDGRUPO = 70032
   and a.NRCTACNS = 191830
   and a.NRCOTCNS = 190
   and a.NRCTRATO = 372264;
   commit;
