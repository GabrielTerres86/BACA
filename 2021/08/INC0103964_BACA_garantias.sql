update crapprp p
   set nrgarope = 10
 where p.cdcooper = 9
   and p.tpctrato = 90
   and NVL(p.nrgarope,0) = 0
   and (p.cdcooper, p.nrdconta, p.nrctrato)
     in (select e.cdcooper
              , e.nrdconta
              , e.nrctremp
           from crapepr e
              , crapass a
          where e.cdcooper = a.cdcooper
            and e.nrdconta = a.nrdconta
            and e.inliquid = 0
            and a.cdcooper = 9
            and a.cdagenci = 28);

COMMIT;
