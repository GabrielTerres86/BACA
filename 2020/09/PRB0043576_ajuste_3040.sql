UPDATE craptdb tdb
   SET tdb.insittit = 2 -- 4
 WHERE tdb.cdcooper = 1
   AND tdb.nrdconta = 7094612
   AND tdb.nrborder = 568523
   AND tdb.nrdocmto = 1253
   AND tdb.vlsdprej = 0;

UPDATE craptdb tdb
   SET tdb.insittit = 2 -- 4
 WHERE tdb.cdcooper = 1
   AND tdb.nrdconta = 8636443
   AND tdb.nrborder = 550609
   AND tdb.nrdocmto IN (852, 854)
   AND tdb.vlsdprej = 0;

UPDATE craptdb tdb
   SET tdb.insittit = 2 -- 4
 WHERE tdb.cdcooper = 1
   AND tdb.nrdconta = 9419578
   AND tdb.nrborder = 547951
   AND tdb.nrdocmto = 214
   AND tdb.vlsdprej = 0;

-- Bordero Rejeitado
UPDATE craptdb tdb
   SET tdb.dtlibbdt = NULL -- 09/10/2019
      ,tdb.vlsldtit = 0 -- 830,02
 WHERE tdb.cdcooper = 1
   AND tdb.nrdconta = 10345000
   AND tdb.nrborder = 629444
   AND tdb.nrdocmto = 307
   AND tdb.vlsdprej = 0;

UPDATE crapbdt bdt
   SET bdt.dtlibbdt = NULL -- 09/10/2019
 WHERE bdt.cdcooper = 1
   AND bdt.nrdconta = 10345000
   AND bdt.nrborder = 629444;
   
   
COMMIT;