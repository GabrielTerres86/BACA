BEGIN
  DELETE CECRED.crapcex 
   WHERE tpextrat = 4
     AND progress_recid IN (15770,16068,16071);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => 3
                                ,pr_compleme => ' Script: => INC0308364.sql'); 
END;
