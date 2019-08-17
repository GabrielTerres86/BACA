  UPDATE crawepr
     SET insitapr = 1,
         dtenvest = SYSDATE,
         hrenvest = TO_CHAR(SYSDATE,'SSSSS'),
         cdopeste = '1'
   WHERE cdcooper = 11
     AND nrdconta = 533084
     AND nrctremp = 57282;
	 
   
COMMIT;