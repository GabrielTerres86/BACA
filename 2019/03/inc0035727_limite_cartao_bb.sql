update crapcrd p
   set p.cdlimcrd = 66 -- 60.000,00
      ,p.dtaltlim = trunc(sysdate)
 where p.cdcooper = 1
   and p.nrdconta = 2202107
   and p.nrctrcrd = 93742;
   
update crawcrd d
   set d.cdlimcrd = 66 -- 60.000,00
      ,d.cdoperad = '1'
 where d.cdcooper = 1
   and d.nrdconta = 2202107
   and d.nrctrcrd = 93742;   

   commit;
