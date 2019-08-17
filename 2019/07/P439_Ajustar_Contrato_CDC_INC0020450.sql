  UPDATE crawepr
     SET insitapr = 1,
         dtenvest = SYSDATE,
         hrenvest = TO_CHAR(SYSDATE,'SSSSS'),
         cdopeste = '1'
   WHERE cdcooper = 1
     AND nrdconta = 7093853
     AND nrctremp = 1602788;
   
   
COMMIT;
