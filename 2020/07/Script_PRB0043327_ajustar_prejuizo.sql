-- PRB0043327 

UPDATE crapbdt bdt
   SET bdt.inprejuz = 0
 WHERE bdt.nrborder = 547576
   AND bdt.cdcooper = 1
   AND bdt.nrdconta = 6766404;
   
COMMIT;   