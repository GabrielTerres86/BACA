UPDATE crapbdt bdt
   SET bdt.insitapr = 4
      ,bdt.insitbdt = 3
 WHERE bdt.cdcooper = 13
   AND bdt.nrdconta = 5070
   AND bdt.nrborder = 47447;
   
COMMIT;   