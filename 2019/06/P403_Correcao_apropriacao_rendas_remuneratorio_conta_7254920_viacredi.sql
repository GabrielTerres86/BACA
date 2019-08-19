BEGIN
  UPDATE tbdsct_lancamento_bordero lcb
     SET vllanmto = 57.98
   WHERE lcb.cdcooper = 1
     AND lcb.nrdconta = 7254920
     AND lcb.nrborder = 559889
     AND lcb.dtmvtolt = to_date('29/03/2019','DD/MM/RRRR') 
     AND lcb.cdhistor = 2667
     AND lcb.progress_recid = 358455;
  COMMIT;
END;
