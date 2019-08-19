  UPDATE crawepr
     SET insitapr = 1,
         dtenvest = SYSDATE,
         hrenvest = TO_CHAR(SYSDATE,'SSSSS'),
         cdopeste = '1'
   WHERE cdcooper = 1
     AND nrdconta = 2010151
     AND nrctremp = 1521434;
	 
UPDATE craptdb t
   SET t.insitapr = 2
 WHERE t.cdcooper = 1
   AND t.nrdconta IN (2584620, 3948951)
   AND t.nrborder IN (571556, 572663)
   AND t.insitapr = 0
   AND t.dtlibbdt IS NULL;
   
COMMIT;