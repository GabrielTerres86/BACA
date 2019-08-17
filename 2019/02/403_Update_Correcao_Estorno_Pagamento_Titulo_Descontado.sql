
  -- 1
  -- Titulo deve ficar pago, pago no mesmo dia do vencimento, sem cobrança de juros mora e iof
  -- Contrato cyber baixado em 18/02/2019
  UPDATE craptdb tdb
     SET insittit = 2
        ,dtdpagto = to_date('13/02/2019','DD/MM/RRRR') 
        ,vliofcpl = 0
        ,vlmtatit = 0
        ,vlmratit = 0
        ,vlpagiof = 0
        ,vlpagmta = 0
        ,vlpagmra = 0
   WHERE tdb.cdcooper = 1
     AND tdb.nrdconta = 3946126
     AND tdb.nrborder = 546436
     AND tdb.nrdocmto = 745
     AND tdb.cdbandoc = 85
     AND tdb.nrdctabb = 10110
     AND tdb.nrcnvcob = 10110;

  UPDATE crapbdt 
     SET insitbdt = 4
   WHERE cdcooper = 1
     AND nrborder = 546436;


  -- 2
  -- Titulo deve ficar liberado, foi pago no mesmo dia do vencimento mas depois foi estornado e não teve mais nenhum pagamento.
  -- Verificar se as rotinas noturnas vão cobrar o juros e mora do titulo por estar em aberto.
  -- Excluir o pagamento do extrato da operação
  -- Contrato sem baixa no cyber
  UPDATE craptdb tdb
     SET insittit = 4
        ,dtdpagto = NULL 
        ,vlsldtit = 330
        ,vliofcpl = 0
        ,vlmtatit = 0
        ,vlmratit = 0
        ,vlpagiof = 0
        ,vlpagmta = 0
        ,vlpagmra = 0
   WHERE tdb.cdcooper = 1
     AND tdb.nrdconta = 4059824
     AND tdb.nrborder = 545731
     AND tdb.nrdocmto = 667
     AND tdb.cdbandoc = 85
     AND tdb.nrdctabb = 101001
     AND tdb.nrcnvcob = 101001;
     
  DELETE tbdsct_lancamento_bordero lcb
   WHERE lcb.cdcooper = 1
     AND lcb.nrdconta = 4059824
     AND lcb.nrborder = 545731
     AND lcb.nrdocmto = 667
     AND lcb.cdbandoc = 85
     AND lcb.nrdctabb = 101001
     AND lcb.nrcnvcob = 101001
     AND lcb.cdhistor = 2673
     AND lcb.dtmvtolt = to_date('15/02/2019','DD/MM/RRRR') ;


  -- 3
  -- Titulo deve ficar pago, pago no mesmo dia do vencimento, sem cobrança de juros mora e iof
  -- Contrato sem registro no cyber
  UPDATE craptdb tdb
     SET insittit = 2
        ,dtdpagto = to_date('15/02/2019','DD/MM/RRRR') 
        ,vliofcpl = 0
        ,vlmtatit = 0
        ,vlmratit = 0
        ,vlpagiof = 0
        ,vlpagmta = 0
        ,vlpagmra = 0
   WHERE tdb.cdcooper = 14
     AND tdb.nrdconta = 7838
     AND tdb.nrborder = 36591
     AND tdb.nrdocmto = 1155
     AND tdb.cdbandoc = 85
     AND tdb.nrdctabb = 113002
     AND tdb.nrcnvcob = 113002;


  COMMIT;
