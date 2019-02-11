UPDATE crapbdt bdt
   SET bdt.nrctrlim = 230
 WHERE bdt.cdcooper = 5
   AND bdt.nrdconta = 121525
   AND bdt.nrborder = 13718
   AND bdt.nrctrlim = 64;

COMMIT;