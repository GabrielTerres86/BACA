-- Cooperativa 7 Credcrea
-- Baca para corrigir apropriação de juros referente a Outubro de 2018 que estão
-- causando diferença de saldo anterior na consulta TITCTO
BEGIN
-- ITEM  CONTA BORDERÔ VALOR A CORRIGIR
--    1  25666   27592            -0,15
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 0.75
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 25666	
   AND lcb.nrborder = 27592
   AND lcb.nrdocmto = 1583
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('05/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3048;

--    2  37842   27594            -0,56
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 2.8
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 37842	
   AND lcb.nrborder = 27594
   AND lcb.nrdocmto = 635
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('05/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3127;


--    3  74160   27303            -0,28
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 1.42
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 74160	
   AND lcb.nrborder = 27303
   AND lcb.nrdocmto = 1239
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('05/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3093;


--    4  86223   27460            -0,65
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 0.65
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 86223	
   AND lcb.nrborder = 27460
   AND lcb.nrdocmto = 1926
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('01/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3064;

--    5  93963   27611            -1,08
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 5.39
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 93963	
   AND lcb.nrborder = 27611
   AND lcb.nrdocmto = 183
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('05/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3105;

--    6  98990   27374            -1,62
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 14.62
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 98990	
   AND lcb.nrborder = 27374
   AND lcb.nrdocmto = 301
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('09/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3552;

--    7 125970   27472            -1,63
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 8.18
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 125970	
   AND lcb.nrborder = 27472
   AND lcb.nrdocmto = 317
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('05/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3095;


--    8 144762   27299            -0,21
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 1.26
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 144762	
   AND lcb.nrborder = 27299
   AND lcb.nrdocmto = 239
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('06/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3310;


--    9 150037   27402            -0,63
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 0.39
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 150037	
   AND lcb.nrborder = 27402
   AND lcb.nrdocmto = 551
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('01/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3070;

UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 1.20
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 150037	
   AND lcb.nrborder = 27402
   AND lcb.nrdocmto = 549
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('05/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3117;


--   10 168955   27459            -0,22
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 1.09
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 168955	
   AND lcb.nrborder = 27459
   AND lcb.nrdocmto = 156
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('05/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3106;


--   11 234540   27435            -0,22
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 1.08
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 234540	
   AND lcb.nrborder = 27435
   AND lcb.nrdocmto = 586
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('05/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3132;


--   12 236012   27340            -1,31
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 6.54
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 236012	
   AND lcb.nrborder = 27340
   AND lcb.nrdocmto = 178
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('05/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3094;


--   13 236012   27371            -0,92
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 4.60
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 236012	
   AND lcb.nrborder = 27371
   AND lcb.nrdocmto = 182
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('05/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3112;


--   14 330361   27272            -0,33
UPDATE tbdsct_lancamento_bordero lcb
   SET lcb.vllanmto = 1.66
 WHERE lcb.cdcooper = 7
   AND lcb.nrdconta = 330361	
   AND lcb.nrborder = 27272
   AND lcb.nrdocmto = 1215
   AND lcb.cdhistor = 2668
   AND lcb.dtmvtolt = to_date('05/11/2018','DD/MM/RRRR')
   AND lcb.progress_recid = 3122;


COMMIT;
END;
