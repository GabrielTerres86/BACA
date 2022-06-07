BEGIN
  
  UPDATE cecred.craprda
     SET insaqtot = 1,
         vlsdrdca = 0
   WHERE cdcooper = 1
     AND nrdconta = 3015491
     AND nraplica = 2;  

  COMMIT;
END;
