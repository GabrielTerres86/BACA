BEGIN
  
  UPDATE craplgp lgp
     SET lgp.cdidenti = 65316475396
   WHERE lgp.progress_recid = 3506488;
 
  COMMIT;
END;
