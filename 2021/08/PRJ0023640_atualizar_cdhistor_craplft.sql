BEGIN
  UPDATE craplft lft 
     SET cdhistor = 2515 
   WHERE lft.progress_recid = 50409511;
    
  COMMIT;
EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK; 
END;
