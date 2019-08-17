UPDATE crapbdt bdt
   SET bdt.insitbdt = 5,
       bdt.insitapr = 5,
       bdt.dtrejeit = to_date(SYSDATE, 'DD/MM/YYYY'),
       bdt.hrrejeit = to_char(SYSDATE, 'SSSSS')
 WHERE bdt.cdcooper = 1
   AND bdt.dtlibbdt IS NULL
   AND bdt.dtmvtolt <= to_date('15/01/2019', 'DD/MM/YYYY')
   AND bdt.insitbdt NOT IN (5);

UPDATE crapbdt bdt
   SET bdt.nrctrlim = 8052
 WHERE bdt.cdcooper = 1
   AND bdt.nrborder = 542938
   AND bdt.nrdconta = 6407544;

UPDATE crawlim lim
   SET lim.insitlim = 2
 WHERE lim.cdcooper = 1
   AND lim.nrdconta = 7113196
   AND lim.tpctrlim = 3
   AND lim.nrctrlim = 485;