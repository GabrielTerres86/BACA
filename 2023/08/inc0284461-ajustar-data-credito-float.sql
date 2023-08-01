BEGIN

  UPDATE CECRED.crapret
     SET dtcredit = TO_DATE('01/08/2023', 'DD/MM/YYYY')
   WHERE 1 = 1
     AND cdocorre IN (6, 17, 76, 77)
     AND dtcredit = TO_DATE('31/07/2023', 'DD/MM/YYYY')
     AND (cdcooper, nrcnvcob, nrdconta, nrdocmto) IN
         ((1, 101004, 12831603, 10741)
         ,(1, 101004, 12831603, 10994)
         ,(1, 980101, 850004, 922901)
         ,(1, 980101, 850004, 979860)
         ,(1, 980101, 850004, 2365162)
         ,(1, 980101, 850004, 4263838)
         ,(1, 980101, 850004, 4447344)
         ,(1, 980101, 850004, 4450111)
         ,(1, 980101, 850004, 4638946)
         ,(7, 106002, 91693, 977)
         ,(9, 108004, 930, 2372183)
         ,(9, 108004, 930, 2377433)
         ,(10, 110004, 16288629, 2395));

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC0284461');
    ROLLBACK;
    RAISE;
END;
