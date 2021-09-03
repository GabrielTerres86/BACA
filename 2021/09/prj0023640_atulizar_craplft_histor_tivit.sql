BEGIN
  UPDATE craplft lft 
     SET cdhistor = 3361 
   WHERE lft.progress_recid = 50409547;
    
  COMMIT;
EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK; 
END;
