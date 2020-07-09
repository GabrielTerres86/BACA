-- PRB0043327 

UPDATE crapbdt bdt
   SET bdt.inprejuz = 0
      ,bdt.dtliqprj = to_date('20/05/2020','DD/MM/RRRR')
 WHERE bdt.nrborder = 547576
   AND bdt.cdcooper = 1
   AND bdt.nrdconta = 6766404;
   
COMMIT;   
