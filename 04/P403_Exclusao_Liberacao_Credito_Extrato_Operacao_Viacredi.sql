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

  COMMIT;
END;
