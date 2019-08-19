
UPDATE crapbdt bdt
   SET bdt.nrctrlim = 258
 WHERE bdt.cdcooper = 16
   AND bdt.nrdconta = 74470
   AND bdt.nrborder = 68829;

COMMIT;