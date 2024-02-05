BEGIN
  UPDATE craplcm t 
     SET t.vllanmto = t.vllanmto - 6660.29
       , t.cdhistor = 4529
   WHERE ROWID = 'AABCorAAAAAJV1MAAG';
  
  COMMIT;
  
END;
