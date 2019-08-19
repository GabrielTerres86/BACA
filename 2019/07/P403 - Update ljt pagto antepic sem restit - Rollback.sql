BEGIN
  UPDATE crapljt ljt
     SET vldjuros = 1.47
        ,vlrestit = 0
   WHERE ljt.cdcooper = 1
     AND ljt.nrdconta = 3742547
     AND ljt.nrborder = 580209
     AND ljt.dtrefere = to_date('31/07/2019','DD/MM/RRRR') 
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 101002
     AND ljt.nrcnvcob = 101002
     AND ljt.nrdocmto = 174
     AND ljt.progress_recid = 11718867;

  UPDATE crapljt ljt
     SET vldjuros = 1.47
        ,vlrestit = 0
   WHERE ljt.cdcooper = 1
     AND ljt.nrdconta = 3742547
     AND ljt.nrborder = 580209
     AND ljt.dtrefere = to_date('31/08/2019','DD/MM/RRRR') 
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 101002
     AND ljt.nrcnvcob = 101002
     AND ljt.nrdocmto = 174
     AND ljt.progress_recid = 11718868;

  UPDATE crapljt ljt
     SET vldjuros = 0.57
        ,vlrestit = 0
   WHERE ljt.cdcooper = 1
     AND ljt.nrdconta = 3742547
     AND ljt.nrborder = 580209
     AND ljt.dtrefere = to_date('30/09/2019','DD/MM/RRRR') 
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 101002
     AND ljt.nrcnvcob = 101002
     AND ljt.nrdocmto = 174
     AND ljt.progress_recid = 11718869;

  UPDATE crapljt ljt
     SET vldjuros = 0.57
        ,vlrestit = 0
   WHERE ljt.cdcooper = 1
     AND ljt.nrdconta = 7695624
     AND ljt.nrborder = 564878
     AND ljt.dtrefere = to_date('31/05/2019','DD/MM/RRRR') 
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 10120
     AND ljt.nrcnvcob = 10120
     AND ljt.nrdocmto = 1308
     AND ljt.progress_recid = 11305246;

  UPDATE crapljt ljt
     SET vldjuros = 11.19
        ,vlrestit = 0
   WHERE ljt.cdcooper = 2
     AND ljt.nrdconta = 418455
     AND ljt.nrborder = 48169
     AND ljt.dtrefere = to_date('31/03/2019','DD/MM/RRRR') 
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 102030
     AND ljt.nrcnvcob = 102030
     AND ljt.nrdocmto = 235
     AND ljt.progress_recid = 11052334;

  UPDATE crapljt ljt
     SET vldjuros = 7.58
        ,vlrestit = 0
   WHERE ljt.cdcooper = 2
     AND ljt.nrdconta = 418455
     AND ljt.nrborder = 48169
     AND ljt.dtrefere = to_date('30/04/2019','DD/MM/RRRR') 
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 102030
     AND ljt.nrcnvcob = 102030
     AND ljt.nrdocmto = 235
     AND ljt.progress_recid = 11052335;

  UPDATE crapljt ljt
     SET vldjuros = 0.39
        ,vlrestit = 0
   WHERE ljt.cdcooper = 7
     AND ljt.nrdconta = 237914
     AND ljt.nrborder = 29868
     AND ljt.dtrefere = to_date('30/06/2019','DD/MM/RRRR') 
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 10610
     AND ljt.nrcnvcob = 10610
     AND ljt.nrdocmto = 2171
     AND ljt.progress_recid = 11594572;

  UPDATE crapljt ljt
     SET vldjuros = 9.75
        ,vlrestit = 0
   WHERE ljt.cdcooper = 16
     AND ljt.nrdconta = 3963160
     AND ljt.nrborder = 70240
     AND ljt.dtrefere = to_date('30/06/2019','DD/MM/RRRR') 
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 115050
     AND ljt.nrcnvcob = 115050
     AND ljt.nrdocmto = 345
     AND ljt.progress_recid = 11451416;

  UPDATE crapljt ljt
     SET vldjuros = 3.25
        ,vlrestit = 0
   WHERE ljt.cdcooper = 16
     AND ljt.nrdconta = 3963160
     AND ljt.nrborder = 70240
     AND ljt.dtrefere = to_date('31/07/2019','DD/MM/RRRR') 
     AND ljt.cdbandoc = 85
     AND ljt.nrdctabb = 115050
     AND ljt.nrcnvcob = 115050
     AND ljt.nrdocmto = 345
     AND ljt.progress_recid = 11451417;

  COMMIT;
END;
