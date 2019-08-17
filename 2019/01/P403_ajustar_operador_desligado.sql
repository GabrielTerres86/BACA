UPDATE crapbdt bdt
   SET bdt.cdoperad = 'f0013308'
 WHERE bdt.cdcooper = 1
   AND bdt.nrdconta = 4058240
   AND bdt.nrborder = 545075
   AND bdt.cdoperad = 'f0014306';

COMMIT;