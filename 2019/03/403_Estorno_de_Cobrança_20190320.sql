BEGIN
  
  -- ========== PRIMEIRO CASO =================
  
  -- 1) Atualiza o saldo da tdb
  UPDATE craptdb tdb
     SET tdb.vlsldtit = tdb.vltitulo 
   WHERE tdb.cdcooper = 1
     AND tdb.nrdconta = 9624163
     AND tdb.nrborder = 550109
     AND tdb.nrdocmto = 118
     AND tdb.nrcnvcob = 101002
     AND tdb.nrdctabb = 101002
     AND tdb.cdbandoc = 85;  

  -- 2) Remove o lançamento de pagamento do extrato   
    DELETE
      FROM tbdsct_lancamento_bordero lcb
     WHERE lcb.cdcooper = 1
       AND lcb.nrdconta = 9624163
       AND lcb.nrborder = 550109
       AND lcb.nrdocmto = 118
       AND lcb.cdbandoc = 85
       AND lcb.nrdctabb = 101002
       AND lcb.nrcnvcob = 101002
       AND lcb.cdhistor = 2673
       AND lcb.dtmvtolt = to_date('18/03/2019','DD/MM/RRRR');
    
  -- ========== SEGUNDO CASO ================= 

  -- 1) Atualiza o saldo da tdb
  UPDATE craptdb tdb
     SET tdb.vlsldtit = tdb.vltitulo 
   WHERE tdb.cdcooper = 16
     AND tdb.nrdconta = 235245
     AND tdb.nrborder = 69263
     AND tdb.nrdocmto = 479
     AND tdb.nrcnvcob = 115080
     AND tdb.nrdctabb = 115080
     AND tdb.cdbandoc = 85;  

  -- 2) Remove o lançamento de pagamento do extrato   
    DELETE
      FROM tbdsct_lancamento_bordero lcb
     WHERE lcb.cdcooper = 16
       AND lcb.nrdconta = 235245
       AND lcb.nrborder = 69263
       AND lcb.nrdocmto = 479
       AND lcb.nrcnvcob = 115080
       AND lcb.nrdctabb = 115080
       AND lcb.cdbandoc = 85
       AND lcb.cdhistor = 2673
       AND lcb.dtmvtolt = to_date('15/03/2019','DD/MM/RRRR');

  -- ========== TERCEIRO CASO ================= 

  -- 1) Atualiza o saldo da tdb
  UPDATE craptdb tdb
     SET tdb.vlsldtit = tdb.vltitulo 
   WHERE tdb.cdcooper = 16
     AND tdb.nrdconta = 235245
     AND tdb.nrborder = 69518
     AND tdb.nrdocmto = 515
     AND tdb.nrcnvcob = 115080
     AND tdb.nrdctabb = 115080
     AND tdb.cdbandoc = 85;  

  -- 2) Remove o lançamento de pagamento do extrato   
    DELETE
      FROM tbdsct_lancamento_bordero lcb
     WHERE lcb.cdcooper = 16
       AND lcb.nrdconta = 235245
       AND lcb.nrborder = 69518
       AND lcb.nrdocmto = 515
       AND lcb.nrcnvcob = 115080
       AND lcb.nrdctabb = 115080
       AND lcb.cdbandoc = 85
       AND lcb.cdhistor = 2673
       AND lcb.dtmvtolt = to_date('15/03/2019','DD/MM/RRRR');
        
END;
