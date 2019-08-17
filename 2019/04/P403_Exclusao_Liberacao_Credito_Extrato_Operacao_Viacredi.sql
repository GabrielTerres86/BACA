BEGIN
  DELETE tbdsct_lancamento_bordero lcb
   WHERE lcb.cdcooper = 1
     AND lcb.nrdconta = 7254920
     AND lcb.nrborder = 559889
     AND lcb.dtmvtolt = to_date('20/03/2019','DD/MM/RRRR') 
     AND lcb.cdhistor = 2665
     AND lcb.progress_recid IN (294482,294486);

  DELETE tbdsct_lancamento_bordero lcb
   WHERE lcb.cdcooper = 1
     AND lcb.nrdconta = 7254920
     AND lcb.nrborder = 559889
     AND lcb.dtmvtolt = to_date('20/03/2019','DD/MM/RRRR') 
     AND lcb.cdhistor = 2666
     AND lcb.progress_recid IN (294487,294503);

  DELETE crapljt ljt
   WHERE cdcooper = 1
     AND nrdconta = 7254920
     AND nrborder = 559889
     AND nrdocmto = 1430
     AND cdbandoc = 85
     AND nrdctabb = 101110
     AND nrcnvcob = 101110
     AND dtrefere = to_date('31/03/2019','DD/MM/RRRR')
     AND progress_recid IN (11175359, 11175569);

  DELETE crapljt ljt
   WHERE cdcooper = 1
     AND nrdconta = 7254920
     AND nrborder = 559889
     AND nrdocmto = 1430
     AND cdbandoc = 85
     AND nrdctabb = 101110
     AND nrcnvcob = 101110
     AND dtrefere = to_date('30/04/2019','DD/MM/RRRR')
     AND progress_recid IN (11175360, 11175570);

  COMMIT;
END;
