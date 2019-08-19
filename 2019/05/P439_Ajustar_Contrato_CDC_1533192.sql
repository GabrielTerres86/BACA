  UPDATE crawepr
     SET insitapr = 1,
         dtenvest = SYSDATE,
         hrenvest = TO_CHAR(SYSDATE,'SSSSS'),
         cdopeste = '1'
   WHERE cdcooper = 1
     AND nrdconta = 7844670
     AND nrctremp = 1533192;
	 
   
COMMIT;
