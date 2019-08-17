update crawcrd d
   set d.flgprcrd = 1
 where d.flgprcrd = 0
   and d.insitcrd = 4
   and d.nrcrcard > 0
   and d.cdadmcrd between 10 and 80
   and d.flgdebcc = 1
   and d.dtpropos >= '01/06/2018'
   and d.cdadmcrd not in(16, 17)
   and d.dtcancel is null
   and not exists(select 1 from crawcrd a 
                      where a.cdcooper = d.cdcooper 
                        and a.nrdconta = d.nrdconta
                        and a.nrcpftit <> d.nrcpftit                        
                        and a.nrcrcard > 0)
   and  exists(select 1 from crawcrd b 
                      where b.cdcooper = d.cdcooper 
                        and b.nrdconta = d.nrdconta
                        and b.nrcpftit = d.nrcpftit
                        and b.nrcctitg = 0
                        and b.nrcrcard = 0
                        and b.flgprcrd = 1)
   AND NOT EXISTS (SELECT 1 
                     FROM crawcrd k                 
                    WHERE k.cdcooper = d.cdcooper
                      and k.nrdconta = d.nrdconta                     
                      and k.flgprcrd = 1
                      and k.insitcrd = 4);
                      
commit;                      
