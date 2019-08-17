UPDATE crapbdt bdt
   SET bdt.nrctrlim = 8544
 WHERE bdt.cdcooper = 1
   AND bdt.nrdconta = 10179283
   AND bdt.nrborder = 551203
   AND bdt.nrctrlim = 7938;

UPDATE crapbdt bdt
   SET bdt.nrctrlim = 8545
 WHERE bdt.cdcooper = 1
   AND bdt.nrdconta = 7414200
   AND bdt.nrborder = 551474
   AND bdt.nrctrlim = 3295;

COMMIT;