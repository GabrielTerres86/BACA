BEGIN
  UPDATE craptdb tdb
     SET insittit = 2
        ,dtdpagto = to_date('06/03/2019','DD/MM/RRRR') 
        ,vliofcpl = 0.23
   WHERE tdb.cdcooper = 9
     AND tdb.nrdconta = 209759
     AND tdb.nrborder = 59507
     AND tdb.nrdocmto = 8
     AND tdb.cdbandoc = 85
     AND tdb.nrdctabb = 108002
     AND tdb.nrcnvcob = 108002;

  COMMIT;
END;
