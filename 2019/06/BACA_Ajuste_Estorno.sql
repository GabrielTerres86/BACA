BEGIN
  
  UPDATE craptdb set vlsldtit = vltitulo where cdcooper = 6 and nrdconta = 507890 and nrborder = 12117 and nrdocmto = 481;
  delete from tbdsct_lancamento_bordero where cdcooper = 6 and nrdconta = 507890 and nrborder = 12117 and nrdocmto = 481;
  COMMIT;
END;
/*
/

select * from craptdb where cdcooper = 6 and nrdconta = 507890 and nrdocmto = 481;
select * from tbdsct_lancamento_bordero where cdcooper = 6 and nrdconta = 507890 and nrdocmto = 481;
select * from crapljt where cdcooper = 6 and nrdconta = 507890 and nrdocmto = 481;

BEGIN
  ROLLBACK;
END;
*/
