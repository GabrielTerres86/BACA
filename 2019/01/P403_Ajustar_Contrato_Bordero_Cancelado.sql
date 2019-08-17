UPDATE crapbdt bdt
   SET bdt.nrctrlim = 8271
 WHERE bdt.cdcooper = 1
   AND bdt.nrdconta = 9691472
   AND bdt.nrborder = 547535
   AND bdt.nrctrlim = 8249;

UPDATE crapbdt bdt
   SET bdt.nrctrlim = 349
 WHERE bdt.cdcooper = 11
   AND bdt.nrdconta = 400777
   AND bdt.nrborder = 30016
   AND bdt.nrctrlim = 180;

COMMIT;