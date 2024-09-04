declare
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  
begin
  cecred.pc_crps796(pr_cdcooper => 1
                   ,pr_dsjobnam => 'JB_POUP_REL_1'
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic);
				   
  COMMIT;				   

end;