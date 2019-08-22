--select a.nrdconta, a.nrconven from crapceb a
update crapceb a 
   set  a.flgapihm = 1
        ,a.cdhomapi = 'SIS'
        ,a.dhhomapi = sysdate
where a.nrdconta in ( 9586083,
                    8199124,
                    9334530,
                    8199124,
                    10668225,
                    4033035,
                    9848010,
                    8173508,
                    10605940,
                    3714586)
  and a.cdcooper = 1
  and a.insitceb = 1
  and a.nrconven in (10111, 101004, 101071, 101003);

commit;
