begin
update crapcns a
   set a.dtcancel = TO_DATE('27/05/2021', 'dd/mm/yyyy'), a.cdsitcns = 'DES', a.flgativo = 0
 where a.cdcooper = 11
   and a.NRDGRUPO = 30454
   and a.NRCTACNS = 794070
   and a.NRCOTCNS = 350
   and a.NRCTRATO = 973519;
   commit;
end;