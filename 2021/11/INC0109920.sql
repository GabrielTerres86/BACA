BEGIN
  UPDATE crappep
     SET vlpagpar = 320.93,
         inliquid = 1,
         vlsdvpar = 0,
         vlsdvatu = 0
   WHERE cdcooper = 13
     AND nrdconta = 172448
     AND nrctremp = 106536
     AND inliquid = 0;
     
  UPDATE crappep
     SET vlpagpar = 16.77,
         inliquid = 1,
         vlsdvpar = 0,
         vlsdvatu = 0
   WHERE cdcooper = 13
     AND nrdconta = 172448
     AND nrctremp = 106540
     AND inliquid = 0;

  COMMIT;
 
END;