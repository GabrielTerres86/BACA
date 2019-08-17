BEGIN
  UPDATE craptdb tdb
     SET insittit = 2
        ,dtdpagto = to_date('13/02/2019','DD/MM/RRRR') 
        ,vlmratit = 9.29
        ,vliofcpl = 0.38
        ,vlpagiof = 0.38
   WHERE tdb.cdcooper = 13
     AND tdb.nrdconta = 406600
     AND tdb.nrborder = 37817
     AND tdb.nrdocmto = 520
     AND tdb.cdbandoc = 85
     AND tdb.nrdctabb = 112002
     AND tdb.nrcnvcob = 112002;

  COMMIT;
END;