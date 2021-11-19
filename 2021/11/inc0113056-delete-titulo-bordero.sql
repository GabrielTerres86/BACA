BEGIN

  DELETE craptdb tdb
   WHERE tdb.cdcooper = 5
     AND tdb.nrdconta = 273805
     AND tdb.nrborder = 26983
     AND tdb.nrdocmto = 358;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
