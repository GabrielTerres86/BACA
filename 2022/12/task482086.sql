BEGIN

  UPDATE craprda 
     SET insaqtot = 1,
         vlsdrdca = 0
   WHERE cdcooper = 1 
     AND nrdconta = 90316010
     AND nraplica = 1;
 
 COMMIT;

END;    