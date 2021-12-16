BEGIN
  
  UPDATE craplgp lgp
     SET lgp.cdidenti = 11568545800061,
         lgp.cdidenti2 = 11568545800061
   WHERE lgp.progress_recid = 57845566;
 
  COMMIT;
END;
