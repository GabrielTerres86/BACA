UPDATE craprda r
   SET r.insaqtot = 0
     , r.dtsaqtot = NULL
 WHERE r.cdcooper = 1
   AND r.nrdconta = 9868178
   AND r.nraplica = 6;

COMMIT;
