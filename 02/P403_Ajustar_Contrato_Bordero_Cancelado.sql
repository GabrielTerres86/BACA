UPDATE crapbdt bdt
   SET bdt.nrctrlim = 8555
 WHERE bdt.cdcooper = 1
   AND bdt.nrdconta = 8973709
   AND bdt.nrborder = 550499
   AND bdt.nrctrlim = 7073;

COMMIT;