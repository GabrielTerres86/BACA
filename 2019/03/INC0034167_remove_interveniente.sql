--SELECT bpr.nrcpfbem, bpr.* FROM crapbpr bpr WHERE bpr.cdcooper = 14 AND bpr.nrdconta = 83739;
UPDATE crapbpr bpr
   SET bpr.nrcpfbem = NULL
 WHERE bpr.cdcooper = 14 
   AND bpr.nrdconta = 83739
   AND bpr.nrctrpro = 8831;
   
COMMIT;
