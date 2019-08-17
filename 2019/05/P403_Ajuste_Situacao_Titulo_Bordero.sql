UPDATE craptdb t
   SET t.insitapr = 2
 WHERE t.cdcooper = 1
   AND t.nrdconta = 3948951
   AND t.nrborder = 574062
   AND t.insitapr = 0
   AND t.dtlibbdt IS NULL;

UPDATE craptdb t
   SET t.insitapr = 2
 WHERE t.cdcooper = 1
   AND t.nrdconta = 2584620
   AND t.nrborder = 574509
   AND t.insitapr = 0
   AND t.dtlibbdt IS NULL;

UPDATE craptdb t
   SET t.insitapr = 2
 WHERE t.cdcooper = 9
   AND t.nrdconta = 930
   AND t.nrborder = 60880
   AND t.insitapr = 0
   AND t.dtlibbdt IS NULL;

COMMIT;