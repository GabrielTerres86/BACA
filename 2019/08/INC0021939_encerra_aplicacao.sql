UPDATE craprda r
   SET r.insaqtot = 1
     , r.dtsaqtot = TRUNC(SYSDATE)
 WHERE r.cdcooper = 1
   AND r.nrdconta = 9868178
   AND r.nraplica = 6;

COMMIT;
