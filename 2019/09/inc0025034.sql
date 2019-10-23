update crawlim lim
   set insitlim = 3 -- cancelado
      ,
       insitest = 3 -- analise finalizada
      ,
       dtrejeit = trunc(sysdate),
       hrrejeit = to_char(sysdate, 'SSSSS'),
       cdoperej = 1
 where lim.cdcooper = 2
   and lim.nrdconta = 234788
   and lim.nrctrlim = 503
   and lim.tpctrlim = 3;

commit;

Update crapprp x
   set x.dsobserv##1 = replace(x.dsobserv##1, '"', ' ')
 where x.cdcooper >= 1
   and x.dsobserv##1 like '%"%'
   and x.dtmvtolt > '01/08/2019';
   
commit;   
