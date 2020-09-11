-- Script exclusão bordero de cheque
DELETE FROM crapbdc bdc
 WHERE bdc.cdcooper = 1
   AND bdc.nrdconta = 8383316
   AND bdc.nrborder = 2016803
   AND NOT EXISTS (SELECT 1
          FROM crapcdb cdb
         WHERE cdb.cdcooper = bdc.cdcooper
           AND cdb.nrdconta = bdc.nrdconta
           AND cdb.nrborder = bdc.nrborder);

UPDATE crapdcc
   SET nrborder = 0
 WHERE cdcooper = 1
   AND nrdconta = 8383316
   AND nrborder = 2016803;

UPDATE crapcst
   SET nrborder = 0
 WHERE cdcooper = 1
   AND nrdconta = 8383316
   AND nrborder = 2016803;  

COMMIT;