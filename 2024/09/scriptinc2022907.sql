DECLARE
  vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;
BEGIN
  UPDATE cecred.craprda
     SET vlslfmes = 0,
         insaqtot = 1,
         vlsdrdca = 0
   WHERE cdcooper = 1
     AND ((nrdconta = 2023180 and nraplica in (163391,148888))or
          (nrdconta = 2022907 and nraplica in (188092)));       
  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => SQLERRM,
                           pr_cdmensagem => 333,
                           pr_cdprograma => 'INC0344661',
                           pr_cdcooper   => 3,
                           pr_idprglog   => vr_idprglog); 
      ROLLBACK;  
END;      
