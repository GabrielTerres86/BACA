BEGIN
  UPDATE cecred.crapljt ljt
     SET vldjuros = 0
        ,vlrestit = 260.15
   WHERE ljt.cdcooper = 2
     AND ljt.nrdconta = 780383
     AND ljt.nrborder = 45585
     AND ljt.dtrefere = to_date('28/02/2019','DD/MM/RRRR')
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 102030
     AND ljt.nrcnvcob = 102030
     AND ljt.nrdocmto = 328;

  UPDATE cecred.crapljt ljt
     SET vldjuros = 0
        ,vlrestit = 146.05
   WHERE ljt.cdcooper = 2
     AND ljt.nrdconta = 780383
     AND ljt.nrborder = 46267
     AND ljt.dtrefere = to_date('28/02/2019','DD/MM/RRRR')
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 102030
     AND ljt.nrcnvcob = 102030
     AND ljt.nrdocmto = 332;

  UPDATE cecred.crapljt ljt
     SET vldjuros = 0
        ,vlrestit = 19.75
   WHERE ljt.cdcooper = 2
     AND ljt.nrdconta = 700479
     AND ljt.nrborder = 45241
     AND ljt.dtrefere = to_date('31/03/2019','DD/MM/RRRR')
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 10210
     AND ljt.nrcnvcob = 10210
     AND ljt.nrdocmto = 88;

  UPDATE cecred.crapljt ljt
     SET vldjuros = 793.41
        ,vlrestit = 0
   WHERE ljt.cdcooper = 2
     AND ljt.nrdconta = 780383
     AND ljt.nrborder = 45585
     AND ljt.dtrefere = to_date('31/01/2019','DD/MM/RRRR')
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 102030
     AND ljt.nrcnvcob = 102030
     AND ljt.nrdocmto = 328;

  UPDATE cecred.crapljt ljt
     SET vldjuros = 177.10
        ,vlrestit = 0
   WHERE ljt.cdcooper = 2
     AND ljt.nrdconta = 780383
     AND ljt.nrborder = 46267
     AND ljt.dtrefere = to_date('31/01/2019','DD/MM/RRRR')
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 102030
     AND ljt.nrcnvcob = 102030
     AND ljt.nrdocmto = 332;

  UPDATE cecred.crapljt ljt
     SET vldjuros = 36.260
        ,vlrestit = 0
   WHERE ljt.cdcooper = 2
     AND ljt.nrdconta = 700479
     AND ljt.nrborder = 45241
     AND ljt.dtrefere = to_date('28/02/2019','DD/MM/RRRR')
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 10210
     AND ljt.nrcnvcob = 10210
     AND ljt.nrdocmto = 88;
  
  COMMIT;
END;
