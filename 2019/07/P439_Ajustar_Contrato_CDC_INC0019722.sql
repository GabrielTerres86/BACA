  UPDATE crawepr
     SET insitapr = 1,
         dtenvest = SYSDATE,
         hrenvest = TO_CHAR(SYSDATE,'SSSSS'),
         cdopeste = '1'
   WHERE cdcooper = 11
     AND nrdconta = 392278
     AND nrctremp = 57360;

  UPDATE crawepr
     SET insitapr = 1,
         dtenvest = SYSDATE,
         hrenvest = TO_CHAR(SYSDATE,'SSSSS'),
         cdopeste = '1'
   WHERE cdcooper = 11
     AND nrdconta = 431303
     AND nrctremp = 57424;   
   
COMMIT;