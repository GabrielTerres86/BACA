BEGIN
  
DELETE craptfc tfc 
 WHERE tfc.cdcooper in (1, 10, 16) 
   AND tfc.nrdconta = 0
   AND tfc.progress_recid in (3156187, 3156188, 3156192, 3156193, 3156341);

  COMMIT;
  
END;