UPDATE crapbdt bdt
   SET bdt.dtprejuz = to_date('03/08/2020', 'DD/MM/RRRR')
 WHERE bdt.cdcooper = 1
   AND bdt.nrdconta = 8636443
   AND bdt.nrborder = 550609;

COMMIT;